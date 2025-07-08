// TitleBar.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    height: 60 // 标题栏高度
    color: "#16161A" // 深色背景

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 10 // 各个功能块之间的间距

        // --- 1. 左侧导航区 ---
        RowLayout {
            id: navigationControls
            spacing: 5
            IconButton {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
            }
            IconButton {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
            }
        }

        // --- 2. 搜索区 ---
        Item {
            // Layout.preferredWidth: 200
            Layout.fillWidth: true
            SearchField {
                anchors.fill: parent
            }
        }
        IconButton {
            id: micButton
            iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
        }

        // --- 3. 中间弹簧 ---
        Item {
            Layout.fillWidth: true
        }

        // --- 4. 用户信息区 ---
        UserProfile {}

        // --- 5. 功能按钮区 ---
        RowLayout {
            id: actionButtons
            spacing: 5

            // 带小红点的邮件按钮
            Item {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                IconButton {
                    anchors.centerIn: parent
                    iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
                }
                Rectangle {
                    // 小红点
                    x: parent.width - 10
                    y: 4
                    width: 8
                    height: 8
                    radius: 4
                    color: "red"
                    border.color: root.color
                    border.width: 1
                }
            }

            IconButton {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
            }
            IconButton {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
            }
        }

        // 分隔线
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 16
            color: "#3A3A3A"
            Layout.alignment: Qt.AlignVCenter
        }

        // --- 6. 窗口控制区 ---
        RowLayout {
            id: windowControls
            spacing: 5
            IconButton {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
            }
            IconButton {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
            }
            IconButton {
                iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
            }
        }
    }
}
