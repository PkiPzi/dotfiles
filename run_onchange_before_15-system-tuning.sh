#!/bin/bash
# Memory/OOM tuning so heavy jobs (builds, LLMs, many tabs) slow down instead of freezing the box.
# Re-runs whenever this file changes. Idempotent.
set -euo pipefail

sudo pacman -S --needed --noconfirm zram-generator earlyoom

# compressed-RAM swap first; the disk swap partition (prio -2) is only the overflow
sudo tee /etc/systemd/zram-generator.conf >/dev/null <<'CONF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
CONF

# swappiness 100 is right for zram; page-cluster 0 = no readahead on swap-in
sudo tee /etc/sysctl.d/99-memory.conf >/dev/null <<'CONF'
vm.swappiness = 100
vm.page-cluster = 0
vm.vfs_cache_pressure = 50
CONF

# kill the biggest browser/build/LLM process early (at 5% RAM+swap free), never the desktop or claude
sudo tee /etc/default/earlyoom >/dev/null <<'CONF'
EARLYOOM_ARGS="-m 5 -s 5 -r 3600 -n --avoid '(^|/)(init|systemd|Xorg|Xwayland|sshd|kwin_wayland|plasmashell|plasmalogin|alacritty|claude)$' --prefer '(^|/)(Isolated Web Co|Web Content|llama-server|cc1plus|rustc|node)$'"
CONF

# unload ollama models 1 minute after use instead of the 5 minute default
sudo install -d /etc/systemd/system/ollama.service.d
if systemctl cat ollama.service &>/dev/null; then
	printf '[Service]\nEnvironment=OLLAMA_KEEP_ALIVE=1m\n' | sudo tee /etc/systemd/system/ollama.service.d/keepalive.conf >/dev/null
fi

sudo systemctl daemon-reload
sudo sysctl --system >/dev/null
sudo systemctl start systemd-zram-setup@zram0.service
sudo systemctl enable earlyoom
sudo systemctl restart earlyoom
systemctl cat ollama.service &>/dev/null && sudo systemctl try-restart ollama
true
