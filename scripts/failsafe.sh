#!/bin/sh

#
# *Script info*
# Ping destination at a given interval. On failure, disable modem.
# ModemWatcher sees modem is disabled and will restart it. 
# This covers the edge case where carrier side routing becomes broken on a cell.
#
# *Assumptions*
# Script to be used for a single ModemManager modem defined as $LIFACE in uci.
# This script should exist under '/scripts/'.
# 'pservice' daemon w/ modemwatcher.sh should be running.
# At first run this script will add this script to 'pservice' config.
#
# *Required Inputs*
# $PINGDST, $LIFACE, $INTERVAL - Domains to ping, logical (uci) name of the modem interface, and interval.
#
# *Dependencies*
# This script requires 'modemmanager' and 'modemwatcher.sh' to be installed and active.
#
# Copyright 2022 hazarjast (and aliases) - hazarjast at protonmail dot com
#
MMCLI="/usr/bin/mmcli"
INFO="/usr/bin/logger -t FAILSAFE"
DISABLED=0
PIDFILE="/var/run/failsafe.pid"
LOOPPID="/var/run/failsafe_loop.pid"
CYCLING="/var/run/modem.cycling"
PINGDST="google.com cloudflare.com"
LIFACE="WWAN"
INTERVAL=300

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

# Setup this script as a 'pservice' daemon if it's not already
PSCONF=/etc/config/pservice
if ! $(grep -q 'failsafe' $PSCONF) 
then
  [ -f /etc/config/pservice ] && cp -p $PSCONF $PSCONF.bak
cat << EOF >> $PSCONF
config pservice
        option name 'failsafe'
        option respawn_maxfail 0
        option command /bin/sh
        list args -c
        list args 'exec /scripts/failsafe.sh'
EOF

  echo "Setup 'failsafe' as a pservice daemon."
  echo "Execute 'service pservice [re]start' or reboot OpenWRT to start it."
  $INFO "Pservice daemon configured. Notified user to manually start it or reboot."
  exit 0
else
  continue
fi

# Wrapper for 'ping' which tests internet connectivity
# Ping instructed to use the $PIFACE gateway
pinger () {
CONNECTED=0
for DEST in $PINGDST
do
  if [ $CONNECTED -eq 0 ]
  then
    $INFO "Checking internet connectivity by pinging $DEST."
    while [ -z $PIFACE ]
    do
      ubus -v call network.interface.$LIFACE status >/dev/null 2>/dev/null && \
      PIFACE=$(ubus -v call network.interface.$LIFACE status | egrep -o 'l3_device.*' | tr -d "l3_device: \|\"\,")
      sleep 1
    done
    ping -I $PIFACE -c1 $DEST >/dev/null 2>/dev/null
    [ $? -eq 0 ] && CONNECTED=1
  fi
done
}

# Checks for connectivity with 'pinger' and exits early if found
check() {
pinger
if [ $CONNECTED -eq 1 ]
then
  $INFO "Modem is connected to the internet."
  $INFO "Sleeping $INTERVAL seconds until next check."
else
  $INFO "Cannot reach internet. Disabling modem."
  MINDEX="$($MMCLI -L -K | egrep -o '/org/freedesktop/.*' | tr -d "'")"
  $MMCLI -m $MINDEX -d >/dev/null 2>/dev/null
  $INFO "Waiting one minute for the modem to reconnect."
  sleep 60
  pinger
    if [ $CONNECTED -eq 1 ]
    then
      $INFO "Modem successfully reconnected to the internet."
    else
      $INFO "Unable to restore connection, sleeping $INTERVAL seconds until next check."
    fi
fi
}

# Function to cleanup processes and pidfiles when script is terminated
terminate() {
  LOOP=$(cat $LOOPPID)
  rm -f $LOOPPID $PIDFILE
  $INFO "Failsafe killed!"
  kill $LOOP
  exit 0
}

trap terminate SIGHUP SIGINT SIGQUIT SIGTERM

$INFO "Failsafe initialized!"

# Main failsafe logic
while true
do
  if [ ! -f $CYCLING ]
  then
    check
  else
    $INFO "ModemWatcher is already restarting the modem. Skipping check."
  fi  
  sleep $INTERVAL
done & echo $! > $LOOPPID

wait
