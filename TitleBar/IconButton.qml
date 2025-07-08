import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: root
    property string iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
    property color defaultColor: "#A9A9C4"
    property color hoverColor: "white"

    icon.source: root.iconSource
    icon.width: 18
    icon.height: 18
    icon.color: hovered ? hoverColor : defaultColor // 悬浮时变色

    background: Rectangle {
        color: root.hovered ? "#252525" : "transparent"
        radius: 8
    }
}
