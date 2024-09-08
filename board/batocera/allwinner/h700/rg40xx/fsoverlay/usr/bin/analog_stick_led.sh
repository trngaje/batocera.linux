#!/bin/bash

# Define some keys for batocera.conf
KEY_LED_MODE="led.mode"
KEY_LED_BRIGHTNESS="led.brightness"
KEY_LED_SPEED="led.speed"
KEY_LED_COLOUR="led.colour"
KEY_LED_COLOUR_RIGHT="led.colour.right"

# Define some default values
DEFAULT_LED_MODE=1
DEFAULT_BRIGHTNESS=100
DEFAULT_SPEED=1
DEFAULT_COLOUR=(80 120 10)

# Read settings from batocera.conf
LED_MODE=$(batocera-settings-get $KEY_LED_MODE)
BRIGHTNESS=$(batocera-settings-get $KEY_LED_BRIGHTNESS)
SPEED=$(batocera-settings-get $KEY_LED_SPEED)
COLOUR=($(batocera-settings-get $KEY_LED_COLOUR))
COLOUR_RIGHT=($(batocera-settings-get $KEY_LED_COLOUR_RIGHT))

# Define the serial device
SERIAL_DEVICE="/dev/ttyS5"

# Open the serial device
exec 20<>$SERIAL_DEVICE

# Configure the serial device
stty -F $SERIAL_DEVICE 115200 -opost -isig -icanon -echo

# Ensure MCU has power enabled
echo 1 > /sys/class/power_supply/axp2202-battery/mcu_pwr
#echo 1 > /sys/class/power_supply/axp2202-battery/mcu_esckey
sleep 0.05

# Set default mode if no mode selected or selected mode is invalid
if [ -z $LED_MODE ] || [ $LED_MODE -lt 1 ] || [ $LED_MODE -gt 6 ]; then
  echo "Invalid or missing LED mode - setting LED mode to default ($DEFAULT_LED_MODE)"
  batocera-settings-set $KEY_LED_MODE $DEFAULT_LED_MODE
  LED_MODE=$(batocera-settings-get $KEY_LED_MODE)
fi

# Set default brightness if no brightness selected or selected brightness is invalid
if [ -z $BRIGHTNESS ] || [ $BRIGHTNESS -lt 0 ] || [ $BRIGHTNESS -gt 255 ]; then
  echo "Invalid or missing LED brightness - setting LED brightness to default ($DEFAULT_BRIGHTNESS)"
  batocera-settings-set $KEY_LED_BRIGHTNESS $DEFAULT_BRIGHTNESS
  BRIGHTNESS=$(batocera-settings-get $KEY_LED_BRIGHTNESS)
fi

# Function to calculate checksum
calculate_checksum() {
  local sum=0
  for byte in "$@"; do
    sum=$((sum + byte))
  done
  echo $((sum & 0xFF))
}

