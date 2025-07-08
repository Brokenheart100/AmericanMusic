// PlayerBar.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// 播放栏的根容器
Rectangle {
    id: root

    // --- 数据属性 ---
    property string coverSource: "qrc:/images/player/cover.jpg"
    property string songTitle: "Take Me Hand"
    property string artist: "DAISHI DANCE / Cécile Corbel"
    property var tags: [
        {
            text: "超清母带",
            borderColor: "#FFD700"
        },
        {
            text: "原唱",
            borderColor: "#FF4500"
        }
    ]

    // --- 视觉属性 ---
    width: 600
    height: 80
    color: "#2C2C2C" // 深灰色背景
    radius: 16

    // --- 鼠标悬浮区域 ---
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    // --- 整体布局：使用 RowLayout 水平排列 ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 20
        spacing: 15

        // --- 1. 封面图区域 (包含悬浮播放按钮) ---
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
                source: "qrc:/svg/play_overlay.svg"
                opacity: 0 // 初始时透明
            }
        }

        // --- 2. 歌曲信息 ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: root.songTitle
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }
            RowLayout {
                spacing: 8
                Repeater {
                    model: root.tags
                    delegate: /* ... 和之前 SongItem 一样的标签代码 ... */ Rectangle {}
                }
                Label {
                    text: root.artist
                    color: "#AAAAAA"
                    font.pixelSize: 14
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

            // 简单的图标按钮实现
            Image {
                source: "qrc:/svg/download.svg"
                width: 24
                height: 24
            }
            Image {
                source: "qrc:/svg/heart.svg"
                width: 24
                height: 24
            }
            Image {
                source: "qrc:/svg/more.svg"
                width: 24
                height: 24
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
                target: playOverlayIcon
                opacity: 1 // 封面播放按钮变得可见
            }
            PropertyChanges {
                target: controlButtons
                opacity: 1 // 右侧控制按钮容器变得可见
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
