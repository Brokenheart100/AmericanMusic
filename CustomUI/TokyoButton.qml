import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    id: control
    // --- 自定义属性 ---
    property string buttonText: "nmdmp"
    property string iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/send-plane-fill.svg"
    property bool active: false
    leftPadding: 10
    // --- 内容项：图标和文字 ---
    contentItem: RowLayout {
        spacing: control.active ? 10 : 8 // 激活时间距也可调整

        Image {
            id: icon
            // Layout.preferredWidth: 24
            // Layout.preferredHeight: 24
            fillMode: Image.PreserveAspectFit
            source: control.iconSource
            // 根据激活状态改变图标颜色/不透明度
            opacity: control.active ? 1.0 : 0.8
        }

        Label {
            id: label
            text: control.buttonText
            // 根据激活状态改变文字颜色和样式
            color: control.active ? "white" : "#CCCCCC"
            font.pixelSize: 20
            font.bold: control.active // 激活时加粗
        }
    }

    // --- 背景项：根据激活状态显示不同背景 ---
    background: Rectangle {
        // 如果是激活状态，显示红色背景；否则为透明
        color: {
            if (control.active) {
                return control.down ? "#E04848" : "#F85151"; // 激活时的红色
            } else {
                return control.down ? "#444444" : "transparent"; // 非激活时，按下给个反馈
            }
        }
        radius: 16
        border.color: (!control.active && control.hovered) ? "#555555" : "transparent"
        border.width: 1
    }
}
