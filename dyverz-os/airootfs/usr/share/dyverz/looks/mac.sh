# macOS look on GNOME (WhiteSur)
default theme "$( [ -d /usr/share/themes/WhiteSur-Light ] && echo WhiteSur-Light || echo Adwaita)"
default icons "$( [ -d /usr/share/icons/WhiteSur ] && echo WhiteSur || echo Adwaita)"
default wallpaper mac; default taskbar.position bottom; default taskbar.size 48; default taskbar.autohide on; default startmenu dock
default cursor "$( [ -d /usr/share/icons/WhiteSur-cursors ] && echo WhiteSur-cursors || echo Adwaita)"; default font "Noto Sans 11"
default files nautilus; default settings gnome; default editor gnome
default favorites "org.gnome.Nautilus.desktop,firefox.desktop,thunderbird.desktop,wps-office-wps.desktop,org.gnome.TextEditor.desktop,dyverz-settings.desktop"
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:' 2>/dev/null
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false 2>/dev/null; gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true 2>/dev/null
