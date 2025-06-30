import QtQuick
import QtQuick.Controls
import AmericanMusic 1.0 // <-- 使用模块名和版本号导入

//ssh Brokenheart100@192.168.102.129
Rectangle {
    id: rightPage
    TitleBar {
        id: titleBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 40
    }
    // RectTest {
    //     anchors.top: titleBar.bottom
    //     anchors.left: parent.left
    //     anchors.right: parent.right
    //     anchors.bottom: parent.bottom
    //     anchors.bottomMargin: 100
    //     clip: true
    // }
    // 下方主页面栈区
    StackView {
        id: mainStackView
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        clip: true
        initialItem: MusicCherryPick {
            anchors.fill: parent
            // width: 300
            // height: 400
            // clip: true
        }
        // 设置StackView的背景颜色为浅蓝色
        background: Rectangle {
            color: "lightblue"
        }
    }
}
