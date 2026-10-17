# Windows 11 look on KDE Plasma
lf=$(ls /usr/share/plasma/look-and-feel 2>/dev/null | grep -i 'win11.*light' | head -1); default theme "${lf:-org.kde.breeze.desktop}"
ic=$(ls /usr/share/icons | grep -i '^Win11' | head -1); default icons "${ic:-breeze}"
default wallpaper windows; default taskbar.position bottom; default taskbar.size 44; default taskbar.autohide off; default startmenu windows
default cursor breeze_cursors; default font "Noto Sans 10"; default files dolphin; default settings kde; default editor kate
default favorites "org.kde.dolphin.desktop,firefox.desktop,wps-office-wps.desktop,org.kde.kate.desktop,dyverz-settings.desktop,dyverz-store.desktop"
[ -f /etc/dyverz/edition ] && sudo -n dyverz-boot title "Dyverz OS" >/dev/null 2>&1
