#!/bin/sh

#
# Activate intake and exhaust fans if modem cpu temp exceeds $LIMIT (in degress celsius)
# Deactivate fans if modem cpu temp falls below $LIMIT
#

PIDFILE=/var/run/fan_control.pid
LOG=/var/log/fan_control.log
LIMIT=55
HUB="1-1.3"
ATDEVICE=/dev/ttyUSB2
UHUBCTL=/usr/sbin/uhubctl

# Preliminary logic to ensure this only runs one instance at a time
if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps | awk '{print $1}' | grep -q $PID
  if [ $? -eq 0 ]
  then
    echo "$(date) - Process already running. Exiting." >> $LOG
    exit 1
  else
    echo $$ > $PIDFILE
    if [ $? -ne 0 ]
    then
      echo "$(date) - Could not create PID file. Exiting." >> $LOG
      exit 1
    fi
  fi
else
  echo $$ > $PIDFILE
  if [ $? -ne 0 ]
  then
    echo "$(date) - Could not create PID file. Exiting." >> $LOG
    exit 1
  fi
fi

# Query current fan state from uhubctl
STATE=$($UHUBCTL -l $HUB | grep -o -m 1 'off\|power')

# Query current temperature of modem cpu
TEMP=$(echo -e AT+QTEMP | socat -W - $ATDEVICE,crnl | grep cpu0-a7-usr | egrep -o "[0-9][0-9]+")

# Check that returned fan state is valid before proceeding; error exit if not.
if [ $(echo $STATE | egrep -o "off") ]
then
  continue
else
  echo "$(date) -  Could not obtain a valid state from the fan; maybe uhubctl is busy. Exiting." >> $LOG
  exit 1
fi

# Check that returned modem cpu temp is valid before proceeding; error exit if not.
if [ $(echo $TEMP | egrep -o "[0-9][0-9]+") ]
then
  continue
else
  echo "$(date) -  Could not obtain a valid cpu temperature from the modem; maybe it is busy. Exiting." >> $LOG
  exit 1
fi

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

# Houskeeping
if [ -f $LOG ]
then
  echo "$(tail -1000 $LOG)" > $LOG
fi
rm $PIDFILE

exit 0
