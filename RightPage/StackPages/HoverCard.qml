// HoverCard.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls

Rectangle {
    id: root

    // --- 卡片基本属性 ---
    // width: 150
    // height: 200

    radius: 30
    clip: true // 必须裁剪，否则内容会画到圆角外

    // --- 数据属性 ---
    property string coverImage: "file:///E:/Computer/Qt6/AmericanMusic/image/2.jpg" // 封面图片
    property string title: "私人雷达"
    property string mainText: "刹那の誓い"
    property var songList: ["刹那の誓い", "plan", "夏色花火"]

    // --- 鼠标悬浮区域 ---
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true // 必须开启 hover 事件
    }

    // --- 背景图片 ---
    // 1. 创建一个透明的 Item 作为图片的容器/画框
    Item {
        id: imageFrame

        // 2. 让这个画框填充父容器，并设置边距
        anchors.fill: parent
        // anchors.margins: 10 // <-- 在这里设置你想要的边距大小！

        // 3. 必须启用裁剪，这样图片才会被这个带边距的画框裁剪
        clip: true

        // 4. 现在，让图片完全填充这个新的“画框”
        Image {
            id: cover
            source: root.coverImage
            anchors.fill: parent // 这里的 parent 是 imageFrame
            fillMode: Image.PreserveAspectCrop
            Rectangle {
                // 添加圆角
                anchors.fill: parent
                radius: 8
                clip: true // 确保圆角裁剪生效
                color: "transparent"
                border.color: "#FFFFFF1A" // 加个细微的边框
                border.width: 1
            }
        }
    }

    // --- 顶部标题 ---
    Label {
        id: titleLabel
        text: root.title
        color: "white"
        font.pixelSize: 22
        font.bold: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20
    }

    // --- 底部信息区域 ---
    Rectangle {
        id: infoArea
        // 初始高度只够显示一行文字
        height: 80
        color: "#6B5F8A" // 类似紫灰色
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        // --- 用于布局底部所有内容的 ColumnLayout ---
        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: 20

            // 主文本（“今天从...听起”）
            Label {
                id: mainTextLabel
                // 使用富文本格式，让歌曲名加粗
                text: `今天从《<b>${root.mainText}</b>》听起`
                color: "white"
                font.pixelSize: 18
                textFormat: Text.RichText
                // 1. 允许文本换行
                wrapMode: Text.Wrap
                // 2. 限制最大行数为 2
                maximumLineCount: 2
                // 3. 当文本被截断时，在右侧显示省略号
                elide: Text.ElideRight
                // (可选但推荐) 确保 Label 在布局中能正确地扩展宽度
                Layout.fillWidth: true
            }

            // 歌曲列表 (初始时透明且被挤在下面)
            ColumnLayout {
                id: songListColumn
                opacity: 0 // 初始时完全透明
                Layout.topMargin: 15
                spacing: 10

                Repeater {
                    model: root.songList
                    delegate: Label {
                        // 使用 model.index + 1 来显示序号
                        text: `${index + 1} ${modelData}`
                        color: "white"
                        font.pixelSize: 16
                        opacity: 0.5
                    }
                }
            }
        }

        // 播放按钮 (初始时在右下角，但透明)
        Image {
            id: playButton

            // 1. 使用你的 SVG 文件路径
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-fill.svg"
            // 2. 设置图标的尺寸
            width: 42
            height: 42
            // 3. 初始时透明 (这部分逻辑不变)
            opacity: 0
            // 4. 定位在右下角 (这部分逻辑不变)
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
        }
    }

    // --- 核心：状态和过渡动画 ---
    states: [
        // 1. 定义悬浮状态 'hovered'
        State {
            name: "hovered"
            // 当鼠标进入时，此状态被激活
            when: mouseArea.containsMouse

            // 描述在此状态下，哪些属性需要改变
            PropertyChanges {
                target: infoArea
                height: 220 // 底部区域的高度拉长
            }
            PropertyChanges {
                target: songListColumn
                opacity: 1 // 歌曲列表变得可见
            }
            PropertyChanges {
                target: playButton
                opacity: 1 // 播放按钮变得可见
            }
        }
    ]

    // 2. 定义从一个状态切换到另一个状态时的过渡动画
    transitions: [
        // 定义“进入”时的动画
        // Transition {
        //     from: ""
        //     to: "hovered" // "" 代表默认状态
        //     // 进入时动画快一些
        //     NumberAnimation {
        //         properties: "height, opacity"
        //         duration: 2500
        //     }
        // },

        // // 定义“离开”时的动画
        // Transition {
        //     from: "hovered"
        //     to: ""
        //     // 离开时动画慢一些，显得更优雅
        //     NumberAnimation {
        //         properties: "height, opacity"
        //         duration: 4000
        //     }
        // }
        Transition {
            NumberAnimation {
                properties: "height, opacity"
                duration: 2000 // <--- 就是这个值！
                easing.type: Easing.OutCubic
            }
        }
    ]
}
