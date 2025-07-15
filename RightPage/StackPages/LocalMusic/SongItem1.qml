import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls

Rectangle {
    id: root
    // 数据属性
    property int rank: 1
    property string coverSource1: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/0.jpg"
    property string title1: "STAY"
    property string artist1: "The Kid LAROI / Justin Bieber"
    property string album1: "STAY"
    property string duration1: "02:21"
    property bool isCurrent: false // 是否是当前播放项
    signal clicked
    // 视觉属性
    width: parent.width
    height: 60

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
    color: mouseArea.containsMouse ? "#babab1" : "transparent"
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 15
        readonly property real availableWidth: contentLayout.width - 60

        // --- 1. 序号 / 播放按钮区域 ---
        Item {
            id: rankPlayContainer
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20

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
                source: root.coverSource1 // 一个灰色的播放图标
                width: 24
                height: 24
                opacity: 0 // 默认隐藏
            }
        }

        // --- 2. 封面图 ---
        RowLayout {
            Layout.preferredWidth: contentLayout.availableWidth * 0.45
            Image {
                id: coverImage
                source: root.coverSource1
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                }
            }
            // --- 3. 歌曲信息 (标题、标签、作者) ---
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4
                Label {
                    id: titleLabel
                    text: root.title1
                    color: "white"
                    font.pixelSize: 16
                    elide: Text.ElideRight
                    Layout.preferredWidth: 250 // 留出专辑、喜欢、时长的空间
                }
                Label {
                    id: artistLabel
                    text: root.artist1
                    color: "#888"
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    Layout.preferredWidth: 250 // 留出专辑、喜欢、时长的空间
                }
            }
            Item {
                Layout.fillWidth: true // 填充剩余空间
            }
            // --- 4. 悬浮时出现的操作按钮 ---
            RowLayout {
                id: actionButtons
                spacing: 15
                opacity: 0 // 默认透明
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
        }
        // --- 5. 专辑、喜欢、时长 ---
        Label {
            id: albumLabel
            text: root.album1
            color: "#888"
            // Layout.preferredWidth: 150
            Layout.preferredWidth: contentLayout.availableWidth * 0.3

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
            text: root.duration1
            color: "#888"
            font.pixelSize: 14
            Layout.preferredWidth: contentLayout.availableWidth * 0.08
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
