pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: rootBtn
    color: "grey"
    width: parent.width
    // --- 数据模型 ---
    ListModel {
        id: buttonModel
        ListElement {
            text1: "推荐"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
        }
        ListElement {
            text1: "关注"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
        }
        ListElement {
            text1: "直播"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
        }
        ListElement {
            text1: "动画"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
        }
        ListElement {
            text1: "游戏"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
        }
    }
    property int navCurrentIndex: 0 // 专门用于导航按钮的状态
    property int currentIndex: 0
    // --- 信号声明 ---
    signal navigationClicked(int index)
    signal playlistClicked(int index)
    signal buttonClicked(int index)

    // --- 视图 ---
    ScrollView {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true // 启用裁剪是个好习惯
        ColumnLayout {
            width: parent.width
            spacing: 10 // 按钮之间的间距
            Repeater {
                model: buttonModel
                delegate: TokyoButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50 // 按钮的高度
                    required property int index
                    required property string text1
                    required property string source
                    required property bool active
                    buttonText: text1
                    iconSource: source
                    active: rootBtn.currentIndex === index
                    onClicked: {
                        rootBtn.currentIndex = index;
                        rootBtn.buttonClicked(index);
                        rootBtn.navCurrentIndex = index;
                        rootBtn.navigationClicked(index); // 发射导航信号
                    }
                }
            }

            RowLayout {
                id: titleLayout
                // 让布局填满根容器
                Layout.fillWidth: true

                // 1. 左侧标题文本
                Label {
                    id: titleLabel
                    text: "我的" // 默认文本
                    color: "#E0E0E0" // 亮灰色
                    font.pixelSize: 18
                    font.bold: true

                    // 在布局中垂直居中
                    Layout.alignment: Qt.AlignVCenter
                }

                // 2. 中间弹簧
                Item {
                    // 占据所有可用的水平空间
                    Layout.fillWidth: true
                }

                // 3. 右侧编辑按钮
                Button {
                    id: editButton

                    // 设置图标源
                    icon.source: "file:///E:/Computer/Qt6/AmericanMusic/svg/add-circle-fill.svg" // 替换为你的编辑图标
                    icon.width: 22
                    icon.height: 22
                    icon.color: hovered ? "white" : "#A9A9C4" // 悬浮时变白

                    // 移除背景，让它只是一个图标
                    background: Rectangle {
                        color: "transparent"
                    }

                    // 在布局中垂直居中
                    Layout.alignment: Qt.AlignVCenter
                }
            }
            Repeater {
                model: buttonModel
                delegate: TokyoButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50 // 按钮的高度
                    required property int index
                    required property string text1
                    required property string source
                    required property bool active
                    buttonText: text1
                    iconSource: source
                    active: rootBtn.currentIndex === index
                    onClicked: {
                        console.log("leftbar 当前选中按钮索引:", rootBtn.currentIndex, index);
                        rootBtn.currentIndex = index;
                    }
                }
            }

            CollapseList1 {
                Layout.fillWidth: true
            }
            // 这就是分割线
            Rectangle {
                id: separator1
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#8f8b8b" // 浅灰色
            }
            CollapseList {
                Layout.fillWidth: true
            }
            Rectangle {
                id: separator2
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#ed1c1c" // 浅灰色
            }
            CollapseList {
                Layout.fillWidth: true
            }
        }
    }
}
