#!/bin/bash

export LC_NUMERIC="en_US.UTF-8"

# Daemon modes
DAEMON_MODE_OFF=0
DAEMON_MODE_STATIC=1
DAEMON_MODE_BREATHING_FAST=2
DAEMON_MODE_BREATHING_MEDIUM=3
DAEMON_MODE_BREATHING_SLOW=4
DAEMON_MODE_SINGLE_RAINBOW=5
DAEMON_MODE_MULTI_RAINBOW=6

# Known TrimUI LED modes
LED_MODE_OFF=0
LED_MODE_LINEAR=1
LED_MODE_BREATH=2
LED_MODE_SNIFF=3
LED_MODE_STATIC=4
LED_MODE_BLINK_SINGLE=5
LED_MODE_BLINK_DOUBLE=6
LED_MODE_BLINK_TRIPLE=7

# TrimUI LEDs have an odd max integer value of 60
MAX_INTEGER=60

# TrimUI LEDs interpret effect cycles value -1 as infinite loop
EFFECT_CYCLES_INFINITE_LOOP=-1

# Initialize color (black)
COLOR="00000"

# Initialize mode (off)
MODE=0

# Initialize brightness (none)
BRIGHTNESS=0

# Converts Daemon mode into TrimUI LED mode
#
# The analog_stick_led_daemon.sh was written for the
# Anbernic RG40XXH/V and RGCubeXX, consequently it
# sets the modes known from those devices.
# Before a mode can be set, it must be translated
# from a daemon/Anbernic mode to a TrimUI LED mode.
setMode() {
  
  if [ $1 -eq $DAEMON_MODE_OFF ]; then
    MODE=$LED_MODE_OFF
  elif [ $1 -eq $DAEMON_MODE_STATIC ]; then
    MODE=$LED_MODE_STATIC # TODO: Check if this is the correct mode?
  elif [ $1 -eq $DAEMON_MODE_BREATHING_FAST ]; then
    echo "Daemon mode 2 (Breath (fast)) is not supported, yet. Using Breath (medium) instead"
    MODE=$LED_MODE_BREATH # TODO: Is it possible to modify breath speed?
  elif [ $1 -eq $DAEMON_MODE_BREATHING_MEDIUM ]; then
    MODE=$LED_MODE_BREATH # TODO: Is it possible to modify breath speed?
  elif [ $1 -eq $DAEMON_MODE_BREATHING_SLOW ]; then
    echo "Daemon mode 2 (Breath (slow)) is not supported, yet. Using Breath (slow) instead"
    MODE=$LED_MODE_BREATH # TODO: Is it possible to modify breath speed?
  elif [ $1 -eq $DAEMON_MODE_SINGLE_RAINBOW ]; then
    # TODO: Figure out a way to manually run rainbow mode
    MODE=$LED_MODE_LINEAR # TODO: Verify if linear mode is similar to rainbow mode (cycling through colors randomly)
  elif [ $1 -eq $DAEMON_MODE_MULTI_RAINBOW ]; then
    # TODO: Figure out a way to manually run multi rainbow mode
    echo "Daemon mode 6 (Multi Rainbow) is not supported, yet. Using Static instead."
    MODE=$LED_MODE_STATIC
  fi

}

# Converts brightness (0-255) into an integer of (0-60)
setBrightness() {

  BRIGHTNESS_DEC=$1
  
  # The TSP has an integer range of 0-60
  # So we need to do some math first:
  # Divide by 255 and mulitply by 60
  BRIGHTNESS_TSP_FLOAT=$(echo "scale=2; $BRIGHTNESS_DEC/255*$MAX_INTEGER" | bc)

  # Round it to get applicable brightness
  BRIGHTNESS="$(printf '%.0f' ${BRIGHTNESS_TSP_FLOAT})"

}

# Converts integer RGB values into a TSP-compatible hex string
setHexColor() {

  R_DEC=$1
  G_DEC=$2
  B_DEC=$3
  
  echo R_DEC $R_DEC
  echo G_DEC $G_DEC
  echo B_DEC $B_DEC

  # The TSP has an integer range of 0-60
  # So we need to do some math first:
  # Divide by 255 and mulitply by 60
  R_TSP_FLOAT=$(echo "scale=2; $R_DEC/255*$MAX_INTEGER" | bc)
  G_TSP_FLOAT=$(echo "scale=2; $G_DEC/255*$MAX_INTEGER" | bc)
  B_TSP_FLOAT=$(echo "scale=2; $B_DEC/255*$MAX_INTEGER" | bc)

  
  echo R_TSP_FLOAT $R_TSP_FLOAT
  echo G_TSP_FLOAT $G_TSP_FLOAT
  echo B_TSP_FLOAT $B_TSP_FLOAT

  R_TSP="$(printf '%.0f' ${R_TSP_FLOAT})"
  G_TSP="$(printf '%.0f' ${G_TSP_FLOAT})"
  B_TSP="$(printf '%.0f' ${B_TSP_FLOAT})"

  echo R_TSP $R_TSP
  echo G_TSP $G_TSP
  echo B_TSP $B_TSP

  R_HEX="$(printf '%02x' $R_TSP)"
  G_HEX="$(printf '%02x' $G_TSP)"
  B_HEX="$(printf '%02x' $B_TSP)"
  
  echo R_HEX $R_HEX
  echo G_HEX $G_HEX
  echo B_HEX $B_HEX

  COLOR="$R_HEX$G_HEX$B_HEX"
  
  echo TSPColor $COLOR

}

