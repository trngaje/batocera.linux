#!/bin/bash

# Define RGB LED keys for batocera.conf
KEY_LED_MODE="led.mode"
KEY_LED_BRIGHTNESS="led.brightness"
KEY_LED_SPEED="led.speed"
KEY_LED_COLOUR="led.colour"
KEY_LED_COLOUR_RIGHT="led.colour.right"

# Paths to variables
VAR_PID="/var/run/analog_stick_led_daemon.pid"
VAR_CONF_CHANGE_DATE="/var/run/analog_stick_led_daemon.date"
VAR_MODE="/var/run/analog_stick_led_daemon.mode"
VAR_BRIGHTNESS="/var/run/analog_stick_led_daemon.brightness"
VAR_SPEED="/var/run/analog_stick_led_daemon.speed"
VAR_COLOUR="/var/run/analog_stick_led_daemon.colour"
VAR_COLOUR_RIGHT="/var/run/analog_stick_led_daemon.colour_right"

# Sleep interval for daemon
UPDATE_INTERVAL_SECONDS=1

# Constants for different LED Daemon modes (different from LED modes!)
MODE_CHARGING=3
MODE_WARNING=2
MODE_DANGER=1
MODE_DEFAULT=0

# Define some default RGB LED settings
DEFAULT_LED_MODE=1
DEFAULT_BRIGHTNESS=100
DEFAULT_SPEED=5
DEFAULT_COLOUR=(80 120 10)

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
LAST_LED_MODE=-1
LAST_BRIGHTNESS=-1
LAST_SPEED=-1
LAST_COLOUR=-1
LAST_COLOUR_RIGHT=-1

# Initialize last known change dates
LAST_CONF_CHANGE_DATE=-1
LAST_MODE_CHANGE_DATE=-1
LAST_BRIGHTNESS_CHANGE_DATE=-1
LAST_SPEED_CHANGE_DATE=-1
LAST_COLOUR_CHANGE_DATE=-1
LAST_COLOUR_RIGHT_CHANGE_DATE=-1

# Recover last known change date of batocera.conf (relevant for recovering from reset)
if [ -f "$VAR_CONF_CHANGE_DATE" ]; then
  LAST_CONF_CHANGE_DATE=$(cat $VAR_CONF_CHANGE_DATE)
fi

# Initialize current state variables
CURRENT_MODE=-1
LED_SETTINGS_CHANGE_DETECTED=false

readLedVariables() {

  if [ -f "$VAR_MODE" ] && [ "$LAST_MODE_CHANGE_DATE" != "$(date -r $VAR_MODE)" ]; then
    LAST_LED_MODE=$(cat $VAR_MODE)
    LAST_MODE_CHANGE_DATE=$(date -r $VAR_MODE)
    LED_SETTINGS_CHANGE_DETECTED=true
  fi
  
  if [ -f "$VAR_BRIGHTNESS" ] && [ "$LAST_BRIGHTNESS_CHANGE_DATE" != "$(date -r $VAR_BRIGHTNESS)" ]; then
    LAST_BRIGHTNESS=$(cat $VAR_BRIGHTNESS)
    LAST_BRIGHTNESS_CHANGE_DATE=$(date -r $VAR_BRIGHTNESS)
    LED_SETTINGS_CHANGE_DETECTED=true
  fi
  
  if [ -f "$VAR_SPEED" ] && [ "$LAST_SPEED_CHANGE_DATE" != "$(date -r $VAR_SPEED)" ]; then
    LAST_SPEED=$(cat $VAR_SPEED)
    LAST_SPEED_CHANGE_DATE=$(date -r $VAR_SPEED)
    LED_SETTINGS_CHANGE_DETECTED=true
  fi

  CURRENT_COLOUR_CHANGE_DATE=
  if [ -f "$VAR_COLOUR" ] && [ "$LAST_COLOUR_CHANGE_DATE" != "$(date -r $VAR_COLOUR)" ]; then
    LAST_COLOUR=($(cat $VAR_COLOUR))
    LAST_COLOUR_CHANGE_DATE=$(date -r $VAR_COLOUR)
    LED_SETTINGS_CHANGE_DETECTED=true
  fi

  if [ -f "$VAR_COLOUR_RIGHT" ] && [ "$LAST_COLOUR_RIGHT_CHANGE_DATE" != "$(date -r $VAR_COLOUR_RIGHT)" ]; then
    LAST_COLOUR_RIGHT=($(cat $VAR_COLOUR_RIGHT))
    LAST_COLOUR_RIGHT_CHANGE_DATE=$(date -r $VAR_COLOUR_RIGHT)
    LED_SETTINGS_CHANGE_DETECTED=true
  fi

}

# Sets LED variables to given values.
setLedVariables() {

  echo $1 > $VAR_MODE
  echo $2 > $VAR_BRIGHTNESS
  echo $3 > $VAR_SPEED
  echo "$4 $5 $6" > $VAR_COLOUR
  echo "$7 $8 $9" > $VAR_COLOUR_RIGHT

}

