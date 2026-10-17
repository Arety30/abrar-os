#!/usr/bin/env bash
# Dyverz Terminal installer.
#   sudo ./install.sh          → live system: pacman deps + files, then activates dconf/systemd bits
#   ./install.sh /path/to/root → ISO build (archiso customize step): files only, no network, no pacman
# Packages needed: vte4 python-gobject libadwaita distrobox podman ttf-cascadia-code ipython
set -euo pipefail
cd "$(dirname "$0")"
ROOT=${1:-/}; ROOT=${ROOT%/}   # "" means live root
if [[ -z $ROOT ]]; then
  pacman -S --needed --noconfirm vte4 python-gobject libadwaita distrobox podman ttf-cascadia-code ipython
fi
install -Dm755 dyverz-terminal "$ROOT/usr/local/bin/dyverz-terminal"
install -Dm755 dyverz-shell    "$ROOT/usr/local/bin/dyverz-shell"
install -Dm755 dyverz-subids   "$ROOT/usr/local/bin/dyverz-subids"
install -Dm644 dyverz-subids.service "$ROOT/etc/systemd/system/dyverz-subids.service"
install -Dm644 settings.json   "$ROOT/etc/dyverz/terminal.json"
install -Dm644 os.dyverz.Terminal.desktop "$ROOT/usr/share/applications/os.dyverz.Terminal.desktop"
# default terminal + Ctrl+Alt+T for GNOME / Cinnamon (dconf system db); KDE reads X-KDE-Shortcuts from the .desktop
mkdir -p "$ROOT/etc/dconf/db/local.d" "$ROOT/etc/dconf/profile" "$ROOT/etc/xdg"
grep -qs '^system-db:local' "$ROOT/etc/dconf/profile/user" || printf 'user-db:user\nsystem-db:local\n' > "$ROOT/etc/dconf/profile/user"
cat > "$ROOT/etc/dconf/db/local.d/20-dyverz-terminal" <<'D'
[org/gnome/desktop/default-applications/terminal]
exec='dyverz-terminal'
[org/cinnamon/desktop/default-applications/terminal]
exec='dyverz-terminal'
[org/gnome/settings-daemon/plugins/media-keys]
custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/dyverz-terminal/']
[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/dyverz-terminal]
name='Dyverz Terminal'
command='dyverz-terminal'
binding='<Control><Alt>t'
D
echo "os.dyverz.Terminal.desktop" > "$ROOT/etc/xdg/xdg-terminals.list"
# enable the sub-ID service (symlink works for an offline target root too)
mkdir -p "$ROOT/etc/systemd/system/multi-user.target.wants"
ln -sf /etc/systemd/system/dyverz-subids.service "$ROOT/etc/systemd/system/multi-user.target.wants/dyverz-subids.service"
if [[ -z $ROOT ]]; then
  dconf update; update-desktop-database /usr/share/applications 2>/dev/null || true
  systemctl daemon-reload; systemctl start dyverz-subids.service
  echo "Dyverz Terminal installed (live). Ubuntu/Kali containers are created on first use."
else
  echo "Dyverz Terminal files installed into $ROOT (no pacman run; add vte4 python-gobject libadwaita distrobox podman ttf-cascadia-code ipython to the package list)."
fi
