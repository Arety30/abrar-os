EDITION_DE="kde"; EDITION_DM="sddm"
EDITION_REPO="$DE_KDE"
EDITION_AUR="fluent-icon-theme win11-icon-theme-git"
edition_apply_user() {  # $1=user $2=home — runs as that user at first login via dyverz-look
  cat > "$2/.config/dyverz-look.sh" <<'L'
# Windows-like Plasma: bottom panel, centred launcher, Fluent icons, single-click off
plasma-apply-lookandfeel -a org.kde.breeze.desktop 2>/dev/null || true
kwriteconfig6 --file kdeglobals --group Icons --key Theme Fluent
kwriteconfig6 --file kdeglobals --group KDE --key SingleClick false
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight IAX
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var p = panels()[0]; p.location = "bottom"; p.height = 44; p.alignment = "center";
var kick = p.widgets("org.kde.plasma.kickoff")[0]; if (kick) { kick.currentConfigGroup=["General"]; kick.writeConfig("icon","start-here-symbolic"); }
' 2>/dev/null || true
L
}
