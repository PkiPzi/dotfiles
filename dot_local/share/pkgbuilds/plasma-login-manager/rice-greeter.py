#!/usr/bin/env python3
"""Restyle the Plasma Login Manager greeter like the rice lock screen (~/.local/bin/rice LOCK_PATCHES):
clock on glass pills, password field and buttons as glass pills. Unlike the lock screen the
user list stays: Login.qml asks for a username whenever it's hidden.

Only looks change; login logic stays Plasma's. Each stock text must appear exactly once,
otherwise the build stops, so a changed upstream greeter never gets half-patched."""

import shutil
import sys
from pathlib import Path

src = Path(sys.argv[1]) / "src/frontend/greeter"
here = Path(sys.argv[2])

PATCHES = [
    ("CMakeLists.txt", "    qml/KeyboardButton.qml\n",
     "    qml/KeyboardButton.qml\n    qml/GlassPill.qml\n    qml/GlassClock.qml\n"),
    ("qml/Main.qml", "        BreezeComponents.Clock {\n            id: clock\n",
     "        GlassClock {\n            id: clock\n"),
    ("qml/Main.qml", "            visible: y > 0 && Settings.showClock\n",
     "            visible: Settings.showClock\n"),
    ("qml/Main.qml", "            visible: !softwareRendering && clock.visible\n",
     "            visible: false  // the clock has a pill instead of a shadow\n"),
    ("qml/Login.qml", "        id: userNameInput\n", """        id: userNameInput
        leftPadding: Kirigami.Units.gridUnit
        background: GlassPill {
            implicitHeight: Kirigami.Units.gridUnit * 2.2
            radius: height / 2
            lit: userNameInput.activeFocus
        }
"""),
    ("qml/Login.qml", "            id: passwordBox\n", """            id: passwordBox
            leftPadding: Kirigami.Units.gridUnit
            // the reveal-password eye sits 1px from the edge, made for Plasma's square frame;
            // inset it so it clears the pill's curve
            _rightActionsRow.anchors.rightMargin: Kirigami.Units.gridUnit * 0.75
            rightPadding: _rightActionsRow.width + Kirigami.Units.gridUnit * 0.75 + Kirigami.Units.smallSpacing
            background: GlassPill {
                implicitHeight: Kirigami.Units.gridUnit * 2.2
                radius: height / 2
                lit: passwordBox.activeFocus
            }
"""),
    ("qml/Login.qml", "            id: loginButton\n", """            id: loginButton
            // the pill is taller than Plasma's frame and the icon grows with the button; keep it label-sized
            icon.width: Kirigami.Units.iconSizes.small
            icon.height: Kirigami.Units.iconSizes.small
            background: GlassPill {
                radius: height / 2
                lit: loginButton.activeFocus || loginButton.hovered
            }
"""),
]

texts = {}
for name, old, new in PATCHES:
    text = texts.get(name) or (src / name).read_text()
    if text.count(old) != 1:
        sys.exit(f"rice-greeter: {name} changed upstream, {old.strip()!r} not found once")
    texts[name] = text.replace(old, new)
for name, text in texts.items():
    (src / name).write_text(text)
for qml in ("GlassPill.qml", "GlassClock.qml"):
    shutil.copy(here / qml, src / "qml" / qml)
print(f"rice-greeter: {len(PATCHES)} patches applied")
