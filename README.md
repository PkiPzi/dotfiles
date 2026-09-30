# dotfiles

Arch / EndeavourOS + KDE Plasma 6 (Wayland) with Krohnkite tiling, zsh, Alacritty, starship and LazyVim, riced after [solstice-dots](https://github.com/Kuehnelt/solstice-dots). Managed with [chezmoi](https://chezmoi.io).

## New machine

```sh
sudo pacman -S --needed chezmoi git
chezmoi init --apply <this repo>
```

That installs the packages, Krohnkite and switches the login shell to zsh (`run_onchange_before_10-install-packages.sh`), then applies Krohnkite settings, virtual desktops and global shortcuts (`~/.local/bin/kde-tiling-setup`) and the rice (`~/.local/bin/rice`). Log out and back in afterwards.

## Keys

| Keys | Action |
|---|---|
| Meta + H/J/K/L | focus left/down/up/right |
| Meta + Shift + H/J/K/L | move window |
| Meta + Ctrl + H/J/K/L | resize |
| Meta + Enter | terminal |
| Meta + Shift + Enter | make master |
| Meta + Q | close window |
| Meta + 1–5 / Shift | go to desktop / send window |
| Meta + Space / Shift | next / previous layout |
| Meta + T / M | tile / monocle |
| Meta + F / Shift+F | float window / float all |
| Meta + I / D | more / fewer masters |
| Meta + R | rotate |
| Ctrl + Alt + L | lock |
| tap Meta | rofi launcher (solstice rice) |

Shortcuts live in `kde-tiling-setup`; change them there, not in System Settings.

## Rice

`rice solstice` (the default) ports [Kuehnelt/solstice-dots](https://github.com/Kuehnelt/solstice-dots): Catppuccin Mocha Red, Amethyst Haze, monochrome icons, Karla, Better Blur DX, rounded windows with a pink outline, translucent windows, no titlebars, a rounded wallpaper frame with a top bar and dock, rofi on Meta, the solstice starship prompt, fastfetch, yazi, cava and glow themes, and the Catppuccin login screen. Krohnkite, alacritty and every keybinding stay as they are.

Alacritty gets the soft version of the look: a translucent blurred background, subtext1 instead of the brighter text colour, JetBrains Mono with extra line height. Nvim goes transparent with it.

`rice plain` restores the KDE files saved when solstice was switched on (panels, colours, effects, rules) and the plain alacritty/prompt. `rice` alone shows which one is active.

Left out of solstice on purpose: fish (zsh stays), Kvantum (Breeze with Catppuccin colours looks the same without Kvantum's Plasma 6 glitches), kitty and the fastfetch image (alacritty can't draw images), keyd, Spotify/Zen/Obsidian themes.

## Competitive programming (C++)

- Install the [Competitive Companion](https://github.com/jmerle/competitive-companion) browser extension, then in nvim `<leader>rp` (problem) or `<leader>rc` (contest) and click the extension on the problem page. Files land in `~/cp/<judge>/<contest>/`, starting from `~/cp/template.cpp`.
- `<leader>rr` compiles and runs every testcase; `<leader>ra` / `<leader>re` add or edit testcases.
- In the shell: `cr a.cpp < in.txt` to compile and run, `crd` for a sanitizer debug build.

## Everyday

- `chezmoi edit <file>` then `chezmoi apply`, or edit in place and `chezmoi re-add`
- `chezmoi cd` to commit and push
