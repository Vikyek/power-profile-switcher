# Waybar Power Profile Switcher

A native, lightweight GTK-based dropdown menu and keyboard shortcut daemon for switching power profiles (Performance, Balanced, Power Saver) in a Waybar + Hyprland setup.

## Features

* ⚡ **GTK Dropdown Menu**: Left-clicking the status bar module displays a native GTK popup menu next to your status bar.
* ⌨️ **Keyboard Shortcut (`SUPER + Y`)**: Cycle through profiles instantly using your keyboard.
* 🔋 **Status Indicators**: Dynamically updates the status bar icon (`⚡` / `⚖️` / `🔋`) and shows active mode in the tooltip upon hover.
* 💬 **Synchronous Notifications**: Displays a clean, single-line desktop notification that updates in-place when cycling modes (no desktop notification clutter).
* 👤 **Author**: Vikyek <vika.jedr@gmail.com>

---

## Dependencies

This utility relies on the following components:

* **`power-profiles-daemon`** (provides `powerprofilesctl` for CPU governor power management)
* **`waybar`** (the status bar panel)
* **`libnotify`** (provides `notify-send` for displaying OSD indicators)
* **`hyprland`** (window manager for handling binds and reloads)

---

## Installation

1. **Clone and Navigate to the Repository Directory**:
   
   ```bash
   git clone https://github.com/Vikyek/power-profile-switcher.git
   cd power-profile-switcher
   ```

2. **Run the Installer**:
   
   ```bash
   ./install.sh
   ```

The script will automatically check for all dependencies, copy files to their respective configuration folders, and integrate the setups for you.

---

## Manual Configuration (For Reference)

If the installer skipped your configuration files or if you want to set things up manually, follow these steps:

### 1. File Placements

Ensure files are placed in these locations and made executable:

* Waybar script: `~/.config/waybar/scripts/powerprofile.sh`
* GTK menu definition: `~/.config/waybar/power_profile_menu.xml`
* Switch script: `~/.config/hypr/scripts/set_power_profile.sh`
* Cycle script: `~/.config/hypr/scripts/toggle_power_profile.sh`

### 2. Waybar Configuration (`~/.config/waybar/config`)

Add `custom/powerprofile` to your list of modules (e.g. inside `modules-right`):

```json
"modules-right": [
    ...
    "idle_inhibitor",
    "custom/powerprofile",
    "clock",
    ...
]
```

Define the custom module settings:

```json
"custom/powerprofile": {
    "exec": "~/.config/waybar/scripts/powerprofile.sh",
    "interval": 30,
    "format": "{}",
    "menu": "on-click",
    "menu-file": "/home/YOUR_USERNAME/.config/waybar/power_profile_menu.xml",
    "menu-actions": {
        "balanced": "/home/YOUR_USERNAME/.config/hypr/scripts/set_power_profile.sh balanced",
        "performance": "/home/YOUR_USERNAME/.config/hypr/scripts/set_power_profile.sh performance",
        "power-saver": "/home/YOUR_USERNAME/.config/hypr/scripts/set_power_profile.sh power-saver"
    },
    "signal": 8,
    "return-type": "json",
    "tooltip": true
}
```

*(Replace `YOUR_USERNAME` with your actual username, as Waybar requires absolute paths for native GTK menus.)*

### 3. Waybar Styling (`~/.config/waybar/style.css`)

Append the styling to the end of your stylesheet:

```css
#custom-powerprofile {
    color: #88c0d0; /* Frost Cyan */
}
```

### 4. Hyprland Keybind (`~/.config/hypr/hyprland.conf`)

Add a bind directive under your bindings section:

```ini
bind = SUPER, Y, exec, ~/.config/hypr/scripts/toggle_power_profile.sh
```

Finally, reload Waybar (`killall -USR2 waybar`) and Hyprland (`hyprctl reload`) to apply changes.
