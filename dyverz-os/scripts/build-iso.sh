#!/usr/bin/env bash
# Build a Dyverz OS live+installer ISO with archiso.
# usage: sudo scripts/build-iso.sh [edition]  edition: all|windows|mac|ubuntu|fedora|mint  (default all)
set -euo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd); . "$HERE/scripts/lib.sh"
ED=${1:-all}; [ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
REPO=${REPO:-/home/${SUDO_USER:-abrar}/dyverz-repo}; [ -f "$REPO/dyverz.db" ] || { echo "no AUR repo at $REPO — run scripts/build-aur-repo.sh first"; exit 1; }
WORK=${WORK:-/var/tmp/dyverz-work}; OUT=${OUT:-/home/${SUDO_USER:-abrar}/dyverz-out}; P=$WORK/profile
rm -rf "$P"; mkdir -p "$WORK" "$OUT"; cp -r /usr/share/archiso/configs/releng "$P"

# packages
{ pkgs "$HERE/packages/base.txt" $(edition_lists "$ED"); pkgs "$HERE/packages/aur.txt"; } | sort -u > "$P/packages.x86_64"
# pacman.conf for the build: multilib + local dyverz repo
grep -q '^\[multilib\]' "$P/pacman.conf" || printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> "$P/pacman.conf"
printf '\n[dyverz]\nSigLevel = Optional TrustAll\nServer = file://%s\n' "$REPO" >> "$P/pacman.conf"
# overlay
rsync -a "$HERE/airootfs/" "$P/airootfs/"
echo "$ED" > "$P/airootfs/etc/dyverz/edition"
# live session: autologin user "dyverz" into the edition's desktop, GDM instead of tty autologin
rm -rf "$P/airootfs/etc/systemd/system/getty@tty1.service.d"
mkdir -p "$P/airootfs/etc/systemd/system/display-manager.service"; ln -sfn /usr/lib/systemd/system/gdm.service "$P/airootfs/etc/systemd/system/display-manager.service"
mkdir -p "$P/airootfs/etc/systemd/system/multi-user.target.wants"
for s in NetworkManager winkernel; do ln -sfn /usr/lib/systemd/system/$s.service "$P/airootfs/etc/systemd/system/multi-user.target.wants/$s.service"; done
sess=$(/usr/bin/env bash -c ". $HERE/airootfs/usr/share/dyverz/looks/common.sh; look_session ${ED/all/windows}")
cat > "$P/airootfs/etc/gdm/custom.conf" <<EOG
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=dyverz
DefaultSession=$sess.desktop
EOG
mkdir -p "$P/airootfs/var/lib/AccountsService/users"
printf '[User]\nSession=%s\nIcon=/usr/share/pixmaps/dyverz.png\nSystemAccount=false\n' "$sess" > "$P/airootfs/var/lib/AccountsService/users/dyverz"
# live user
cat >> "$P/airootfs/etc/passwd" <<EOG
dyverz:x:1000:1000:Dyverz Live:/home/dyverz:/usr/bin/bash
EOG
cat >> "$P/airootfs/etc/group" <<EOG
dyverz:x:1000:
EOG
cat >> "$P/airootfs/etc/shadow" <<EOG
dyverz:$(openssl passwd -6 dyverz):14871::::::
EOG
sed -i 's/^wheel:.*/&dyverz/; s/^docker:.*/&,dyverz/' "$P/airootfs/etc/group" 2>/dev/null || true
mkdir -p "$P/airootfs/home/dyverz/Desktop" "$P/airootfs/home/dyverz/.config"
cp "$HERE/airootfs/usr/share/applications/dyverz-install.desktop" "$P/airootfs/home/dyverz/Desktop/"
cp -r "$HERE/airootfs/etc/skel/.config/." "$P/airootfs/home/dyverz/.config/"
echo "$ED" > "$P/airootfs/home/dyverz/.config/dyverz-look"
# profiledef
cat > "$P/profiledef.sh" <<EOG
#!/usr/bin/env bash
iso_name="dyverz-os-$ED"
iso_label="DYVERZ_\$(date --date="@\${SOURCE_DATE_EPOCH:-\$(date +%s)}" +%Y%m)"
iso_publisher="Dyverz OS <https://example.com>"
iso_application="Dyverz OS Live/Installer ($ED)"
iso_version="\$(date --date="@\${SOURCE_DATE_EPOCH:-\$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi.grub.esp' 'uefi.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/etc/sudoers.d/"]="0:0:750"
  ["/root"]="0:0:750"
  ["/usr/local/bin/"]="0:0:755"
  ["/home/dyverz"]="1000:1000:750"
)
EOG
# customize script: runs inside the airootfs at build time
cat > "$P/airootfs/root/customize_airootfs.sh" <<'EOG'
#!/usr/bin/env bash
set -e
chown -R 1000:1000 /home/dyverz; chmod +x /home/dyverz/Desktop/*.desktop
for s in adduser deluser; do ln -sfn dyverz-adduser /usr/local/bin/$s; done; ln -sfn dyverz-exe-install /usr/local/bin/install-exe
ln -sfn /var/lib/snapd/snap /snap 2>/dev/null || true
/usr/local/bin/dyverz-branding || true
/usr/local/bin/make-wallpapers || true
/usr/local/bin/install-looks || true
dconf update || true
mkdir -p /var/lib/winkernel /mnt/cdrive
EOG
chmod +x "$P/airootfs/root/customize_airootfs.sh"
cp "$HERE/scripts/make-wallpapers.sh" "$P/airootfs/usr/local/bin/make-wallpapers"; cp "$HERE/scripts/install-looks.sh" "$P/airootfs/usr/local/bin/install-looks"
# components from other folders (terminal/, drivers/, updates/ ...): anything with an install.sh
for c in "$HERE"/*/install.sh; do n=$(basename "$(dirname "$c")"); mkdir -p "$P/airootfs/usr/share/dyverz/components"; cp -r "$(dirname "$c")" "$P/airootfs/usr/share/dyverz/components/$n"; echo "component: $n"; done
cat >> "$P/airootfs/root/customize_airootfs.sh" <<'EOG'
for c in /usr/share/dyverz/components/*/install.sh; do [ -f "$c" ] && { echo "== component $(basename "$(dirname "$c")")"; bash "$c" / || echo "!! component failed: $c"; }; done
EOG
# GRUB menu title
sed -i "s/Arch Linux/Dyverz OS ($ED)/g" "$P/grub/grub.cfg" "$P/syslinux/"*.cfg 2>/dev/null || true
echo "== mkarchiso ($ED) -> $OUT"; mkarchiso -v -w "$WORK/build" -o "$OUT" "$P"
ls -lh "$OUT"/dyverz-os-$ED-*.iso
