# vi mode; `ff` leaves insert mode
bindkey -v
export KEYTIMEOUT=20
bindkey -M viins 'ff' vi-cmd-mode

# emacs-style keys that are still handy in insert mode
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^P' up-history
bindkey -M viins '^N' down-history
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# edit the current command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^V' edit-command-line
bindkey -M vicmd '^V' edit-command-line

# hjkl in the completion menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# special keys
[[ -n ${terminfo[kdch1]} ]] && bindkey -- "${terminfo[kdch1]}" delete-char
[[ -n ${terminfo[kend]}  ]] && bindkey -- "${terminfo[kend]}"  end-of-line
[[ -n ${terminfo[khome]} ]] && bindkey -- "${terminfo[khome]}" beginning-of-line
[[ -n ${terminfo[kich1]} ]] && bindkey -- "${terminfo[kich1]}" overwrite-mode
[[ -n ${terminfo[kcbt]}  ]] && bindkey -- "${terminfo[kcbt]}"  reverse-menu-complete
bindkey '^[[1;5C' forward-word   # ctrl+right
bindkey '^[[1;5D' backward-word  # ctrl+left

# ci" / da( style text objects
autoload -Uz select-quoted select-bracketed
zle -N select-quoted
zle -N select-bracketed
for m in visual viopp; do
	for c in {a,i}{\',\",\`}; do
		bindkey -M $m $c select-quoted
	done
	for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
		bindkey -M $m $c select-bracketed
	done
done

# freeze terminal settings so a crashed program can't leave it broken
ttyctl -f
