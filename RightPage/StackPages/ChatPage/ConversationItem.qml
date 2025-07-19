import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ItemDelegate {
    id: root
    width: parent.width
    height: 70

    // 公共属性，让外部可以设置数据
    property string convName: "User Name"
    property string lastMessage: "Last Message"
    property url avatarSource: ""

    property bool isSelected
    background: Rectangle {
        color: root.isSelected ? "#D9D9D9" : (root.hovered ? "#E9E9E9" : "transparent")
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Image {
            source: root.avatarSource
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            fillMode: Image.PreserveAspectCrop
            clip: true
            Rectangle {
                anchors.fill: parent
                radius: parent.width / 2
                color: "transparent"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Label {
                text: root.convName
                font.pixelSize: 16
                elide: Text.ElideRight
            }
            Label {
                text: root.lastMessage
                color: "gray"
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Label {
                text: "13:23"
                color: "gray"
            }
            Label {
                text: "✓"
                color: "gray"
            }
        }
    }
}
