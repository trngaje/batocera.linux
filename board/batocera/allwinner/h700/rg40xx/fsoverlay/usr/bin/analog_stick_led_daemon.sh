#!/bin/bash

# Define RGB LED keys for batocera.conf
KEY_LED_MODE="led.mode"
KEY_LED_BRIGHTNESS="led.brightness"
KEY_LED_SPEED="led.speed"
KEY_LED_COLOUR="led.colour"
KEY_LED_COLOUR_RIGHT="led.colour.right"

# Paths to variables
VAR_CONF_PID="/var/run/analog_stick_led_daemon.conf.pid"
VAR_LED_PID="/var/run/analog_stick_led_daemon.led.pid"
VAR_LED_VALUES="/var/run/analog_stick_led_daemon.values"

# Sleep interval for daemon
UPDATE_INTERVAL_SECONDS=1

# Constants for different LED Daemon modes (different from LED modes!)
MODE_OFF=0
MODE_DEFAULT=1
MODE_WARNING=2
MODE_DANGER=3
MODE_CHARGING=4

# Define some default RGB LED settings
DEFAULT_LED_MODE=1
DEFAULT_BRIGHTNESS=100
DEFAULT_SPEED=5
DEFAULT_COLOUR=(160 240 20)

# Colours and mode for low battery
BATTERY_WARNING_MODE=2
BATTERY_WARNING_COLOUR=(255 255 0)
BATTERY_DANGER_COLOUR=(255 0 0)

# Paths to battery values
KEY_BATTERY_CAPACITY="/sys/class/power_supply/axp2202-battery/capacity"
KEY_BATTERY_STATUS="/sys/class/power_supply/axp2202-battery/status"

# Battery status names
BATTERY_CHARGING="Charging"
BATTERY_DISCHARGING="Discharging"
BATTERY_FULL="Full"

# Low battery charge thresholds (inclusive) for warning/danger
THRESHOLD_WARNING=20
THRESHOLD_DANGER=5

# Initialize last known RGB LED settings
LAST_LED_VALUES=-1

# Initialize current state variables
CURRENT_MODE=-1

# Sets LED variables to given values.
setLedValues() {

  printf "\nUpdating LED values to\nMode: $1\nBrightness: $2\nSpeed: $3\nColor Left: $4 $5 $6\nColor Right: $7 $8 $9\n\n"
  echo "$1 $2 $3 $4 $5 $6 $7 $8 $9" > $VAR_LED_VALUES

}

# Clears all LED variables by removing the files.
clearLedVariables() {

  LAST_LED_VALUES=-1
  if [ -f "$VAR_LED_VALUES" ]; then
    rm $VAR_LED_VALUES
  fi

  echo "Removed all variables from previous session."

}

