import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: rightPage
    Component.onCompleted: {
        console.log("RightPage initialized");
        setCurrentPage(1); // 默认显示音乐精选页面
    }
    // --- 声明 UI 结构 ---
    StackView {
        id: mainStackView
        anchors.fill: parent
        clip: true
        Component {
            id: musicCherryPick
            MusicCherryPick {}
        }
        Component {
            id: playlistDetailPage
            PlaylistDetailPage {}
        }
        initialItem: MusicCherryPick {}
    }

    // --- 核心修正：正确的页面切换函数 ---
    function setCurrentPage(index) {
        if (index === 0) {
            mainStackView.replace(musicCherryPick);
        } else if (index === 1) {
            mainStackView.replace(playlistDetailPage);
        } else {
            console.warn("未知的页面索引:", index);
        }
    }

    function showPlaylist(playlistId) {
    // 这个函数用于打开特定的歌单详情页
    // mainStackView.push(playlistPage, {
    //     "playlistId": playlistId
    // }); // 可以传递参数
    }
}
