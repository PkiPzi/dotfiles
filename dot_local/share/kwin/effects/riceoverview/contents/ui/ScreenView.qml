// One screen of the rice overview: blurred wallpaper, a glass strip with this screen's desktops
// on top, and a glass panel with the current desktop's windows below.

import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import org.kde.kwin as KWinComponents
import org.kde.kwin.private.effects

FocusScope {
    id: root
    focus: true

    // WindowHeap and its cards look these two up by name
    readonly property QtObject targetScreen: KWinComponents.SceneView.screen
    readonly property QtObject currentDesktop: KWinComponents.SceneView.currentDesktop
    readonly property real t: effect.partialActivationFactor
    readonly property int gap: 12  // Krohnkite's gaps
    readonly property var windowTypes: ~KWinComponents.WindowFilterModel.Dock &
                                       ~KWinComponents.WindowFilterModel.Desktop &
                                       ~KWinComponents.WindowFilterModel.Notification &
                                       ~KWinComponents.WindowFilterModel.CriticalNotification

    function switchTo(desktop) {
        if (desktop) {
            KWinComponents.SceneView.currentDesktop = desktop;
        }
    }

    function step(delta) {
        const desktops = KWinComponents.Workspace.desktops;
        const n = desktops.length;
        let i = desktops.indexOf(currentDesktop) + delta;
        if (KWinComponents.Workspace.virtualDesktopNavigationWrapsAround) {
            i = (i + n) % n;
        } else {
            i = Math.max(0, Math.min(n - 1, i));
        }
        switchTo(desktops[i]);
    }

    // keys the window panel doesn't take (it handles arrows, Return and Space)
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            effect.deactivate();
        } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
            switchTo(KWinComponents.Workspace.desktops[event.key - Qt.Key_1]);
        } else if (event.key === Qt.Key_PageUp) {
            step(-1);
        } else if (event.key === Qt.Key_PageDown) {
            step(1);
        } else {
            return;
        }
        event.accepted = true;
    }

    // scroll anywhere to flip through desktops without leaving
    WheelHandler {
        property int delta: 0
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            delta += event.angleDelta.y ? event.angleDelta.y : -event.angleDelta.x;
            while (delta >= 120) {
                delta -= 120;
                root.step(-1);
            }
            while (delta <= -120) {
                delta += 120;
                root.step(1);
            }
        }
    }

    // wallpaper: sharp at rest, frosted and darkened like the rice's acrylic once open
    KWinComponents.DesktopBackground {
        id: wallpaper
        anchors.fill: parent
        activity: KWinComponents.Workspace.currentActivity
        desktop: root.currentDesktop
        outputName: root.targetScreen.name
    }
    Item {
        anchors.fill: parent
        opacity: root.t
        FastBlur {
            anchors.fill: parent
            source: wallpaper
            radius: 64
        }
        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            opacity: 0.35
        }
        TapHandler {
            onTapped: effect.deactivate()
        }
    }

    // the bar fades out as the strip comes in
    Repeater {
        model: KWinComponents.WindowFilterModel {
            desktop: root.currentDesktop
            screenName: root.targetScreen.name
            windowModel: stackModel
            windowType: KWinComponents.WindowFilterModel.Dock
        }
        KWinComponents.WindowThumbnail {
            z: 600
            visible: !model.window.hidden && opacity > 0
            wId: model.window.internalId
            x: model.window.x - root.targetScreen.geometry.x
            y: model.window.y - root.targetScreen.geometry.y
            width: model.window.width
            height: model.window.height
            opacity: 1 - root.t
        }
    }

    DesktopStrip {
        id: strip
        z: 500  // above windows flying in, below a window being dragged
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.gap * 2 - (1 - root.t) * (height + root.gap * 2)
        opacity: root.t
        thumbHeight: Math.round(root.height * 0.11)
        windowModel: stackModel
    }

    Glass {
        id: panel
        x: root.gap * 2
        y: strip.y + strip.height + root.gap * 2
        width: root.width - root.gap * 4
        height: root.height - y - root.gap * 2
        radius: 18
        color: "#4d1e2127"  // lighter than the bar's islands: a big slab at 80 % reads as a hole
        opacity: root.t
        scale: 0.97 + 0.03 * root.t
    }

    WindowHeap {
        id: heap
        x: panel.x
        y: strip.height + root.gap * 4  // where the panel ends up, so the layout doesn't slide
        width: panel.width
        height: root.height - y - root.gap * 2
        focus: true
        padding: Kirigami.Units.gridUnit * 2
        animationDuration: effect.animationDuration
        animationEnabled: true
        organized: true
        layout.maxScale: 0.85
        model: KWinComponents.WindowFilterModel {
            activity: KWinComponents.Workspace.currentActivity
            desktop: root.currentDesktop
            screenName: root.targetScreen.name
            windowModel: stackModel
            windowType: root.windowTypes
        }
        delegate: WindowCard {
            windowHeap: heap
            contentItemParent: root
            partialActivationFactor: root.t
            gestureInProgress: false
        }
        onActivated: effect.deactivate()
    }

    KWinComponents.WindowModel {
        id: stackModel
    }
}
