EDITION_DE="gnome"; EDITION_DM="gdm"
EDITION_REPO="$DE_GNOME"
EDITION_AUR="whitesur-gtk-theme whitesur-icon-theme gnome-shell-extension-dash-to-dock gnome-shell-extension-blur-my-shell"
edition_apply_user() {
  cat > "$2/.config/dyverz-look.sh" <<'L'
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur'
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
gsettings set org.gnome.shell enabled-extensions "['user@example.com','blur-my-shell@aunetx','user@example.com']"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light' 2>/dev/null || true
L
}
