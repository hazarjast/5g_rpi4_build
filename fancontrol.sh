#!/bin/sh
# Activate intake and exhaust fans if modem cpu temp exceeds 55c (130f)

LOG="/var/log/fan_history"
LIMIT=55
HUB="1-1.3"
STATE=$(/usr/sbin/uhubctl -l $HUB | grep -m 1 -q off)
TEMP=$(echo -e AT+QTEMP | socat -t 1 - /dev/ttyUSB2,crnl | grep cpu0-a7-usr | egrep -o "[0-9][0-9]+")

if [ $TEMP -ge $LIMIT ] || [ $STATE -eq 0 ]
then
  /usr/sbin/uhubctl -l $HUB -a 1 >/dev/null 2>/dev/null
else
  echo "placeholder"
fi
