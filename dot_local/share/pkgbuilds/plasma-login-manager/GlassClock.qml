// time and date on two pills, in the top bar clock's font and format
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.clock as PlasmaClock

ColumnLayout {
    spacing: 10

    GlassPill {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: time.implicitWidth + 64
        implicitHeight: time.implicitHeight + 20
        radius: 28
        Text {
            id: time
            anchors.centerIn: parent
            text: Qt.formatTime(timeSource.dateTime, "HH:mm")
            color: "#cdd6f4"
            font.family: "JetBrainsMono Nerd Font"
            font.pointSize: 54
            font.weight: Font.Light
        }
    }
    GlassPill {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: date.implicitWidth + 32
        implicitHeight: date.implicitHeight + 12
        Text {
            id: date
            anchors.centerIn: parent
            text: Qt.formatDate(timeSource.dateTime, "ddd d MMM")
            color: "#bac2de"
            font.family: "JetBrainsMono Nerd Font"
            font.pointSize: 11
        }
    }

    PlasmaClock.Clock {
        id: timeSource
    }
}
