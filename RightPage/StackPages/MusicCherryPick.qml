import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import AmericanMusic 1.0

Item {
    id: cherryPick
    Item {
        anchors.fill: parent

        StackView {
            id: musicCherryPickStackView // 为 StackView 设置 id。
            anchors.fill: parent // 使 StackView 填充整个父元素（即这个 Item）。
            clip: true

            initialItem: CherryPick {
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
            }
            background: Rectangle {
                color: "orange"
            }
        }
    }
}
