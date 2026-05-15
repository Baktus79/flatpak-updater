#!/bin/bash
# #!/bin/bash
# install.sh – Installs the flatpak-updater extension and sets up crontab

EXT_UUID="flatpak-updater@baktus79"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"
SCRIPT_DIR="$HOME/.local/share/flatpak-updater"
CACHE_DIR="$HOME/.cache/flatpak-updater"
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

echo "=== Flatpak Updater – Installation ==="
echo ""

# Create directories
echo "→ Creating directories..."
mkdir -p "$EXT_DIR/icons"
mkdir -p "$SCRIPT_DIR"
mkdir -p "$CACHE_DIR"

# Copy extension files
echo "→ Copying GNOME Shell extension..."
cp "$SCRIPT_PATH/extension.js" "$EXT_DIR/"
cp "$SCRIPT_PATH/metadata.json" "$EXT_DIR/"

# Copy icon
if [ -d "$SCRIPT_PATH/icons" ]; then
    cp "$SCRIPT_PATH/icons/"* "$EXT_DIR/icons/"
fi

# Copy scripts
echo "→ Copying scripts..."
cp "$SCRIPT_PATH/scripts/check-flatpak-updates.sh" "$SCRIPT_DIR/"
cp "$SCRIPT_PATH/scripts/install-flatpak-updates.sh" "$SCRIPT_DIR/"
chmod +x "$SCRIPT_DIR/check-flatpak-updates.sh"
chmod +x "$SCRIPT_DIR/install-flatpak-updates.sh"

# Initialize state files
echo "up_to_date" > "$CACHE_DIR/state"
echo "0" > "$CACHE_DIR/count"

# Set up crontab
echo "→ Setting up crontab..."
CRON_CMD="*/30 * * * * bash $SCRIPT_DIR/check-flatpak-updates.sh"
( crontab -l 2>/dev/null | grep -v "flatpak-updater" ; echo "$CRON_CMD" ) | crontab - && \
    echo "   Crontab set to: every 30 minutes" || \
    echo "   WARNING: Could not set up crontab – please do it manually."

# Enable extension
echo "→ Enabling GNOME Shell extension..."
if command -v gnome-extensions &>/dev/null; then
    gnome-extensions enable "$EXT_UUID" 2>/dev/null && \
        echo "   Extension enabled." || \
        echo "   WARNING: Could not enable automatically."
else
    echo "   gnome-extensions not found."
fi

# Run first check
echo "→ Running first check..."
bash "$SCRIPT_DIR/check-flatpak-updates.sh"

echo ""
echo "=== Installation complete! ==="
echo ""
echo "────────────────────────────────────────"
echo " IMPORTANT: You must restart GNOME Shell"
echo " X11:     Alt+F2 → r → Enter"
echo " Wayland: Log out and back in"
echo ""
echo " Manual activation (if needed):"
echo "   gnome-extensions enable $EXT_UUID"
echo "────────────────────────────────────────"
echo ""
