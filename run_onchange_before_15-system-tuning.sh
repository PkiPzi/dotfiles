#!/bin/bash
# Memory/OOM tuning so heavy jobs (builds, LLMs, many tabs) slow down instead of freezing the box.
# Re-runs whenever this file changes. Idempotent.
set -euo pipefail

sudo pacman -S --needed --noconfirm zram-generator earlyoom thermald

# compressed-RAM swap first; the disk swap partition (prio -2) is only the overflow
sudo tee /etc/systemd/zram-generator.conf >/dev/null <<'CONF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
CONF

# values from the Arch wiki zram page (Pop!_OS defaults): swappiness >100 is right when swap is RAM-fast,
# page-cluster 0 = no readahead on swap-in, no watermark boosting, earlier background reclaim
sudo tee /etc/sysctl.d/99-memory.conf >/dev/null <<'CONF'
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
vm.vfs_cache_pressure = 50
# start writeback early so a big build/copy can't stall the UI with one huge flush
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
CONF

# zswap in front of zram double-compresses and starves it (Arch wiki: disable it); set at every boot
echo 'w /sys/module/zswap/parameters/enabled - - - - 0' | sudo tee /etc/tmpfiles.d/zswap-off.conf >/dev/null
sudo systemd-tmpfiles --create /etc/tmpfiles.d/zswap-off.conf

# kill the biggest browser/build/LLM process early (at 5% RAM+swap free), never the desktop or claude
sudo tee /etc/default/earlyoom >/dev/null <<'CONF'
EARLYOOM_ARGS="-m 5 -s 5 -r 3600 -n --avoid '(^|/)(init|systemd|Xorg|Xwayland|sshd|kwin_wayland|plasmashell|plasmalogin|alacritty|claude)$' --prefer '(^|/)(Isolated Web Co|Web Content|llama-server|cc1plus|rustc|node)$'"
CONF

# unload ollama models 1 minute after use instead of the 5 minute default
sudo install -d /etc/systemd/system/ollama.service.d
if systemctl cat ollama.service &>/dev/null; then
	printf '[Service]\nEnvironment=OLLAMA_KEEP_ALIVE=1m\n' | sudo tee /etc/systemd/system/ollama.service.d/keepalive.conf >/dev/null
fi

# thermald keeps the Intel CPU just under its trip points instead of hitting the throttle cliff
sudo systemctl enable --now thermald

# makepkg/yay builds use every core; journal capped
sudo install -d /etc/makepkg.conf.d /etc/systemd/journald.conf.d
printf 'MAKEFLAGS="-j$(nproc)"\nCOMPRESSXZ=(xz -c -z - --threads=0)\n' | sudo tee /etc/makepkg.conf.d/10-perf.conf >/dev/null
printf '[Journal]\nSystemMaxUse=200M\n' | sudo tee /etc/systemd/journald.conf.d/10-size.conf >/dev/null

sudo systemctl daemon-reload
sudo sysctl --system >/dev/null
sudo systemctl restart systemd-journald
sudo systemctl start systemd-zram-setup@zram0.service
sudo systemctl enable earlyoom
sudo systemctl restart earlyoom
systemctl cat ollama.service &>/dev/null && sudo systemctl try-restart ollama
true
