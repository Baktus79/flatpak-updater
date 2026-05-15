#!/bin/bash
# check-flatpak-updates.sh
# Sjekker om det finnes flatpak-oppdateringer og lagrer resultatet

STATE_FILE="$HOME/.cache/flatpak-updater/state"
COUNT_FILE="$HOME/.cache/flatpak-updater/count"

mkdir -p "$HOME/.cache/flatpak-updater"

# Hent liste over tilgjengelige oppdateringer
# Ignorer nettverksfeil fra utilgjengelige remotes (f.eks. kde-applications)
UPDATES=$(flatpak remote-ls --updates --columns=application 2>&1 | grep -v '^error:' | grep '\S')
COUNT=$(echo "$UPDATES" | grep -c '\S' 2>/dev/null || echo 0)

if [ "$COUNT" -gt 0 ]; then
    echo "updates_available" > "$STATE_FILE"
    echo "$COUNT" > "$COUNT_FILE"
else
    echo "up_to_date" > "$STATE_FILE"
    echo "0" > "$COUNT_FILE"
fi

