#!/bin/sh

#
# *Script info*
# Activate intake and exhaust fans if modem cpu temp exceeds $LIMIT (in degress celsius).
# Deactivate fans if modem cpu temp falls below $LIMIT.
#
# NOTE: A ModemManager udev rule is added at first run to unbind a secondary AT port for our use.
# User is then prompted to reboot OpenWRT for the change to take effect.
# Be sure that $MMUBIND is populated with the correct MM USBIFNUM before running this script!
#
# *Assumptions*
# Intended to be used with a USB hub which supports Per Port Power Switching (PPPS).
# Specifically written for hosts with a modem managed by ModemManager.
# Modem should be in a 'usbnet' mode which provides a secondary AT port:
# ex. RM502Q-AE in QMI mode
#
# *Required Input*
# $HUB, $PRODID - Obtain w/ 'lsusb' and 'lsusb -v' ('idVendor:idProduct'; 'idVendor/idProduct/bcdDevice')
# For $PRODID, ignore leading zeros in idVendor/idProduct and separating decimal in bcdDevice
# ex. 'idVendor 0x05e3, idProduct 0x0608, bcdDevice 60.52' = "5e3/608/6052"
#
# $PORTS - Populate with hub port numbers of connected fans using appropriate uhubctl syntax:
# ex. '2-3' (ports two through three), '1,4 (ports one and four), etc.
#
# $MMVID, $MMPID, $MMUBIND - Found in '/lib/udev/rules.d/77-mm-[vendor]-port-types.rules':
# ex. '...ttyUSB3...AT secondary port...ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0800", ENV{.MM_USBIFNUM}=="03"...'
# (MMVID="2c7c", MMPID="0800", MMUBIND="03")
#
# *Dependencies*
# This script requires, 'lsusb', 'uhubctl', 'modemmanager', 'socat', and 'timeout' packages to be installed.
#

PIDFILE=/var/run/fan_control.pid
FANON=/var/run/fan.on
STATE="off"
LOG=/var/log/fan_control.log
LIMIT=55
HUB="05e3:0608"
PRODID="5e3/608/6052"
PORTS="3-4"
ATDEVICE=/dev/ttyUSB3
MMVID="2c7c"
MMPID="0800"
MMUBIND="03"
HPDIR=/etc/hotplug.d/usb

# Preliminary logic to ensure this only runs one instance at a time
if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  if [ $(ps | awk '{print $1}' | grep $PID) ]
  then
    echo "$(date) - Process already running. Exiting." >> $LOG
    exit 1
  else
    continue
  fi
else
  echo $$ > $PIDFILE
  if [ ! -f "$PIDFILE" ]
  then
    echo "$(date) - Could not create PID file. Exiting." >> $LOG
    exit 1
  else
    continue
  fi
fi

# Add a hotplug rule to keep fans from starting themselves
# uhubctl power off sometimes causes hub to drop/reconect from kernel
# This hotplug rule ensures fans are stopped in this scenario
if [ ! -f "/etc/hotplug.d/usb/20-uhubctl-usb" ]
then
cat << EOF >> /etc/hotplug.d/usb/20-uhubctl-usb
#!/bin/sh

# If D-Link USB hub disconnects and comes back, stop the connected fans

PRODID="$PRODID"
HUB="$HUB"
PORTS="$PORTS"
BINARY="/usr/sbin/uhubctl -n \$HUB -p \$PORTS -a off"

if [ "\${PRODUCT}" = "\${PRODID}" ]; then
    if [ "\${ACTION}" = "add" ]; then
        \${BINARY}
    fi
fi
EOF

  echo "$(date) - Set hotplug rule for USB hub '$HUB'." >> $LOG
else
  continue
fi

# Unbind ModemManager from an AT port so we can use it
# Without this 'socat' commands can hang or return no value
if [ ! -f "/lib/udev/rules.d/77-mm-test.rules" ]
then
cat << EOF >> /lib/udev/rules.d/77-mm-test.rules
ACTION!="add|change|move|bind", GOTO="mm_test_end"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="$MMVID", GOTO="mm_test_rules"
GOTO="mm_test_end"

LABEL="mm_test_rules"
SUBSYSTEMS=="usb", ATTRS{bInterfaceNumber}=="?*", ENV{.MM_USBIFNUM}="\$attr{bInterfaceNumber}"
ATTRS{idVendor}=="$MMVID", ATTRS{idProduct}=="$MMPID", ENV{.MM_USBIFNUM}=="$MMUBIND", ENV{ID_MM_PORT_IGNORE}="1"
LABEL="mm_test_end"
EOF

  echo "$(date) - Unbound ModemManager from USBIFNUM $MMUBIND on modem $MMVID:$MMPID." >> $LOG
  echo "ModemManager config changes were made. Please reboot OpenWRT before executing this script again."
  echo "$(date) - ModemManager config changes were made. Prompted user to reboot." >> $LOG
else
  continue
fi

# Check if fan is already on
[ -f $FANON ] && STATE="power"

# Query current temperature of modem cpu
TEMP=$(timeout -k 5 5 echo -e AT+QTEMP | socat -W - $ATDEVICE,crnl | grep cpu0-a7-usr | egrep -o "[0-9][0-9]")

# Check that returned modem cpu temp is valid, if not, query it again up 5x until it gets a valid result
# If no valid result returned, exit with error
TRIES=0
while [ ! $(echo $TEMP | egrep -o "[0-9][0-9]") ]
do
  TEMP=$(timeout -k 5 5 echo -e AT+QTEMP | socat -W - $ATDEVICE,crnl | grep cpu0-a7-usr | egrep -o "[0-9][0-9]")
  sleep 2
  TRIES=$(expr $TRIES + 1)
  if [ $TRIES -lt 5 ]
  then
    continue
  else
    echo "$(date) - Could not obtain a valid cpu temperature from the modem; maybe it is busy. Exiting." >> $LOG
    exit 1
  fi
done

# Main fan control logic
if [ $STATE = "off" ] && [ $TEMP -ge $LIMIT ]
then
  uhubctl -n $HUB -p $PORTS -a on >/dev/null 2>/dev/null
  touch $FANON
  echo "$(date) - Modem cpu reached $TEMP which is greater than or equal to the limit of $LIMIT. Fans activated." >> $LOG
elif [ $STATE = "power" ] && [ $TEMP -lt $LIMIT ]
then
  uhubctl -n $HUB -p $PORTS -a off >/dev/null 2>/dev/null
  rm $FANON
  echo "$(date) - Modem cpu cooled to $TEMP which is less than the limit of $LIMIT. Fans deactivated." >> $LOG
else
  uhubctl -n $HUB -p $PORTS -a off >/dev/null 2>/dev/null
fi

# Houskeeping for log and pidfile
if [ -f $LOG ]
then
  echo "$(tail -1000 $LOG)" > $LOG
fi
rm $PIDFILE

exit 0
