import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    id: control
    // --- 自定义属性 ---
    property string buttonText: "nmdmp"
    property string iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/send-plane-fill.svg"
    property bool active: false // 用于标记按钮是否被激活
    leftPadding: 10
    checkable: true

    // --- 内容项：图标和文字 ---
    contentItem: RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        Image {
            id: icon
            fillMode: Image.PreserveAspectFit
            source: control.iconSource
            opacity: control.hovered ? 1.0 : 0.8
        }

        Label {
            id: label
            text: control.buttonText
            // 根据激活状态改变文字颜色和样式
            color: control.hovered ? "white" : "#CCCCCC"
            font.pixelSize: 20
            font.bold: control.active // 激活时加粗
        }
        Item {
            Layout.fillWidth: true // 这个弹簧会占据所有剩余空间
        }
    }

    // --- 背景项：根据激活状态显示不同背景 ---
    background: Rectangle {
        radius: 8
        border.width: 1
        color: {
            if (control.active) {
                // --- 状态1: 已选中 ---
                return "#F85151"; // 选中时为红色，按下时更深
            } else if (control.hovered) {
                // --- 状态2: 未选中，但悬浮 ---
                return "#9f9c9c"; // 悬浮时为半透明灰色 (可以调整)
            } else {
                // --- 状态3: 普通状态 (未选中，未悬浮) ---
                return "transparent"; // 普通状态为透明
            }
        }

        border.color: {
            if (control.active) {
                return "transparent"; // 选中时不需要边框
            } else if (control.hovered) {
                return "#666666"; // 悬浮时给个边框
            } else {
                return "#444444"; // 普通状态给个更暗的边框
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
