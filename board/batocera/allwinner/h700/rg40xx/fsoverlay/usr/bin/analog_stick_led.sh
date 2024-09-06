#!/bin/bash

# Define some keys for batocera.conf
KEY_LED_MODE="rg40xxh.rgb.mode"
KEY_BRIGHTNESS="rg40xxh.rgb.brightness"
KEY_SPEED="rg40xxh.rgb.speed"
KEY_RED="rg40xxh.rgb.r"
KEY_GREEN="rg40xxh.rgb.g"
KEY_BLUE="rg40xxh.rgb.b"
KEY_LEFT_RED="rg40xxh.rgb.r.left"
KEY_LEFT_GREEN="rg40xxh.rgb.g.left"
KEY_LEFT_BLUE="rg40xxh.rgb.b.left"
KEY_RIGHT_RED="rg40xxh.rgb.r.right"
KEY_RIGHT_GREEN="rg40xxh.rgb.g.right"
KEY_RIGHT_BLUE="rg40xxh.rgb.b.right"

# Define some default values
DEFAULT_LED_MODE=1
DEFAULT_BRIGHTNESS=100
DEFAULT_SPEED=1
DEFAULT_RED=80
DEFAULT_GREEN=120
DEFAULT_BLUE=10

# Read settings from batocera.conf
LED_MODE=$(batocera-settings-get $KEY_LED_MODE)
BRIGHTNESS=$(batocera-settings-get $KEY_BRIGHTNESS)
SPEED=$(batocera-settings-get $KEY_SPEED)
R=$(batocera-settings-get $KEY_RED)
G=$(batocera-settings-get $KEY_GREEN)
B=$(batocera-settings-get $KEY_BLUE)
LEFT_R=$(batocera-settings-get $KEY_LEFT_RED)
LEFT_G=$(batocera-settings-get $KEY_LEFT_GREEN)
LEFT_B=$(batocera-settings-get $KEY_LEFT_BLUE)
RIGHT_R=$(batocera-settings-get $KEY_RIGHT_RED)
RIGHT_G=$(batocera-settings-get $KEY_RIGHT_GREEN)
RIGHT_B=$(batocera-settings-get $KEY_RIGHT_BLUE)

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
  batocera-settings-set $KEY_BRIGHTNESS $DEFAULT_BRIGHTNESS
  BRIGHTNESS=$(batocera-settings-get $KEY_BRIGHTNESS)
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
    batocera-settings-set $KEY_SPEED $DEFAULT_SPEED
    SPEED=$(batocera-settings-get $KEY_SPEED)
  fi

  # Calculate the checksum
  CHECKSUM=$(calculate_checksum $LED_MODE $BRIGHTNESS 1 1 $SPEED)

  # Construct the payload
  PAYLOAD=$(printf '\\x%02X\\x%02X\\x%02X\\x%02X\\x%02X\\x%02X' $LED_MODE $BRIGHTNESS 1 1 $SPEED $CHECKSUM)