readLedSettings() {

  # Read LED settings from batocera.conf
  LED_MODE=$(batocera-settings-get $KEY_LED_MODE)
  LED_BRIGHTNESS=$(batocera-settings-get $KEY_LED_BRIGHTNESS)
  LED_SPEED=$(batocera-settings-get $KEY_LED_SPEED)
  LED_COLOUR=($(batocera-settings-get $KEY_LED_COLOUR))
  LED_COLOUR_RIGHT=($(batocera-settings-get $KEY_LED_COLOUR_RIGHT))

  # Ensure mode is set and within valid range, set to default if not
  if [ -z $LED_MODE ]; then
    LED_MODE=0
    batocera-settings-set $KEY_LED_MODE 0
  elif [ $LED_MODE -lt 0 ] || [ $LED_MODE -gt 6 ]; then
    echo "Invalid or missing LED mode ($LED_MODE) - setting LED mode to default ($DEFAULT_LED_MODE)"
    batocera-settings-set $KEY_LED_MODE $DEFAULT_LED_MODE
    LED_MODE=$(batocera-settings-get $KEY_LED_MODE)
  fi
  
  # Set default brightness if no brightness selected or selected brightness is invalid
  if [ -z $LED_BRIGHTNESS ]; then
    LED_BRIGHTNESS=0
    batocera-settings-set $KEY_LED_BRIGHTNESS 0
  elif [ $LED_BRIGHTNESS -lt 0 ] || [ $LED_BRIGHTNESS -gt 255 ]; then
    echo "Invalid or missing LED brightness ($LED_BRIGHTNESS) - setting LED brightness to default ($DEFAULT_BRIGHTNESS)"
    batocera-settings-set $KEY_LED_BRIGHTNESS $DEFAULT_BRIGHTNESS
    LED_BRIGHTNESS=$(batocera-settings-get $KEY_LED_BRIGHTNESS)
  fi

  # Ensure speed is provided for modes 5 and 6 and within the valid range (0-255)
  if [ -z $LED_SPEED ]; then
    LED_SPEED=0
    batocera-settings-set $KEY_LED_SPEED 0
  elif [ -z $LED_SPEED ] || [ $LED_SPEED -lt 0 ] || [ $LED_SPEED -gt 255 ]; then
    echo "Invalid or missing LED speed ($LED_SPEED) - setting LED speed to default ($DEFAULT_SPEED)"
    batocera-settings-set $KEY_LED_SPEED $DEFAULT_SPEED
    LED_SPEED=$(batocera-settings-get $KEY_LED_SPEED)
  fi

  # Ensure RGB colours for modes 1-4 are set and within valid range, set to default if not
  if [ -z $LED_COLOUR ] || [ "${#LED_COLOUR[@]}" -lt 3 ] || [ -z ${LED_COLOUR[0]} ] || [ ${LED_COLOUR[0]} -lt 0 ] || [ ${LED_COLOUR[0]} -gt 255 ] || [ -z ${LED_COLOUR[1]} ] || [ ${LED_COLOUR[1]} -lt 0 ] || [ ${LED_COLOUR[1]} -gt 255 ] || [ -z ${LED_COLOUR[2]} ] || [ ${LED_COLOUR[2]} -lt 0 ] || [ ${LED_COLOUR[2]} -gt 255 ]; then
    echo "Invalid or missing LED colours - setting LED colours to default (${DEFAULT_COLOUR[@]})"
    batocera-settings-set $KEY_LED_COLOUR "$(printf "%s" "${DEFAULT_COLOUR[*]}")"
    LED_COLOUR=($(batocera-settings-get $KEY_LED_COLOUR))
  fi

  # Determine if overrides for the right sticks exist and are within valid range, ignore them if not
  if [ -z $LED_COLOUR_RIGHT ] || [ "${#LED_COLOUR_RIGHT[@]}" -lt 3 ] || [ -z ${LED_COLOUR_RIGHT[0]} ] || [ ${LED_COLOUR_RIGHT[0]} -lt 0 ] || [ ${LED_COLOUR_RIGHT[0]} -gt 255 ] || [ -z ${LED_COLOUR_RIGHT[1]} ] || [ ${LED_COLOUR_RIGHT[1]} -lt 0 ] || [ ${LED_COLOUR_RIGHT[1]} -gt 255 ] || [ -z ${LED_COLOUR_RIGHT[2]} ] || [ ${LED_COLOUR_RIGHT[2]} -lt 0 ] || [ ${LED_COLOUR_RIGHT[2]} -gt 255 ]; then
    echo "No LED colour overrides for the right stick found - using regular colors on the right stick (${DEFAULT_COLOUR[@]})"
    LED_COLOUR_RIGHT=(${LED_COLOUR[0]} ${LED_COLOUR[1]} ${LED_COLOUR[2]})
  fi

  # Update LED variable
  setLedValues $LED_MODE $LED_BRIGHTNESS $LED_SPEED ${LED_COLOUR[0]} ${LED_COLOUR[1]} ${LED_COLOUR[2]} ${LED_COLOUR_RIGHT[0]} ${LED_COLOUR_RIGHT[1]} ${LED_COLOUR_RIGHT[2]}

}

