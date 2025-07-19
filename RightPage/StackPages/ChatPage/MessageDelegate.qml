import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    implicitHeight: contentRow.implicitHeight + 15 // 动态计算高度

    // 公共属性
    property string msgType: "system"
    property string author: "nmd"
    property string text: "fuck"
    property url avatar: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/25.jpg"

    RowLayout {
        id: contentRow
        width: parent.width
        spacing: 15
        // 如果是系统消息
        Label {
            visible: root.msgType === "system"
            text: root.text
            color: "#AAA"
            background: Rectangle {
                color: "#E0E0E0"
                radius: 4
            }
            padding: 4
            Layout.alignment: Qt.AlignHCenter
        }

        // 如果是接收的消息
        Item {
            visible: root.msgType === "incoming"
            Layout.maximumWidth: parent.width * 0.6
            Layout.leftMargin: 15

            Image {
                source: root.avatar
                width: 40
                height: 40
                clip: true
                Rectangle {
                    anchors.fill: parent
                    radius: parent.width / 2
                    color: "transparent"
                }
            }
            ColumnLayout {
                Label {
                    text: root.author
                    color: "#888"
                }
                Rectangle {
                    color: "white"
                    radius: 8
                    Label {
                        text: root.text
                        anchors.margins: 10
                    }
                }
            }
        }

        // 如果是发送的消息
        Item {
            visible: root.msgType === "outgoing"
            Layout.maximumWidth: parent.width * 0.6
            Layout.rightMargin: 15
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            } // 弹簧
            ColumnLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: root.author
                    color: "#888"
                    Layout.alignment: Qt.AlignRight
                }
                Rectangle {
                    color: "#95EC69"
                    radius: 8
                    Label {
                        text: root.text
                        anchors.margins: 10
                    }
                }
            }
            Image {
                source: root.avatar
                width: 40
                height: 40
                clip: true
                Rectangle {
                    anchors.fill: parent
                    radius: parent.width / 2
                    color: "transparent"
                }
            }
        }
    }
}
