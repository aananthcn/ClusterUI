import QtQuick
import QtQuick.Shapes

Item {
    id: root
    width:  260
    height: 260

    // ── Arc parameters ────────────────────────────────────────────────────────
    readonly property real minAngle: -220   // degrees, 0 km/h position
    readonly property real maxAngle:   40   // degrees, 240 km/h position
    readonly property real maxSpeed:  240.0

    property real needleAngle: minAngle
        + (maxAngle - minAngle) * Math.min(vehicle.speed / maxSpeed, 1.0)

    // ── Background arc (track) ────────────────────────────────────────────────
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
                radiusX:    100
                radiusY:    100
                startAngle: root.minAngle + 90
                sweepAngle: root.maxAngle - root.minAngle
            }
        }

        // Filled arc (speed value)
        ShapePath {
            strokeColor: root.needleAngle > -60 ? "#e24b4a" : "#1d9e75"
            strokeWidth: 14
            fillColor:   "transparent"
            capStyle:    ShapePath.RoundCap

            Behavior on strokeColor {
                ColorAnimation { duration: 300 }
            }

            PathAngleArc {
                centerX:    root.width  / 2
                centerY:    root.height / 2
                radiusX:    100
                radiusY:    100
                startAngle: root.minAngle + 90
                sweepAngle: root.needleAngle - root.minAngle
            }
        }
    }

    // ── Speed readout ─────────────────────────────────────────────────────────
    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(vehicle.speed).toString()
            font.pixelSize: 52
            font.bold:      true
            color:          "#ffffff"

            Behavior on text {
                // No animation on text — just instant update
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "km/h"
            font.pixelSize: 14
            color:          "#888888"
            font.letterSpacing: 2
        }
    }

    // ── Smooth needle angle transition ────────────────────────────────────────
    Behavior on needleAngle {
        NumberAnimation {
            duration:   80   // fast enough for 500 Hz updates
            easing.type: Easing.OutQuad
        }
    }
}
