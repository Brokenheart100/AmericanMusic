pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Rectangle {
    id: rootBtn
    color: "grey"

    width: parent.width

    // --- 数据模型 ---
    // 定义8个按钮的文本和图标。
    // 注意: 为了演示，这里复用了同一个图标。在实际项目中，请替换为对应的图标路径。
    ListModel {
        id: buttonModel
        ListElement {
            text: "推荐"
            icon: "qrc:/icons/home_icon.svg"
        }
        ListElement {
            text: "关注"
            icon: "qrc:/icons/home_icon.svg"
        }
        ListElement {
            text: "直播"
            icon: "qrc:/icons/home_icon.svg"
        }
        ListElement {
            text: "动画"
            icon: "qrc:/icons/home_icon.svg"
        }
        ListElement {
            text: "游戏"
            icon: "qrc:/icons/home_icon.svg"
        }
        ListElement {
            text: "知识"
            icon: "qrc:/icons/home_icon.svg"
        }
        ListElement {
            text: "体育"
            icon: "qrc:/icons/home_icon.svg"
        }
        ListElement {
            text: "音乐"
            icon: "qrc:/icons/home_icon.svg"
        }
    }

    // --- 状态管理 ---
    // 用于记录当前哪个按钮被选中 (通过索引)
    property int currentIndex: 0

    // --- 视图 ---
    // 使用ScrollView确保按钮过多时可以滚动
    ScrollView {
        anchors.verticalCenter: parent.verticalCenter

        height: parent.height // 限制滚动视图的高度

        ColumnLayout {
            spacing: 10 // 按钮之间的间距

            // Repeater会根据model中的数据，为每一项创建一个delegate
            Repeater {
                model: 8

                // delegate是每个列表项的模板
                delegate: TokyoButton {
                    // 将model中的数据绑定到按钮的属性上
                    Layout.fillWidth: true
                    // 核心：根据currentIndex判断当前按钮是否为激活状态
                    // model.index 是Repeater提供的当前项的索引
                    active: rootBtn.currentIndex === index

                    // 当按钮被点击时，更新全局的currentIndex
                    onClicked: {
                        currentIndex = index;
                    }
                }
            }
        }
    }
}
