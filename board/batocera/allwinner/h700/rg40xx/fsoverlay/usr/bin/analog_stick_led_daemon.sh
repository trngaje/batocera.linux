#!/bin/bash

# Sleep interval for daemon
UPDATE_INTERVAL_SECONDS=60

# Battery charge thresholds (inclusive) for warning/danger
THRESHOLD_WARNING=20
THRESHOLD_DANGER=5

# Constants for different modes
MODE_WARNING=2
MODE_DANGER=1
MODE_DEFAULT=0

CURRENT_MODE=-1

daemon() {
  while :; do
  
    # Determine current battery charge
    BATTERY_CHARGE=$(batocera-info | grep "Battery" | sed -e "s/^Battery: //" -e "s/%$//")
  
    # Go to LED mode "warning" if not set to warning but battery charge is equal or below warning threshold (and still above danger threshold)
    if [ $CURRENT_MODE -ne $MODE_WARNING ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_WARNING ] || ([ $BATTERY_CHARGE -lt $THRESHOLD_WARNING ] && [ $BATTERY_CHARGE -gt $THRESHOLD_DANGER ])); then
      echo "Battery charge at $BATTERY_CHARGE - going to LED mode 'warning'"
      analog_stick_led.sh warn
      CURRENT_MODE=$MODE_WARNING
    # Go to LED mode "danger" if not set to danger but battery charge is equal or below danger threshold
    elif [ $CURRENT_MODE -ne $MODE_DANGER ] && ([ $BATTERY_CHARGE -eq $THRESHOLD_DANGER ] || [ $BATTERY_CHARGE -lt $THRESHOLD_DANGER ]); then
      echo "Battery charge at $BATTERY_CHARGE - Going to LED mode 'danger'"
      analog_stick_led.sh danger
      CURRENT_MODE=$MODE_DANGER
    # Go back to normal LED mode if set to either warning or danger but battery status is above warning threshold
    elif [ $CURRENT_MODE -ne $MODE_DEFAULT ] && [ $BATTERY_CHARGE -gt $THRESHOLD_WARNING ]; then
      echo "Battery charge at $BATTERY_CHARGE - Going to normal LED mode"
      analog_stick_led.sh
      CURRENT_MODE=$MODE_DEFAULT
    fi
  
    # Sleep until interval is over
    sleep $UPDATE_INTERVAL_SECONDS
  
  done
}

start() {
  daemon &
  PID=$!
  echo $PID > /var/run/$0.pid
  echo "Started analog stick RGB LED daemon."
}

stop() {
  kill $(cat /var/run/$0.pid)
  analog_stick_led.sh off
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

