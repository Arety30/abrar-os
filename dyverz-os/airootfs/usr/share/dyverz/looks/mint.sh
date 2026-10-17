# Linux Mint look on Cinnamon (Mint-Y)
default theme "$( [ -d /usr/share/themes/Mint-Y-Dark-Green ] && echo Mint-Y-Dark-Green || echo Adwaita)"
default icons "$( [ -d /usr/share/icons/Mint-Y-Green ] && echo Mint-Y-Green || echo Adwaita)"
default wallpaper mint; default taskbar.position bottom; default taskbar.size 40; default taskbar.autohide off; default startmenu mint
default cursor Adwaita; default font "Noto Sans 10"; default files nemo; default settings cinnamon; default editor xed
default favorites "firefox.desktop,thunderbird.desktop,nemo.desktop,wps-office-wps.desktop,xed.desktop,dyverz-store.desktop"
