// Rice overview: a mission-control style overview in the rice's glass look (~/.local/bin/rice).
// Desktops of each screen along the top, that screen's current desktop's windows on a glass
// panel below. The window layout and the window cards build on KWin's own overview pieces
// (org.kde.kwin.private.effects), so this file only drives activation and the animation.

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.kwin as KWinComponents

KWinComponents.SceneEffect {
    id: effect

    property bool activated: false
    readonly property int animationDuration: Kirigami.Units.longDuration
    // 0 = windows where they really are, 1 = laid out on the panel. WindowHeap reads both.
    property real partialActivationFactor: activated ? 1 : 0
    readonly property bool gestureInProgress: false
    Behavior on partialActivationFactor {
        NumberAnimation {
            duration: effect.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    // Declared inline so the effect owns the component. A parentless Qt.createComponent() result is
    // garbage-collected after a few toggles, leaving KWin a dangling delegate (dead overview, and a
    // crash in QuickSceneEffect::addScreen when an output appears).
    delegate: ScreenView {}

    Instantiator {
        model: effect.configuration.BorderActivate
        KWinComponents.ScreenEdgeHandler {
            mode: KWinComponents.ScreenEdgeHandler.Pointer
            edge: modelData
            onActivated: effect.toggle()
        }
    }

    Instantiator {
        model: effect.configuration.TouchBorderActivate
        KWinComponents.ScreenEdgeHandler {
            mode: KWinComponents.ScreenEdgeHandler.Touch
            edge: modelData
            onActivated: effect.toggle()
        }
    }

    KWinComponents.ShortcutHandler {
        name: "Rice Overview"
        text: "Toggle Rice Overview"
        sequence: "Meta+Tab"
        onActivated: effect.toggle()
    }

    Timer {
        id: deactivateTimer
        interval: effect.animationDuration
        onTriggered: effect.visible = false
    }

    // KWin can hide the effect on its own (screen changes, lock, another effect); without this
    // the flag stays true and the next Meta+Tab or corner hit only "closes" what isn't showing
    onVisibleChanged: {
        if (!visible) {
            activated = false;
        }
    }

    function toggle() {
        if (activated && visible) {
            deactivate();
        } else {
            activate();
        }
    }

    function activate() {
        if (deactivateTimer.running) {
            return;
        }
        visible = true;
        activated = true;
    }

    function deactivate() {
        if (!activated) {
            return;
        }
        activated = false;
        deactivateTimer.start();
    }
}
