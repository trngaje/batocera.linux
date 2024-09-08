#!/bin/bash

# Define some keys for batocera.conf
KEY_LED_MODE="led.mode"
KEY_BRIGHTNESS="led.brightness"
KEY_SPEED="led.speed"
KEY_LED_COLOUR="led.colour"
KEY_LED_COLOUR_RIGHT="led.colour.right"

# Last known RGB settings
LAST_LED_MODE=-1
LAST_BRIGHTNESS=-1
LAST_SPEED=-1
LAST_COLOUR=-1
LAST_COLOUR_RIGHT=-1

# Last change date
LAST_CHANGE_DATE=-1

# Sleep interval for daemon
UPDATE_INTERVAL_SECONDS=1

# Battery charge thresholds (inclusive) for warning/danger
THRESHOLD_WARNING=20
THRESHOLD_DANGER=5

# Constants for different modes
MODE_WARNING=2
MODE_DANGER=1
MODE_DEFAULT=0

CURRENT_MODE=-1
RGB_CHANGE_DETECTED=false

detectRgbChanges() {
	CURRENT_CHANGE_DATE=$(date -r "/userdata/system/batocera.conf")
	# Only check for details if batocera.conf has recently been changed
	if [ "$LAST_CHANGE_DATE" != "$CURRENT_CHANGE_DATE" ]; then
		LAST_CHANGE_DATE=$CURRENT_CHANGE_DATE
		LED_MODE=$(batocera-settings-get $KEY_LED_MODE)
		BRIGHTNESS=$(batocera-settings-get $KEY_BRIGHTNESS)
		SPEED=$(batocera-settings-get $KEY_SPEED)
		COLOUR=($(batocera-settings-get $KEY_LED_COLOUR))
		COLOUR_RIGHT=($(batocera-settings-get $KEY_LED_COLOUR_RIGHT))
		if [ $LED_MODE -ne $LAST_LED_MODE ] ||
			[ $BRIGHTNESS -ne $LAST_BRIGHTNESS ] || 
			[ $SPEED -ne $LAST_SPEED ] ||
			[ "$(printf "%s" "${COLOUR[*]}")" != "$(printf "%s" "${LAST_COLOUR[*]}")" ] ||
			[ "$(printf "%s" "${COLOUR_RIGHT[*]}")" != "$(printf "%s" "${LAST_COLOUR_RIGHT[*]}")" ]; then
			RGB_CHANGE_DETECTED=true
			echo "Change in RGB LED settings detected!"
		fi
		LAST_LED_MODE=$LED_MODE
		LAST_BRIGHTNESS=$BRIGHTNESS
		LAST_SPEED=$SPEED
		LAST_COLOUR=$COLOUR
		LAST_COLOUR_RIGHT=$COLOUR_RIGHT
	fi
}

daemon() {
  while :; do
  	# Detect RGB changes
  	detectRgbChanges
  
    # Determine current battery charge
    BATTERY_CHARGE=$(batocera-info | grep "Battery" | sed -e "s/^Battery: //" -e "s/%$//")
  
    # Go to LED mode "warning" if not set to warning but battery charge is equal or below warning threshold (and still above danger threshold)
    if [ $CURRENT_MODE -ne $MODE_WARNING ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_WARNING ] || ([ $BATTERY_CHARGE -lt $THRESHOLD_WARNING ] && [ $BATTERY_CHARGE -gt $THRESHOLD_DANGER ])); then
      echo "Battery charge at $BATTERY_CHARGE - going to LED mode 'warning'"
      /usr/bin/analog_stick_led.sh warn
      CURRENT_MODE=$MODE_WARNING
    # Go to LED mode "danger" if not set to danger but battery charge is equal or below danger threshold
    elif [ $CURRENT_MODE -ne $MODE_DANGER ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_DANGER ] || [ $BATTERY_CHARGE -lt $THRESHOLD_DANGER ]); then
      echo "Battery charge at $BATTERY_CHARGE - Going to LED mode 'danger'"
      /usr/bin/analog_stick_led.sh danger
      CURRENT_MODE=$MODE_DANGER
    # Go back to normal LED mode if set to either warning or danger but battery status is above warning threshold
    elif ($RGB_CHANGE_DETECTED || [ $CURRENT_MODE -ne $MODE_DEFAULT ]) && [ $BATTERY_CHARGE -gt $THRESHOLD_WARNING ]; then
      echo "Battery charge at $BATTERY_CHARGE - Going to normal LED mode"
      /usr/bin/analog_stick_led.sh
      CURRENT_MODE=$MODE_DEFAULT
      RGB_CHANGE_DETECTED=false
    fi
  
    # Sleep until interval is over
    sleep $UPDATE_INTERVAL_SECONDS
  
  done
}

start() {
  daemon &
  PID=$!
  echo $PID > /var/run/analog_stick_led_daemon.pid
  echo "Started analog stick RGB LED daemon."
}

stop() {
  kill $(cat /var/run/analog_stick_led_daemon.pid)
  /usr/bin/analog_stick_led.sh off
  echo "Stopped analog stick RGB LED daemon."
}

restart() {
  stop
  start
}

if [ $# -eq 0 ]; then
  echo "Usage: $0 <start|stop|restart>"
  exit 1
elif [ "$1" == "start" ]; then
  start
elif [ "$1" == "stop" ]; then
  stop
elif [ "$1" == "restart" ]; then
  restart
else 
  echo "Usage: $0 <start|stop|restart|status>"
fi

