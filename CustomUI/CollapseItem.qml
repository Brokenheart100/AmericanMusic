import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    id: control

    // --- 对外暴露的属性 ---
    property string playlistName: "默认歌单"
    property url albumArt: "file:///E:/Computer/C/QMLTest/image/3.jpg"
    property bool active: false // 控制是否为选中状态

    // 移除默认内边距，我们自己控制
    leftPadding: 10
    rightPadding: 10
    topPadding: 10
    bottomPadding: 10

    // --- 内容布局 ---
    contentItem: RowLayout {
        spacing: 15

        // 左侧专辑封面
        Rectangle {
            id: imageContainer
            width: 50
            height: 50
            radius: 8 // 圆角
            clip: true // 裁剪图片以适应圆角

            Image {
                anchors.fill: parent
                source: control.albumArt
                fillMode: Image.PreserveAspectCrop // 保持比例并裁剪
            }
        }

        // 右侧文字
        Label {
            id: nameLabel
            text: control.playlistName
            font.pixelSize: 18
            wrapMode: Text.WordWrap // 支持多行文字
            Layout.fillWidth: true // 填充剩余宽度

            // 根据是否选中改变颜色
            color: control.active ? "white" : "#E0E0E0"
        }
    }

    // --- 自定义背景 ---
    background: Rectangle {
        // 根据是否选中改变颜色
        color: control.active ? "#F85151" : "transparent"
        radius: 12 // 背景圆角
    }
}
