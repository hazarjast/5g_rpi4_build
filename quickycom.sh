#!/bin/sh

#
# Script info:
# Wrapper script for 'socat' which communicates with a USB modem's 'AT' serial interface.
# Noticed that 'socat' would sometimes hang on interface communication even with native locking switches.
# This wrapper adds another layer of lock protection to the serial interface along with a kill failsafe.
#
# NOTE: On first run this scrip checks that ModemManager is unbound from the selected AT interface.
# If this is not the case, a udev rule is created to accomplish this and user is then prompted to reboot.
#
# Assumptions:
# Specifically written for OpenWRT hosts with a modem managed by ModemManager.
# Modem should be in a USB mode which provides a free AT serial port.
#
# Dependencies:
# This script requires 'timeout' and 'socat' packages to be installed along with any serial drivers for the interface.
#

PIDFILE=/var/run/quickycom.pid
ATDEVICE=/dev/ttyUSB3
CMD="$1"
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

# Send cleaned command to the interface; kill socat if it hangs
timeout -k 5 5 echo -e $CMD | socat -W - $ATDEVICE,crnl

# Houskeeping for pidfile
rm $PIDFILE

exit 0
