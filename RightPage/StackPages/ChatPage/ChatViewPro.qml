import QtQuick
import QtQuick.Layouts

RowLayout {
    anchors.fill: parent
    spacing: 0
    ConversationListView {
        id: conversationListView
        Layout.preferredWidth: 280
        Layout.fillHeight: true
        currentIndex: 0 // 控制当前选中的是哪一项
    }
    ChatView {
        id: chatView
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
