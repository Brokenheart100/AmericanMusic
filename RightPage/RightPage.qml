import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: rightPage
    Component.onCompleted: {
        console.log("RightPage initialized");
        setCurrentPage(2); // 默认显示音乐精选页面
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
        Component {
            id: chatPage
            ChatPage {}
        }
        initialItem: MusicCherryPick {}
    }

    // --- 核心修正：正确的页面切换函数 ---
    function setCurrentPage(index) {
        if (index === 0) {
            mainStackView.replace(musicCherryPick);
        } else if (index === 1) {
            mainStackView.replace(playlistDetailPage);
        } else if (index === 2) {
            mainStackView.replace(chatPage);
        } else {
            console.warn("未知的页面索引:", index);
        }
    }
}
