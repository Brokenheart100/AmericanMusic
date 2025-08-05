pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    // 让 delegate 的高度由内部 StackLayout 动态决定
    implicitHeight: layoutSwitcher.implicitHeight

    // --- 属性定义 ---
    property string msgType: "received"
    property string author: ""
    property string text: ""
    property url avatar: ""
    property string timestamp: "21:56"

    // --- 组件定义 (将每个布局封装成一个组件，非常清晰) ---
    // 边框
    Rectangle {
        anchors.fill: parent
        color: "transparent" // 透明背景，只显示边框
        border.color: "gray"
        border.width: 1
        radius: 4 // 圆角边框
    }
    // 1. 接收消息的布局组件
    Component {
        id: receivedMessageLayout
        RowLayout {
            spacing: 10
            // 头像
            Image {
                source: root.avatar
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                fillMode: Image.PreserveAspectCrop
                clip: true
            }
            // 消息体
            ColumnLayout {
                Layout.maximumWidth: root.width * 0.65 // 消息体最大宽度
                // Layout.preferredWidth: root.width * 0.8

                spacing: 5
                // 作者
                Label {
                    text: root.author
                    color: "#666"
                    font.pixelSize: 12
                }
                // 白色气泡
                Rectangle {
                    color: "white"
                    radius: 8
                    implicitWidth: messageLabel.implicitWidth + 20
                    implicitHeight: messageLabel.implicitHeight + 20
                    Label {
                        id: messageLabel
                        text: root.text
                        anchors.fill: parent
                        anchors.margins: 10
                        wrapMode: Text.WordWrap
                    }
                }
            }
            // 弹簧：把所有内容推到左边
            Item {
                Layout.fillWidth: true
            }
        }
    }

    // 2. 发送消息的布局组件
    Component {
        id: sentMessageLayout
        RowLayout {
            spacing: 10
            // 弹簧：把所有内容推到右边
            Item {
                Layout.fillWidth: true
            }
            // 蓝色气泡
            Rectangle {
                Layout.maximumWidth: root.width * 0.65 // 消息体最大宽度
                color: "#007BFF" // 蓝色
                radius: 8
                implicitWidth: messageLabel.implicitWidth + 20
                implicitHeight: messageLabel.implicitHeight + 20
                Label {
                    id: messageLabel
                    text: root.text
                    anchors.fill: parent
                    anchors.margins: 10
                    wrapMode: Text.WordWrap
                    color: "white" // 白色文字
                }
            }
            // 头像
            Image {
                source: root.avatar
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                fillMode: Image.PreserveAspectCrop
                clip: true
            }
        }
    }

    // 3. 系统消息的布局组件
    Component {
        id: systemMessageLayout
        RowLayout {
            // 左右两个弹簧，实现完美居中
            Item {
                Layout.fillWidth: true
            }
            Label {
                text: root.timestamp
                color: "#999" // 灰色，不显眼
                font.pixelSize: 12
                padding: 10
            }
            Item {
                Layout.fillWidth: true
            }
        }
    }

    // --- 布局切换器 ---
    StackLayout {
        id: layoutSwitcher
        anchors.fill: parent

        // --- 核心逻辑：根据 msgType 切换当前显示的布局 ---
        currentIndex: {
            if (root.msgType === "received")
                return 0;
            if (root.msgType === "sending")
                return 1;
            if (root.msgType === "system")
                return 2;
            return 0; // 默认显示接收类型
        }

        // --- 按顺序放置三种布局的实例 ---
        Loader {
            sourceComponent: receivedMessageLayout
        }
        Loader {
            sourceComponent: sentMessageLayout
        }
        Loader {
            sourceComponent: systemMessageLayout
        }
    }
}
