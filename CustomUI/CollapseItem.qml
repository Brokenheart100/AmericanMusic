import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    id: control

    property string playlistName: "默认歌单"
    property url albumArt: "file:///E:/Computer/C/QMLTest/image/3.jpg"
    property bool active: false // 控制是否为选中状态

    leftPadding: 10
    rightPadding: 10
    topPadding: 10
    bottomPadding: 10
    checkable: true // 允许选中状态
    // --- 内容布局 ---
    contentItem: RowLayout {
        spacing: 15
        // 左侧专辑封面
        Rectangle {
            id: imageContainer
            Layout.preferredWidth: 25 // 固定宽度
            Layout.preferredHeight: 25
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
            font.pixelSize: 12 // 字体大小可以根据你的UI调整
            Layout.fillWidth: true // 填充剩余宽度 (这个很重要，保证了Label有足够的宽度来计算换行)

            // --- 核心修正：添加以下两行 ---

            // 1. 允许换行 (你已经有了)
            wrapMode: Text.WordWrap

            // 2. 限制最大行数为 2
            maximumLineCount: 2

            // 3. 当文本被截断时，在右侧显示省略号
            elide: Text.ElideRight

            // 根据是否选中改变颜色
            color: control.active ? "white" : "#E0E0E0"
        }
    }

    // --- 自定义背景 ---
    background: Rectangle {
        // 根据是否选中改变颜色
        color: control.active ? "#F85151" : "transparent"
        radius: 8 // 背景圆角
    }
}
