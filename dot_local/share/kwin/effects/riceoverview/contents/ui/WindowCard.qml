/*
    A window on the overview's panel: KWin's WindowHeapDelegate (overview effect, Plasma 6.7),
    restyled for the rice: rounded thumbnail outlined like the real windows (pink for the active
    one, grey for the rest), lavender ring and a small lift on hover, title on a glass pill.

    SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
    SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import org.kde.kwin as KWinComponents
import org.kde.kwin.private.effects

ExpoCell {
    id: thumb

    required property QtObject window
    required property int index
    required property Item windowHeap

    readonly property bool selected: windowHeap.selectedIndex === index
    readonly property bool lit: !windowHeap.dragActive && (hoverHandler.hovered || (selected && Window.window.activeFocusItem))
    readonly property bool isActive: KWinComponents.Workspace.activeWindow === window
    property bool gestureInProgress: false
    property Item contentItemParent: this

    readonly property bool presentOnCurrentDesktop: !window.desktops.length || window.desktops.indexOf(KWinComponents.Workspace.currentDesktop) !== -1
    readonly property bool initialHidden: window.minimized
    readonly property bool activeHidden: window.skipSwitcher

    property bool animationEnabled: false
    property real targetScale: 1.0
    property DragManager activeDragHandler: dragHandler

    property bool isReady: width !== 0 && height !== 0

    function restoreDND(oldGlobalRect: rect) {
        thumbSource.restoreDND(oldGlobalRect);
    }

    layout: windowHeap.layout
    shouldLayout: !thumb.activeHidden
    partialActivationFactor: effect.partialActivationFactor
    naturalX: thumb.window.x - thumb.window.output.geometry.x
    naturalY: thumb.window.y - thumb.window.output.geometry.y
    naturalWidth: thumb.window.width
    naturalHeight: thumb.window.height
    persistentKey: thumb.window.internalId
    bottomMargin: caption.height + Kirigami.Units.largeSpacing * 2

    Behavior on x {
        enabled: thumb.isReady
        NumberAnimation { duration: thumb.windowHeap.animationDuration; easing.type: Easing.InOutCubic }
    }
    Behavior on y {
        enabled: thumb.isReady
        NumberAnimation { duration: thumb.windowHeap.animationDuration; easing.type: Easing.InOutCubic }
    }
    Behavior on width {
        enabled: thumb.isReady
        NumberAnimation { duration: thumb.windowHeap.animationDuration; easing.type: Easing.InOutCubic }
    }
    Behavior on height {
        enabled: thumb.isReady
        NumberAnimation { duration: thumb.windowHeap.animationDuration; easing.type: Easing.InOutCubic }
    }

    contentItem: Item {
        id: mainContent
        parent: contentItemParent
        visible: opacity > 0 && (!activeHidden || !initialHidden)
        opacity: initialHidden ? partialActivationFactor : 1
        z: (activeDragHandler.active || returnAnimation.running) ? 1000
            : thumb.window.stackingOrder * (presentOnCurrentDesktop ? 1 : 0.001)

        KWinComponents.WindowThumbnail {
            id: thumbSource
            wId: thumb.window.internalId
            scale: targetScale * (thumb.lit && !activeDragHandler.active ? 1.03 : 1)
            width: mainContent.width
            height: mainContent.height
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: thumbSource.width
                    height: thumbSource.height
                    radius: 12
                }
            }

            Binding on width {
                value: mainContent.width
                when: !returnAnimation.active
            }
            Binding on height {
                value: mainContent.height
                when: !returnAnimation.active
            }

            Drag.proposedAction: Qt.MoveAction
            Drag.supportedActions: Qt.MoveAction
            Drag.source: thumb.window
            Drag.hotSpot: Qt.point(
                thumb.activeDragHandler.centroid.pressPosition.x,
                thumb.activeDragHandler.centroid.pressPosition.y)
            Drag.keys: ["kwin-window"]

            onXChanged: effect.checkItemDraggedOutOfScreen(thumbSource)
            onYChanged: effect.checkItemDraggedOutOfScreen(thumbSource)

            function saveDND() {
                const oldGlobalRect = mapToItem(null, 0, 0, width, height);
                thumb.windowHeap.saveDND(thumb.window.internalId, oldGlobalRect);
            }
            function restoreDND(oldGlobalRect: rect) {
                const newGlobalRect = mapFromItem(null, oldGlobalRect);
                const heapRect = thumb.windowHeap.mapToItem(null, Qt.size(thumb.windowHeap.width, thumb.windowHeap.height));
                returnAnimation.active = true;
                x = newGlobalRect.x;
                y = newGlobalRect.y;
                width = newGlobalRect.width;
                height = newGlobalRect.height;

                returnAnimation.restart();

                if ((oldGlobalRect.x < heapRect.x && heapRect.x + heapRect.width < oldGlobalRect.x + oldGlobalRect.width) ||
                    (oldGlobalRect.y < heapRect.y && heapRect.y + heapRect.height < oldGlobalRect.y + oldGlobalRect.height)) {
                    returnAnimation.complete();
                }
            }
            function deleteDND() {
                thumb.windowHeap.deleteDND(thumb.window.internalId);
            }

            ParallelAnimation {
                id: returnAnimation
                property bool active: false
                onRunningChanged: active = running
                NumberAnimation { target: thumbSource; properties: "x,y"; to: 0; duration: thumb.windowHeap.animationDuration; easing.type: Easing.InOutCubic }
                NumberAnimation { target: thumbSource; property: "width"; to: mainContent.width; duration: thumb.windowHeap.animationDuration; easing.type: Easing.InOutCubic }
                NumberAnimation { target: thumbSource; property: "height"; to: mainContent.height; duration: thumb.windowHeap.animationDuration; easing.type: Easing.InOutCubic }
            }
        }

        // outline, drawn like the rounded-corners effect draws it on the real windows
        Rectangle {
            x: thumbSource.x - (thumbSource.scale - 1) * thumbSource.width / 2 - border.width
            y: thumbSource.y - (thumbSource.scale - 1) * thumbSource.height / 2 - border.width
            width: thumbSource.width * thumbSource.scale + border.width * 2
            height: thumbSource.height * thumbSource.scale + border.width * 2
            radius: 12 + border.width
            color: "transparent"
            border.width: thumb.lit || thumb.isActive ? 2 : 1.5
            border.color: thumb.lit ? "#b4befe" : thumb.isActive ? "#f38ba8" : "#45475a"
            Behavior on border.color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
            anchors.fill: thumbSource
            acceptedButtons: Qt.NoButton
            cursorShape: thumb.activeDragHandler.active ? Qt.ClosedHandCursor : Qt.ArrowCursor
        }

        // icon and title on a glass pill under the window
        Glass {
            id: caption
            readonly property real maxWidth: Math.max(thumbSource.width, Kirigami.Units.gridUnit * 6)
            anchors.horizontalCenter: thumbSource.horizontalCenter
            anchors.top: thumbSource.bottom
            anchors.topMargin: Kirigami.Units.largeSpacing
            width: Math.min(captionRow.implicitWidth + 24, maxWidth)
            height: captionRow.implicitHeight + 10
            radius: height / 2
            lit: thumb.lit
            opacity: partialActivationFactor
            visible: !thumb.activeHidden && !activeDragHandler.active && !returnAnimation.running && opacity > 0

            Row {
                id: captionRow
                anchors.centerIn: parent
                spacing: 6
                Kirigami.Icon {
                    width: Kirigami.Units.iconSizes.small
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    source: thumb.window.icon
                }
                Text {
                    width: Math.min(implicitWidth, caption.maxWidth - 24 - Kirigami.Units.iconSizes.small - 6)
                    anchors.verticalCenter: parent.verticalCenter
                    text: thumb.window.caption
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: "#cdd6f4"
                    font.family: "Karla"
                    font.pointSize: 10
                }
            }
        }

        HoverHandler {
            id: hoverHandler
            onHoveredChanged: if (hovered !== selected) {
                thumb.windowHeap.resetSelected();
            }
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: {
                KWinComponents.Workspace.activeWindow = thumb.window;
                thumb.windowHeap.activated();
            }
            onPressedChanged: {
                if (pressed) {
                    thumbSource.Drag.active = true;
                } else if (!thumb.activeDragHandler.active) {
                    thumbSource.Drag.active = false;
                }
            }
        }

        // middle click closes, like the stock overview
        TapHandler {
            acceptedButtons: Qt.MiddleButton
            onTapped: thumb.window.closeWindow()
        }

        component DragManager : DragHandler {
            target: thumbSource
            grabPermissions: PointerHandler.CanTakeOverFromAnything

            onActiveChanged: {
                thumb.windowHeap.dragActive = active;
                if (active) {
                    thumb.activeDragHandler = this;
                } else {
                    thumbSource.saveDND();
                    returnAnimation.restart();

                    var action = thumbSource.Drag.drop();
                    if (action === Qt.MoveAction) {
                        if (typeof thumbSource !== "undefined") {
                            thumbSource.deleteDND();
                        }
                        return;
                    }

                    var globalPos = targetScreen.mapToGlobal(centroid.scenePosition);
                    effect.checkItemDroppedOutOfScreen(globalPos, thumbSource);

                    if (typeof thumbSource !== "undefined") {
                        thumbSource.deleteDND();
                    }
                }
            }
        }

        DragManager {
            id: dragHandler
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
        }

        // close button: a small glass circle in the corner while hovered
        Glass {
            width: 26
            height: 26
            radius: 13
            anchors.right: thumbSource.right
            anchors.top: thumbSource.top
            anchors.margins: 8
            visible: hoverHandler.hovered && thumb.window.closeable && !thumb.activeDragHandler.active && !returnAnimation.running
            lit: closeHover.hovered
            Text {
                anchors.centerIn: parent
                text: "✕"
                color: closeHover.hovered ? "#f38ba8" : "#cdd6f4"
                font.pointSize: 9
            }
            HoverHandler {
                id: closeHover
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: thumb.window.closeWindow()
            }
        }

        Component.onDestruction: {
            if (selected) {
                windowHeap.resetSelected();
            }
        }
    }
}
