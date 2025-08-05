// IconDelegate.qml
import QtQuick
import Qt5Compat.GraphicalEffects

/*!
* @brief 一个通用的图标代理组件 (Qt 6.8 风格)。
*
* 用于在侧边栏中显示单个图标。它处理了图标的显示、颜色变化、
* 鼠标悬停提示（Tooltip）等功能。
*/
Item {
    id: delegateRoot

    // --- 公共属性 ---
    /*! @brief 图标的图像资源路径 (例如 "qrc:/icons/chat.svg") */
    property string iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/mail-fill.svg"
    /*! @brief 鼠标悬停时显示的提示文本 */
    property string tooltipText: "123"
    /*! @brief 当前图标是否被选中 */
    property bool isSelected: false
    /*! @brief 图标的默认颜色 */
    property color iconColor: "#5C5F62"
    /*! @brief 图标被选中时的颜色 */
    property color selectedIconColor: "white"

    // --- 组件实现 ---
    width: 48
    height: 48

    Image {
        id: iconImage
        anchors.centerIn: parent
        width: 24
        height: 24
        source: delegateRoot.iconSource
    }

    ColorOverlay {
        anchors.fill: iconImage
        source: iconImage
        color: delegateRoot.isSelected ? delegateRoot.selectedIconColor : delegateRoot.iconColor
        antialiasing: true
    }

    Timer {
        id: tooltipTimer
        interval: 800
        onTriggered: tooltip.visible = true
    }

    Rectangle {
        id: tooltip
        visible: false
        width: tooltipTextLabel.width + 16
        height: tooltipTextLabel.height + 8
        radius: 4
        color: "#333333"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.right
        anchors.leftMargin: 12
        z: 99

        Text {
            id: tooltipTextLabel
            anchors.centerIn: parent
            text: delegateRoot.tooltipText
            color: "white"
            font.pixelSize: 12
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: tooltipTimer.start()
        onExited: {
            tooltipTimer.stop();
            tooltip.visible = false;
        }
    }
}
