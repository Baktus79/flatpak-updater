import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import St from 'gi://St';
import Clutter from 'gi://Clutter';
import GObject from 'gi://GObject';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';

const STATE_FILE = GLib.get_home_dir() + '/.cache/flatpak-updater/state';
const COUNT_FILE = GLib.get_home_dir() + '/.cache/flatpak-updater/count';
const CHECK_SCRIPT = GLib.get_home_dir() + '/.local/share/flatpak-updater/check-flatpak-updates.sh';
const INSTALL_SCRIPT = GLib.get_home_dir() + '/.local/share/flatpak-updater/install-flatpak-updates.sh';

const FlatpakIndicator = GObject.registerClass(
class FlatpakIndicator extends PanelMenu.Button {
    _init(extension) {
        super._init(0.0, 'Flatpak Updater');
        this._extension = extension;
        this._updateCount = 0;
        this._timeoutId = null;

        this._buildUI();
        this._watchStateFile();
        this._readState();

        // Fallback poll every 5 minutes
        this._timeoutId = GLib.timeout_add_seconds(
            GLib.PRIORITY_DEFAULT,
            300,
            () => {
                this._readState();
                return GLib.SOURCE_CONTINUE;
            }
        );
    }

    _buildUI() {
        this._box = new St.BoxLayout({});

        this._icon = new St.Icon({
            gicon: Gio.icon_new_for_string(this._extension.path + '/icons/flatpak-update-symbolic.svg'),
            style_class: 'system-status-icon',
            style: 'color: orange;',
        });

        this._box.add_child(this._icon);
        this.add_child(this._box);

        this.hide();
        this._buildMenu();
    }

    _buildMenu() {
        this._menuTitle = new PopupMenu.PopupMenuItem('Flatpak updates', {
            reactive: false,
        });
        this.menu.addMenuItem(this._menuTitle);
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        const installItem = new PopupMenu.PopupMenuItem('📦 Install updates');
        installItem.connect('activate', () => {
            this.menu.close();
            this._installUpdates();
        });
        this.menu.addMenuItem(installItem);

        const checkItem = new PopupMenu.PopupMenuItem('🔄 Check now');
        checkItem.connect('activate', () => {
            this.menu.close();
            this._checkNow();
        });
        this.menu.addMenuItem(checkItem);
    }

    _watchStateFile() {
        try {
            const file = Gio.File.new_for_path(STATE_FILE);
            const dir = file.get_parent();

            if (!dir.query_exists(null))
                dir.make_directory_with_parents(null);

            this._monitor = file.monitor_file(Gio.FileMonitorFlags.NONE, null);
            this._monitor.connect('changed', () => {
                GLib.idle_add(GLib.PRIORITY_DEFAULT, () => {
                    this._readState();
                    return GLib.SOURCE_REMOVE;
                });
            });
        } catch (e) {
            logError(e, 'FlatpakUpdater: Could not monitor state file');
        }
    }

    _readState() {
        try {
            const [ok, contents] = GLib.file_get_contents(STATE_FILE);
            if (!ok) return;

            const state = new TextDecoder().decode(contents).trim();

            let count = 0;
            try {
                const [cok, ccontents] = GLib.file_get_contents(COUNT_FILE);
                if (cok) count = parseInt(new TextDecoder().decode(ccontents).trim()) || 0;
            } catch (_) {}

            this._updateCount = count;
            this._updateDisplay(state === 'updates_available' && count > 0);
        } catch (_) {}
    }

    _updateDisplay(hasUpdates) {
        if (hasUpdates) {
            const txt = this._updateCount === 1
                ? '1 update available'
                : `${this._updateCount} updates available`;
            this._menuTitle.label.set_text(txt);
            this.show();
        } else {
            this.hide();
        }
    }

    _installUpdates() {
        try {
            GLib.spawn_command_line_async(`bash ${INSTALL_SCRIPT}`);
        } catch (e) {
            logError(e, 'FlatpakUpdater: Could not run install script');
        }
    }

    _checkNow() {
        try {
            GLib.spawn_command_line_async(`bash ${CHECK_SCRIPT}`);
        } catch (e) {
            logError(e, 'FlatpakUpdater: Could not run check script');
        }
    }

    destroy() {
        if (this._timeoutId) {
            GLib.source_remove(this._timeoutId);
            this._timeoutId = null;
        }
        if (this._monitor) {
            this._monitor.cancel();
            this._monitor = null;
        }
        super.destroy();
    }
});

export default class FlatpakUpdaterExtension extends Extension {
    enable() {
        this._indicator = new FlatpakIndicator(this);
        Main.panel.addToStatusArea(this.uuid, this._indicator);
    }

    disable() {
        this._indicator?.destroy();
        this._indicator = null;
    }
}
