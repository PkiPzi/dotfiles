#!/bin/bash
# Packages the dotfiles rely on. Re-runs whenever this list changes.
set -euo pipefail

sudo pacman -S --needed --noconfirm \
	zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
	ttf-firacode-nerd \
	fzf fd ripgrep eza bat zoxide starship git-delta \
	neovim tree-sitter-cli lazygit unzip gcc gdb fastfetch btop wl-clipboard python-dbus \
	papirus-icon-theme ttf-jetbrains-mono-nerd rofi yazi cava glow chafa

# alacritty with Sixel images (ayosec's graphics fork) so yazi previews are real pixels
yay -S --needed --noconfirm --mflags --nocheck alacritty-graphics

# the solstice rice (see ~/.local/bin/rice)
yay -S --needed --noconfirm \
	catppuccin-plasma-colorscheme-mocha catppuccin-sddm-theme-mocha yamis-icon-theme-git ttf-karla \
	kwin-effects-better-blur-dx kwin-effect-rounded-corners kwin6-effects-burn-my-windows \
	kwin-effects-geometry-change kwin-effects-kinetic plasma6-applets-panel-colorizer plasma6-applets-plasmusic-toolbar

# kara pinned past v1.0.0 for the Plasma 6.7 per-monitor desktop fix
pkgbuild="$CHEZMOI_SOURCE_DIR/dot_local/share/pkgbuilds/kara/PKGBUILD"
if [[ $(pacman -Q plasma6-applets-kara 2>/dev/null) != "plasma6-applets-kara $(sed -n 's/^pkgver=//p' "$pkgbuild")-"* ]]; then
	(cd "$(mktemp -d)" && cp "$pkgbuild" . && makepkg -si --noconfirm)
fi

# KDE Store items, checked against the store's md5
store_get() { # id filename -> path of the verified download
	python3 - "$1" "$2" <<'EOF'
import hashlib, json, sys, tempfile, urllib.request
cid, name = sys.argv[1], sys.argv[2]
d = json.load(urllib.request.urlopen(f"https://api.kde-look.org/ocs/v1/content/data/{cid}?format=json"))["data"][0]
i = next(i for i in range(1, 20) if d.get(f"downloadname{i}") == name)
data = urllib.request.urlopen(d[f"downloadlink{i}"]).read()
if hashlib.md5(data).hexdigest() != d[f"downloadmd5sum{i}"]:
    sys.exit(f"{name}: md5 mismatch")
path = f"{tempfile.mkdtemp()}/{name}"
open(path, "wb").write(data)
print(path)
EOF
}
if [[ ! -d ~/.local/share/plasma/desktoptheme/Amethyst.Haze ]]; then
	mkdir -p ~/.local/share/plasma/desktoptheme
	tar -xf "$(store_get 2218601 Amethyst.Haze.tar.xz)" -C ~/.local/share/plasma/desktoptheme
fi
if [[ ! -d ~/.local/share/kwin/scripts/FullOpacityFS ]]; then
	kpackagetool6 --type=KWin/Script -i "$(store_get 2316974 FullOpacityFS.kwinscript)"
fi

# wallpapers and the rofi banner from solstice-dots, pinned
solstice=https://raw.githubusercontent.com/Kuehnelt/solstice-dots/f4d75b2258244e4fa5d718cf8dd89678ec263676
mkdir -p ~/.local/share/wallpapers/solstice ~/.config/rofi
for w in storm.jpg dark-forest.jpg purpled-night.jpg serenity.jpg soft-rose.jpg haunted-house.jpg \
	wanderer.jpg hollow-knight.jpg knight-templar.jpg bg.png flowers-1.jpg flowers-2.jpg flowers-4.jpg \
	flowers-9.jpg flowers-12.jpg flowers-13.jpg flowers-15.jpg; do
	[[ -e ~/.local/share/wallpapers/solstice/$w ]] || curl -fsSL -o ~/.local/share/wallpapers/solstice/$w "$solstice/wallpapers/$w"
done
[[ -e ~/.config/rofi/girl-2.png ]] || curl -fsSL -o ~/.config/rofi/girl-2.png "$solstice/config/rofi/girl-2.png"

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
