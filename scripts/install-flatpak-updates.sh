#!/bin/bash
# install-flatpak-updates.sh
# Installerer flatpak-oppdateringer i bakgrunnen

STATE="$HOME/.cache/flatpak-updater/state"
COUNT="$HOME/.cache/flatpak-updater/count"
LOG="$HOME/.cache/flatpak-updater/install.log"

flatpak update -y > "$LOG" 2>&1

echo "up_to_date" > "$STATE"
echo "0" > "$COUNT"