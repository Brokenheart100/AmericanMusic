pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Button {
        id: rootBtn

        // --- 对外暴露的属性和信号 ---
        // expanded 属性，控制展开/折叠状态，并允许外部读写
        property bool expanded: false

        // 当状态改变时，发出信号通知外部
        signal toggled(bool isExpanded)

        // --- 视觉和布局 ---
        // 移除默认背景，我们自己控制
        background: Rectangle {
            color: "transparent"
        }

        // 点击时，切换 expanded 状态
        onClicked: {
            root.expanded = !root.expanded;
            root.toggled(root.expanded); // 发出信号
        }

        // --- 内容项 ---
        contentItem: RowLayout {
            // 让内容在 Button 内部居中
            anchors.centerIn: parent
            spacing: 4 // 图标和文本之间的紧凑间距

            // --- 文本 ---
            Label {
                id: label

                // 根据 expanded 状态切换文本
                text: root.expanded ? "收起" : "更多"

                color: root.hovered ? "white" : "#A9A9C4" // 悬浮时变白
                font.pixelSize: 14

                // 添加平滑的颜色过渡
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            // --- V 形图标 ---
            Image {
                id: arrowIcon

                // 使用一个向下的 V 形图标
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/mail-fill.svg"

                // 图标颜色与文本颜色保持一致
                // (需要 ColorOverlay 效果来实现 SVG 变色)
                // 为了简单，我们只改变透明度
                opacity: root.hovered ? 1.0 : 0.8

                // --- 核心动画：旋转 ---
                // 根据 expanded 状态设置旋转角度
                // 展开时是 180度 (倒V)，折叠时是 0度 (V)
                rotation: root.expanded ? 180 : 0

                // 为旋转属性添加平滑动画
                Behavior on rotation {
                    RotationAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
    // --- 状态属性 ---
    property bool expanded: true // 控制是否展开
    property int currentIndex: 0 // 控制当前选中的是哪一项
    // --- 数据模型 ---
    ListModel {
        id: playlistModel
        ListElement {
            name: "<练习金曲>"
            art: "file:///E:/Computer/Qt6/AmericanMusic/image/1.jpg"
        }
        ListElement {
            name: "<画面感极强的BGM>"
            art: "file:///E:/Computer/Qt6/AmericanMusic/image/2.jpg"
        }
        ListElement {
            name: "<安静的钢琴曲>"
            art: "file:///E:/Computer/Qt6/AmericanMusic/image/3.jpg"
        }
        ListElement {
            name: "<跑步专用>"
            art: "file:///E:/Computer/Qt6/AmericanMusic/image/4.jpg"
        }
    }
    // --- 歌单列表 ---
    ListView {
        id: listView
        Layout.fillWidth: true
        clip: true // 必须设置，否则折叠时内容会溢出

        // --- 核心动画逻辑 ---
        // 高度根据展开状态和内容高度变化
        Layout.preferredHeight: root.expanded ? contentHeight : 0
        // 当高度变化时，使用动画平滑过渡
        Behavior on Layout.preferredHeight {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        model: playlistModel
        spacing: 5

        delegate: CollapseItem {
            id: collapseitem
            width: listView.width // 委托宽度与ListView一致
            implicitHeight: 50 // 设置一个默认高度，ListView会根据内容自动调整
            // 从模型绑定数据
            required property int index
            required property string name
            required property string art

            playlistName: name
            albumArt: art

            // 判断当前项是否被选中
            active: root.currentIndex === index

            // 点击时，更新当前选中项的索引
            onClicked: {
                root.currentIndex = index;
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.currentIndex = collapseitem.index;
                    console.log("Clicked item index:", collapseitem.index);
                }
            }
        }
    }
}
