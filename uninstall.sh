#!/bin/bash
# uninstall.sh – Removes flatpak-updater

EXT_UUID="flatpak-updater@baktus79"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"
SCRIPT_DIR="$HOME/.local/share/flatpak-updater"
CACHE_DIR="$HOME/.cache/flatpak-updater"

echo "=== Uninstalling Flatpak Updater ==="

gnome-extensions disable "$EXT_UUID" 2>/dev/null || true
rm -rf "$EXT_DIR"
rm -rf "$SCRIPT_DIR"
rm -rf "$CACHE_DIR"

# Remove from crontab
( crontab -l 2>/dev/null | grep -v "flatpak-updater" ) | crontab -

echo "Done. Restart GNOME Shell to remove the icon."
echo " X11:     Alt+F2 → r → Enter"
echo " Wayland: Log out and back in"
