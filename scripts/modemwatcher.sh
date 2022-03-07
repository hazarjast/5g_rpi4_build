#!/bin/sh

#
# *Script info*
# Watch Modem status under ModemManager to ensure it stays connected to the Internet.
# When connectivity is lost, cycle the modem and recheck connectivity.
# If cycling the modem does not restore connectivity, then cycle ModemManager.
#
# *Assumptions*
# Script to be used for a single ModemManager modem defined as $LIFACE in uci.
# Package 'pservice' should be installed and used to run this as a daemon.
# NOTE: At first run this script will add this script to 'pservice' config.
#
# *Required Inputs*
# $PINGDST, $LIFACE - Domains to ping, logical (uci) name of the modem interface.
#
# $ATDEVICE, $MMVID, $MMPID, $MMUBIND - Found in '/lib/udev/rules.d/77-mm-[vendor]-port-types.rules':
# ex. '...ttyUSB2...AT primary port...ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0800", ENV{.MM_USBIFNUM}=="02"...'
# (ATDEVICE="/dev/ttyUSB2", MMVID="2c7c", MMPID="0800", MMUBIND="02")
#
# *Dependencies*
# This script requires 'modemmanager', 'socat', 'timeout', and 'pservice' packages.
#
# Copyright 2022 hazarjast (and aliases) - hazarjast@protonmail.com
#
# Inspired by Nicholas Smith's excellent work here:
# https://github.com/nickberry17/modem-manager-keepalive/blob/master/30-keepalive_modemmanager
#

ATDEVICE=/dev/ttyUSB2
MMVID="2c7c"
MMPID="0800"
MMUBIND="02"
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

    $INFO "Setup 'modemwatcher' as a pservice daemon."
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
  timeout -k 5 5 echo -e AT+CFUN=1,1 | socat -W - $ATDEVICE,crnl
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
