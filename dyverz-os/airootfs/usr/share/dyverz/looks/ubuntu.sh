# Ubuntu look on GNOME (Yaru)
default theme "$( [ -d /usr/share/themes/Yaru ] && echo Yaru || echo Adwaita)"; default icons "$( [ -d /usr/share/icons/Yaru ] && echo Yaru || echo Adwaita)"
default wallpaper ubuntu; default taskbar.position left; default taskbar.size 48; default taskbar.autohide off; default startmenu windows
default cursor "$( [ -d /usr/share/icons/Yaru ] && echo Yaru || echo Adwaita)"; default font "Noto Sans 11"; default files nautilus; default settings gnome; default editor gnome
default favorites "firefox.desktop,thunderbird.desktop,org.gnome.Nautilus.desktop,wps-office-wps.desktop,org.gnome.TextEditor.desktop,dyverz-store.desktop,dyverz-settings.desktop"
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close' 2>/dev/null
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true 2>/dev/null
