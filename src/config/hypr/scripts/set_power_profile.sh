#!/usr/bin/env bash

next="$1"

if [ "$next" = "performance" ]; then
    label="Performance Mode"
    icon="⚡"
elif [ "$next" = "power-saver" ]; then
    label="Power Saver Mode"
    icon="🔋"
else
    next="balanced"
    label="Balanced Mode"
    icon="⚖️"
fi

# Set the profile
powerprofilesctl set "$next"

# Send notification (no newline)
notify-send -t 1200 -h string:x-canonical-private-synchronous:power-profile "$icon  $label"

# Signal waybar
pkill -RTMIN+8 waybar
