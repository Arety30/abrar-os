#!/usr/bin/env bash
# Build every AUR package into a local pacman repo used by mkarchiso.  Run as normal user (needs yay).
set -euo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd); . "$HERE/scripts/lib.sh"
REPO=${REPO:-$HOME/dyverz-repo}; mkdir -p "$REPO"
for p in $(pkgs "$HERE/packages/aur.txt"); do
  if ls "$REPO"/"$p"-*.pkg.tar.zst >/dev/null 2>&1; then echo "have $p"; continue; fi
  echo "== building $p"
  # yay builds & (re)installs; copy the built package out of yay's cache
  yay -S --needed --noconfirm --answerdiff None --answerclean None "$p" || { echo "!! $p failed"; continue; }
  find "$HOME/.cache/yay/$p" -maxdepth 1 -name "*.pkg.tar.zst" ! -name "*debug*" -exec cp -n {} "$REPO"/ \;
done
# also the *dependencies* yay pulled from AUR (e.g. libtiff5 for wps) live in other cache dirs
find "$HOME/.cache/yay" -maxdepth 2 -name "*.pkg.tar.zst" ! -name "*debug*" -exec cp -n {} "$REPO"/ \; 2>/dev/null || true
cd "$REPO" && repo-add -R dyverz.db.tar.gz ./*.pkg.tar.zst >/dev/null && echo "repo ready: $REPO ($(ls *.pkg.tar.zst | wc -l) pkgs)"
