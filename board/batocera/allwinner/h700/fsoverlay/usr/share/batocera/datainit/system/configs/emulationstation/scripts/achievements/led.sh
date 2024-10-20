#!/bin/bash

BOARD=$(cat /boot/boot/batocera.board)
# We only want the script to run for these devices
if [ "$BOARD" != "rg40xx-h" ] && [ "$BOARD" != "rg40xx-v" ]; then
    exit 1
fi

# Let the LED daemon run the rainbow animation
/usr/bin/analog_stick_led_daemon.sh animation rainbow