applyLedSettings() {

  # Determine current battery status:
  BATTERY_CHARGE=$(cat $KEY_BATTERY_CAPACITY)
  BATTERY_STATUS=$(cat $KEY_BATTERY_STATUS)

  # Read LED variables from file:
  if [ -f $VAR_LED_VALUES ]; then
    LED_VALUES=($(cat $VAR_LED_VALUES))
    if [ "${#LED_VALUES[@]}" -lt 9 ]; then
      echo "Invalid number of LED values (${#LED_VALUES[@]}/9) - keeping last known values instead."
    elif [ "${#LED_VALUES[@]}" -eq 9 ] && [ "$(printf "%s" "${LED_VALUES[*]}")" != "$(printf "%s" "${LAST_LED_VALUES[*]}")" ]; then
      LED_SETTINGS_CHANGE_DETECTED=true
      LAST_LED_VALUES=(${LED_VALUES[0]} ${LED_VALUES[1]} ${LED_VALUES[2]} ${LED_VALUES[3]} ${LED_VALUES[4]} ${LED_VALUES[5]} ${LED_VALUES[6]} ${LED_VALUES[7]} ${LED_VALUES[8]})
    fi
  fi

  # Let's make LED values human-readable to avoid headaches:
  LED_MODE=${LAST_LED_VALUES[0]}
  LED_BRIGHTNESS=${LAST_LED_VALUES[1]}
  LED_SPEED=${LAST_LED_VALUES[2]}
  LED_LEFT_R=${LAST_LED_VALUES[3]}
  LED_LEFT_G=${LAST_LED_VALUES[4]}
  LED_LEFT_B=${LAST_LED_VALUES[5]}
  LED_RIGHT_R=${LAST_LED_VALUES[6]}
  LED_RIGHT_G=${LAST_LED_VALUES[7]}
  LED_RIGHT_B=${LAST_LED_VALUES[8]}

  # Go to LED mode "off" if the user turned LEDs off.
  if [ $CURRENT_MODE -ne $MODE_OFF ] && [ $LED_MODE -eq 0 ]; then
    echo "Turning off RGB LEDs."
    /usr/bin/analog_stick_led.sh $LED_MODE
    CURRENT_MODE=$MODE_OFF

  elif [ $LED_MODE -ne 0 ]; then

    # Go to LED mode "charging" if the battery is currently charging.
    if [ $CURRENT_MODE -ne $MODE_CHARGING ] && [ $BATTERY_STATUS == $BATTERY_CHARGING ] && [ $BATTERY_CHARGE -lt 100 ]; then
      echo "Battery charge at $BATTERY_CHARGE - going to LED mode 'charging'"
      /usr/bin/analog_stick_led.sh $BATTERY_WARNING_MODE $LED_BRIGHTNESS ${DEFAULT_COLOUR[0]} ${DEFAULT_COLOUR[1]} ${DEFAULT_COLOUR[2]} ${DEFAULT_COLOUR[0]} ${DEFAULT_COLOUR[1]} ${DEFAULT_COLOUR[2]}
      CURRENT_MODE=$MODE_CHARGING

    # Go to LED mode "warning" if not set to warning but battery charge is equal or below warning threshold (and still above danger threshold)
    elif [ $CURRENT_MODE -ne $MODE_WARNING ] && [ $BATTERY_STATUS == $BATTERY_DISCHARGING ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_WARNING ] || ([ $BATTERY_CHARGE -lt $THRESHOLD_WARNING ] && [ $BATTERY_CHARGE -gt $THRESHOLD_DANGER ])); then
      echo "Battery charge at $BATTERY_CHARGE - going to LED mode 'warning'"
      /usr/bin/analog_stick_led.sh $BATTERY_WARNING_MODE $LED_BRIGHTNESS ${BATTERY_WARNING_COLOUR[0]} ${BATTERY_WARNING_COLOUR[1]} ${BATTERY_WARNING_COLOUR[2]} ${BATTERY_WARNING_COLOUR[0]} ${BATTERY_WARNING_COLOUR[1]} ${BATTERY_WARNING_COLOUR[2]}
      CURRENT_MODE=$MODE_WARNING

    # Go to LED mode "danger" if not set to danger but battery charge is equal or below danger threshold
    elif [ $CURRENT_MODE -ne $MODE_DANGER ] && [ $BATTERY_STATUS == $BATTERY_DISCHARGING ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_DANGER ] || [ $BATTERY_CHARGE -lt $THRESHOLD_DANGER ]); then
      echo "Battery charge at $BATTERY_CHARGE - Going to LED mode 'danger'"
      /usr/bin/analog_stick_led.sh $BATTERY_WARNING_MODE $LED_BRIGHTNESS ${BATTERY_DANGER_COLOUR[0]} ${BATTERY_DANGER_COLOUR[1]} ${BATTERY_DANGER_COLOUR[2]} ${BATTERY_DANGER_COLOUR[0]} ${BATTERY_DANGER_COLOUR[1]} ${BATTERY_DANGER_COLOUR[2]}
      CURRENT_MODE=$MODE_DANGER

    # Go back to normal LED mode if set to either warning or danger but battery status is above warning threshold
    elif ($LED_SETTINGS_CHANGE_DETECTED || [ $CURRENT_MODE -ne $MODE_DEFAULT ]) && ([ $BATTERY_STATUS == $BATTERY_FULL ] || ([ $BATTERY_STATUS == $BATTERY_DISCHARGING ] && [ $BATTERY_CHARGE -gt $THRESHOLD_WARNING ])); then
      echo "Battery charge at $BATTERY_CHARGE - Going to normal LED mode"
      if [ $LED_MODE -lt 5 ]; then
        /usr/bin/analog_stick_led.sh $LED_MODE $LED_BRIGHTNESS  $LED_RIGHT_R $LED_RIGHT_G $LED_RIGHT_B $LED_LEFT_R $LED_LEFT_G $LED_LEFT_B
      else
        /usr/bin/analog_stick_led.sh $LED_MODE $LED_BRIGHTNESS $LED_SPEED
      fi
      CURRENT_MODE=$MODE_DEFAULT
      LED_SETTINGS_CHANGE_DETECTED=false
    fi

  fi

}

