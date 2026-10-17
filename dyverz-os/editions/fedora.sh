EDITION_DE="gnome"; EDITION_DM="gdm"
EDITION_REPO="$DE_GNOME"
EDITION_AUR=""
edition_apply_user() {
  cat > "$2/.config/dyverz-look.sh" <<'L'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:close'
gsettings set org.gnome.shell enabled-extensions "[]"
L
}
