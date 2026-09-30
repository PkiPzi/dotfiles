# listing (eza replaces exa)
alias ls='eza --group-directories-first --icons=auto'
alias la='eza -al --group-directories-first --icons=auto --git'
alias ll='eza -l --group-directories-first --icons=auto --git'
alias lt='eza --tree --level=2 --group-directories-first --icons=auto'

alias cat='bat --paging=never'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# verbose file ops; rm asks once before deleting >3 files or recursing
alias mv='mv -v'
alias cp='cp -rv'
alias rm='rm -Iv'
alias mkdir='mkdir -vp'

# systemd
alias sys='sudo systemctl start'
alias syq='sudo systemctl stop'
alias syr='sudo systemctl restart'
alias syt='systemctl status'
alias sye='sudo systemctl enable --now'
alias syd='sudo systemctl disable --now'
alias jctl='journalctl -xeu'

# packages
alias yu='yay -Syu'
alias yi='yay -S'
alias yr='yay -Rns'
alias ys='yay -Ss'
alias yc='yay -Yc'   # remove orphans

# git
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'

# editor
alias v='nvim'
alias vim='nvim'
alias -s {c,h,cpp,hpp,py,rs,go,js,ts,jsx,tsx,json,yaml,yml,toml,sql,conf,lua,sh}='nvim'
alias -s {txt,md,markdown}='nvim'

alias cz='chezmoi'
