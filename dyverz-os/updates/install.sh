#!/usr/bin/env bash
# Install the Dyverz Update Manager component into $1 (target root; "/" on a live system). Run as root.
set -euo pipefail
T=${1:-/}; H=$(cd "$(dirname "$0")" && pwd)
install -d "$T/usr/local/bin" "$T/etc/systemd/system" "$T/etc/systemd/user" "$T/usr/local/share/applications" "$T/etc/polkit-1/rules.d" "$T/etc/dyverz"
install -m755 "$H/dyverz-update" "$H/dyverz-update-gui" "$T/usr/local/bin/"
install -m644 "$H/dyverz-update-download.service" "$H/dyverz-update-download.timer" "$T/etc/systemd/system/"
install -m644 "$H/dyverz-update.service" "$H/dyverz-update.timer" "$T/etc/systemd/user/"
install -m644 "$H/dyverz-update.desktop" "$T/usr/local/share/applications/"
install -m644 "$H/polkit-dyverz.rules" "$T/etc/polkit-1/rules.d/50-dyverz.rules"
[[ -f $T/etc/dyverz/updates.conf ]] || echo "mode=ask" > "$T/etc/dyverz/updates.conf"
systemctl --root="$T" --global enable dyverz-update.timer >/dev/null 2>&1 || true
echo "updates: installed into $T (needs packages: pacman-contrib python-gobject libadwaita polkit)"
