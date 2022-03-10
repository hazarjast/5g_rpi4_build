#!/bin/sh

#
# *Script info*
# Activate intake and exhaust fans if modem cpu temp exceeds $LIMIT.
# Deactivate fans if modem cpu temp falls below $LIMIT.
#
# NOTE: A ModemManager udev rule is added at first run to unbind the primary AT port for our use.
# User is then prompted to reboot OpenWRT for the change to take effect.
# Be sure that $MMUBIND is populated with the correct MM USBIFNUM before running this script!
#
# *Assumptions*
# Specifically written for OpenWRT hosts with a modem managed by ModemManager.
# Intended to be used with a USB hub which supports Per Port Power Switching (PPPS).
# Modem should be in a 'usbnet' mode which provides an AT port:
# ex. RM502Q-AE in QMI mode
# This script should exist under '/scripts/'.
# Package 'pservice' should be installed and used to run this as a daemon.
# At first run this script will add this script to 'pservice' config.
#
# *Required Input*
# $HUB, $PRODID - Obtain w/ 'lsusb' and 'lsusb -v' ('idVendor:idProduct'; 'idVendor/idProduct/bcdDevice')
# For $PRODID, ignore leading zeros in idVendor/idProduct and separating decimal in bcdDevice
# ex. 'idVendor 0x05e3, idProduct 0x0608, bcdDevice 60.52' = "5e3/608/6052"
#
# $PORTS - Populate with hub port numbers of connected fans using appropriate uhubctl syntax:
# ex. '2-3' (ports two through three), '1,4 (ports one and four), etc.
#
# $ATDEVICE, $MMVID, $MMPID, $MMUBIND - Found in '/lib/udev/rules.d/77-mm-[vendor]-port-types.rules':
# ex. '...ttyUSB2...AT primary port...ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0800", ENV{.MM_USBIFNUM}=="02"...'
# (ATDEVICE="/dev/ttyUSB2", MMVID="2c7c", MMPID="0800", MMUBIND="02")
#
# $LIMIT - Temperature threshold in degrees celsius when fans should be activated.
#
# $INTERVAL - Time in seconds between polling modem temperature.
#
# *Dependencies*
# This script requires, 'uhubctl', 'modemmanager', 'socat', 'timeout', and 'pservice' packages to be installed.
#
# Copyright 2022 hazarjast (and aliases) - hazarjast at protonmail dot com
#

HUB="05e3:0608"
PRODID="5e3/608/6052"
PORTS="3-4"
ATDEVICE=/dev/ttyUSB2
MMVID="2c7c"
MMPID="0800"
MMUBIND="02"
LIMIT=55
INTERVAL=60
PIDFILE=/var/run/fan_control.pid
LOOPPID=/var/run/fan_control_loop.pid
INFO="/usr/bin/logger -t FAN_CONTROL"
ERROR="/usr/bin/logger -p err -t FAN_CONTROL"
HPDIR=/etc/hotplug.d/usb
FANON=/var/run/fan.on

# Preliminary logic to ensure this only runs one instance at a time
[ -f $PIDFILE ] && PFEXST="true" || PFEXST="false"
case "$PFEXST" in
  "true") PID=$(cat $PIDFILE)
         $(ps | awk '{print $1}' | grep -q $PID) && \
         $($ERROR "Already running. Exiting." && exit 1) || \
         $(echo $$ > $PIDFILE || $ERROR "Could not create PID file. Exiting." && exit 1)
  ;;
  "false") $(echo $$ > $PIDFILE) || $($ERROR "Could not create PID file. Exiting." && exit 1)
  ;;
esac

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
FANON=/var/run/fan.on
BINARY="/usr/sbin/uhubctl -n \$HUB -p \$PORTS -a off"
INFO="/usr/bin/logger -t hotplug"

if [ "\${PRODUCT}" = "\${PRODID}" ]; then
    if [ "\${ACTION}" = "add" ]; then
        \${BINARY} && rm -f \$FANON
        \$INFO "USB hub unexpectedly detached; powered off fan ports."
    fi
fi
EOF

  $INFO "Set hotplug rule for USB hub '$HUB'."
else
  continue
fi

# Unbind ModemManager from an AT port so we can use it
# Without this 'socat' commands can hang or return no value
# Also setup this script as a 'pservice' daemon if it's not already
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

  PSCONF=/etc/config/pservice
  if ! $(grep -q 'fancontrol' $PSCONF)
  then
    [ -f /etc/config/pservice ] && cp -p $PSCONF $PSCONF.bak
cat << EOF >> $PSCONF

config pservice
        option name 'fancontrol'
        option respawn_maxfail 0
        option command /bin/sh
        list args -c
        list args 'exec /scripts/fancontrol.sh'
EOF

    $INFO "Setup 'fancontrol' as a pservice daemon."
  else
    continue
  fi

  $INFO "Unbound ModemManager from USBIFNUM $MMUBIND on modem $MMVID:$MMPID."
  echo "ModemManager and/or pservice config changes were made. Please reboot OpenWRT to take effect."
  $INFO "ModemManager and/or pservice config changes were made. Prompted user to reboot."
  exit 0
else
  continue
fi

# Function to cleanup processes and pidfiles when script is terminated
terminate() {
  LOOP=$(cat $LOOPPID)
  rm -f $LOOPPID $PIDFILE
  $INFO "Fan controller killed!"
  kill $LOOP
  exit 0
}

trap terminate SIGHUP SIGINT SIGQUIT SIGTERM

$INFO "Fan controller initialized!"

# Main fan control logic
# Query current temperature of modem cpu
# Trigger fan behavior based on current temp
while true
do
  ATE0=$(timeout -k 5 5 echo -e ATE0 | socat -W - $ATDEVICE,crnl) # Deactivate AT echo if it is enabled
  [ $ATE0 = "OK" ] && TEMP=$(timeout -k 5 5 echo -e AT+QTEMP | socat -W - $ATDEVICE,crnl | grep cpu0-a7-usr | egrep -wo "[0-9][0-9]")
  if $(echo $TEMP | egrep -qwo "[0-9][0-9]")
  then
    [ -f $FANON ] && STATE="on" || STATE="off" # Check current fan state
    if [ $TEMP -ge $LIMIT ]
    then
      [ $STATE = "off" ] && \
      $(uhubctl -n $HUB -p $PORTS -a on >/dev/null 2>/dev/null && touch $FANON) && \
      $INFO "Modem cpu reached $TEMP which is greater than or equal to the limit of $LIMIT. Fans activated."
    elif [ $TEMP -lt $LIMIT ]
    then
      [ $STATE = "on" ] && \
      $(uhubctl -n $HUB -p $PORTS -a off >/dev/null 2>/dev/null && rm $FANON) && \
      $INFO "Modem cpu cooled to $TEMP which is less than the limit of $LIMIT. Fans deactivated."
    fi
  else
    $INFO "Could not obtain a valid temperature reading. Will retry after $INTERVAL seconds."
  fi
  sleep $INTERVAL
done & echo $! > $LOOPPID

wait
