import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    height: 90
    width: parent.width
    color: "#16161A" // 深邃的背景色

    // 顶部进度条
    Rectangle {
        id: progressBar
        width: parent.width * 0.4 // 假设播放了 40%
        height: 3
        color: "#EF4444" // 红色
        anchors.top: parent.top
    }

    // --- 主内容布局 ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 5

        // --- 1. 左侧歌曲信息 ---
        RowLayout {
            Layout.preferredWidth: 120
            Layout.alignment: Qt.AlignVCenter
            SongInfo {
                id: songInfoArea
            }
            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/playstation-fill.svg"
            }
            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/message-2-fill.svg"
            }
        }
        Item {
            Layout.fillWidth: true
        }
        // --- 2. 中间主要控制区 ---
        RowLayout {
            spacing: 5
            Layout.alignment: Qt.AlignHCenter
            // Layout.minimumWidth: 200
            Layout.preferredWidth: 120
            // Layout.maximumWidth: 150
            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/terminal-box-fill.svg"
            }
            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/skip-back-fill.svg"
            } // 带数字15的图标需要特殊处理

            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/skip-back-fill.svg"
                iconSize: 28
                hoverColor: "#EF4444"
            }
            // 中间的播放/暂停大按钮
            Button {
                id: playPauseButton
                property bool playing: true
                icon.source: playing ? "file:///E:/Computer/Qt6/AmericanMusic/svg/play-circle-fill.svg" : "file:///E:/Computer/Qt6/AmericanMusic/svg/play-circle-line.svg"
                icon.width: 48
                icon.height: 48
                icon.color: "#EF4444"
                background: Rectangle {
                    color: "transparent"
                }
                onClicked: playing = !playing
            }
            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/skip-forward-fill.svg"
                iconSize: 28
            }
            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/replay-30-fill.svg"
            } // 带数字30的图标
            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-list-2-line.svg"
            }
        }

        // --- 3. 弹簧，将中间和右侧区域分开 ---
        Item {
            Layout.fillWidth: true
        }

        // --- 4. 右侧附加控制区 ---
        RowLayout {
            spacing: 5
            Layout.alignment: Qt.AlignHCenter
            // width: 50
            // Layout.alignment: Qt.AlignRight
            // 播放速度按钮
            Button {
                id: speedButton // <-- 1. 给 Button 一个 id
                text: "1.25X"
                font.pixelSize: 15
                padding: 6 // 左右各6px的padding
                topPadding: 4 // 上下各4px的padding
                bottomPadding: 4
                leftPadding: 4
                rightPadding: 4
                background: Rectangle {
                    color: "transparent"
                    border.color: "#A9A9C4"
                    border.width: 1
                    radius: 4
                }
                contentItem: Label {
                    // 2. 通过 id 引用 Button 的 text 属性
                    text: speedButton.text
                    color: "#A9A9C4"
                    padding: 2
                }
            }

            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/home-2-fill.svg"
            }
            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/home-2-fill.svg"
            }
            IconButton1 {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/home-2-fill.svg"
            }
        }
    }
}
