import QtQuick
import QtQuick.Controls

Window {
    id: root
    width:  1920
    height: 720
    visible: true
    title: "Instrument Cluster"
    color: "#0d0d0d"

    // ── Drive mode state machine ──────────────────────────────────────────────
    // vehicle.driveMode: 0=normal  1=sport  2=reverse
    // QML states change layout, colours, and which widgets are visible.

    // Use a root container to handle states and transitions
    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: "transparent"

        state: {
            switch (vehicle.driveMode) {
                case 1:  return "sport"
                case 2:  return "reverse"
                default: return "normal"
            }
        }

        states: [
            State {
                name: "normal"
                PropertyChanges { target: speedometer; x: 80;  scale: 1.0 }
                PropertyChanges { target: tachometer;  visible: true }
                PropertyChanges { target: pipOverlay;  visible: false }
                PropertyChanges { target: modeLabel;   text: "NORMAL"; color: "#aaaaaa" }
            },
            State {
                name: "sport"
                PropertyChanges { target: speedometer; x: 40;  scale: 1.15 }
                PropertyChanges { target: tachometer;  visible: true }
                PropertyChanges { target: pipOverlay;  visible: false }
                PropertyChanges { target: modeLabel;   text: "SPORT";  color: "#e24b4a" }
            },
            State {
                name: "reverse"
                PropertyChanges { target: speedometer; x: 80;  scale: 0.85 }
                PropertyChanges { target: tachometer;  visible: false }
                PropertyChanges { target: pipOverlay;  visible: true  }
                PropertyChanges { target: modeLabel;   text: "REVERSE"; color: "#f0c040" }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation {
                    properties: "x, scale, opacity"
                    duration:   250
                    easing.type: Easing.OutCubic
                }
                ColorAnimation { duration: 250 }
            }
        ]

        // ── Layout ────────────────────────────────────────────────────────────────

        Speedometer {
            id: speedometer
            x:  80
            y:  (root.height - height) / 2
        }

        Tachometer {
            id: tachometer
            x:  root.width - width - 80
            y:  (root.height - height) / 2
        }

        // Centre info block
        Column {
            anchors.centerIn: parent
            spacing: 8

            Text {
                id: modeLabel
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 18
                font.letterSpacing: 4
                color: "#aaaaaa"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "GEAR  " + (vehicle.gear <= 0
                                ? (vehicle.gear < 0 ? "R" : "N")
                                : vehicle.gear.toString())
                font.pixelSize: 32
                font.bold: true
                color: "#ffffff"
            }

            // Fuel bar
            Rectangle {
                width:  160
                height: 8
                radius: 4
                color:  "#333333"
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width:  parent.width * (vehicle.fuel / 100.0)
                    height: parent.height
                    radius: parent.radius
                    color:  vehicle.fuel < 15 ? "#e24b4a" : "#1d9e75"

                    Behavior on width {
                        NumberAnimation { duration: 300 }
                    }
                }
            }

            // Warning icons row
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Rectangle {
                    width: 28; height: 28; radius: 14
                    color:   vehicle.warnEngine  ? "#e24b4a" : "#1a1a1a"
                    border.color: "#444"; border.width: 1
                    Text { anchors.centerIn: parent; text: "E"; color: "white"; font.pixelSize: 13 }
                }
                Rectangle {
                    width: 28; height: 28; radius: 14
                    color:   vehicle.warnBatt    ? "#f0c040" : "#1a1a1a"
                    border.color: "#444"; border.width: 1
                    Text { anchors.centerIn: parent; text: "B"; color: "white"; font.pixelSize: 13 }
                }
                Rectangle {
                    width: 28; height: 28; radius: 14
                    color:   vehicle.warnBrake   ? "#e24b4a" : "#1a1a1a"
                    border.color: "#444"; border.width: 1
                    Text { anchors.centerIn: parent; text: "!"; color: "white"; font.pixelSize: 13 }
                }
            }
        }

        PipOverlay {
            id: pipOverlay
            z: tachometer.z + 1
            anchors {
                right:  parent.right
                //bottom: parent.bottom
                verticalCenter: tachometer.verticalCenter
                margins: 50
            }
            visible: true
        }
    }
}