else

  # Ensure red value is provided for mode 1-4 and within valid range, set to default if not
  if ([ -z $R ] || [ $R -lt 0 ] || [ $R -gt 255 ]) && ([ -z $LEFT_R ] || [ $LEFT_R -lt 0 ] || [ $LEFT_R -gt 255 ] || [ -z $RIGHT_R ] || [ $RIGHT_R -lt 0 ] || [ $RIGHT_R -gt 255 ]); then
    echo "Invalid or missing LED left red - setting LED left red to default ($DEFAULT_RED)"
    batocera-settings-set $KEY_RED $DEFAULT_RED
    R=$(batocera-settings-get $KEY_RED)
  fi

  # Ensure green value is provided for mode 1-4 and within valid range, set to default if not
  if ([ -z $G ] || [ $G -lt 0 ] || [ $G -gt 255 ]) && ([ -z $LEFT_G ] || [ $LEFT_G -lt 0 ] || [ $LEFT_G -gt 255 ] || [ -z $RIGHT_G ] || [ $RIGHT_G -lt 0 ] || [ $RIGHT_G -gt 255 ]); then
    echo "Invalid or missing LED left green - setting LED left green to default ($DEFAULT_GREEN)"
    batocera-settings-set $KEY_GREEN $DEFAULT_GREEN
    G=$(batocera-settings-get $KEY_GREEN)
  fi

  # Ensure blue value is provided for mode 1-4 and within valid range, set to default if not
  if ([ -z $B ] || [ $B -lt 0 ] || [ $B -gt 255 ]) && ([ -z $LEFT_B ] || [ $LEFT_B -lt 0 ] || [ $LEFT_B -gt 255 ] || [ -z $RIGHT_B ] || [ $RIGHT_B -lt 0 ] || [ $RIGHT_B -gt 255 ]); then
    echo "Invalid or missing LED left green - setting LED left green to default ($DEFAULT_BLUE)"
    batocera-settings-set $KEY_BLUE $DEFAULT_BLUE
    B=$(batocera-settings-get $KEY_BLUE)
  fi

  # Ensure left red value is provided for mode 1-4 and within valid range
  if [ -z $LEFT_R ] || [ $LEFT_R -lt 0 ] || [ $LEFT_R -gt 255 ]; then
    echo "No LED left red override found - using regular red ($R)"
    LEFT_R=$R
  fi

  # Ensure left green value is provided for mode 1-4 and within valid range
  if [ -z $LEFT_G ] || [ $LEFT_G -lt 0 ] || [ $LEFT_G -gt 255 ]; then
    echo "No LED left green override found - using regular green ($G)"
    LEFT_G=$G
  fi

  # Ensure left blue value is provided for mode 1-4 and within valid range
  if [ -z $LEFT_B ] || [ $LEFT_B -lt 0 ] || [ $LEFT_B -gt 255 ]; then
    echo "No LED left blue override found - using regular blue ($B)"
    LEFT_B=$B
  fi

  # Ensure right red value is provided for mode 1-4 and within valid range
  if [ -z $RIGHT_R ] || [ $RIGHT_R -lt 0 ] || [ $RIGHT_R -gt 255 ]; then
    echo "No LED right red override found - using regular red ($R)"
    RIGHT_R=$R
  fi

  # Ensure right green value is provided for mode 1-4 and within valid range
  if [ -z $RIGHT_G ] || [ $RIGHT_G -lt 0 ] || [ $RIGHT_G -gt 255 ]; then
    echo "No LED right green override found - using regular green ($G)"
    RIGHT_G=$G
  fi

  # Ensure right blue value is provided for mode 1-4 and within valid range
  if [ -z $RIGHT_B ] || [ $RIGHT_B -lt 0 ] || [ $RIGHT_B -gt 255 ]; then
    echo "No LED right blue override found - using regular blue ($B)"
    RIGHT_B=$B
  fi

  # Construct the payload for jeft and right joystick values
  PAYLOAD=$(printf '\\x%02X\\x%02X' $LED_MODE $BRIGHTNESS)
  for ((i = 0; i < 8; i++)); do
    PAYLOAD+=$(printf '\\x%02X\\x%02X\\x%02X' $RIGHT_R $RIGHT_G $RIGHT_B)
  done
  for ((i = 0; i < 8; i++)); do
    PAYLOAD+=$(printf '\\x%02X\\x%02X\\x%02X' $LEFT_R $LEFT_G $LEFT_B)
  done

  # Calculate checksum for the payload
  PAYLOAD_BYTES=($LED_MODE $BRIGHTNESS)
  for ((i = 0; i < 8; i++)); do
    PAYLOAD_BYTES+=($RIGHT_R $RIGHT_G $RIGHT_B)
  done
  for ((i = 0; i < 8; i++)); do
    PAYLOAD_BYTES+=($LEFT_R $LEFT_G $LEFT_B)
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
