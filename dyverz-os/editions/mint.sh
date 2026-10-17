EDITION_DE="cinnamon"; EDITION_DM="lightdm"
EDITION_REPO="$DE_CINNAMON"
EDITION_AUR="mint-themes mint-y-icons mint-x-icons"
edition_apply_user() {
  cat > "$2/.config/dyverz-look.sh" <<'L'
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y'
gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y'
gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y'
gsettings set org.cinnamon.theme name 'Mint-Y'
L
}
