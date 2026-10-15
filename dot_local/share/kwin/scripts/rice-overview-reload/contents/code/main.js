// The rice overview effect (~/.local/share/kwin/effects/riceoverview) stops answering Meta+Tab and
// the top-left corner once an output is added or removed. Unloading and loading it again brings
// it back, so do that whenever the screen layout changes.

const EFFECT = "riceoverview";
let busy = false;

function effects(method, done) {
    callDBus("org.kde.KWin", "/Effects", "org.kde.kwin.Effects", method, EFFECT, done);
}

function reload() {
    if (busy) return;
    busy = true;
    effects("unloadEffect", () => effects("loadEffect", () => { busy = false; }));
}

workspace.screensChanged.connect(reload);

// plasmashell recreates the bars after a screen change or restart, after screensChanged has fired
workspace.windowAdded.connect(w => { if (w.dock) reload(); });
