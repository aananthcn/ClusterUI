import QtQuick
import QtQuick.Shapes

Item {
    id: root
    width:  260
    height: 260

    readonly property real minAngle: -220
    readonly property real maxAngle:   40
    readonly property real maxRpm:   8000.0
    readonly property real redlineRpm: 6000.0

    property real needleAngle: minAngle
        + (maxAngle - minAngle) * Math.min(vehicle.rpm / maxRpm, 1.0)

    readonly property bool inRedline: vehicle.rpm >= redlineRpm

    // Track arc
    Shape {
        anchors.fill: parent

        ShapePath {
            strokeColor: "#2a2a2a"
            strokeWidth: 14
            fillColor:   "transparent"
            capStyle:    ShapePath.RoundCap

            PathAngleArc {
                centerX:    root.width  / 2
                centerY:    root.height / 2
                radiusX:    150
                radiusY:    150
                startAngle: root.minAngle + 90
                sweepAngle: root.maxAngle - root.minAngle
            }
        }

        // Value arc
        ShapePath {
            strokeColor: root.inRedline ? "#e24b4a" : "#378add"
            strokeWidth: 14
            fillColor:   "transparent"
            capStyle:    ShapePath.RoundCap

            Behavior on strokeColor {
                ColorAnimation { duration: 150 }
            }

            PathAngleArc {
                centerX:    root.width  / 2
                centerY:    root.height / 2
                radiusX:    150
                radiusY:    150
                startAngle: root.minAngle + 90
                sweepAngle: root.needleAngle - root.minAngle
            }
        }
    }

    // RPM readout
    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           Math.round(vehicle.rpm / 100).toString()
            font.pixelSize: 52
            font.bold:      true
            color:          root.inRedline ? "#e24b4a" : "#ffffff"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "×100 rpm"
            font.pixelSize: 14
            color:          "#888888"
            font.letterSpacing: 2
        }
    }

    Behavior on needleAngle {
        NumberAnimation {
            duration:    80
            easing.type: Easing.OutQuad
        }
    }
}
