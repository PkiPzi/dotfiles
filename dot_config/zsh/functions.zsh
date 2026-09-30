# block cursor in vi normal mode, beam in insert mode
function zle-keymap-select () {
	case $KEYMAP in
		vicmd) echo -ne '\e[1 q';;      # block
		viins|main) echo -ne '\e[5 q';; # beam
	esac
}
zle -N zle-keymap-select

zle-line-init() {
	zle -K viins
	echo -ne '\e[5 q'
}
zle -N zle-line-init

autoload -Uz add-zsh-hook
_beam_cursor() { echo -ne '\e[5 q' }
add-zsh-hook preexec _beam_cursor

# make a directory and cd into it
mkcd() { mkdir -p -- "$1" && cd -- "$1" }

# open anything with its default KDE app, detached from the terminal
o() { setsid -f xdg-open "$@" >/dev/null 2>&1 }
