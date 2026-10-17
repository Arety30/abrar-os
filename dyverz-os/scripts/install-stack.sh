#!/usr/bin/env bash
# Install the Dyverz OS stack + overlay onto a RUNNING Arch system (e.g. the dev VM).
# usage: sudo scripts/install-stack.sh [edition]   (edition: all|windows|mac|ubuntu|fedora|mint, default all)
set -euo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd); . "$HERE/scripts/lib.sh"
ED=${1:-all}; [ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
AURUSER=${SUDO_USER:-abrar}

echo "== multilib"; grep -q '^\[multilib\]' /etc/pacman.conf || printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf
echo "== official packages ($ED)"
pacman -Syu --needed --noconfirm $(pkgs "$HERE/packages/base.txt" $(edition_lists "$ED") | grep -vE '^(mkinitcpio-archiso)$')
echo "== AUR packages (as $AURUSER)"
sudo -u "$AURUSER" yay -S --needed --noconfirm --answerdiff None --answerclean None $(pkgs "$HERE/packages/aur.txt") || echo "!! some AUR packages failed; continuing"

echo "== overlay"; "$HERE/scripts/apply-overlay.sh"
echo "== theme assets"; "$HERE/scripts/install-looks.sh"
echo "== wallpapers"; "$HERE/scripts/make-wallpapers.sh"
echo "== services"
systemctl enable NetworkManager gdm docker bluetooth winkernel >/dev/null 2>&1 || true
systemctl enable snapd.socket snapd.apparmor >/dev/null 2>&1 && ln -sfn /var/lib/snapd/snap /snap || true
systemctl restart systemd-binfmt || true
dconf update
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
echo "$ED" > /etc/dyverz/edition
/usr/local/bin/dyverz-branding
echo "== done. Try:  dyverz-look windows   |  winkernel status  |  dyverz-setup (wizard)"
