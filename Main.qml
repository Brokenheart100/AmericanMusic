import QtQuick
import QtQuick.Controls.Basic as Basic

Window {
    id: mainWindow
    width: 800
    height: 600
    visible: true
    title: qsTr("nmdmp")
    LeftPage {
        id: leftRect
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: bottomRect.top
        // anchors.right: rightRect.left
        width: 150
        // height: 400
    }
    RightPage {
        id: rightRect
        anchors.left: leftRect.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: bottomRect.top // <-- 添加这一行来指定底部边界
        color: "#4848e1"
    }
    BottomBar {
        id: bottomRect
        height: 150
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#35df98"
    }
}
