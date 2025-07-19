import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    visible: true
    width: 1000
    height: 700
    color: "#EFEBE8"
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 直接实例化我们的视图组件
        ConversationListView {}

        ChatView {}
    }
}
