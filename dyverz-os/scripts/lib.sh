# shared helpers
pkgs() { grep -hv '^\s*#' "$@" | tr ' ' '\n' | grep -v '^\s*$'; }
edition_lists() {   # edition -> which DE lists it needs
  local d=$(dirname "${BASH_SOURCE[0]}")/../packages
  case "$1" in
    windows|kde) echo "$d/kde.txt";;
    mac|ubuntu|fedora|gnome) echo "$d/gnome.txt";;
    mint) echo "$d/cinnamon.txt";;
    all|*) echo "$d/gnome.txt $d/kde.txt $d/cinnamon.txt";;
  esac
}
