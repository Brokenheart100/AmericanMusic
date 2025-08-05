// ContactsView.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// 模拟数据：联系人列表

/*!
* @brief 联系人主页面
* 包含左侧的好友/群组列表和右侧的内容显示区。
*/
RowLayout {
    spacing: 5
    ListModel {
        id: contactsModel
        // 分组 1
        ListElement {
            type: "group"
            name: "我的设备 0/1"
            isExpanded: true
        }

        // 分组 2
        ListElement {
            type: "group"
            name: "【 ε-世界线】 22/29"
            isExpanded: true
        }
        ListElement {
            type: "contact"
            name: "土豆"
            avatar: "file:///E:/Computer/Qt6/AmericanMusic/svg/mail-fill.svg"
        }
        ListElement {
            type: "contact"
            name: "GLORY"
            avatar: "file:///E:/Computer/Qt6/AmericanMusic/svg/mail-fill.svg"
        }
        ListElement {
            type: "contact"
            name: "Mr.王子"
            avatar: "file:///E:/Computer/Qt6/AmericanMusic/svg/mail-fill.svg"
        }
    }

    // --- 1. 左侧：联系人列表 ---
    Rectangle {
        Layout.preferredWidth: 250
        Layout.fillHeight: true
        color: "#F7F7F7"
        border.color: "#E0E0E0"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 顶部的好友/群聊切换栏
            Rectangle {
                Layout.preferredHeight: 50
                Layout.fillWidth: true
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    Button {
                        text: "好友"
                        flat: true
                        font.bold: true
                    }
                    Button {
                        text: "群聊"
                        flat: true
                        enabled: false
                    }
                }
            }

            // 联系人列表
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: contactsModel

                delegate: Item {
                    width: parent.width
                    // 根据类型决定代理的高度
                    height: model.type === "header" ? 30 : 50

                    // 如果是分组标题
                    Rectangle {
                        visible: model.type === "header"
                        width: parent.width
                        height: 30
                        color: "#F0F0F0"
                        Text {
                            text: "▶ " + model.name
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            font.pixelSize: 12
                            color: "gray"
                        }
                    }

                    // 如果是联系人
                    RowLayout {
                        visible: model.type === "contact"
                        anchors.fill: parent
                        anchors.leftMargin: 20

                        Image {
                            source: model.avatar
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Text {
                            text: model.name
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    // --- 2. 右侧：内容区域 ---
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#FFFFFF"

        // 占位符内容
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 15

            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/6.jpg" // 一个占位符图标
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "打开世界的另一扇窗"
                font.pointSize: 20
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "主动一点，世界会更大。"
                color: "gray"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
