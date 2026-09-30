#!/bin/bash
# Packages the dotfiles rely on. Re-runs whenever this list changes.
set -euo pipefail

sudo pacman -S --needed --noconfirm \
	zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
	alacritty ttf-firacode-nerd \
	fzf fd ripgrep eza bat zoxide starship git-delta \
	neovim tree-sitter-cli lazygit unzip fastfetch btop wl-clipboard python-dbus

# krohnkite from its release (the AUR source tarball checksum is flaky)
if [[ ! -d ~/.local/share/kwin/scripts/krohnkite && ! -d /usr/share/kwin/scripts/krohnkite ]]; then
	tmp=$(mktemp -d)
	curl -fsSL -o "$tmp/krohnkite.kwinscript" \
		https://codeberg.org/anametologin/Krohnkite/releases/download/0.9.9.2/krohnkite.kwinscript
	echo "42f7f66531d366c74b5fc860381da3517ccb4cdccd1f80c122fcab6e9a8fcf7e  $tmp/krohnkite.kwinscript" | sha256sum -c
	kpackagetool6 --type=KWin/Script -i "$tmp/krohnkite.kwinscript"
	rm -rf "$tmp"
fi

if [[ $(getent passwd "$USER" | cut -d: -f7) != /usr/bin/zsh ]]; then
	chsh -s /usr/bin/zsh
fi
