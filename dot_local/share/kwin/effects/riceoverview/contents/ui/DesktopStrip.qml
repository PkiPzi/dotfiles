// This screen's desktops as live thumbnails on a glass island, numbered like the bar's
// workspace pills: pink for the current desktop, faint grey when a desktop has windows.
// Click one to go there, drop a window on one to send it there.

import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.kwin as KWinComponents

Glass {
    id: strip

    required property int thumbHeight
    required property QtObject windowModel
    readonly property real thumbWidth: Math.round(thumbHeight * targetScreen.geometry.width / targetScreen.geometry.height)
    readonly property int pad: 12

    radius: 18
    width: row.width + pad * 2
    height: row.height + pad * 2

    Row {
        id: row
        x: strip.pad
        y: strip.pad
        spacing: strip.pad

        Repeater {
            model: KWinComponents.Workspace.desktops

            Column {
                id: entry
                required property QtObject modelData
                required property int index
                readonly property bool current: modelData === root.currentDesktop
                spacing: 8

                Item {
                    id: thumb
                    width: strip.thumbWidth
                    height: strip.thumbHeight
                    scale: hover.hovered && !entry.current ? 1.04 : 1
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    // the desktop at screen size, scaled down and clipped to rounded corners
                    Item {
                        anchors.fill: parent
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: thumb.width
                                height: thumb.height
                                radius: 10
                            }
                        }
                        Item {
                            width: targetScreen.geometry.width
                            height: targetScreen.geometry.height
                            scale: strip.thumbHeight / targetScreen.geometry.height
                            transformOrigin: Item.TopLeft

                            KWinComponents.DesktopBackground {
                                anchors.fill: parent
                                activity: KWinComponents.Workspace.currentActivity
                                desktop: entry.modelData
                                outputName: targetScreen.name
                            }
                            Repeater {
                                id: windows
                                model: KWinComponents.WindowFilterModel {
                                    activity: KWinComponents.Workspace.currentActivity
                                    desktop: entry.modelData
                                    screenName: targetScreen.name
                                    windowModel: strip.windowModel
                                    windowType: root.windowTypes
                                }
                                KWinComponents.WindowThumbnail {
                                    wId: model.window.internalId
                                    x: model.window.x - targetScreen.geometry.x
                                    y: model.window.y - targetScreen.geometry.y
                                    width: model.window.width
                                    height: model.window.height
                                    z: model.window.stackingOrder
                                    visible: !model.window.minimized
                                }
                            }
                        }
                    }

                    // outline: pink on the current desktop and while a window hovers over it
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -border.width
                        radius: 10 + border.width
                        color: "transparent"
                        border.width: entry.current || drop.containsDrag ? 2 : 1
                        border.color: entry.current || drop.containsDrag ? "#f38ba8"
                            : hover.hovered ? "#99b4befe" : "#29b4befe"
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }

                    HoverHandler {
                        id: hover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: {
                            root.switchTo(entry.modelData);
                            effect.deactivate();
                        }
                    }
                    DropArea {
                        id: drop
                        anchors.fill: parent
                        keys: ["kwin-window"]
                        onDropped: dropEvent => {
                            dropEvent.accepted = true;
                            const window = drag.source;
                            if (window.desktops.length === 0 || window.desktops.indexOf(entry.modelData) !== -1) {
                                dropEvent.action = Qt.IgnoreAction;
                                return;
                            }
                            window.desktops = [entry.modelData];
                        }
                    }
                }

                // the number, as the bar shows it
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 30
                    height: 22
                    radius: 6
                    color: entry.current ? "#f38ba8" : windows.count > 0 ? "#99585b70" : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text {
                        anchors.centerIn: parent
                        text: entry.modelData.name || entry.index + 1
                        color: entry.current ? "#1e2127" : "#cdd6f4"
                        font.family: "Karla"
                        font.pointSize: 11
                        font.bold: entry.current
                    }
                }
            }
        }
    }
}