# Updates LED settings based on changes to batocera.conf
confDaemon() {

  # Watch userdata/system folder for changes to batocera.conf
  while inotifywait /userdata/system -e close_write -e move -e create --includei "batocera\.conf"; do
    echo "Batocera.conf has been changed - updating LED settings."
    readLedSettings
  done

}

# Applies changes to the LEDs based on LED variables and battery status
ledDaemon() {

  # If no variables are set from previous session, initialize led settings from batocera.conf
  if [ ! -f "$VAR_LED_VALUES" ]; then
    readLedSettings
  fi
  # Apply updated LED settings when variables or battery capacity/status has changed
  while :; do
    applyLedSettings

    # Sleep until interval is over
    sleep $UPDATE_INTERVAL_SECONDS
  done

}

start() {
  if [ $# -eq 1 ] && [ "$1" == "clear" ]; then
    clearLedVariables
  fi
  ledDaemon &
  LED_PID=$!
  echo $LED_PID > $VAR_LED_PID
  echo "Started analog stick RGB LED daemon."
  confDaemon &
  CONF_PID=$!
  echo $CONF_PID > $VAR_CONF_PID
  echo "Started batocera.conf watcher daemon."
}

stop() {
  kill $(cat $VAR_LED_PID)
  kill $(cat $VAR_CONF_PID)
  /usr/bin/analog_stick_led.sh 0
  echo "Stopped analog stick RGB LED daemon."
}

restart() {
  stop
  start $1
}

if [ $# -eq 0 ]; then
  echo "Usage: $0 start|restart|stop|set|import [clear|<r_value> <g_value> <b_value>]"
  exit 1
elif [ "$1" == "start" ]; then
  start $2
elif [ "$1" == "stop" ]; then
  stop
elif [ "$1" == "restart" ]; then
  restart $2
elif [ "$1" == "import" ]; then
  readLedSettings
elif [ $# -eq 4 ] && [ "$1" == "set" ]; then
  BRIGHTNESS=$(batocera-settings-get $KEY_LED_BRIGHTNESS)
  SPEED=$(batocera-settings-get $KEY_LED_SPEED)
  setLedValues 1 $BRIGHTNESS $SPEED $2 $3 $4 $2 $3 $4
else 
  echo "Usage: $0 <start|stop|restart|set [r g b]>"
fi
