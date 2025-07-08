// IconButton.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: root
    property string iconSource
    property color defaultColor: "#A9A9C4"
    property color hoverColor: "white"
    property int iconSize: 22

    icon.source: root.iconSource
    icon.width: root.iconSize
    icon.height: root.iconSize
    icon.color: hovered ? hoverColor : defaultColor
    // padding: 2
    background: Rectangle {
        color: "transparent"
    }
}
