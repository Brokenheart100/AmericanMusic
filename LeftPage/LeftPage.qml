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
            text: "推荐"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
        }
        ListElement {
            text: "关注"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"

            icon1: "file:///E:\\Computer\\Qt6\\AmericanMusic\\svg\\computer-fill.svg"
        }
        ListElement {
            text: "直播"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"

            icon1: "file:///E:\\Computer\\Qt6\\AmericanMusic\\svg\\computer-fill.svg"
        }
        ListElement {
            text: "动画"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"

            icon1: "file:///E:\\Computer\\Qt6\\AmericanMusic\\svg\\computer-fill.svg"
        }
        ListElement {
            text: "游戏"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"

            icon1: "file:///E:\\Computer\\Qt6\\AmericanMusic\\svg\\computer-fill.svg"
        }
        ListElement {
            text: "知识"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"

            icon1: "file:///E:\\Computer\\Qt6\\AmericanMusic\\svg\\computer-fill.svg"
        }
        ListElement {
            text: "体育"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"

            icon1: "file:///E:\\Computer\\Qt6\\AmericanMusic\\svg\\computer-fill.svg"
        }
        ListElement {
            text: "音乐"
            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"
            icon1: "file:///E:\\Computer\\Qt6\\AmericanMusic\\svg\\computer-fill.svg"
        }
    }

    // --- 状态管理 ---
    // 用于记录当前哪个按钮被选中 (通过索引)
    property int currentIndex: 0

    // --- 视图 ---
    // 使用ScrollView确保按钮过多时可以滚动
    ScrollView {
        anchors.fill: parent
        ColumnLayout {
            // Layout.fillWidth: true
            width: parent.width
            spacing: 10 // 按钮之间的间距

            // Repeater会根据model中的数据，为每一项创建一个delegate
            Repeater {
                model: buttonModel

                // delegate是每个列表项的模板
                delegate: TokyoButton {
                    // 将model中的数据绑定到按钮的属性上
                    Layout.fillWidth: true
                    buttonText: "ctmd"
                    iconSource: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-fill.svg"

                    active: rootBtn.currentIndex === index

                    // 当按钮被点击时，更新全局的currentIndex
                    onClicked: {
                        currentIndex = index;
                    }
                }
            }
            // 这就是分割线
            Rectangle {
                id: separator1
                Layout.fillWidth: true
                height: 1 // 高度为1像素
                color: "#ed1c1c" // 浅灰色
            }
            CollapseList {
                Layout.fillWidth: true
            }
            Rectangle {
                id: separator2
                Layout.fillWidth: true
                height: 1 // 高度为1像素
                color: "#ed1c1c" // 浅灰色
            }
            CollapseList {
                Layout.fillWidth: true
            }
        }
    }
}
