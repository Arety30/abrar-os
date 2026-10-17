#!/usr/bin/env bash
# Install the Dyverz Driver Manager component into $1 (target root; "/" on a live system). Run as root.
set -euo pipefail
T=${1:-/}; H=$(cd "$(dirname "$0")" && pwd)
install -d "$T/usr/local/bin" "$T/etc/systemd/system" "$T/usr/local/share/applications"
install -m755 "$H/dyverz-drivers" "$H/dyverz-device-manager" "$T/usr/local/bin/"
install -m644 "$H/dyverz-drivers.service" "$T/etc/systemd/system/"
install -m644 "$H/dyverz-device-manager.desktop" "$T/usr/local/share/applications/"
systemctl --root="$T" enable dyverz-drivers.service >/dev/null 2>&1 || true   # runs once on first boot, then ConditionPathExists stops it
echo "drivers: installed into $T (needs packages: pciutils usbutils vulkan-tools python-gobject libadwaita polkit)"