# Clears all LED variables by removing the files.
clearLedVariables() {

  LAST_LED_MODE=-1
  LAST_BRIGHTNESS=-1
  LAST_SPEED=-1
  LAST_COLOUR=-1
  LAST_COLOUR_RIGHT=-1
  LAST_CONF_CHANGE_DATE=-1
  LAST_MODE_CHANGE_DATE=-1
  LAST_BRIGHTNESS_CHANGE_DATE=-1
  LAST_SPEED_CHANGE_DATE=-1
  LAST_COLOUR_CHANGE_DATE=-1
  LAST_COLOUR_RIGHT_CHANGE_DATE=-1

  if [ -f "$VAR_MODE" ]; then
    rm $VAR_MODE
  fi
  
  if [ -f "$VAR_BRIGHTNESS" ]; then
    rm $VAR_BRIGHTNESS
  fi
  
  if [ -f "$VAR_SPEED" ]; then
    rm $VAR_SPEED
  fi

  if [ -f "$VAR_COLOUR" ]; then
    rm $VAR_COLOUR
  fi

  if [ -f "$VAR_COLOUR_RIGHT" ]; then
    rm $VAR_COLOUR_RIGHT
  fi

  if [ -f "$VAR_CONF_CHANGE_DATE" ]; then
    rm $VAR_CONF_CHANGE_DATE
  fi
  
  echo "Removed all variables from previous session."

}

# Function which retrieves latest LED settings from batocera.conf.
# Also puts back valid settings if invalid settings have been made.
# Sets LED_SETTINGS_CHANGE_DETECTED to true if LED settings have
# been changed since last check. 
updateLedSettings() {

  # Read LED settings from batocera.conf
  LED_MODE=$(batocera-settings-get $KEY_LED_MODE)
  BRIGHTNESS=$(batocera-settings-get $KEY_LED_BRIGHTNESS)
  SPEED=$(batocera-settings-get $KEY_LED_SPEED)
  COLOUR=($(batocera-settings-get $KEY_LED_COLOUR))
  COLOUR_RIGHT=($(batocera-settings-get $KEY_LED_COLOUR_RIGHT))

  # Ensure mode is set and within valid range, set to default if not
  if [ -z $LED_MODE ] || [ $LED_MODE -lt 0 ] || [ $LED_MODE -gt 6 ]; then
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

  # Ensure speed is provided for modes 5 and 6 and within the valid range (0-255)
  if [ -z $SPEED ] || [ $SPEED -lt 0 ] || [ $SPEED -gt 255 ]; then
    echo "Invalid or missing LED speed - setting LED speed to default ($DEFAULT_SPEED)"
    batocera-settings-set $KEY_LED_SPEED $DEFAULT_SPEED
    SPEED=$(batocera-settings-get $KEY_LED_SPEED)
  fi

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

  # Determine if any RGB LED setting has changed since last check.
  if [ $LED_MODE -ne $LAST_LED_MODE ] ||
    [ $BRIGHTNESS -ne $LAST_BRIGHTNESS ] || 
    [ $SPEED -ne $LAST_SPEED ] ||
    [ "$(printf "%s" "${COLOUR[*]}")" != "$(printf "%s" "${LAST_COLOUR[*]}")" ] ||
    [ "$(printf "%s" "${COLOUR_RIGHT[*]}")" != "$(printf "%s" "${LAST_COLOUR_RIGHT[*]}")" ]; then
    LED_SETTINGS_CHANGE_DETECTED=true
    echo "Change in RGB LED settings detected!"
    setLedVariables $LED_MODE $BRIGHTNESS $SPEED ${COLOUR[0]} ${COLOUR[1]} ${COLOUR[2]} ${COLOUR_RIGHT[0]} ${COLOUR_RIGHT[1]} ${COLOUR_RIGHT[2]}
  fi

}

# Checks last change date of batocera.conf, checks for LED-related
# changes only if the file has been modified since the last check.
detectRgbChanges() {
  CURRENT_CHANGE_DATE=$(date -r "/userdata/system/batocera.conf")
  # Only check for details if batocera.conf has recently been changed
  if [ "$LAST_CONF_CHANGE_DATE" != "$CURRENT_CHANGE_DATE" ]; then
    LAST_CONF_CHANGE_DATE=$CURRENT_CHANGE_DATE
    echo $CURRENT_CHANGE_DATE > $VAR_CONF_CHANGE_DATE
    echo "Batocera.conf has been changed - updating LED settings."
    readLedVariables
    updateLedSettings
  fi
}

