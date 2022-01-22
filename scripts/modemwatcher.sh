#!/bin/sh

#
# *Script info*
# Watch Modem status under ModemManager to ensure it stays connected to the Internet.
# If connectivity is lost, cycle ModemManager and bring the modem interface up
#
# *Assumptions*
# Script to be used for a single ModemManager modem defined as $LIFACE in uci.
#
# *Required Inputs*
# $PINGDST, $WAIT - Domains to ping, how long to wait for ModemManager.
# $LIFACE - Logical (uci) name of the modem interface.
#
# *Dependencies*
# This script requires 'modemmanager' v1.10+ to be installed.
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
if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  if [ $(ps | awk '{print $1}' | grep $PID) ]
  then
    $ERROR "Already running. Exiting."
    exit 1
  else
    continue
  fi
else
  echo $$ > $PIDFILE
  if [ ! -f "$PIDFILE" ]
  then
    $ERROR "Could not create PID file. Exiting."
    exit 1
  else
    continue
  fi
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
    "disabled") $INFO "Modem is disabled; connecting." ; RE=0 ; connect
    ;;
    "idle") $INFO "Modem is idle; connecting." ; RE=0 ; connect
    ;;
    "connected") $INFO "Modem is connected; checking connectivity." ; RE=1 ; connect
    ;;
    "searching") $INFO "Modem is searching; checking connectivity." ; RE=1 ; connect
    ;;
    "registered") $INFO "Modem is registered; checking connectivity." ; RE=1 ; connect
     ;;
  esac
  $INFO "Sleeping until next state change."
}

# Log watcher
watcher() {
  logread -f | while read line
  do
    if [ "${line#*$LOGSTRNG*}" != "$line" ]
    then
      check
    fi
  done
}

watcher
