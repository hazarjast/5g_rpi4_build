#!/bin/sh
# Activate intake and exhaust fans if modem cpu temp exceeds $LIMIT (in degress celsius)

PIDFILE=/var/run/fan_control.pid
LOG=/var/log/fan_control.log
LIMIT=55
HUB="1-1.3"

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

STATE=$(/usr/sbin/uhubctl -l $HUB | grep -m 1 -q off; echo $?)
TEMP=$(echo -e AT+QTEMP | socat -W - /dev/ttyUSB2,crnl | grep cpu0-a7-usr | egrep -o "[0-9][0-9]+")

if [ echo $TEMP | egrep -o "[0-9][0-9]+" ]
then
  break
else
  echo "$(date) -  Could not obtain a valid cpu temperature from the modem; maybe it is busy. Exiting." >> $LOG
  exit 1

if [ $STATE -eq 0 ] && [ $TEMP -ge $LIMIT ]
then
  /usr/sbin/uhubctl -l $HUB -a 1 >/dev/null 2>/dev/null
  echo "$(date) -  Modem cpu reached $TEMP which is greater than or equal to the limit of $LIMIT. Fans activated." >> $LOG
elif [ $STATE -eq 1 ] && [ $TEMP -lt $LIMIT ]
then
  /usr/sbin/uhubctl -l $HUB -a 0 >/dev/null 2>/dev/null
  echo "$(date) -  Modem cpu cooled to $TEMP which is less than the limit of $LIMIT. Fans deactivated." >> $LOG
fi

# Keep log from getting too large
if [ -f $LOG ]
then
  echo "$(tail -1000 $LOG)" > $LOG
fi

rm $PIDFILE

exit 0
