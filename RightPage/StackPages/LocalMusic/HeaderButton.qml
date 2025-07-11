import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // --- 公共属性 ---
    property alias text: titleLabel.text
    property string sortIndicatorText: "↓"
    property bool hoverable: true // 控制是否启用悬浮效果

    Layout.preferredHeight: 30    // 默认填充父布局高度

    // 背景和边框
    Rectangle {
        id: background
        anchors.fill: parent
        radius: 8
        color: "transparent"
    }

    // 内容布局
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        Label {
            id: titleLabel
            color: "#888"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
        }

        Label {
            id: sortIndicatorLabel
            text: root.sortIndicatorText
            color: "white"
            font.pixelSize: 16
            opacity: 0
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // 交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.hoverable
        cursorShape: root.hoverable ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    // 状态管理
    states: [
        State {
            name: "hovered"
            when: root.hoverable && mouseArea.containsMouse
            PropertyChanges {
                target: background
                color: "#3C444C"
            }
            PropertyChanges {
                target: titleLabel
                color: "white"
            }
            PropertyChanges {
                target: sortIndicatorLabel
                opacity: 1
            }
        }
    ]

    // 动画
    transitions: Transition {
        ColorAnimation {
            duration: 200
        }
        NumberAnimation {
            properties: "opacity"
            duration: 200
        }
    }
}
