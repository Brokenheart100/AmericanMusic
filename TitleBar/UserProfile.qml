// UserProfile.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

RowLayout {
    spacing: 10

    // 头像
    Image {
        source: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"// 你的头像图片
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        Layout.alignment: Qt.AlignVCenter
    }

    // 昵称
    Label {
        text: "Brokenheart"
        color: "white"
        font.pixelSize: 14
        elide: Text.ElideRight
        Layout.alignment: Qt.AlignVCenter
    }

    // VIP 标识
    Rectangle {
        Layout.preferredWidth: vipLabel.width + 24
        Layout.preferredHeight: 20
        radius: Layout.preferredHeight / 2
        color: "#3A3A3A"
        Layout.alignment: Qt.AlignVCenter

        RowLayout {
            anchors.centerIn: parent
            spacing: 4
            Rectangle {
                // 左侧的小圆圈
                Layout.preferredWidth: 12
                Layout.preferredHeight: 12
                radius: 6
                color: "#555"
                border.color: "#888"
                border.width: 1
            }
            Label {
                id: vipLabel
                text: "VIP 续费 >"
                color: "#E0C392"
                font.pixelSize: 11
            }
        }
    }
}
