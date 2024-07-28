#!/bin/bash

# Sleep interval for daemon
UPDATE_INTERVAL_SECONDS=60

# Battery charge thresholds (inclusive) for warning/danger
THRESHOLD_WARNING=20
THRESHOLD_DANGER=5

# Currently active modes
MODE_WARNING=false
MODE_DANGER=false

while :; do

  # Determine current battery charge
  BATTERY_CHARGE=$(batocera-info | grep "Battery" | sed -e "s/^Battery: //" -e "s/%$//")

  # Go to LED mode "warning" if not set to warning but battery charge is equal or below warning threshold (and still above danger threshold)
  if [ "$MODE_WARNING" = false ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_WARNING ] || ([ $BATTERY_CHARGE -lt $THRESHOLD_WARNING ] && [ $BATTERY_CHARGE -gt $THRESHOLD_DANGER ])); then
    echo "Battery charge at $BATTERY_CHARGE - going to LED mode 'warning'"
    analog_stick_led.sh warn
	MODE_DANGER=false
	MODE_WARNING=true
  # Go to LED mode "danger" if not set to danger but battery charge is equal or below danger threshold
  elif [ "$MODE_DANGER" = false ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_DANGER ] || [ $BATTERY_CHARGE -lt $THRESHOLD_DANGER ]); then
    echo "Battery charge at $BATTERY_CHARGE - Going to LED mode 'danger'"
    analog_stick_led.sh danger
	MODE_DANGER=true
	MODE_WARNING=false
  # Go back to normal LED mode if set to either warning or danger but battery status is above warning threshold
  elif ([ "$MODE_WARNING" = true ] || [ "$MODE_DANGER" = true ]) && [ $BATTERY_CHARGE -gt $THRESHOLD_WARNING ]; then
    echo "Battery charge at $BATTERY_CHARGE - Going to normal LED mode"
    analog_stick_led.sh
    MODE_DANGER=false
	MODE_WARNING=false
  else
    echo "Battery charge at $BATTERY_CHARGE - no mode change required"
  fi

  # Sleep until interval is over
  sleep $UPDATE_INTERVAL_SECONDS

done
