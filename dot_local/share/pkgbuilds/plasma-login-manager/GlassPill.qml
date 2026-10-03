// the top bar's glass islands (~/.local/bin/rice), as on the rice lock screen
import QtQuick

Rectangle {
    property bool lit: false  // keyboard focus: red ring, like the focused window outline
    color: "#cc1e2127"
    radius: 14
    border.width: lit ? 2 : 1
    border.color: lit ? "#f38ba8" : "#29b4befe"
    Behavior on border.color { ColorAnimation { duration: 150 } }
}
