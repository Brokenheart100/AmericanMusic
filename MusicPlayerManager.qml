import QtQuick
import QtMultimedia // 只需导入这个
import Qt.labs.platform 1.1

// 使用 QtObject 作为根，因为它不需要可视化
QtObject {
    id: root

    // --- 私有核心组件 ---
    // 1. AudioOutput 和 MediaPlayer 作为兄弟元素
    // AudioOutput {
    //     id: audioOutput
    //     // 音量在这里控制
    //     volume: 1.0
    // }
    property AudioOutput _audioOutput: AudioOutput {
        id: audioOutput
        volume: 1.0
    }
    property MediaPlayer _player: MediaPlayer {
        id: mediaPlayer
        audioOutput: root._audioOutput // 引用下面的 _audioOutput 属性

        onMetaDataChanged: {
            // 在信号处理器中，'mediaPlayer' 就是信号的发送者
            root.currentTitle = mediaPlayer.metaData.value(QMediaMetaData.Title) || "未知歌曲";
            root.currentArtist = mediaPlayer.metaData.value(QMediaMetaData.Artist) || "未知艺术家";
            root.currentCoverArt = mediaPlayer.metaData.value(QMediaMetaData.CoverArtUrl) || "";
        }
    }

    // --- 公共属性 (Public API) ---
    // 4. 使用 property alias 直接暴露 MediaPlayer 的属性，这是最高效的方式
    readonly property alias playing: mediaPlayer.playing
    readonly property alias position: mediaPlayer.position
    readonly property alias duration: mediaPlayer.duration
    readonly property alias source: mediaPlayer.source

    // 自定义的、用于显示的元数据属性
    property string currentTitle: "请选择一首歌曲"
    property string currentArtist: ""
    property url currentCoverArt: ""

    // --- 公共方法 (Public API) ---
    function play(songUrl) {
        if (songUrl && _player.source !== songUrl) {
            _player.source = songUrl;
        }
        _player.play();
    }

    function pause() {
        _player.pause();
    }

    function seek(targetPosition) {
        if (_player.seekable) {
            _player.setPosition(targetPosition);
        }
    }
}
