#!/bin/bash

BOARD=$(cat /boot/boot/batocera.board)
# We only want the script to run for these devices
if [ "$BOARD" != "rg40xx-h" ] && [ "$BOARD" != "rg40xx-v" ]; then
    exit 1
fi

KEY_LED_RETRO_ACHIEVEMENTS="led.retroachievements"
EFFECT_ON=1

# Check batocera.conf for retroachievement effect setting
LED_RETRO_ACHIEVEMENTS=$(batocera-settings-get $KEY_LED_RETRO_ACHIEVEMENTS)

# Initialize unset retroachievement effect setting with default value if necessary
if [[ ! -n $LED_RETRO_ACHIEVEMENTS ]] || [ $LED_RETRO_ACHIEVEMENTS -lt 0 ] || [ $LED_RETRO_ACHIEVEMENTS -gt 1 ]; then
  batocera-settings-set $KEY_LED_RETRO_ACHIEVEMENTS $EFFECT_ON
  LED_RETRO_ACHIEVEMENTS=$EFFECT_ON
fi

# Let the LED daemon run the rainbow animation if retroachievement effect is turned on
if [ $LED_RETRO_ACHIEVEMENTS -eq $EFFECT_ON ]; then
  /usr/bin/analog_stick_led_daemon.sh animation rainbow
fi
