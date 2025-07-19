import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    visible: true
    color: "#EFEBE8"
    anchors.fill: parent
    RowLayout {
        anchors.fill: parent
        ConversationListView {}
        ChatView {}
    }
}
