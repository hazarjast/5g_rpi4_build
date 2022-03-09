#!/bin/sh

#
# *Script info*
# Watch Modem status under ModemManager to ensure it stays connected to the Internet.
# When connectivity is lost, cycle the modem and recheck connectivity.
# We cycle the modem instead of just the interface because the RM502Q-AE seems to lose NSA/CA ability without a full restart.
#
# *Assumptions*
# Script to be used for a single ModemManager modem defined as $LIFACE in uci.
# Package 'pservice' should be installed and used to run this as a daemon.
# NOTE: At first run this script will add this script to 'pservice' config.
#
# *Required Inputs*
# $PINGDST, $LIFACE - Domains to ping, logical (uci) name of the modem interface.
#
# *Dependencies*
# This script requires 'modemmanager' and 'pservice' packages.
#
# Copyright 2022 hazarjast (and aliases) - hazarjast@protonmail.com
#
# Inspired by Nicholas Smith's excellent work here:
# https://github.com/nickberry17/modem-manager-keepalive/blob/master/30-keepalive_modemmanager
#

PINGDST="google.com cloudflare.com"
LIFACE="WWAN"
PIFACE=$(ubus -v call network.interface.$LIFACE status | egrep -o 'l3_device.*' | tr -d "l3_device: \|\"\,")
PIDFILE=/var/run/modem_watcher.pid
WATCHPID="/var/run/modem_logread.pid"
LOOPPID="/var/run/modem_loop.pid"
INFO="/usr/bin/logger -t MODEM_WATCHER"
ERROR="/usr/bin/logger -p err -t MODEM_WATCHER"
DISCONNECT="state changed (connected ->"
RECONNECT="state changed (registered -> connected"
MMCLI="/usr/bin/mmcli"

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
    $INFO "Checking interet connectivity by pinging $DEST."
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
  [ "$1" = "$DISCONNECT" ] && [ -f $LOOPPID ] && check
fi
}

# Checks for connectivity with 'pinger' and exits early if found
# Restarts ModemManager if no connectivity is found
check() {
$INFO "Modem left connected state."

pinger

if [ $CONNECTED -eq 1 ]
then
  $INFO "Modem is connected to the internet."
else
  $INFO "Cannot reach internet. Cycling modem."
  MINDEX="$($MMCLI -L -K | egrep -o '/org/freedesktop/.*' | tr -d "'")"
  $MMCLI -m $MINDEX -r >/dev/null 2>/dev/null
  watch $RECONNECT
  $INFO "Waiting 30 seconds for interface to come online."
  sleep 30
  pinger
    if [ $CONNECTED -eq 1 ]
    then
      $INFO "Modem is connected to the internet."
    else
      $INFO "Still cannot reach Internet. Send help."
    fi
fi
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
