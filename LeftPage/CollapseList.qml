pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

ColumnLayout {
    id: root
    width: 250
    spacing: 10

    // --- 状态属性 ---
    property bool expanded: true // 控制是否展开
    property int currentIndex: 0 // 控制当前选中的是哪一项

    // --- 数据模型 ---
    ListModel {
        id: playlistModel
        ListElement {
            name: "<练习金曲>"
            art: "file:///E:/Computer/C/QMLTest/image/3.jpg"
        }
        ListElement {
            name: "<画面感极强的BGM>"
            art: "file:///E:/Computer/C/QMLTest/image/3.jpg"
        }
        ListElement {
            name: "<安静的钢琴曲>"
            art: "file:///E:/Computer/C/QMLTest/image/3.jpg"
        }
        ListElement {
            name: "<跑步专用>"
            art: "file:///E:/Computer/C/QMLTest/image/3.jpg"
        }
    }

    // --- 标题栏 ---
    RowLayout {
        Layout.fillWidth: true

        Label {
            text: "创建的歌单 " + playlistModel.count
            font.pixelSize: 20
            font.bold: true
            color: "#E0E0E0"
        }

        // 旋转的V形图标
        Image {
            source: "file:///E:/Computer/C/QMLTest/image/3.jpg"
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            // 根据展开状态旋转图标
            rotation: root.expanded ? 0 : -90
            // 动画
            Behavior on rotation {
                RotationAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Item {
            Layout.fillWidth: true
        } // 一个弹簧，把加号推到最右边

        // 加号按钮
        Button {
            icon.source: "file:///E:/Computer/C/QMLTest/image/3.jpg"
            icon.width: 18
            icon.height: 18
            background: Rectangle {
                color: "#444"
                radius: width / 2 // 圆形
            }
        }

        // 使整个标题栏可点击
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded // 点击时切换展开状态
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
            width: listView.width // 委托宽度与ListView一致

            // 从模型绑定数据
            playlistName: name
            albumArt: art

            // 判断当前项是否被选中
            active: root.currentIndex === index

            // 点击时，更新当前选中项的索引
            onClicked: {
                root.currentIndex = index;
            }
        }
    }
}
