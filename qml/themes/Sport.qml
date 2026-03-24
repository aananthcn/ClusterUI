// themes/Sport.qml
// Reserved for sport-mode specific sub-components or colour tokens.
// ClusterRoot.qml drives mode switching via its State machine —
// these theme files exist so the QML module registry is complete
// and you can import ClusterUI.themes later for token sharing.

import QtQuick

QtObject {
    readonly property color accentColor:  "#e24b4a"
    readonly property color arcColor:     "#e24b4a"
    readonly property int   transitionMs: 200
}
