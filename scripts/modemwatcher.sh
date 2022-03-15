#!/bin/sh

#
# *Script info*
# Watch Modem status under ModemManager to ensure it stays connected to the Internet.
# When connectivity is lost, cycle the modem and recheck connectivity.
# We cycle the modem instead of just the interface because the RM502Q-AE seems to lose CA ability under NSA without a full restart.
#
# *Assumptions*
# Script to be used for a single ModemManager modem defined as $LIFACE in uci.
# This script should exist under '/scripts/'.
# Package 'pservice' should be installed and used to run this as a daemon.
# At first run this script will add this script to 'pservice' config.
#
# *Required Inputs*
# $PINGDST, $LIFACE - Domains to ping, logical (uci) name of the modem interface.
#
# *Dependencies*
# This script requires 'modemmanager' and 'pservice' packages.
#
# Copyright 2022 hazarjast (and aliases) - hazarjast at protonmail dot com
#
# Inspired by Nicholas Smith's excellent work here:
# https://github.com/nickberry17/modem-manager-keepalive/blob/master/30-keepalive_modemmanager
#

PINGDST="google.com cloudflare.com"
LIFACE="WWAN"
PIDFILE=/var/run/modem_watcher.pid
WATCHPID="/var/run/modem_logread.pid"
LOOPPID="/var/run/modem_loop.pid"
INFO="/usr/bin/logger -t MODEM_WATCHER"
ERROR="/usr/bin/logger -p err -t MODEM_WATCHER"
DISCONNECT="state changed (connected ->"
RECONNECT="state changed (registered -> connected"
MMCLI="/usr/bin/mmcli"
IFRESTART="successfully disabled the modem"
FRESET=0

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

  echo "Setup 'modemwatcher' as a pservice daemon."
  echo "Execute '/etc/init.d/pservice [re]start' or reboot OpenWRT to start it."
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

# Watch the system log for modem status change
watch() {
if [ -f $PIDFILE ]
then
  (logread -f & echo $! > $WATCHPID;) | \
  (grep -q "$1" && kill $(cat $WATCHPID) && rm $WATCHPID;)
  [ $FRESET -eq 0 ] && sleep 5 && logread |grep -q "$IFRESTART" && FRESET=1
  [ "$1" = "$DISCONNECT" ] && [ -f $LOOPPID ] && check
fi
}

# Checks for connectivity with 'pinger' and exits early if found
check() {
$INFO "Modem left connected state."
pinger
if [ $CONNECTED -eq 1 ] && [ $FRESET -eq 0 ]
then
  $INFO "Modem is connected to the internet."
elif [ $FRESET -eq 1 ]
then
  $INFO "$LIFACE was restarted. Cycling modem."
  FRESET=0
  mcycle
  pinger
    if [ $CONNECTED -eq 1 ]
    then
      $INFO "Modem is connected to the internet."
    else
      $INFO "Still cannot reach Internet. Send help."
    fi
else
  $INFO "Cannot reach internet. Cycling modem."
  mcycle
  pinger
    if [ $CONNECTED -eq 1 ]
    then
      $INFO "Modem is connected to the internet."
    else
      $INFO "Still cannot reach Internet. Send help."
    fi
fi
}

# Restarts modem if no connectivity is found or if $LIFACE is restarted
mcycle() {
MINDEX="$($MMCLI -L -K | egrep -o '/org/freedesktop/.*' | tr -d "'")"
$MMCLI -m $MINDEX -r >/dev/null 2>/dev/null
watch $RECONNECT
}

# Cleanup $PIDFILE and kill watcher loop when daemon is stopped
# Required for use w/ 'pservice' since it doesn't stop descendants
terminate() {
CHILD=$(cat $WATCHPID)
LOOP=$(cat $LOOPPID)
rm -f $WATCHPID $PIDFILE $LOOPPID
$INFO "Modem watcher killed!"
kill $CHILD $LOOP
exit 0
}

$INFO "Modem watcher initialized!"

trap terminate SIGHUP SIGINT SIGQUIT SIGTERM

while true
do
  watch "$DISCONNECT"
  $INFO "Sleeping until next modem state change."
done & echo $! > $LOOPPID

wait
