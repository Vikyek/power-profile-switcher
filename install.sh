#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define color codes for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Power Profile Switcher Installer ===${NC}"

# 1. Dependency Checking
dependencies=("powerprofilesctl" "waybar" "notify-send" "hyprctl")
missing_deps=0

echo "Checking system dependencies..."
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo -e "  [${RED}✗${NC}] Missing dependency: $dep"
        missing_deps=$((missing_deps + 1))
    else
        echo -e "  [${GREEN}✓${NC}] Found: $dep"
    fi
done

if [ $missing_deps -ne 0 ]; then
    echo -e "\n${RED}Error: Missing dependencies. Please install the required packages before continuing.${NC}"
    echo "Tip: Install power-profiles-daemon, waybar, libnotify, and hyprland."
    exit 1
fi

echo -e "${GREEN}All dependencies met!${NC}"

# 2. Target Directories Creation
WAYBAR_DIR="$HOME/.config/waybar"
HYPR_DIR="$HOME/.config/hypr"

echo -e "\nCreating configuration directories..."
mkdir -p "$WAYBAR_DIR/scripts"
mkdir -p "$HYPR_DIR/scripts"

# 3. Copying Source Files
echo "Installing helper scripts..."
cp src/config/waybar/scripts/powerprofile.sh "$WAYBAR_DIR/scripts/powerprofile.sh"
cp src/config/waybar/power_profile_menu.xml "$WAYBAR_DIR/power_profile_menu.xml"
cp src/config/hypr/scripts/set_power_profile.sh "$HYPR_DIR/scripts/set_power_profile.sh"
cp src/config/hypr/scripts/toggle_power_profile.sh "$HYPR_DIR/scripts/toggle_power_profile.sh"

# Make scripts executable
chmod +x "$WAYBAR_DIR/scripts/powerprofile.sh"
chmod +x "$HYPR_DIR/scripts/set_power_profile.sh"
chmod +x "$HYPR_DIR/scripts/toggle_power_profile.sh"

echo -e "${GREEN}Scripts successfully copied and marked executable.${NC}"

# 4. Configure files
echo -e "\nIntegrating configurations..."

# We use Python to parse and update the Waybar config safely
python3 - <<EOF
import json
import os

waybar_config_path = os.path.expanduser("~/.config/waybar/config")

if os.path.exists(waybar_config_path):
    print("  Reading Waybar config...")
    try:
        with open(waybar_config_path, 'r') as f:
            data = json.load(f)
        
        # Add custom/powerprofile to modules-right if not present
        modules_right = data.get("modules-right", [])
        if "custom/powerprofile" not in modules_right:
            # Place next to idle_inhibitor if found, else append at end
            if "idle_inhibitor" in modules_right:
                idx = modules_right.index("idle_inhibitor")
                modules_right.insert(idx + 1, "custom/powerprofile")
            else:
                modules_right.append("custom/powerprofile")
            data["modules-right"] = modules_right
            print("  Added 'custom/powerprofile' next to 'idle_inhibitor' in modules-right.")
        
        # Add custom/powerprofile module configuration
        user_home = os.path.expanduser("~")
        data["custom/powerprofile"] = {
            "exec": "~/.config/waybar/scripts/powerprofile.sh",
            "interval": 30,
            "format": "{}",
            "menu": "on-click",
            "menu-file": f"{user_home}/.config/waybar/power_profile_menu.xml",
            "menu-actions": {
                "balanced": f"{user_home}/.config/hypr/scripts/set_power_profile.sh balanced",
                "performance": f"{user_home}/.config/hypr/scripts/set_power_profile.sh performance",
                "power-saver": f"{user_home}/.config/hypr/scripts/set_power_profile.sh power-saver"
            },
            "signal": 8,
            "return-type": "json",
            "tooltip": true
        }
        
        with open(waybar_config_path, 'w') as f:
            json.dump(data, f, indent=4)
        print("  Waybar module configuration successfully integrated.")
    except Exception as e:
        print(f"  Warning: Failed to automatically edit Waybar config: {e}")
        print("  Please manually add the module as shown in the README.")
else:
    print(f"  Warning: {waybar_config_path} not found. Skipping automatic integration.")
EOF

# Integrate style.css
WAYBAR_STYLE_PATH="$WAYBAR_DIR/style.css"
if [ -f "$WAYBAR_STYLE_PATH" ]; then
    if ! grep -q "#custom-powerprofile" "$WAYBAR_STYLE_PATH"; then
        echo -e "\n#custom-powerprofile{\n   color:#88c0d0;\n}" >> "$WAYBAR_STYLE_PATH"
        echo "  Added CSS style definition for #custom-powerprofile to style.css."
        
        # Attempt to add to main selector list for padding/border
        # Simple replace if standard list is found
        sed -i 's/#custom-power,/#custom-power,#custom-powerprofile,/g' "$WAYBAR_STYLE_PATH"
    fi
else
    echo "  Warning: style.css not found. Skipping CSS integration."
fi

# Integrate Hyprland Bind
HYPR_CONF_PATH="$HYPR_DIR/hyprland.conf"
if [ -f "$HYPR_CONF_PATH" ]; then
    if ! grep -q "toggle_power_profile.sh" "$HYPR_CONF_PATH"; then
        echo -e "\n# Power profile switcher shortcut\nbind = SUPER, Y, exec, ~/.config/hypr/scripts/toggle_power_profile.sh" >> "$HYPR_CONF_PATH"
        echo "  Added keybinding (SUPER + Y) to hyprland.conf."
    fi
else
    echo "  Warning: hyprland.conf not found. Skipping binding integration."
fi

# 5. Reload Services
echo -e "\nReloading configurations..."
if pgrep waybar > /dev/null; then
    killall -USR2 waybar || true
    echo "  Waybar config reloaded."
fi

if pgrep Hyprland > /dev/null; then
    hyprctl reload || true
    echo "  Hyprland config reloaded."
fi

echo -e "\n${GREEN}=== Installation Complete! ===${NC}"
echo "Use SUPER + Y to cycle profiles, or click the power profile icon on your status bar to open the GTK menu."
