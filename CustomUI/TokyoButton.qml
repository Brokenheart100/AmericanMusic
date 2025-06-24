pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects // 导入新的 Effects 模块

Rectangle {
    id: btnRoot

    // --- 公开属性 (API) ---
    property bool isSelected: false
    property url leftIcon: ""
    property string text: ""
    property url rightIcon: ""
    readonly property color iconColor: (isSelected || mouseArea.containsMouse) ? "white" : "gray"
    color: {
        if (isSelected)
            return "#e84f50";
        if (mouseArea.containsMouse)
            return "#27272d"; // 悬停时的背景色
        return "transparent";
    }
    signal clicked

    // 整个按钮的交互区域
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            // 发射 btnRoot 上定义的 clicked 信号
            btnRoot.clicked();
        }
    }

    Row {
        id: contentRow
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        // 防止内容超出按钮边界
        width: parent.width - 20

        // --- 左侧图标 (使用 MultiEffect) ---
        Image {
            id: leftIcon
            width: 20
            height: 20
            source: btnRoot.leftIcon
            sourceSize: Qt.size(width, height)
            visible: source.toString() !== ""

            // 将 Effect 作为 Image 的子元素
            layer.enabled: true // 必须启用 layer 才能应用 Effect
            layer.effect: MultiEffect {
                // 使用 colorization 属性进行颜色叠加
                colorization: (btnRoot.isSelected || mouseArea.containsMouse) ? "white" : "gray"
            }
        }

        // --- 文本 ---
        Label {
            id: textLabel
            text: btnRoot.text
            color: (btnRoot.isSelected || mouseArea.containsMouse) ? "white" : "#a3a3a6"
            font.pixelSize: 16
            elide: Text.ElideRight

            // RowLayout 会自动处理宽度，无需手动计算
            // Layout.fillWidth: true
        }
    }
}
