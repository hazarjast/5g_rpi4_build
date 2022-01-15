#!/bin/sh

#
# Script info:
# Activate intake and exhaust fans if modem cpu temp exceeds $LIMIT (in degress celsius)
# Deactivate fans if modem cpu temp falls below $LIMIT
#
# Dependencies:
# This script requires 'socat' and 'timeout' packages to be installed
#

PIDFILE=/var/run/fan_control.pid
LOG=/var/log/fan_control.log
LIMIT=55
HUB="1-1.3"
ATDEVICE=/dev/ttyUSB2
UHUBCTL=/usr/sbin/uhubctl
TTRIES=0
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
  if [ ! -f "$PIDFILE" ] && [ ! $(grep -s $$ $PIDFILE) ]
  then
    echo "$(date) - Could not create PID file. Exiting." >> $LOG
    exit 1
  else
    continue
  fi
fi

# Check for ModemManager hotplug actions and move them if present
# This mitigates inconsistent uhubctl behavior when checking fan state
HPFILE=$(ls $HPDIR | grep modemmanager)
if [ ! -z $HPFILE ] && [ -f "$HPDIR/$HPFILE" ]
then
  mkdir $HPDIR/bak 2>/dev/null
  if [ ! -d "$HPDIR/bak" ]
  then
    echo "$(date) - Could not backup ModemManager Hotplug config backup directory. Exiting." >> $LOG
    exit 1
  else
    mv $HPDIR/$HPFILE $HPDIR/bak/ 2>/dev/null
    if [ ! -f "$HPDIR/bak/$HPFILE" ]
    then
      echo "$(date) - Could not backup ModemManager Hotplug config file. Exiting." >> $LOG
      exit 1
    else
      echo "$(date) - Moved ModemManager Hotplug config '$HPDIR/$HPFILE' to '$HPDIR/bak/$HPFILE'; this avoids uhubctl conflicts." >> $LOG
    fi
  fi
else
  continue
fi

# Query current fan state from uhubctl
STATE=$($UHUBCTL -l $HUB | grep -o -m 1 'off\|power')

# Query current temperature of modem cpu
TEMP=$(timeout 5 echo -e AT+QTEMP | socat -W - $ATDEVICE,crnl | grep cpu0-a7-usr | egrep -o "[0-9][0-9]")

# Check that returned fan state is valid before proceeding; error exit if not.
if [ $(echo $STATE | grep -o -m 1 'off\|power') ]
then
  continue
else
  echo "$(date) -  Could not obtain a valid state from the fan. Exiting." >> $LOG
  exit 1
fi

# Check that returned modem cpu temp is valid, if not, query it again up 5x until it gets a valid result
while [ ! $(echo $TEMP | egrep -o "[0-9][0-9]") ]
do
  TEMP=$(timeout 5 echo -e AT+QTEMP | socat -W - $ATDEVICE,crnl | grep cpu0-a7-usr | egrep -o "[0-9][0-9]")
  sleep 2
  TTRIES=$(expr $TTRIES + 1)
  if [ $TTRIES -lt 5 ]
  then
    continue
  else
    echo "$(date) -  Could not obtain a valid cpu temperature from the modem; maybe it is busy. Exiting." >> $LOG
    exit 1
  fi
done

# Main fan control logic
if [ $STATE = "off" ] && [ $TEMP -ge $LIMIT ]
then
  $UHUBCTL -l $HUB -a on >/dev/null 2>/dev/null
  echo "$(date) -  Modem cpu reached $TEMP which is greater than or equal to the limit of $LIMIT. Fans activated." >> $LOG
elif [ $STATE = "power" ] && [ $TEMP -lt $LIMIT ]
then
  $UHUBCTL -l $HUB -a off >/dev/null 2>/dev/null
  echo "$(date) -  Modem cpu cooled to $TEMP which is less than the limit of $LIMIT. Fans deactivated." >> $LOG
fi

# Houskeeping for log and pidfile
if [ -f $LOG ]
then
  echo "$(tail -1000 $LOG)" > $LOG
fi
rm $PIDFILE

exit 0
