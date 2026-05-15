# Flatpak Updater

A GNOME Shell extension that shows a top bar indicator when Flatpak updates are available.

## Features

- Orange icon in the top bar when updates are available
- Right-click menu to install updates or trigger an immediate check
- Updates are checked automatically every 30 minutes via crontab
- Installs and runs silently in the background

## Requirements

- GNOME Shell 45 or later
- Flatpak

## Installation

```bash
git clone https://github.com/baktus79/flatpak-updater.git
cd flatpak-updater
bash install.sh
```

Then restart GNOME Shell:
- **X11:** Press `Alt+F2`, type `r`, press Enter
- **Wayland:** Log out and back in

## Uninstallation

```bash
bash uninstall.sh
```

## License

GPL-2.0-or-later
