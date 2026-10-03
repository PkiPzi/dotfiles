// the top bar's glass islands (~/.local/bin/rice): One Dark base at 80 %, faint lavender edge
import QtQuick

Rectangle {
    property bool lit: false  // red ring, like the focused window's outline
    color: "#cc1e2127"
    radius: 14
    border.width: lit ? 2 : 1
    border.color: lit ? "#f38ba8" : "#29b4befe"
    Behavior on border.color { ColorAnimation { duration: 150 } }
}
