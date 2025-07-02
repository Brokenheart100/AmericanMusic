import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    // --- 自定义属性 ---
    // 允许从外部设置封面图片源
    property alias imageSource: coverImage.source
    property alias tagText1: tagLabel1.text
    property alias tagText2: tagLabel2.text
    property bool hovered: mouseArea.hovered // 用于指示鼠标是否悬停在组件上

    // 推荐尺寸
    width: 150
    height: 150
 
    // --- 关键点 1: 定义一个 Scale 变换 ---
    transform: Scale {
        id: scaleTransform
        origin.x: root.width / 2 // 设置缩放原点为组件的水平中心
        origin.y: root.height / 2 // 设置缩放原点为组件的垂直中心

        // --- 关键点 2: 绑定 xScale 和 yScale ---
        // 将缩放比例与 root.hovered 绑定
        xScale: mouseArea.hovered ? 1.03 : 1.0
        yScale: mouseArea.hovered ? 1.03 : 1.0

        // --- 关键点 3: 为缩放比例添加动画 ---
        Behavior on xScale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
        Behavior on yScale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
    // 使用MouseArea来检测悬停和点击
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        property bool hovered: false // 用于指示鼠标是否悬停在组件上
        onEntered: {
            hovered = true; // 鼠标进入时设置 hovered 为 true
        }
        onExited: {
            hovered = false; // 鼠标离开时设置 hovered 为 false
        }
        onClicked: {
            console.log("Clicked on cover: " + root.imageSource);
        }
    }

    // 背景和封面图片
    Rectangle {
        id: coverContainer
        anchors.fill: parent
        radius: 12 // 圆角
        // clip: true // 裁切超出边界的子项（主要是图片）

        // 这是我们的图片源
        Image {
            id: coverImage
            anchors.fill: parent
            source: root.imageSource // 确保 Image 的 source 是绑定的
            fillMode: Image.PreserveAspectCrop
        }

        // 悬停时的遮罩效果
        Rectangle {
            anchors.fill: parent
            color: "#22FFFFFF" // 淡淡的白色遮罩
            opacity: mouseArea.hovered ? 1 : 0 // 悬停时显示
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
        }
    }
    Rectangle {
        id: tagName
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 10

        // 尺寸自适应文字内容
        width: tagLabel1.implicitWidth + 12
        height: tagLabel1.implicitHeight + 6

        color: "#99333333" // 半透明深灰色背景
        radius: 5

        Label {
            id: tagLabel1
            anchors.centerIn: parent
            // text: root.tagText
            color: "white"
            font.pixelSize: 12
        }
    }

    // "播客" 标签
    Rectangle {
        id: tagType
        // 定位在左下角
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10

        // 尺寸自适应文字内容
        width: tagLabel2.implicitWidth + 12
        height: tagLabel2.implicitHeight + 6

        color: "#99333333" // 半透明深灰色背景
        radius: 5

        Label {
            id: tagLabel2
            anchors.centerIn: parent
            text: "播客"
            color: "white"
            font.pixelSize: 12
        }
    }
}
