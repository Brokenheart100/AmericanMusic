pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "#EFEBE8"
    Layout.fillWidth: true
    Layout.fillHeight: true

    Image {
        // 背景图
        source: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/49.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: 0.1
        z: -1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            // 标题栏
            color: "#F5F5F5"
            Layout.preferredHeight: 60
            Layout.fillWidth: true
            border.color: "#E0E0E0"
            border.width: 1
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                Label {
                    text: "高九复读交流群 (4)"
                    font.pixelSize: 18
                    font.bold: true
                }
                Item {
                    Layout.fillWidth: true
                }
            }
        }

        ListModel {
            id: messagesModel
            ListElement {
                type1: "outgoing"
                author1: "[小号1] LV100 群主"
                text1: "😆"
                avatar1: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/38.jpg"
            }
            ListElement {
                type1: "outgoing"
                author1: "[小号1] LV100 群主"
                text1: "😆"
                avatar1: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/37.jpg"
            }
            ListElement {
                type1: "outgoing"
                author1: "[小号1] LV100 群主"
                text1: "😆"
                avatar1: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/35.jpg"
            }
            ListElement {
                type1: "outgoing"
                author1: "[小号1] LV100 群主"
                text1: "😆"
                avatar1: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/31.jpg"
            }
        }
        ListView {
            // 消息区
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 15
            model: messagesModel
            delegate: MessageDelegate {
                required property string type1
                required property string author1
                required property string text1
                required property string avatar1
                msgType: type1
                author: author1
                text: text1
                avatar: avatar1
            }
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        Rectangle {
            // 输入区
            color: "#F5F5F5"
            Layout.minimumHeight: 150
            Layout.maximumHeight: 250
            Layout.fillWidth: true
            border.color: "#E0E0E0"
            border.width: 1
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                /* 工具栏图标 */ RowLayout {}
                TextArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "输入消息..."
                    background: Rectangle {
                        color: "transparent"
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Item {
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "发送"
                    }
                }
            }
        }
    }
}
