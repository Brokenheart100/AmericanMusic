import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls

Rectangle {
    id: root
    // 数据属性
    property int rank: 1
    property string coverSource: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/0.jpg"
    property string title: "STAY"

    property string artist: "The Kid LAROI / Justin Bieber"
    property string album: "STAY"
    property string duration: "02:21"
    property var tags: []

    // 视觉属性
    width: parent.width
    height: 60

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
    color: mouseArea.containsMouse ? "#babab1" : "transparent"
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 15
        // --- 1. 序号 / 播放按钮区域 ---
        Item {
            id: rankPlayContainer
            Layout.preferredWidth: 20
            Layout.preferredHeight: parent.height

            Label { // 序号
                id: rankLabel
                anchors.centerIn: parent
                text: root.rank.toString().padStart(2, '0')
                color: "#888"
                font.pixelSize: 14
            }
            Image { // 播放按钮
                id: playIcon
                anchors.centerIn: parent
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-circle-fill.svg" // 一个灰色的播放图标
                width: 24
                height: 24
                opacity: 0 // 默认隐藏
            }
        }

        // --- 2. 封面图 ---
        Image {
            id: coverImage
            source: root.coverSource
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: "transparent"
            }
        }
        // --- 3. 歌曲信息 (标题、标签、作者) ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4
            RowLayout {
                Label {
                    id: titleLabel
                    text: root.title
                    color: "white"
                    font.pixelSize: 16
                }
            }
            Label {
                id: artistLabel
                text: root.artist
                color: "#888"
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }
        // --- 4. 悬浮时出现的操作按钮 ---
        RowLayout {
            id: actionButtons
            spacing: 15
            opacity: 0 // 默认透明
            Layout.preferredWidth: 0 // 默认宽度为0

            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-circle-fill.svg"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }
            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-circle-fill.svg"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }
            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-circle-fill.svg"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }
            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-circle-fill.svg"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }
        }

        // --- 5. 专辑、喜欢、时长 ---
        Label {
            id: albumLabel
            text: root.album
            color: "#888"
            Layout.preferredWidth: 150
            elide: Text.ElideRight
        }
        Image {
            id: heartIcon
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-circle-fill.svg"
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }
        Label {
            id: durationLabel
            text: root.duration
            color: "#888"
            font.pixelSize: 14
        }
    }
    // --- 核心：状态和过渡 ---
    states: [
        State {
            name: "hovered"
            when: mouseArea.containsMouse
            // --- 定义悬浮状态下的属性变化 ---
            PropertyChanges {
                explicit: true
                rankLabel.opacity: 0
            } // 隐藏序号
            PropertyChanges {
                explicit: true
                playIcon.opacity: 1
            } // 显示播放按钮

            // 显示操作按钮 RowLayout
            PropertyChanges {
                actionButtons.opacity: 1
            }

            // 作者名 Label 变亮
            PropertyChanges {
                artistLabel.color: "white"
            }
        }
    ]

    // 为布局和透明度的变化添加动画
    transitions: Transition {
        NumberAnimation {
            properties: "opacity, Layout.preferredWidth, Layout.rightMargin"
            duration: 200
            easing.type: Easing.InOutQuad
        }
        ColorAnimation {
            duration: 200
        }
    }
}
