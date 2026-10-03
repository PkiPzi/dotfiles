// Window opacity for the rice (~/.local/bin/rice). The focused window and the one under the
// cursor use the "active" opacity, everything else the "inactive" one. This replaces the Force
// opacity window rules, which KWin re-applied on every focus change and so fought with hover.

// first match wins; percentages
const LEVELS = [
    // terminals keep crisp text: their background is translucent itself
    { match: /alacritty|konsole/i, active: 100, inactive: 92 },
    // media and documents stay opaque
    { match: /mpv|vlc|gwenview|spectacle|okular|haruna|obs/i, active: 100, inactive: 100 },
    { match: /.*/, active: 90, inactive: 85 },
];

let active = workspace.activeWindow;
let hovered = null;

function managed(w) {
    return w && !w.deleted && (w.normalWindow || w.dialog);
}

// menus and tooltips count as their parent window
function owner(w) {
    while (w && !managed(w) && w.transient) w = w.transientFor;
    return managed(w) ? w : null;
}

function update(w) {
    if (!managed(w)) return;
    const id = w.resourceClass + " " + w.resourceName;
    const level = LEVELS.find(l => l.match.test(id));
    const lit = w === active || w === hovered;
    const opacity = w.fullScreen ? 1 : (lit ? level.active : level.inactive) / 100;
    if (Math.abs(w.opacity - opacity) > 0.001) w.opacity = opacity;
}

function track(w) {
    if (!managed(w)) return;
    w.fullScreenChanged.connect(() => update(w));
    update(w);
}

workspace.stackingOrder.forEach(track);
workspace.windowAdded.connect(track);
workspace.windowRemoved.connect(w => {
    if (w === hovered) hovered = null;
    if (w === active) active = null;
});

workspace.windowActivated.connect(w => {
    const previous = active;
    active = w;
    update(previous);
    update(w);
});

workspace.cursorPosChanged.connect(() => {
    const w = owner(workspace.windowAt(workspace.cursorPos, 1)[0]);
    if (w === hovered) return;
    const previous = hovered;
    hovered = w;
    update(previous);
    update(w);
});
