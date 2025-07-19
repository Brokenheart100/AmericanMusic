pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: root
    radius: 10
    clip: true // 必须裁剪，否则内容会画到圆角外
    color: "transparent" // 根容器透明，让图片作为背景
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
        // opacity: 0 // 设置透明度
        // 3. 必须启用裁剪，这样图片才会被这个带边距的画框裁剪
        clip: true

        // 4. 现在，让图片完全填充这个新的“画框”
        Image {
            id: cover
            source: root.coverImage
            anchors.fill: parent // 这里的 parent 是 imageFrame
            fillMode: Image.PreserveAspectCrop
            property alias radius: rect.radius
            layer.enabled: true
            layer.effect: ShaderEffect {
                property var mask: rect
                fragmentShader: "file:///E:/Computer/Qt6/AmericanMusic/shaders/mask.frag.qsb"
            }

            Rectangle {
                id: rect
                width: cover.width
                height: cover.height
                layer.enabled: true
                visible: false
            }
        }
    }

    // --- 左上角顶部标题 ---
    Label {
        id: titleLabel
        text: root.title
        color: "white"
        font.pixelSize: 20
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
            // 主文本（“今天从...听起”）
            Label {
                id: mainTextLabel
                // 使用富文本格式，让歌曲名加粗
                text: `今天从《<b>${root.mainText}</b>》听起`
                color: "white"
                font.pixelSize: 15
                textFormat: Text.RichText
                // 1. 允许文本换行
                wrapMode: Text.Wrap
                // 2. 限制最大行数为 2
                maximumLineCount: 2
                // 3. 当文本被截断时，在右侧显示省略号
                elide: Text.ElideRight
                // (可选但推荐) 确保 Label 在布局中能正确地扩展宽度
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.topMargin: 10
            }

            // 歌曲列表 (初始时透明且被挤在下面)
            ColumnLayout {
                id: songListColumn
                opacity: 0 // 初始时完全透明
                spacing: 10
                Layout.leftMargin: 10
                Repeater {
                    model: root.songList
                    delegate: Label {
                        required property int index
                        required property var modelData
                        text: `${index + 1} ${modelData}`
                        color: "white"
                        font.pixelSize: 12
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
            anchors.margins: 5
        }
    }

    // --- 核心：状态和过渡动画 ---
    states: [
        // 1. 定义悬浮状态 'hovered'
        State {
            name: "hovered"
            // 当鼠标进入时，此状态被激活
            when: mouseArea.containsMouse
            PropertyChanges {
                infoArea.height: 150 // 底部区域的高度拉长
            }
            PropertyChanges {
                songListColumn.opacity: 1 // 歌曲列表变得可见
            }
            PropertyChanges {
                playButton.opacity: 1 // 播放按钮变得可见
            }
        }
    ]

    // 2. 定义从一个状态切换到另一个状态时的过渡动画
    transitions: [
        Transition {
            NumberAnimation {
                properties: "height, opacity"
                duration: 500
                easing.type: Easing.OutCubic
            }
        }
    ]
}
