pragma ComponentBehavior: Bound
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

    width: 280
    implicitHeight: 600 // 默认高度
    color: "#f5f5f5"
    border.color: "#e0e0e0"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. 搜索框区域
        Frame {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            background: Rectangle {
                color: "transparent"
            }
            padding: 10

            RowLayout {
                width: parent.width
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "搜索"
                    background: Rectangle {
                        color: "#eeeeee"
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

        // 2. TabBar
        TabBar {
            id: myTabBar
            Layout.fillWidth: true
            currentIndex: 1
            TabButton {
                text: "好友"
            }
            TabButton {
                text: "群聊"
            }
        }

        // 3. 内容区
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: myTabBar.currentIndex

            Item {
                // 好友列表页 (占位)
                Label {
                    anchors.centerIn: parent
                    text: "好友列表"
                    color: "gray"
                }
            }

            ListView { // 群聊列表页
                id: groupListView
                model: root.chatModel // 使用组件的属性作为模型
                clip: true

                delegate: Loader {
                    width: parent.width
                    height: model.isVisible ? (model.type === "header" ? 30 : 60) : 0
                    visible: model.isVisible
                    sourceComponent: model.type === "header" ? headerComponent : itemComponent
                    Behavior on height {
                        SmoothedAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }
    }

    // --- 组件定义 ---

    Component {
        id: headerComponent
        Rectangle {
            // ... (与上一版完全相同，但注意模型引用)
            width: parent.width
            height: 30
            color: "#f5f5f5"
            RowLayout {
                anchors.verticalCenter: parent
                anchors.left: parent
                anchors.leftMargin: 8
                height: parent.height
                Text {
                    text: model.isExpanded ? "▼" : "▶"
                    font.pixelSize: 10
                    color: "#888888"
                }
                Label {
                    text: `${model.title} ${model.current}/${model.count}`
                    font.pixelSize: 12
                    color: "#888888"
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    let newExpandedState = !model.isExpanded;
                    // 注意：这里操作的是 root.chatModel
                    root.chatModel.setProperty(model.index, "isExpanded", newExpandedState);

                    for (let i = model.index + 1; i < root.chatModel.count; ++i) {
                        let item = root.chatModel.get(i);
                        if (item.type === "header")
                            break;
                        root.chatModel.setProperty(i, "isVisible", newExpandedState);
                    }
                }
            }
        }
    }

    Component {
        id: itemComponent
        Rectangle {
            // ... (大部分与上一版相同，但MouseArea有改动)
            width: parent.width
            height: 60
            color: "transparent"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 4
                    color: "lightgray"
                    Image {
                        anchors.fill: parent
                        source: model.avatar
                        fillMode: Image.PreserveAspectCrop
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        text: model.name
                        font.pixelSize: 14
                        color: "#333333"
                        elide: Text.ElideRight
                    }
                }
                Label {
                    text: model.timestamp
                    font.pixelSize: 12
                    color: "#aaaaaa"
                    Layout.alignment: Qt.AlignTop
                }
            }
            Rectangle {
                id: hoverRect
                anchors.fill: parent
                color: "#e0e0e0"
                opacity: 0
                z: -1
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: hoverRect.opacity = 1
                onExited: hoverRect.opacity = 0
                onClicked: {
                    // 当被点击时，发出 chatItemSelected 信号
                    // 并将当前项的数据 (model) 作为参数传递出去
                    root.chatItemSelected(model);
                }
            }
        }
    }
}
