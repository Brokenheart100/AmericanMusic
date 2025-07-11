import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Window {
    id: mainWindow
    width: 1200
    height: 720
    visible: true
    title: qsTr("nmdmp")

    LeftPage {
        id: leftRect
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: bottomRect.top
        width: 220
        // --- 核心联动：连接信号和槽 ---
        onButtonClicked: index => {
            console.log("Main.qml received buttonClicked signal with index:", index);
            rightRect.setCurrentPage(index);
        }

        onNavigationClicked: index => {
            console.log("Main.qml received navigationClicked signal with index:", index);
            rightRect.setCurrentPage(index);
        }
    }
    TitleBar {
        id: titleBar
        anchors.left: leftRect.right
        anchors.right: parent.right
        anchors.top: parent.top
        height: 40
    }
    RightPage {
        id: rightRect
        anchors.left: leftRect.right
        anchors.right: parent.right
        anchors.top: titleBar.bottom
        anchors.bottom: bottomRect.top
        color: "#4848e1"
    }
    BottomBar {
        id: bottomRect
        // height: 150
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#35df98"
    }
    // MusicPlayer {
    //     anchors.centerIn: parent
    // }
}
