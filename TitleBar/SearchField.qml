// SearchField.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

TextField {
    id: root
    placeholderText: "搜索"
    color: "white"
    font.pixelSize: 14

    Layout.fillWidth: true // 在布局中填满宽度
    Layout.preferredHeight: 36

    leftPadding: 35 // 为左侧图标留出空间
    rightPadding: 10

    background: Rectangle {
        radius: 8
        // 漂亮的渐变背景
        gradient: Gradient {
            // 渐变方向，可以是 Gradient.Horizontal, Vertical, etc.
            orientation: Gradient.Horizontal

            // 定义渐变色标
            GradientStop {
                position: 0.0
                color: "#2E2A41"
            }
            GradientStop {
                position: 1.0
                color: "#1E1C2A"
            }
        }
        border.color: root.activeFocus ? "#5E518D" : "transparent"
        border.width: 1
    }

    // 左侧的搜索图标
    Image {
        source: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
        width: 18
        height: 18
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }
}
