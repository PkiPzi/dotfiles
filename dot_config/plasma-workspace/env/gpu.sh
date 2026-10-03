# Sourced by startplasma at login. KWin renders on the first GPU in KWIN_DRM_DEVICES.
# On this laptop the HDMI port hangs off the NVIDIA card while KWin defaults to the Intel iGPU,
# which then draws the 4K screen and copies every frame across. So when a monitor is plugged into
# the NVIDIA card, render there; on the laptop panel alone, leave the default (and the battery) alone.
_card() { # driver name -> /dev/dri/cardN
	for d in /sys/class/drm/card[0-9]; do
		[ "$(basename "$(readlink -f "$d/device/driver")")" = "$1" ] && { echo "/dev/dri/${d##*/}"; return; }
	done
}
_nvidia=$(_card nvidia)
_intel=$(_card i915)
if [ -n "$_nvidia" ] && [ -n "$_intel" ] && grep -qx connected /sys/class/drm/"${_nvidia##*/}"-*/status 2>/dev/null; then
	export KWIN_DRM_DEVICES="$_nvidia:$_intel"
fi
unset -f _card
unset _nvidia _intel