# Construct payload based on LED mode
if [ $# -eq 1 ]; then

  if [ "$1" == "off" ]; then
    # Does this case have to be so complicated? I just set everything to 0 for now.
    echo "Turning RGB LEDs off."
    LED_MODE=1
    BRIGHTNESS=0
    R=0
    G=0
    B=0
  elif [ "$1" == "warn" ]; then
    echo "Switching RGB to warning mode."
    LED_MODE=2
    R=255
    G=255
    B=0
  elif [ "$1" == "danger" ]; then
    echo "Switching RGB to danger mode."
    LED_MODE=2
    R=255
    G=0
    B=0
  else 
    echo "Usage: $0 [off|warn|danger]"
	exit 1
  fi

  # Construct the payload for RGB values
  PAYLOAD=$(printf '\\x%02X\\x%02X' $LED_MODE $BRIGHTNESS)
  for ((i = 0; i < 16; i++)); do
    PAYLOAD+=$(printf '\\x%02X\\x%02X\\x%02X' $R $G $B)
  done

  # Calculate checksum for the payload
  PAYLOAD_BYTES=($LED_MODE $BRIGHTNESS)
  for ((i = 0; i < 16; i++)); do
    PAYLOAD_BYTES+=($R $G $B)
  done
  CHECKSUM=$(calculate_checksum "${PAYLOAD_BYTES[@]}")
  PAYLOAD+=$(printf '\\x%02X' $CHECKSUM)
  
elif [ $LED_MODE -ge 5 ] && [ $LED_MODE -le 6 ]; then

  # Ensure speed is provided for modes 5 and 6 and within the valid range (0-255)
  if [ -z $SPEED ] || [ $SPEED -lt 0 ] || [ $SPEED -gt 255 ]; then
    echo "Invalid or missing LED speed - setting LED speed to default ($DEFAULT_SPEED)"
    batocera-settings-set $KEY_LED_SPEED $DEFAULT_SPEED
    SPEED=$(batocera-settings-get $KEY_LED_SPEED)
  fi

  # Calculate the checksum
  CHECKSUM=$(calculate_checksum $LED_MODE $BRIGHTNESS 1 1 $SPEED)

  # Construct the payload
  PAYLOAD=$(printf '\\x%02X\\x%02X\\x%02X\\x%02X\\x%02X\\x%02X' $LED_MODE $BRIGHTNESS 1 1 $SPEED $CHECKSUM)

else

  # Ensure RGB colours for modes 1-4 are set and within valid range, set to default if not
  if [ -z $COLOUR ] || [ "${#COLOUR[@]}" -lt 3 ] || [ -z ${COLOUR[0]} ] || [ ${COLOUR[0]} -lt 0 ] || [ ${COLOUR[0]} -gt 255 ] || [ -z ${COLOUR[1]} ] || [ ${COLOUR[1]} -lt 0 ] || [ ${COLOUR[1]} -gt 255 ] || [ -z ${COLOUR[2]} ] || [ ${COLOUR[2]} -lt 0 ] || [ ${COLOUR[2]} -gt 255 ]; then
    echo "Invalid or missing LED colours - setting LED colours to default (${DEFAULT_COLOUR[@]})"
    batocera-settings-set $KEY_LED_COLOUR "$(printf "%s" "${DEFAULT_COLOUR[*]}")"
    COLOUR=($(batocera-settings-get $KEY_LED_COLOUR))
  fi

  # Determine if overrides for the right sticks exist and are within valid range, ignore them if not
  if [ -z $COLOUR_RIGHT ] || [ "${#COLOUR_RIGHT[@]}" -lt 3 ] || [ -z ${COLOUR_RIGHT[0]} ] || [ ${COLOUR_RIGHT[0]} -lt 0 ] || [ ${COLOUR_RIGHT[0]} -gt 255 ] || [ -z ${COLOUR_RIGHT[1]} ] || [ ${COLOUR_RIGHT[1]} -lt 0 ] || [ ${COLOUR_RIGHT[1]} -gt 255 ] || [ -z ${COLOUR_RIGHT[2]} ] || [ ${COLOUR_RIGHT[2]} -lt 0 ] || [ ${COLOUR_RIGHT[2]} -gt 255 ]; then
    echo "No LED colour overrides for the right stick found - using regular colors on the right stick (${DEFAULT_COLOUR[@]})"
    COLOUR_RIGHT=(${COLOUR[0]} ${COLOUR[1]} ${COLOUR[2]})
  fi

  # Construct the payload for left and right joystick values
  PAYLOAD=$(printf '\\x%02X\\x%02X' $LED_MODE $BRIGHTNESS)
  for ((i = 0; i < 8; i++)); do
    PAYLOAD+=$(printf '\\x%02X\\x%02X\\x%02X' ${COLOUR_RIGHT[0]} ${COLOUR_RIGHT[1]} ${COLOUR_RIGHT[2]})
  done
  for ((i = 0; i < 8; i++)); do
    PAYLOAD+=$(printf '\\x%02X\\x%02X\\x%02X' ${COLOUR[0]} ${COLOUR[1]} ${COLOUR[2]})
  done

  # Calculate checksum for the payload
  PAYLOAD_BYTES=($LED_MODE $BRIGHTNESS)
  for ((i = 0; i < 8; i++)); do
    PAYLOAD_BYTES+=(${COLOUR_RIGHT[0]} ${COLOUR_RIGHT[1]} ${COLOUR_RIGHT[2]})
  done
  for ((i = 0; i < 8; i++)); do
    PAYLOAD_BYTES+=(${COLOUR[0]} ${COLOUR[1]} ${COLOUR[2]})
  done
  CHECKSUM=$(calculate_checksum "${PAYLOAD_BYTES[@]}")
  PAYLOAD+=$(printf '\\x%02X' $CHECKSUM)

fi

# Debugging output
echo "Debug: Payload is $PAYLOAD"
echo "Debug: Command to be executed: echo -e -n \"$PAYLOAD\" > $SERIAL_DEVICE"

# Write the payload to the serial device
echo -e -n "$PAYLOAD" > $SERIAL_DEVICE

echo "LED mode $LED_MODE set with brightness $BRIGHTNESS"

# Close the serial device
exec 20>&-
