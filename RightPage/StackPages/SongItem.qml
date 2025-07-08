// SongItem.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// 每一行的根容器
Rectangle {
    id: root

    // --- 数据属性，带有默认值方便测试 ---
    property string coverSource: "file:///E:/Computer/Qt6/AmericanMusic/image/1.jpg"
    property string songTitle: "His Theme"
    property string artist: "Toby Fox"
    property var tags: [
        {
            text: "超清母带",
            borderColor: "#FFD700"
        } // 金色
        ,
        {
            text: "原唱",
            borderColor: "#FF4500"
        } // 橙红色
    ]

    color: "transparent" // 行本身是透明的，背景由父容器控制
    // Layout.preferredWidth: 500
    // Layout.preferredHeight: 80
    // --- 鼠标悬浮效果 ---
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
    // 当悬浮时，显示一个半透明的背景色
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#FFFFFF" // 白色
        opacity: mouseArea.containsMouse ? 0.1 : 0 // 悬浮时10%不透明度
        Behavior on opacity {
            OpacityAnimator {
                duration: 200
            }
        }
    }

    // --- 整体布局：使用 RowLayout 水平排列 ---
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        // --- 1. 封面图 ---
        Item {
            id: coverContainer
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60

            // 封面图
            Image {
                id: coverImage
                anchors.fill: parent
                source: root.coverSource
                fillMode: Image.PreserveAspectCrop
                Rectangle {
                    radius: 8
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 0
                }
            }

            // 悬浮时出现的播放按钮
            Image {
                id: playOverlayIcon
                anchors.centerIn: parent
                width: 32
                height: 32
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-fill.svg"
                opacity: 0 // 初始时透明
            }
        }

        // --- 2. 歌曲信息（垂直排列：标题 + 标签和歌手） ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            // 歌曲标题
            Label {
                text: root.songTitle
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

            // 标签和歌手（水平排列）
            RowLayout {
                spacing: 8

                // 动态创建标签
                Repeater {
                    model: root.tags
                    delegate: Rectangle {
                        height: 20
                        // 宽度由内部的 Label 决定
                        width: tagLabel.width + 12
                        color: "transparent"
                        radius: 4
                        border.color: "#FFD700"
                        border.width: 1

                        Label {
                            id: tagLabel
                            anchors.centerIn: parent
                            text: "超清母带"
                            color: "#FFD700"
                            font.pixelSize: 12
                        }
                    }
                }

                // 歌手名
                Label {
                    text: root.artist
                    color: "#AAAAAA"
                    font.pixelSize: 14
                    // 当标签过多时，这个 Label 会被挤压，并显示省略号
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
        // --- 3. 右侧控制按钮 (初始时透明) ---
        RowLayout {
            id: controlButtons
            spacing: 15
            opacity: 0 // 初始时整个容器透明
            Layout.rightMargin: 20 // 例如，给它一个比全局小的特殊边距
            // 简单的图标按钮实现
            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-fill.svg"
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }
            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-fill.svg"
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }
            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-fill.svg"
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }
        }
    }
    // --- 核心：状态和过渡动画 ---
    states: [
        State {
            name: "hovered"
            // 当鼠标进入时，此状态被激活
            when: mouseArea.containsMouse

            // 描述在此状态下，哪些属性需要改变
            PropertyChanges {
                playOverlayIcon.opacity: 1 // 封面播放按钮变得可见
            }
            PropertyChanges {
                controlButtons.opacity: 1 // 右侧控制按钮容器变得可见
            }
        }
    ]

    transitions: [
        Transition {
            // 对 opacity 属性的变化应用平滑动画
            NumberAnimation {
                property: "opacity"
                duration: 250 // 动画时长
                easing.type: Easing.InOutQuad
            }
        }
    ]
}
