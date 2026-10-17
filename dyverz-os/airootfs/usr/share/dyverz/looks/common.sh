# shared by dyverz-look and the looks
look_session() { case "$1" in windows|kde) echo plasma;; mint) echo cinnamon;; *) echo gnome;; esac; }
look_de()      { case "$1" in windows|kde) echo kde;;    mint) echo cinnamon;; *) echo gnome;; esac; }
current_de()   { case "${XDG_CURRENT_DESKTOP,,}" in *kde*|*plasma*) echo kde;; *cinnamon*) echo cinnamon;; *gnome*|*ubuntu*) echo gnome;; *) echo none;; esac; }
CONF=$HOME/.config/dyverz/look.conf
conf_get() { grep -s "^$1=" "$CONF" | tail -1 | cut -d= -f2-; }
conf_set() { mkdir -p "$(dirname "$CONF")"; touch "$CONF"; grep -v "^$1=" "$CONF" > "$CONF.tmp" || true; echo "$1=$2" >> "$CONF.tmp"; mv "$CONF.tmp" "$CONF"; }
