#!/usr/bin/env bash
# Put Dyverz OS onto a fresh Arch system (run as root):  bash install/install-stack.sh
#  - copies setup wizard, apply script, editions and win-kernel files into place
#  - enables the first-boot wizard (text mode on tty1; graphical OOBE session if GNOME exists)
set -euo pipefail
SRC=$(cd "$(dirname "$0")/.." && pwd); LIB=/usr/local/lib/dyverz
install -d $LIB /usr/local/bin /usr/local/share/applications /etc/dyverz
cp -r "$SRC/editions" "$SRC/winkernel" "$SRC/branding" "$SRC/drivers" "$SRC/updates" $LIB/
install -m755 "$SRC/setup/dyverz-setup" "$SRC/setup/dyverz-setup-tui" "$SRC/setup/dyverz-apply" /usr/local/bin/
install -m644 "$SRC/setup/dyverz-firstboot.service" /etc/systemd/system/
install -m644 "$SRC/branding/os-release" /usr/lib/os-release
install -m644 "$SRC/branding/dyverz-setup.desktop" /usr/local/share/applications/
pacman -Sy --noconfirm --needed python-gobject libadwaita libnewt polkit sudo git base-devel
systemctl enable dyverz-firstboot.service
# Graphical OOBE: temporary user auto-logged into GNOME with the wizard autostarted (removed by dyverz-apply)
if pacman -Q gdm >/dev/null 2>&1; then
  id dyverz-oobe >/dev/null 2>&1 || useradd -m -c "Dyverz Setup" dyverz-oobe
  echo 'dyverz-oobe ALL=(ALL) NOPASSWD: /usr/local/bin/dyverz-apply' > /etc/sudoers.d/20-dyverz-oobe; chmod 440 /etc/sudoers.d/20-dyverz-oobe
  install -d -o dyverz-oobe -g dyverz-oobe /home/dyverz-oobe/.config/autostart
  install -o dyverz-oobe -g dyverz-oobe -m644 "$SRC/branding/dyverz-setup.desktop" /home/dyverz-oobe/.config/autostart/
  install -d /etc/gdm; printf '[daemon]\nAutomaticLoginEnable=true\nAutomaticLogin=dyverz-oobe\n' > /etc/gdm/custom.conf
  systemctl enable gdm.service
fi
echo "Dyverz OS staged. Reboot: the setup wizard runs on first boot."
