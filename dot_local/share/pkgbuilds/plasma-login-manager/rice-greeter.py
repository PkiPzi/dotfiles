#!/usr/bin/env python3
"""Restyle the Plasma Login Manager greeter like the rice lock screen (~/.local/bin/rice LOCK_PATCHES):
clock on glass pills, password field and buttons as glass pills, no user list.

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
    ("qml/Main.qml", "            y: (userListComponent.userList.y + mainStack.y)/2 - height/2\n",
     "            y: mainStack.y + mainStack.height / 2 - height - Kirigami.Units.gridUnit * 2\n"),
    ("qml/Main.qml", "            visible: !softwareRendering && clock.visible\n",
     "            visible: false  // the clock has a pill instead of a shadow\n"),
    ("qml/Main.qml", "                showUserList: !PlasmaLogin.GreeterState.beyondUserLimit\n",
     "                showUserList: false\n"),
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
            background: GlassPill {
                implicitHeight: Kirigami.Units.gridUnit * 2.2
                radius: height / 2
                lit: passwordBox.activeFocus
            }
"""),
    ("qml/Login.qml", "            id: loginButton\n", """            id: loginButton
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