daemon() {
  while :; do
    # Detect RGB changes
    detectRgbChanges
    readLedVariables
  
    # Determine current battery status
    BATTERY_CHARGE=$(cat $KEY_BATTERY_CAPACITY)
    BATTERY_STATUS=$(cat $KEY_BATTERY_STATUS)

    # Go to LED mode "charging" if the battery is currently charging.
    if [ $CURRENT_MODE -ne $MODE_CHARGING ] && [ $BATTERY_STATUS == $BATTERY_CHARGING ] && [ $BATTERY_CHARGE -lt 100 ]; then
      echo "Battery charge at $BATTERY_CHARGE - going to LED mode 'charging'"
      /usr/bin/analog_stick_led.sh $BATTERY_WARNING_MODE $LAST_BRIGHTNESS ${DEFAULT_COLOUR[0]} ${DEFAULT_COLOUR[1]} ${DEFAULT_COLOUR[2]} ${DEFAULT_COLOUR[0]} ${DEFAULT_COLOUR[1]} ${DEFAULT_COLOUR[2]}
      CURRENT_MODE=$MODE_CHARGING

    # Go to LED mode "warning" if not set to warning but battery charge is equal or below warning threshold (and still above danger threshold)
    elif [ $CURRENT_MODE -ne $MODE_WARNING ] && [ $BATTERY_STATUS == $BATTERY_DISCHARGING ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_WARNING ] || ([ $BATTERY_CHARGE -lt $THRESHOLD_WARNING ] && [ $BATTERY_CHARGE -gt $THRESHOLD_DANGER ])); then
      echo "Battery charge at $BATTERY_CHARGE - going to LED mode 'warning'"
      /usr/bin/analog_stick_led.sh $BATTERY_WARNING_MODE $LAST_BRIGHTNESS ${BATTERY_WARNING_COLOUR[0]} ${BATTERY_WARNING_COLOUR[1]} ${BATTERY_WARNING_COLOUR[2]} ${BATTERY_WARNING_COLOUR[0]} ${BATTERY_WARNING_COLOUR[1]} ${BATTERY_WARNING_COLOUR[2]}
      CURRENT_MODE=$MODE_WARNING

    # Go to LED mode "danger" if not set to danger but battery charge is equal or below danger threshold
    elif [ $CURRENT_MODE -ne $MODE_DANGER ] && [ $BATTERY_STATUS == $BATTERY_DISCHARGING ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_DANGER ] || [ $BATTERY_CHARGE -lt $THRESHOLD_DANGER ]); then
      echo "Battery charge at $BATTERY_CHARGE - Going to LED mode 'danger'"
      /usr/bin/analog_stick_led.sh $BATTERY_WARNING_MODE $LAST_BRIGHTNESS ${BATTERY_DANGER_COLOUR[0]} ${BATTERY_DANGER_COLOUR[1]} ${BATTERY_DANGER_COLOUR[2]} ${BATTERY_DANGER_COLOUR[0]} ${BATTERY_DANGER_COLOUR[1]} ${BATTERY_DANGER_COLOUR[2]}
      CURRENT_MODE=$MODE_DANGER

    # Go back to normal LED mode if set to either warning or danger but battery status is above warning threshold
    elif ($LED_SETTINGS_CHANGE_DETECTED || [ $CURRENT_MODE -ne $MODE_DEFAULT ]) && ([ $BATTERY_STATUS == $BATTERY_FULL ] || ([ $BATTERY_STATUS == $BATTERY_DISCHARGING ] && [ $BATTERY_CHARGE -gt $THRESHOLD_WARNING ])); then
      echo "Battery charge at $BATTERY_CHARGE - Going to normal LED mode"
      readLedVariables
      if [ $LAST_LED_MODE -eq 0 ]; then
        /usr/bin/analog_stick_led.sh $LAST_LED_MODE
      elif [ $LAST_LED_MODE -lt 5 ]; then
        /usr/bin/analog_stick_led.sh $LAST_LED_MODE $LAST_BRIGHTNESS ${LAST_COLOUR_RIGHT[0]} ${LAST_COLOUR_RIGHT[1]} ${LAST_COLOUR_RIGHT[2]} ${LAST_COLOUR[0]} ${LAST_COLOUR[1]} ${LAST_COLOUR[2]}
      else
        /usr/bin/analog_stick_led.sh $LAST_LED_MODE $LAST_BRIGHTNESS $LAST_SPEED
      fi
      CURRENT_MODE=$MODE_DEFAULT
      LED_SETTINGS_CHANGE_DETECTED=false
    fi
  
    # Sleep until interval is over
    sleep $UPDATE_INTERVAL_SECONDS
  
  done
}

start() {
  if [ $# -eq 1 ] && [ "$1" == "clear" ]; then
    clearLedVariables
  fi
  daemon &
  PID=$!
  echo $PID > $VAR_PID
  echo "Started analog stick RGB LED daemon."
}

stop() {
  kill $(cat $VAR_PID)
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
  updateLedSettings
elif [ $# -eq 4 ] && [ "$1" == "set" ]; then
  BRIGHTNESS=$(batocera-settings-get $KEY_LED_BRIGHTNESS)
  SPEED=$(batocera-settings-get $KEY_LED_SPEED)
  setLedVariables 1 $BRIGHTNESS $SPEED $2 $3 $4 $2 $3 $4
else 
  echo "Usage: $0 <start|stop|restart|set [r g b]>"
fi
