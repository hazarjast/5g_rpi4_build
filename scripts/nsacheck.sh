#!/bin/sh

#
# *Script info*
# Call a speedtest and cache the result. If under 100Mbps disable modem.
# Disabled modem will then be cycled by modemwatcher.sh (if running).
# It is necessary to do this as sometimes NSA aggregation becomes inactive.
#
# *Assumptions*
# This script should be scheduled to run 'off-hours' under root's crontab.
# This script should exist under '/scripts/'.
# 'pservice' daemon w/ modemwatcher.sh should be running.
#
# *Required Inputs*
# $THRESHOLD - Threshold in Mpbs; a result less than or equal to this will trigger disabling modem.
#
# *Dependencies*
# This script requires 'modemmanager' and 'modemwatcher.sh' to be installed and active.
# Also requires latest aarch64 version of Ookla's 'speedtest' script to exist under '/usr/bin'.
# https://www.speedtest.net/apps/cli
#
# Copyright 2022 hazarjast (and aliases) - hazarjast at protonmail dot com
#
MMCLI="/usr/bin/mmcli"
MINDEX="$($MMCLI -L -K | egrep -o '/org/freedesktop/.*' | tr -d "'")"
SPEEDTEST="/usr/bin/speedtest"
INFO="/usr/bin/logger -t NSA_CHECK"
DISABLED=0
THRESHOLD=100

$INFO "Executing speedtest to determine if NSA is active..."
$SPEEDTEST -p no > /tmp/speedtest.result && \
[ $(egrep -o 'Download: *\d*' /tmp/speedtest.result | tr -d "Download: ") -gt $THRESHOLD ] || \
DISABLED=$($MMCLI -m $MINDEX -d >/dev/null 2>/dev/null ; echo 1)

if [ $DISABLED -eq 1 ]
then
  $INFO "Speedtest download result less $THRESHOLD Mbps. NSA appears to be inactive."
  $INFO "Modem was disabled and will be reset momentarily by ModemWatcher."
else
  $INFO "Speedtest download result was greater than $THRESHOLD Mbps. NSA appears to be active."
fi

exit 0