# Disables the LED by simply turning brightness to 0
disableLed() {

  echo 0 > /sys/class/led_anim/max_scale

}

# Stops the effect that is currently set
stopEffect() {

  echo 0 > /sys/class/led_anim/effect_enable

}

# Starts the given effect with the given color and brightness
startEffect() {

  # stop previous effect
  stopEffect

  # set brightness of next effect
  echo $BRIGHTNESS > /sys/class/led_anim/max_scale

  # set color of next effect
  echo "$COLOR " > /sys/class/led_anim/effect_rgb_hex_lr
  echo "$COLOR " > /sys/class/led_anim/effect_rgb_hex_m
  # only the Brick has f1/f2
  if [ -f "/sys/class/led_anim/effect_rgb_hex_f1" ] && [ -f "/sys/class/led_anim/effect_rgb_hex_f2" ];then # TODO: replace with boardcheck if possible!
    echo "$COLOR " > /sys/class/led_anim/effect_rgb_hex_f1
    echo "$COLOR " > /sys/class/led_anim/effect_rgb_hex_f2
  fi
  
  # set cycles of next effect to infinite loop (-1)
  echo $EFFECT_CYCLES_INFINITE_LOOP > /sys/class/led_anim/effect_cycles_lr
  echo $EFFECT_CYCLES_INFINITE_LOOP > /sys/class/led_anim/effect_cycles_m
  # only the Brick has f1/f2
  if [ -f "/sys/class/led_anim/effect_cycles_f1" ] && [ -f "/sys/class/led_anim/effect_cycles_f2" ];then # TODO: replace with boardcheck if possible!
    echo $EFFECT_CYCLES_INFINITE_LOOP > /sys/class/led_anim/effect_cycles_f1
    echo $EFFECT_CYCLES_INFINITE_LOOP > /sys/class/led_anim/effect_cycles_f2
  fi

  #set mode of next effect
  echo $MODE > /sys/class/led_anim/effect_m
  echo $MODE > /sys/class/led_anim/effect_lr
  # only the Brick has f1/f2
  if [ -f "/sys/class/led_anim/effect_f1" ] && [ -f "/sys/class/led_anim/effect_f2" ];then # TODO: replace with boardcheck if possible!
    echo "$MODE " > /sys/class/led_anim/effect_f1
    echo "$MODE " > /sys/class/led_anim/effect_f2
  fi

  # start next effect
  echo 1 > /sys/class/led_anim/effect_enable

}

# Prints instructions to stdout.
printInstructions() {
  echo "Usage:"
  echo "       $0 <mode> <brightness> <red> <green> <blue> for modes 1-4"
  echo "       $0 <mode> <brightness> <speed> for modes 5-6"
  echo ""
  echo "Analog stick RGB LED control for TrimUI Smart Pro."
  echo ""
  echo "Allowed values"
  echo "  mode       0-6"
  echo "             0: off"
  echo "             1: static"
  echo "             2: breath (fast)"
  echo "             3: breath (medium)"
  echo "             4: breath (slow)"
  echo "             5: single rainbow (cyling through colors)"
  echo "             6: multi rainbow (swirl)"
  echo "  brightness 0-255"
  echo "  red        0-255"
  echo "  green      0-255"
  echo "  blue       0-255"
  echo ""
}


# Set daemon mode 1-4 (static, breathing (fast, medium, slow))
# with the given brightness and color.
setRGBBasedMode() {

  # If mode is not between 1-4 or brightness is not between
  # 0 and 100 or any RGB color is not between 0 and 255,
  # print instructions and quit.
  if [ $1 -gt 4 ] || [ $2 -lt 0 ] || [ $2 -gt 100 ] || [ $3 -lt 0 ] || [ $3 -gt 255 ] || [ $4 -lt 0 ] || [ $4 -gt 255 ] || [ $5 -lt 0 ] || [ $5 -gt 255 ]; then
    printInstructions
    exit 1
  fi

  # Set mode
  setMode $1

  # Set BRIGHTNESS variable
  setBrightness $2

  # Set COLOR variable with concatenated hex value of RGB integers
  setHexColor $3 $4 $5

  # Turn on the given effect/brightness/color
  startEffect

}

# On the Anbernic RG40XXH/V and RGCube, rainbow modes
# do not allow setting RGB values because they are irrelevant.
# However, they allow to set a speed setting.
setSpeedBasedMode() {

  # TODO: Find a way to mimic $1=5 (single rainbow) and $=6 (multi rainbow)
  # TODO: Find a way to apply $3 (speed, range 0-100)
  echo "Speed-based modes (single rainbow, multi rainbow) are not supported, yet."

}

# Disable LED and exit if at least one argument (mode) is given and mode is 0
if [ $# -gt 0 ] && [ $1 -eq $DAEMON_MODE_OFF ]; then
  disableLed
  exit 1
# Go to a speed-based mode (not yet supported)
elif [ $# -eq 3 ] && [ $1 -gt 4 ]; then
  setSpeedBasedMode $1 $2 $3
# Go to an RGB-based mode
elif [ $# -gt 4 ] && [ $1 -lt 5 ]; then
  if [ $# -gt 5 ]; then # TODO: Extend daemon to support dedicated control of each available LED (left, right, center, f1, f2)
    echo "Dedicated RGB values for the right stick are not supported, yet."
  fi
  setRGBBasedMode $1 $2 $3 $4 $5
# Invalid input
else
  printInstructions
fi
