// ContactsPage.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

/*!
* @brief 联系人页面，使用 ListView 实现了 QQ 风格的可折叠好友列表。
*/
Rectangle {
    id: contactsRoot
    color: "#FFFFFF" // 整个页面的背景色

    // --- 数据源 (Source of Truth) ---
    // 使用一个 JavaScript 数组来存储完整的、有层级的好友数据。
    // 这样做比 ListModel 更容易进行动态修改。
    property var contactData: [
        {
            type: "group" // 类型：分组
            ,
            name: "我的设备 0/1",
            isExpanded: false // 默认折叠
            ,
            children: [] // 这个分组没有好友
        },
        {
            type: "group",
            name: "【 ε-世界线】 21/29",
            isExpanded: false // 默认折叠
            ,
            children: [
                {
                    type: "contact",
                    name: "土豆",
                    avatar: "qrc:/avatars/avatar1.png"
                },
                {
                    type: "contact",
                    name: "GLORY",
                    avatar: "qrc:/avatars/avatar2.png"
                },
                {
                    type: "contact",
                    name: "Mr.王子",
                    avatar: "qrc:/avatars/avatar3.png"
                },
                {
                    type: "contact",
                    name: "oxygen",
                    avatar: "qrc:/avatars/avatar4.png"
                }
                // ...可以添加更多好友
            ]
        },
        {
            type: "group",
            name: "【 β-世界线】 19/43",
            isExpanded: false,
            children: [
                {
                    type: "contact",
                    name: "联系人A",
                    avatar: "qrc:/avatars/avatar5.png"
                },
                {
                    type: "contact",
                    name: "联系人B",
                    avatar: "qrc:/avatars/avatar6.png"
                }
            ]
        }
        // ...可以添加更多分组
    ]

    // --- 显示模型 ---
    // 这个 ListModel 是 ListView 真正绑定的模型。
    // 它的内容会根据 contactData 的状态动态生成。
    ListModel {
        id: displayModel
    }

    // --- 初始化和刷新逻辑 ---
    Component.onCompleted: {
        rebuildDisplayModel(); // 组件加载完成后，首次构建显示模型
    }

    // 核心函数：根据 contactData 重建 displayModel
    function rebuildDisplayModel() {
        displayModel.clear();
        for (let i = 0; i < contactData.length; ++i) {
            const group = contactData[i];
            // 1. 添加分组标题到显示模型
            displayModel.append({
                "type": "group",
                "name": group.name,
                "isExpanded": group.isExpanded,
                "originalIndex": i // 记住它在原始数据中的索引
            });

            // 2. 如果分组是展开的，添加它的子项（好友）
            if (group.isExpanded) {
                for (let j = 0; j < group.children.length; ++j) {
                    const contact = group.children[j];
                    displayModel.append({
                        "type": "contact",
                        "name": contact.name,
                        "avatar": contact.avatar
                    });
                }
            }
        }
    }

    // --- 界面布局 ---
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // --- 1. 左侧：联系人列表 ---
        Rectangle {
            id: contactListColumn
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: "#FFFFFF" // 列表区背景色

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部搜索框和好友/群聊切换
                Item {
                    Layout.preferredHeight: 100 // 给予足够空间
                    Layout.fillWidth: true

                    // ... (搜索框和按钮的代码可以放在这里) ...
                    TextField {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 10
                        width: parent.width - 20
                        placeholderText: "搜索"
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 40
                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            spacing: 20
                            Text {
                                text: "好友"
                                font.bold: true
                                color: "#007BFF"
                            }
                            Text {
                                text: "群聊"
                                color: "gray"
                            }
                        }
                    }
                }

                // --- 使用 ListView 实现可折叠列表 ---
                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: displayModel // 绑定到动态的 displayModel
                    clip: true

                    // --- 列表项的代理 ---
                    delegate: Item {
                        width: listView.width
                        height: model.type === "group" ? 40 : 50

                        // --- 分组标题的代理 ---
                        Rectangle {
                            visible: model.type === "group"
                            width: parent.width
                            height: parent.height
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10

                                // 展开/折叠的箭头
                                Text {
                                    text: model.isExpanded ? "▼" : "▶"
                                    font.pixelSize: 10
                                    color: "gray"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    text: model.name
                                    font.pixelSize: 14
                                    color: "#333333"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            // 点击区域，覆盖整个分组行
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // 核心交互逻辑：
                                    // 1. 找到原始数据中的分组
                                    const groupIndex = model.originalIndex;
                                    // 2. 切换其 isExpanded 状态
                                    contactData[groupIndex].isExpanded = !contactData[groupIndex].isExpanded;
                                    // 3. 触发模型重建
                                    rebuildDisplayModel();
                                }
                            }
                        }

                        // --- 联系人项的代理 ---
                        Rectangle {
                            visible: model.type === "contact"
                            width: parent.width
                            height: parent.height
                            // 选中时高亮
                            color: mouseArea.containsMouse ? "#F0F0F0" : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 30 // 缩进，看起来像子项
                                spacing: 10

                                Image {
                                    source: model.avatar
                                    width: 36
                                    height: 36
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    text: model.name
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }
                }
            }
        }

        // --- 2. 右侧：内容区域 (占位符) ---
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFFFFF"
            border.color: "#E0E0E0"
            border.width: 1

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 15
                Image {
                    source: "qrc:/images/placeholder_friends.svg"
                    width: 100
                    height: 100
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "打开世界的另一扇窗"
                    font.pointSize: 20
                }
                Text {
                    text: "主动一点，世界会更大。"
                    color: "gray"
                }
            }
        }
    }
}
