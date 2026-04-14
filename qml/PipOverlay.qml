import QtQuick
import QtMultimedia

// Picture-in-picture Rear View Camera overlay.
//
// On Component.onCompleted the VideoOutput hands its QVideoSink to the C++
// RvcStreamHandler so decoded RTP frames can be pushed into it from the
// GStreamer pipeline.  The placeholder text is visible while the stream is
// not yet active (e.g. before the first frame arrives).
Rectangle {
    id: root
    width:  560
    height: 316      // 16:9 at this width
    radius: 8
    color:  "#111111"
    border.color: "#333333"
    border.width: 1

    // Live camera feed — receives frames pushed by RvcStreamHandler
    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        visible: rvcStream.active

        // Pass this VideoOutput's QVideoSink to the C++ handler once the
        // component is fully constructed.  RvcStreamHandler will push every
        // decoded RGBA frame into it from the Qt main thread.
        Component.onCompleted: rvcStream.setVideoSink(videoSink)
    }

    // Shown while the stream is not yet delivering frames
    Column {
        anchors.centerIn: parent
        visible: !rvcStream.active
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "REVERSE CAMERA"
            font.pixelSize: 13
            font.letterSpacing: 3
            color:          "#555555"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "Waiting for stream\u2026"
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
