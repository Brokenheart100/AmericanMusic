import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia
import Qt.labs.platform 1.1

Rectangle {
    id: root
    width: 400
    height: 120
    color: "#2C2C2C"
    radius: 8
    AudioOutput {
        id: audioOutput
        volume: 1.0 // 在这里设置音量
    }
    // --- MediaPlayer 核心组件 (无需改动) ---
    MediaPlayer {
        id: mediaPlayer
        // --- 核心修正 2: 将 MediaPlayer 的音频输出指向 AudioOutput ---
        audioOutput: audioOutput
        // --- 核心调试代码：添加错误监听 ---
        onErrorOccurred: {
            console.error("MediaPlayer Error Occurred!");
            console.error(" Error Code:", error);
            console.error(" Error String:", errorString);
        }

        // 也可以在状态改变时检查
        onPlaybackStateChanged: {
            console.log("Playback state changed to:", mediaPlayer.playbackState);
        }
    }

    // --- 文件选择对话框 (Qt 6 用法) ---
    FileDialog {
        id: fileDialog
        title: "请选择一个音频文件"
        fileMode: FileDialog.OpenFile // 明确指定为打开单个文件模式
        nameFilters: ["音频文件 (*.mp3 *.wav *.flac *.m4a)"]
        folder: Qt.resolvedUrl(".")
        // onAccepted 在 Qt 6 中依然有效，但更现代的用法是连接到信号
        onAccepted: {
            // 当用户选择了一个文件后，设置给 mediaPlayer
            mediaPlayer.source = fileDialog.file;
            mediaPlayer.play();
        }
    }

    // --- UI 布局 (核心修正) ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        // --- 1. 时间显示行 ---
        RowLayout {
            Layout.fillWidth: true

            Label {
                id: currentTimeLabel
                text: root.formatTime(mediaPlayer.position)
                color: "white"
            }
            Item {
                Layout.fillWidth: true
            } // 弹簧
            Label {
                id: totalTimeLabel
                text: root.formatTime(mediaPlayer.duration)
                color: "white"
            }
        }

        // --- 2. 进度条 ---
        Slider {
            id: progressBar
            Layout.fillWidth: true
            from: 0.0
            to: 1.0
            value: mediaPlayer.duration > 0 ? mediaPlayer.position / mediaPlayer.duration : 0
            onMoved: {
                if (mediaPlayer.seekable) {
                    mediaPlayer.setPosition(progressBar.value * mediaPlayer.duration);
                }
            }
        }

        // --- 3. 控制按钮行 ---
        RowLayout {
            Layout.alignment: Qt.AlignHCenter // 让这行按钮在 ColumnLayout 中居中
            spacing: 20

            Button {
                text: "选择文件"
                onClicked: fileDialog.open()
            }
            Button {
                id: playPauseButton
                text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "暂停" : "播放"
                onClicked: {
                    if (mediaPlayer.source.toString() === "") {
                        fileDialog.open();
                    } else if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                        mediaPlayer.pause();
                    } else {
                        mediaPlayer.play();
                    }
                }
            }
            Button {
                text: "停止"
                onClicked: mediaPlayer.stop()
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
}
