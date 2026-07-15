#!/usr/bin/env bash

current=$(powerprofilesctl get)

case "$current" in
    performance)
        icon="⚡"
        label="Performance Mode"
        class="performance"
        ;;
    power-saver)
        icon="🔋"
        label="Power Saver Mode"
        class="power-saver"
        ;;
    *)
        icon="⚖️"
        label="Balanced Mode"
        class="balanced"
        ;;
esac

# Output JSON for Waybar
echo "{\"text\": \"$icon\", \"tooltip\": \"<b>$label</b>\", \"class\": \"$class\"}"
