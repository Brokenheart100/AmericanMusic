import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    // 高度由 contentRow 自动计算，我们让 delegate 的高度等于它加上一些边距
    implicitHeight: contentRow.implicitHeight + 16 // 上下各 8px 边距

    property string msgType: "system"
    property string author: "nmd"
    property string text: "fuck"
    property url avatar: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/25.jpg"
    property bool isSentMessage: msgType === "received" || msgType === "sending"
    // 边框
    Rectangle {
        anchors.fill: parent
        color: "transparent" // 透明背景，只显示边框
        border.color: "gray"
        border.width: 1
        radius: 4 // 圆角边框
    }
    RowLayout {
        id: contentRow
        layoutDirection: root.isSentMessage ? Qt.RightToLeft : Qt.LeftToRight
        Layout.alignment: Qt.AlignTop
        spacing: 10
        Item {
            Layout.fillWidth: root.isSentMessage
        }
        Image {
            id: sentAvatarImage
            source: root.avatar
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            visible: !root.isSentMessage
            fillMode: Image.PreserveAspectCrop
            clip: true
        }
        // 子项 2: 用户名和消息气泡
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4 // 用户名和消息气泡之间的垂直间距
            Label {
                id: authorLabel
                text: root.author
                color: "#888"
                font.pixelSize: 12
            }
            // 消息气泡
            Rectangle {
                // 气泡的宽度应该由其父级 ColumnLayout 决定
                // 但我们不希望它无限宽，所以它会自适应内容，同时受限于父级宽度
                Layout.fillWidth: true // 让 Label 可以知道最大宽度以进行换行
                implicitWidth: messageLabel.implicitWidth + 10// 左右各10px内边距
                implicitHeight: messageLabel.implicitHeight + 16 // 上下各8px内边距
                color: "white"
                radius: 8
                Label {
                    id: messageLabel
                    text: root.text
                    // 使用 anchors 填满气泡，并留出内边距
                    anchors.fill: parent
                    anchors.margins: 8 // 上下左右各8px内边距
                    // 关键：允许文本自动换行
                    wrapMode: Text.WordWrap
                    color: "black" // 明确指定文本颜色
                }
            }
        }
        // 子项 1: 头像
        Image {
            id: avatarImage1
            source: root.avatar
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            visible: root.isSentMessage
            fillMode: Image.PreserveAspectCrop // 保持比例并裁剪，防止头像变形
            clip: true // 裁剪超出部分，为圆角做准备
        }
        Item {
            Layout.fillWidth: !root.isSentMessage
        }
    }
}
