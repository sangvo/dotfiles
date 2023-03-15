#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use
# polybar-msg cmd quit

PRIMARY=$(xrandr --query | grep " connected" | grep "primary" | cut -d" " -f1)
OTHERS=$(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1)

# Launch on primary monitor
MONITOR=$PRIMARY polybar --reload main &
sleep 1

# Launch on all other monitors
for m in $OTHERS; do
 MONITOR=$m polybar --reload rightbar &
done

echo "Bars launched..."
