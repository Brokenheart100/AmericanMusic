import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import AmericanMusic 1.0 // 假设 AmericanMusic 是你的模块名
import QtMultimedia
import Qt.labs.platform 1.1

Rectangle {
    id: root
    height: 90
    width: parent.width
    color: "#16161A" // 深邃的背景色

    ColumnLayout {
        anchors.fill: parent
        spacing: 10 // 进度条和内容栏之间不需要间距

        // --- 1. 进度条 ---
        Slider {
            id: progressBar
            Layout.fillWidth: true
            Layout.preferredHeight: 1 // 设置进度条的高度
            from: 0
            to: musicPlayer.duration
            value: musicPlayer.position

            onMoved: {
                musicPlayer.setPosition(value);
            }

            // --- 核心修正：自定义 background 和 handle ---
            background: Rectangle {
                id: progressBarBackground
                // 让背景填满 Slider 的可用空间
                // Slider 会自动为 handle 留出空间，所以我们限制一下
                width: parent.width
                height: 3
                anchors.verticalCenter: parent.verticalCenter
                color: "#555"

                Rectangle {
                    // 已播放的部分
                    width: progressBar.visualPosition * progressBarBackground.width
                    height: parent.height
                    color: "#EF4444"
                }

                // --- 在背景上覆盖一个 MouseArea 来处理点击和拖动 ---
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor // 悬浮时显示手形光标

                    // 当鼠标按下或拖动时触发
                    onPositionChanged: mouse => handleMouse(mouse)
                    onPressed: mouse => handleMouse(mouse)

                    function handleMouse(mouse) {
                        // 计算点击位置在进度条上的百分比
                        var positionRatio = mouse.x / progressBarBackground.width;

                        // 确保百分比在 0.0 到 1.0 之间
                        positionRatio = Math.max(0.0, Math.min(1.0, positionRatio));
                        musicPlayer.setPosition(positionRatio * progressBar.to);

                    // 调用全局播放器进行 seek 操作
                    }
                }
            }
        }
        // --- 主内容布局 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true // 填满 ColumnLayout 的剩余高度
            Layout.leftMargin: 20
            Layout.rightMargin: 20
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
                Layout.preferredWidth: 120
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
                    onClicked: musicPlayer.previous()
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
                    onClicked: {
                        playing = !playing; // 切换播放状态
                        if (musicPlayer.status === MediaPlayer.PlayingState) {
                            musicPlayer.pause();
                        } else {
                            musicPlayer.play(musicPlayer.currentIndex !== -1 ? musicPlayer.currentIndex : 0);
                        }
                    }
                }
                IconButton1 {
                    iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/skip-forward-fill.svg"
                    iconSize: 28
                    onClicked: musicPlayer.next()
                }
                IconButton1 {
                    iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/replay-30-fill.svg"
                } // 带数字30的图标
                IconButton1 {
                    iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-list-2-line.svg"
                    onClicked: {
                        musicPlayer.openFolder();
                        console.log("Open folder dialog triggered");
                    }
                }
            }
            function formatTime(ms) {
                if (isNaN(ms) || ms <= 0) {
                    return "00:00";
                }
                var totalSeconds = Math.floor(ms / 1000);
                var minutes = Math.floor(totalSeconds / 60);
                var seconds = totalSeconds % 60;
                var formattedMinutes = (minutes < 10 ? "0" : "") + minutes;
                var formattedSeconds = (seconds < 10 ? "0" : "") + seconds;
                return formattedMinutes + ":" + formattedSeconds;
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
}
