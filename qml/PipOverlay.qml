import QtQuick

// Picture-in-picture placeholder.
// On desktop: shows a static placeholder with label.
// Later: replace the inner Rectangle with a QtMultimedia
// VideoOutput pointed at the RTP stream URI.

Rectangle {
    id: root
    width:  560
    height: 316      // 16:9 at this width
    radius: 8
    color:  "#111111"
    border.color: "#333333"
    border.width: 1

    // Animated placeholder — a moving gradient bar simulates
    // video activity so you can see the PiP region while developing
    Rectangle {
        id: scanBar
        width:  parent.width
        height: 3
        color:  "#1d9e75"
        opacity: 0.6
        y: 0

        NumberAnimation on y {
            from:     0
            to:       root.height - scanBar.height
            duration: 1800
            loops:    Animation.Infinite
            easing.type: Easing.InOutSine
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "MAP / CAMERA"
            font.pixelSize: 13
            font.letterSpacing: 3
            color:          "#555555"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "RTP stream pending"
            font.pixelSize: 11
            color:          "#333333"
        }
    }

    // Fade in/out with visibility changes
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    onVisibleChanged: opacity = visible ? 1.0 : 0.0
}
