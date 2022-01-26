#!/bin/sh

#
# *Script info*
# Watch Modem status under ModemManager to ensure it stays connected to the Internet.
# If connectivity is lost, cycle ModemManager and bring the modem interface up
#
# *Assumptions*
# Script to be used for a single ModemManager modem defined as $LIFACE in uci.
# Package 'pservice' should be installed and used to run this as a daemon.
#
# *Required Inputs*
# $PINGDST, $WAIT - Domains to ping, how long to wait for ModemManager.
# $LIFACE - Logical (uci) name of the modem interface.
#
# *Dependencies*
# This script requires 'modemmanager', 'pservice', and 'pkill' packages.
#
# Copyright 2022 hazarjast (and aliases) - hazarjast@protonmail.com
#
# Inspired by Nicholas Smith's excellent work here:
# https://github.com/nickberry17/modem-manager-keepalive/blob/master/30-keepalive_modemmanager
#

PINGDST="google.com cloudflare.com"
WAIT=10
LIFACE="WWAN"
PIFACE=$(ubus -v call network.interface.$LIFACE status | egrep -o 'l3_device.*' | tr -d "l3_device: \|\"\,")
PIDFILE=/var/run/modem_watcher.pid
INFO="/usr/bin/logger -t MODEM_WATCHER"
ERROR="/usr/bin/logger -p err -t MODEM_WATCHER"
LOGSTRNG="state changed (connected ->"
MMCLI="/usr/bin/mmcli"
MMDMN="/etc/init.d/modemmanager"
MINDEX="$($MMCLI -L -K | egrep -o '/org/freedesktop/.*' | tr -d "'")"
BINDEX="$($MMCLI -m $MINDEX -K | egrep -o 'bearers\.value.*' | egrep -o '/org/freedesktop/.*')"
MSTATUS=/tmp/modem.status
BSTATUS=/tmp/bearer.status

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

# Sets up this script as a 'pservice' daemon if it's not already
PSCONF=/etc/config/pservice
if ! $(grep -q 'modemwatcher' $PSCONF) 
then
[ -f /etc/config/pservice ] && cp -p $PSCONF $PSCONF.bak
cat << EOF >> $PSCONF

config pservice
        option name 'modemwatcher'
        option respawn_maxfail 0
        option command /bin/sh
        list args -c
        list args 'exec /scripts/modemwatcher.sh'
EOF

  echo "Setup 'modemwatcher' daemon. Execute the following to start it:"
  echo "/etc/init.d/pservice enable ; /etc/init.d/pservice start"
  $INFO "Setup 'modemwatcher' as a daemon and prompted user to start pservice."
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
    $INFO "Checking interet connectivity by pinging $DEST."
    ping -I $PIFACE -c1 $DEST >/dev/null 2>/dev/null
    [ $? -eq 0 ] && CONNECTED=1
  fi
done
}

# Checks for connectivity with 'pinger' and exits early if found
# Restarts ModemManager if no connectivity is found
connect() {
  case "$RE" in
    1) $INFO "Waiting $WAIT seconds for modem activity to finish before checking connection."
      sleep $WAIT ; pinger
      if [ $CONNECTED -eq 1 ]
      then
          $INFO "Modem is connected to the internet."
      else
         $INFO "Cannot reach internet. Cycling ModemManager and bringing $LIFACE up."
          $MMDMN stop && sleep 2 && $MMDMN start
          sleep $WAIT
          ifup $LIFACE
      fi
    ;;
    0) $INFO "Cycling ModemManager and bringing $LIFACE up."
      $MMDMN && sleep 2 && $MMDMN start
      sleep $WAIT
      ifup $LIFACE
    ;;
  esac
}

# Check for modem index presence and check/connect if not found
# If modem index exists, grep for concerning status indicators
check() {
  $INFO "Modem check script is running."
  if [ -z $MINDEX ]
  then
    RE=1 ; connect
  else
    $MMCLI -m "$MINDEX" > $MSTATUS
    echo $BINDEX > $BSTATUS
    STATUS=$(grep -o 'disabled\|idle\|connected\|searching\|registered' $MSTATUS)
  fi

  # Logic gate for actioning returned modem status
  # If modem is disabled or idle, connect
  # If modem is connected/searching/registered, check and 'RE'connect
  case "$STATUS" in
    "disabled") $INFO "Modem is disabled; connecting." && RE=0 && connect
    ;;
    "idle") $INFO "Modem is idle; connecting." && RE=0 && connect
    ;;
    "connected") $INFO "Modem is connected; checking connectivity." && RE=1 && connect
    ;;
    "searching") $INFO "Modem is searching; checking connectivity." && RE=1 && connect
    ;;
    "registered") $INFO "Modem is registered; checking connectivity." && RE=1 && connect
     ;;
  esac
  $INFO "Sleeping until next state change."
}

# Watch the system log for modem status change
watcher() {
  $INFO "Modem watcher initialized!"
  logread -f | while read line
  do
    if [ "${line#*$LOGSTRNG*}" != "$line" ]
    then
      check
    fi
  done &
}

# Cleanup $PIDFILE and kill watcher loop when daemon is stopped
# Required for use w/ 'pservice' since it doesn't stop descendants
terminate() {
  PID=$(cat $PIDFILE)
  rm -f $PIDFILE
  $INFO "Modem watcher killed!"
  pkill -P $PID
}

trap terminate SIGHUP SIGINT SIGQUIT SIGTERM

watcher

wait
