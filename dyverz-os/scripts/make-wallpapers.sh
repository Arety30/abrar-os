#!/usr/bin/env bash
# Generate original (non-copyrighted) wallpapers per look with ImageMagick.
set -e; D=/usr/share/dyverz/wallpapers; mkdir -p $D; S=2560x1440
mk() { magick -size $S "$2" \( -size $S xc:none -fill "rgba(255,255,255,0.10)" -draw "circle 1900,300 1900,900" \) -composite "$D/$1.png"; }
mk windows "radial-gradient:#4f8ef7-#071a3d"
mk mac     "gradient:#e6a9ff-#3b4bd8"
mk ubuntu  "gradient:#772953-#e95420"
mk fedora  "gradient:#3c6eb4-#0b1f4d"
mk mint    "gradient:#8fd38a-#1d3b1f"
mk gnome   "gradient:#3d3846-#1a1a1a"
mk kde     "gradient:#1d99f3-#0c2a45"
magick -size 512x512 xc:none -fill '#2b6cff' -draw 'roundrectangle 16,16 496,496 96,96' -fill white -gravity center -pointsize 320 -annotate 0 'D' /usr/share/pixmaps/dyverz.png
echo "wallpapers in $D"
