#!/bin/bash
# check-flatpak-updates.sh
# Checks for available Flatpak updates and saves the result

STATE_FILE="$HOME/.cache/flatpak-updater/state"
COUNT_FILE="$HOME/.cache/flatpak-updater/count"

mkdir -p "$HOME/.cache/flatpak-updater"

# Fetch list of available updates
# Ignore network errors from unavailable remotes (e.g. kde-applications)
UPDATES=$(flatpak remote-ls --updates --columns=application 2>&1 | grep -v '^error:' | grep '\S')
COUNT=$(echo "$UPDATES" | grep '\S' | wc -l)

if [ "$COUNT" -gt 0 ]; then
    echo "updates_available" > "$STATE_FILE"
    echo "$COUNT" > "$COUNT_FILE"
else
    echo "up_to_date" > "$STATE_FILE"
    echo "0" > "$COUNT_FILE"
fi

