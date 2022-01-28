#!/bin/sh

#
# *Script info*
# Watch Modem status under ModemManager to ensure it stays connected to the Internet.
# When connectivity is lost, cycle the modem interface and recheck connectivity.
# If cycling the interface does not restore connectivity, cycle ModemManager.
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
#
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
MMDMN="/etc/init.d/modemmanager"

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
  $INFO "Cannot reach internet. Cycling $LIFACE."
  ifup $LIFACE
  watch $RECONNECT
  $INFO "Waiting 10 seconds for interface to come online."
  sleep 10
  pinger
    if [ $CONNECTED -eq 1 ]
    then
      $INFO "Modem is connected to the internet."
    else
      $INFO "Cannot reach internet. Cycling ModemManager."
      $MMDMN stop && sleep 2 && $MMDMN start
      watch $RECONNECT
      $INFO "Waiting 10 seconds for interface to come online."
      sleep 10
      pinger
        if [ $CONNECTED -eq 1 ]
        then
          $INFO "Modem is connected to the internet."
        else
          $ERROR "Could not restore modem internet connectivity."
        fi
    fi
fi
}

# Cleanup $PIDFILE and kill watcher loop when daemon is stopped
# Required for use w/ 'pservice' since it doesn't stop descendants
terminate() {
CHILD=$(cat $WATCHPID)
LOOP=$(cat $LOOPPID)
PARENT=$(cat $PIDFILE)
rm -f $WATCHPID $PIDFILE $LOOPPID
$INFO "Modem watcher killed!"
kill $CHILD $LOOP $PARENT
}

$INFO "Modem watcher initialized!"

trap terminate SIGHUP SIGINT SIGQUIT SIGTERM

while true
do
  watch "$DISCONNECT"
  $INFO "Sleeping until next modem state change."
done & echo $! > $LOOPPID

wait
