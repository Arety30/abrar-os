#!/usr/bin/env bash
# Fetch third-party theme assets system-wide (mac = WhiteSur, windows = Win11OS/Win11 icons).
set -uo pipefail
T=$(mktemp -d); cd "$T"
clone() { git clone -q --depth 1 "$1" "$2" 2>/dev/null || git clone --depth 1 "$1" "$2"; }
echo "-- WhiteSur (mac look)"
clone https://github.com/vinceliuice/WhiteSur-gtk-theme wsg && (cd wsg && ./install.sh -d /usr/share/themes -c Light -c Dark -N glassy >/dev/null 2>&1 || ./install.sh -d /usr/share/themes)
clone https://github.com/vinceliuice/WhiteSur-icon-theme wsi && (cd wsi && ./install.sh -d /usr/share/icons >/dev/null 2>&1)
echo "-- Win11OS (windows look)"
clone https://github.com/yeyushengfan258/Win11OS-kde w11 && (
  cd w11
  [ -d aurorae ]        && mkdir -p /usr/share/aurorae/themes && cp -r aurorae/* /usr/share/aurorae/themes/
  [ -d color-schemes ]  && mkdir -p /usr/share/color-schemes && cp -r color-schemes/* /usr/share/color-schemes/
  [ -d Kvantum ]        && mkdir -p /usr/share/Kvantum && cp -r Kvantum/* /usr/share/Kvantum/
  [ -d plasma ]         && cp -r plasma/* /usr/share/plasma/
  [ -d wallpaper ]      && mkdir -p /usr/share/wallpapers && cp -r wallpaper/* /usr/share/wallpapers/ 2>/dev/null
  [ -d sddm ]           && mkdir -p /usr/share/sddm/themes && cp -r sddm/* /usr/share/sddm/themes/ 2>/dev/null
  true)
clone https://github.com/yeyushengfan258/Win11-icon-theme w11i && (cd w11i && ./install.sh -d /usr/share/icons >/dev/null 2>&1)
echo "-- looks installed:"; ls /usr/share/plasma/look-and-feel 2>/dev/null | tr '\n' ' '; echo; ls -d /usr/share/themes/WhiteSur* 2>/dev/null | head -2
rm -rf "$T"
