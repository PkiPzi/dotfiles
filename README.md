# dotfiles

Arch / EndeavourOS + KDE Plasma 6 (Wayland) with Krohnkite tiling, zsh, Alacritty, starship and LazyVim. Managed with [chezmoi](https://chezmoi.io).

## New machine

```sh
sudo pacman -S --needed chezmoi git
chezmoi init --apply <this repo>
```

That installs the packages, Krohnkite and switches the login shell to zsh (`run_onchange_before_10-install-packages.sh`), then applies Krohnkite settings, virtual desktops and global shortcuts (`~/.local/bin/kde-tiling-setup`). Log out and back in afterwards.

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

Shortcuts live in `kde-tiling-setup`; change them there, not in System Settings.

## Theme

Catppuccin Mocha by default. `theme onedark` switches KDE colours, icons, alacritty, nvim and bat back to One Dark / Breeze Dark; `theme catppuccin` switches again.

## Competitive programming (C++)

- Install the [Competitive Companion](https://github.com/jmerle/competitive-companion) browser extension, then in nvim `<leader>rp` (problem) or `<leader>rc` (contest) and click the extension on the problem page. Files land in `~/cp/<judge>/<contest>/`, starting from `~/cp/template.cpp`.
- `<leader>rr` compiles and runs every testcase; `<leader>ra` / `<leader>re` add or edit testcases.
- In the shell: `cr a.cpp < in.txt` to compile and run, `crd` for a sanitizer debug build.

## Everyday

- `chezmoi edit <file>` then `chezmoi apply`, or edit in place and `chezmoi re-add`
- `chezmoi cd` to commit and push
