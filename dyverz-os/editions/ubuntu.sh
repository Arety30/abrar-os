EDITION_DE="gnome"; EDITION_DM="gdm"
EDITION_REPO="$DE_GNOME"
EDITION_AUR="yaru-gtk-theme yaru-icon-theme yaru-sound-theme gnome-shell-extension-dash-to-dock ubuntu-wallpapers"
edition_apply_user() {
  cat > "$2/.config/dyverz-look.sh" <<'L'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
gsettings set org.gnome.shell enabled-extensions "['user@example.com','user@example.com']"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
gsettings set org.gnome.shell.extensions.user-theme name 'Yaru' 2>/dev/null || true
w=$(ls /usr/share/backgrounds/*ubuntu*/*.jpg /usr/share/backgrounds/*.jpg 2>/dev/null | head -1); [ -n "$w" ] && gsettings set org.gnome.desktop.background picture-uri "file://$w"
L
}
