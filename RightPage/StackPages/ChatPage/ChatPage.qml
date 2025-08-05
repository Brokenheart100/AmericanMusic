import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    visible: true
    color: "#EFEBE8"
    anchors.fill: parent
    RowLayout {
        anchors.fill: parent
        // --- 使用我们创建的侧边栏组件 ---
        ChatLeftBar {
            id: chatSidebar
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillHeight: true

            // --- 必须提供 required 属性 ---
            avatarSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/mail-fill.svg"
            // mainIconsModel: mainIcons
            // bottomIconsModel: bottomIcons

            // --- (可选) 自定义可选属性 ---
            statusColor: "#FFA500"

            // --- 监听信号 ---
            onCurrentIndexChanged: {
                console.log("主页面切换到索引:", currentIndex);
                // mainContentText.text = "当前页面: " + mainIcons.get(currentIndex).tooltip;
            }

            onAvatarClicked: {
                console.log("点击了头像！");
            }

            onBottomIconClicked: index => {
                // 使用箭头函数语法
                console.log("点击了底部图标:", chatSidebar.bottomIconsModel.get(index).tooltip);
            }
        }
        // 2. 主内容区域
        StackLayout {
            id: mainStackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0 // 默认显示第一个页面（消息页面）

            ContactsView {
                id: contactsView
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            SuperChatView {
                id: superChatView
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            ChatViewPro {
                id: chatViewPro
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
        // ConversationListView {}
        // ChatView {}
    }
}
