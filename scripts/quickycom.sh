#!/bin/sh

#
# Script info:
# Wrapper script for 'socat' which communicates with a USB modem's 'AT' serial interface.
# This wrapper allows sending of AT commands, which provide instant return output, to the modem easily.
# Includes an additional 'timeout' failsafe (SIGTERM after $TIMEOUT, SIGKILL after an add'l $TIMEOUT).
# For some query commands (ex. +COPS, +QSCAN, etc.) it is recommended to open an interactive session:
# ex. 'socat -W - $ATDEVICE'. This is because it may take a long time for the modem to return a value.
#
# NOTE: On first run this script checks that ModemManager is unbound from the selected AT interface.
# If this is not the case, a udev rule is created to accomplish this and user is then prompted to reboot.
# Also creates a symlink on first run so that you can execute as simply 'qcom' thereafter.
#
# *Assumptions*
# Specifically written for OpenWRT hosts with a modem managed by ModemManager.
# Modem should be in a USB mode which provides a free AT serial port.
# This script should exist under '/scripts/'.
# Just like raw 'socat' and other serial terminals, double quotes should be escaped (using backslash):
# ex. 'qcom AT+QENG=\"servingcell\"'
#
# *Required Input*
# $CMD, $TIMEOUT - AT command, timeout period before termindation (in seconds)
# $ATDEVICE, $MMVID, $MMPID, $MMUBIND - Found in '/lib/udev/rules.d/77-mm-[vendor]-port-types.rules':
# ex. '...ttyUSB3...AT secondary port...ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0800", ENV{.MM_USBIFNUM}=="03"...'
# ($ATDEVICE="/dev/ttyUSB3", MMVID="2c7c", MMPID="0800", MMUBIND="03")
#
# *Dependencies*
# This script requires 'timeout' and 'socat' packages to be installed along with any serial drivers for the interface.
#
# Copyright 2022 hazarjast (and aliases) - hazarjast@protonmail.com
#

PIDFILE=/var/run/quickycom.pid
CMD="$1"
TIMEOUT=5
ATDEVICE=/dev/ttyUSB3
MMVID="2c7c"
MMPID="0800"
MMUBIND="03"

# Preliminary logic to ensure this only runs one instance at a time
if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  if [ $(ps | awk '{print $1}' | grep $PID) ]
  then
    echo "$(date) - Quickycom already running. Exiting."
    exit 1
  else
    continue
  fi
else
  echo $$ > $PIDFILE
  if [ ! -f "$PIDFILE" ] && [ ! $(grep -s $$ $PIDFILE) ]
  then
    echo "$(date) - Could not create PID file. Exiting."
    exit 1
  else
    continue
  fi
fi

# Unbind ModemManager from the secondary AT port so we can use it
# Without this 'socat' commands can hang indefinitely
# See: https://github.com/openwrt/packages/issues/14197
# If changes are made, prompt for user reboot
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

  echo "$(date) - Unbound ModemManager from USBIFNUM $MMUBIND on modem $MMVID:$MMPID."
  echo "$(date) - ModemManager config changes were made. Prompted user to reboot."
  echo "ModemManager config changes were made. Please reboot OpenWRT before executing this script again."
  exit 0
else
  continue
fi

# Create symlink for easy calls going forward
[ -f /usr/sbin/qcom ] || ln -s /scripts/quickycom.sh /usr/sbin/qcom

# If $CMD entered, send it to the interface; SIGTERM and then SIGKILL (if necesary) socat if it hangs
if [ -z $CMD ]
then
  echo "No AT command entered. Exiting."
  exit 1
else
  timeout -k $TIMEOUT $TIMEOUT echo -e $CMD | socat -W - $ATDEVICE,crnl
fi

# Houskeeping for pidfile
rm $PIDFILE

exit 0
