pragma ComponentBehavior: Bound
// UnifiedChatView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/*!
* @brief 一个统一的聊天视图组件。
*
* 将会话列表和聊天窗口合并在一个视图中，形成经典的三栏式布局。
* 左侧显示所有会话，右侧显示当前选中会话的聊天内容。
*/
Item {
    id: unifiedViewRoot

    // --- 模拟数据 ---

    // 会话列表数据模型
    ListModel {
        id: conversationsModel
        ListElement {
            name: "高九复读交流群"
            lastMessage: "😆55555..."
            avatar: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/2.jpg"
            memberCount: 4
            // 为每个会话关联一个独特的聊天记录模型

        }
        ListElement {
            name: "usususus"
            lastMessage: "啥情况"
            avatar: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/5.jpg"
            memberCount: 12
        }
    }

    // --- 布局 ---

    // 使用 RowLayout 将左右两个区域水平排列
    RowLayout {
        anchors.fill: parent
        spacing: 0 // 两个区域之间没有间隙

        // ===================================
        // 1. 左侧区域：会话列表
        // ===================================
        Rectangle {
            id: conversationColumn
            color: "#F7F7F7"
            Layout.preferredWidth: 280
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 搜索框区域
                Rectangle {
                    color: "#F7F7F7"
                    Layout.preferredHeight: 60
                    Layout.fillWidth: true
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        TextField {
                            placeholderText: "搜索"
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "#E9E9E9"
                                radius: 4
                            }
                        }
                        Button {
                            text: "+"
                            font.pixelSize: 20
                            flat: true
                        }
                    }
                }

                // 会话列表视图
                ListView {
                    id: conversationListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: conversationsModel
                    currentIndex: 0 // 默认选中第一项

                    // 会话列表项的代理
                    delegate: Rectangle {
                        required property int index
                        width: parent.width
                        height: 60
                        // 根据是否为当前选中项来改变背景色
                        color: ListView.isCurrentItem ? "#E0E0E0" : "transparent"

                        property bool isSelected: ListView.isCurrentItem

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            Image {
                                source: conversationListView.model.avatar
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                Layout.alignment: Qt.AlignVCenter
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text {
                                    text: conversationListView.model.name
                                    font.bold: true
                                }
                                Text {
                                    text: conversationListView.model.lastMessage
                                    color: "gray"
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: conversationListView.currentIndex = index
                        }
                    }
                    ScrollIndicator.vertical: ScrollIndicator {}
                }
            }
        }

        // ===================================
        // 2. 右侧区域：聊天视图
        // ===================================
        Rectangle {
            id: chatViewColumn
            color: "#EFEBE8"
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 从模型中获取当前选中的会话数据
            property var currentConversation: conversationsModel.get(conversationListView.currentIndex)

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 标题栏
                Rectangle {
                    color: "#F5F5F5"
                    Layout.preferredHeight: 60
                    Layout.fillWidth: true
                    border.color: "#E0E0E0"
                    border.width: 1
                    Label {
                        // 标题绑定到当前选中会话的名称和成员数
                        text: `${chatViewColumn.currentConversation.name} (${chatViewColumn.currentConversation.memberCount})`
                        font.pixelSize: 18
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }

                // 聊天消息列表视图
                ListView {
                    id: messageListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 15
                    // 关键：模型绑定到当前选中会话的聊天记录
                    model: chatViewColumn.currentConversation.chatHistory

                    // 消息项的代理
                    delegate: Item {
                        width: parent.width
                        height: messageRow.height + 20

                        RowLayout {
                            id: messageRow
                            width: parent.width
                            spacing: 10

                            // 根据消息类型决定布局方向
                            layoutDirection: messageListView.model.type === "outgoing" ? Qt.RightToLeft : Qt.LeftToRight

                            Image {
                                source: messageListView.model.avatar
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                Layout.alignment: Qt.AlignTop
                            }

                            ColumnLayout {
                                // 根据消息类型决定对齐方式
                                Layout.alignment: messageListView.model.type === "outgoing" ? Qt.AlignRight : Qt.AlignLeft

                                Text {
                                    text: messageListView.model.author
                                    color: "gray"
                                    font.pixelSize: 12
                                    // 根据消息类型决定文本对齐
                                    horizontalAlignment: messageListView.model.type === "outgoing" ? Text.AlignRight : Text.AlignLeft
                                }

                                Rectangle {
                                    color: messageListView.model.type === "outgoing" ? "#A0E75A" : "#FFFFFF"
                                    border.color: "#E0E0E0"
                                    radius: 8
                                    implicitWidth: messageText.implicitWidth + 20
                                    implicitHeight: messageText.implicitHeight + 12

                                    Text {
                                        id: messageText
                                        text: "123456sadsada"
                                        anchors.centerIn: parent
                                        wrapMode: Text.Wrap
                                        // 限制文本最大宽度，防止气泡过长
                                        width: Math.min(implicitWidth, messageListView.width * 0.6)
                                    }
                                }
                            }
                            // 弹性空间，将消息推向两侧
                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // 输入区
                Rectangle {
                    color: "#F5F5F5"
                    Layout.preferredHeight: 200 // 给了足够的高度
                    Layout.fillWidth: true
                    border.color: "#E0E0E0"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        // 工具栏可以放在这里
                        /* ... */ RowLayout {}

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
                            } // 弹性空间将按钮推到右侧
                            Button {
                                text: "发送"
                            }
                        }
                    }
                }
            }
        }
    }
}
