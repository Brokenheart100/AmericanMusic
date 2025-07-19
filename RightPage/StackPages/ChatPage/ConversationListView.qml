pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#F7F7F7"
    Layout.preferredWidth: 280
    Layout.fillHeight: true
    property int currentIndex: 0 // 控制当前选中的是哪一项

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            // 搜索框区域
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

        ListModel {
            id: animalModel
            ListElement {
                name: "猫"
                type: "哺乳动物"
            }
            ListElement {
                name: "鸟"
                type: "鸟类"
            }
        }
        ListModel {
            id: conversations
            // 数据项：每个ListElement是一条数据
            ListElement {
                name: "小..."
                lastMessage: "对方已成..."
                avatar: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/2.jpg"
            }
            ListElement {
                name: "天..."
                lastMessage: "对方已..."
                avatar: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/5.jpg"
            }
            ListElement {
                name: "H... 星..."
                lastMessage: "哈哈哈..."
                avatar: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/9.jpg"
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: conversations // 使用单例数据
            currentIndex: 0
            delegate: ConversationItem {
                id: conversationItem
                // 将模型数据绑定到代理的属性上
                required property string name
                required property string lastMessage
                required property string avatar
                required property int index
                convName: name
                lastMessage: lastMessage
                avatarSource: avatar
                isSelected: root.currentIndex === index
                onClicked: {
                    root.currentIndex = index;
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.currentIndex = conversationItem.index;
                        console.log("Clicked item index:", conversationItem.index);
                    }
                }
            }
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }
}
