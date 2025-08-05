import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 封装的聊天列表面板组件
Rectangle {
    id: root

    // --- 公共接口 (API) ---
    // property: 接收外部传入的数据
    // signal: 向外部发送事件通知

    // 1. 属性(Property): 用于接收聊天数据的模型
    // 在使用此组件时，需要为其提供一个符合格式的ListModel
    property var chatModel

    // 2. 信号(Signal): 当一个聊天项被选中时发出
    // 参数 itemData 包含了被点击项在模型中的所有数据 (name, avatar, etc.)
    signal chatItemSelected(var itemData)

    // --- 内部实现 ---

    color: "#f5f5f5"
    border.color: "#e0e0e0"
    border.width: 1

    ListModel {
        id: groupChatModel
        ListElement {
            type: "header"
            title: "我的群聊"
            count: 18
            current: 10
            isExpanded: true
        }
        ListElement {
            type: "item"
            name: "ususuSUS"
            avatar: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
            timestamp: "18:46"
            isVisible: true
        }
        ListElement {
            type: "item"
            name: "高九复读交流群"
            avatar: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
            timestamp: "昨天"
            isVisible: true
        }
        ListElement {
            type: "item"
            name: "BKTV"
            avatar: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
            timestamp: "5-28"
            isVisible: true
        }
        // ... 其他数据
    }

    // --- 主布局 ---
    RowLayout {
        anchors.fill: parent
        spacing: 5

        // --- 左侧：调用我们封装的组件 ---
        ChatListPanel {
            id: chatPanel
            Layout.preferredWidth: 280 // 在布局中指定宽度
            Layout.fillHeight: true

            // 1. 将数据模型传递给组件的 chatModel 属性
            chatModel: groupChatModel

            // 2. 监听组件发出的 chatItemSelected 信号
            onChatItemSelected: itemData => {
                // 当信号发生时，这里的代码会被执行
                // itemData 就是组件传递出来的被点击项的数据
                console.log("Chat item selected:", itemData.name);

                // 更新右侧面板的内容
                placeholder.visible = false;
                chatView.visible = true;
                chatViewTitle.text = itemData.name;
                chatViewContent.text = "正在与 " + itemData.name + " 聊天...";
            }
        } 

        // --- 右侧主内容区 (现在可以响应点击事件了) ---
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            background: Rectangle {
                color: "#ffffff"
            }

            // 初始占位符
            ColumnLayout {
                id: placeholder
                anchors.centerIn: parent
                spacing: 20
                // ... (与上一版相同的占位符内容)
                Label {
                    text: "打开世界的另一扇窗"
                    font.pixelSize: 22
                    color: "#a0a0a0"
                }
                Label {
                    text: "主动一点，世界会更大。"
                    font.pixelSize: 14
                    color: "#c0c0c0"
                }
            }

            // 聊天视图 (默认不可见)
            ColumnLayout {
                id: chatView
                anchors.fill: parent
                visible: false

                Label {
                    id: chatViewTitle
                    text: "Chat Title"
                    font.bold: true
                    font.pixelSize: 18
                    padding: 15
                    background: Rectangle {
                        color: "#f9f9f9"
                        border.color: "#eee"
                        border.width: 1
                    }
                    Layout.fillWidth: true
                }
                Label {
                    id: chatViewContent
                    text: "Chat content goes here..."
                    padding: 15
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
