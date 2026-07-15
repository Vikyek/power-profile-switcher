#!/usr/bin/env bash

# Get current profile
current=$(powerprofilesctl get)

# Cycle to next profile
if [ "$current" = "balanced" ]; then
    next="performance"
    label="Performance Mode"
    icon="⚡"
elif [ "$current" = "performance" ]; then
    next="power-saver"
    label="Power Saver Mode"
    icon="🔋"
else
    next="balanced"
    label="Balanced Mode"
    icon="⚖️"
fi

# Set the new profile
powerprofilesctl set "$next"

# Notify user using only the summary argument (no body, hence no newline)
notify-send -t 1200 -h string:x-canonical-private-synchronous:power-profile "$icon  $label"

# Signal waybar to update the custom module
pkill -RTMIN+8 waybar
