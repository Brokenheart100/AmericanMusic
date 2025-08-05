pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

/*!
* @brief 一个功能完整的聊天软件侧边栏组件。
*
* 封装了头像、主功能图标列表、底部图标列表以及选中状态的
* 动画指示器。通过数据模型驱动，易于扩展和定制。
*/
Rectangle {
    id: sidebarRoot

    // --- 公共属性 (API) ---
    // 通过这些属性，可以在外部定制侧边栏的行为和外观

    /*! @brief 当前选中主图标的索引。使用 alias 使其可以被外部双向绑定。*/
    property alias currentIndex: mainIconsView.currentIndex

    /*! @brief 用户头像的图像资源路径 */
    property string avatarSource: ""

    /*! @brief 头像状态指示灯的颜色 (例如 "#FFA500") */
    property color statusColor: "transparent"

    /*! @brief 主功能图标的数据模型 (应为一个 ListModel) */
    property var mainIconsModel: null

    /*! @brief 底部功能图标的数据模型 (应为一个 ListModel) */
    property var bottomIconsModel: null

    /*! @brief 选中指示器的颜色 */
    property color selectionColor: "#0078D4"

    // --- 信号 ---
    // 用于向外部通知内部发生的事件

    /*! @brief 当用户点击头像时发出此信号 */
    signal avatarClicked

    /*! @brief 当用户点击底部图标时发出此信号
    * @param index 被点击的底部图标的索引
    */
    signal bottomIconClicked(int index)

    // --- 组件实现 ---

    width: 72
    color: "#E3E5E8" // 侧边栏背景色

    // 使用 ColumnLayout 进行垂直布局，非常灵活
    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        // --- 1. 头像区域 ---
        Item {
            Layout.alignment: Qt.AlignHCenter // 在布局中水平居中
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48

            Image {
                id: avatarImage
                anchors.fill: parent
                source: sidebarRoot.avatarSource
                fillMode: Image.PreserveAspectCrop
                // 使用 OpacityMask 实现圆角效果
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: avatarImage.width
                        height: avatarImage.height
                        radius: 12
                    }
                }
            }

            // 状态指示灯
            Rectangle {
                width: 14
                height: 14
                radius: 7
                color: sidebarRoot.statusColor
                border.color: sidebarRoot.color // 边框颜色与背景色一致，制造"挖空"效果
                border.width: 2
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: -2
                anchors.bottomMargin: -2
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sidebarRoot.avatarClicked() // 点击时发射信号
            }
        }

        // --- 2. 主功能图标区域 ---
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
            Layout.preferredHeight: mainIconsView.contentHeight
            // 蓝色选中状态指示器
            Rectangle {
                id: selectionIndicator
                width: 48
                height: 48
                radius: 24
                color: sidebarRoot.selectionColor
                z: 0 // 放置在图标后面

                // Y 坐标绑定到 ListView 中当前项的 Y 坐标
                y: mainIconsView.currentItem.y

                // 使用 Behavior 实现平滑的移动动画
                Behavior on y {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                }
            }

            // 使用 ListView 来显示主功能图标列表
            ListView {
                id: mainIconsView
                width: parent.width
                // 高度由内容和间距动态计算
                height: contentHeight
                model: 3
                spacing: 16
                interactive: false // 禁用滚动，因为我们是固定侧边栏
                z: 1 // 放置在指示器前面

                delegate: IconDelegate {
                    // 传递模型数据和状态给代理
                    // iconSource: modelData.iconSource
                    // tooltipText: modelData.tooltip
                    // 关键：将代理的 isSelected 属性绑定到它是否是 ListView 的当前项
                    isSelected: ListView.isCurrentItem
                }
            }
        }

        // --- 3. 弹性间隔 ---
        // 这个 Item 会自动填充所有剩余的垂直空间，从而将底部图标推到底部
        Item {
            Layout.fillHeight: true
        }

        // --- 4. 底部功能图标区域 ---
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            Repeater {
                model: 2

                delegate: IconDelegate {
                    // iconSource: modelData.iconSource
                    // tooltipText: modelData.tooltip
                    isSelected: false // 底部图标通常没有持久的选中状态

                    // onClicked: sidebarRoot.bottomIconClicked(index) // 发射带索引的信号
                }
            }
        }
    }
}
