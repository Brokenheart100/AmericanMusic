import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: page
    color: "#cba3a3" // 整体背景色

    // --- 数据模型 ---
    ListModel {
        id: songModel
        ListElement {
            rank1: 1
            title1: "STAY"
            artist1: "The Kid LAROI / Justin Bieber"
            album1: "STAY"
            duration1: "02:21"
            coverSource1: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/0.jpg"
        }
        ListElement {
            rank1: 2
            title1: "Rolling in the Deep"
            artist1: "Adele"
            album1: "Rolling in the Deep"
            duration1: "03:48"
            coverSource1: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/1.jpg"
        }
        ListElement {
            rank1: 3
            title1: "Rolling in the Deep"
            artist1: "Adele"
            album1: "Rolling in the Deep"
            duration1: "03:48"
            coverSource1: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/2.jpg"
        }
        ListElement {
            rank1: 4
            title1: "Rolling in the Deep"
            artist1: "Adele"
            album1: "Rolling in the Deep"
            duration1: "03:48"
            coverSource1: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/3.jpg"
        }
    }

    // --- 整体布局 ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        // --- 1. 顶部歌单信息区 ---
        PlaylistHeader {
            Layout.fillWidth: true
        }
        // --- 1. 导航栏 (TabBar) ---
        TabBar {
            id: tabBar
            Layout.fillWidth: true

            // TabButton 是 TabBar 的子项，代表每个标签
            TabButton {
                id: songTab1
                text: "歌曲 " + songModel.count // 显示歌曲数量
                contentItem: Text {
                    text: songTab1.text
                    font.pixelSize: 18
                    font.bold: songTab1.checked // 选中时加粗
                    color: songTab1.checked ? "white" : "#AAAAAA" // 选中时为白色
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                // --- 核心：下划线指示器 ---
                indicator: Rectangle {
                    width: 24 // 指示器宽度
                    height: 3
                    color: "#EC4141" // 红色
                    radius: 2
                    // 让指示器在 x 轴上平滑移动
                    // TabBar 会自动管理它的 x 和 width，我们只需要添加动画
                    Behavior on x {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutCubic
                        }
                    }
                }
            }
            TabButton {
                id: songTab2
                text: "评论"
            }
            TabButton {
                id: songTab3
                text: "收藏者"
            }
            // --- 弹簧 ---
            Item {
                Layout.fillWidth: true
            }

            // --- 搜索框 ---
            TextField {
                placeholderText: "搜索"
                Layout.preferredWidth: 180
                Layout.preferredHeight: 32
                background: Rectangle {
                    color: "#2A2A2A"
                    radius: height / 2
                }
                // ... (可以添加搜索图标)
            }
            // --- 自定义外观 ---
            background: Rectangle {
                color: "transparent"
            }
        }
        // --- 2. 内容区 (StackLayout) ---
        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true // 占据所有剩余空间

            // --- 核心：将 StackLayout 的当前索引与 TabBar 同步 ---
            currentIndex: tabBar.currentIndex
            ColumnLayout {
                // --- 3. 歌曲列表表头 ---
                RowLayout {
                    id: songListHeader
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10

                    Label {
                        text: "#"
                        color: "#888"
                        Layout.preferredWidth: 30
                    }
                    Label {
                        text: "标题"
                        color: "#888"
                        Layout.fillWidth: true
                    }
                    Label {
                        text: "专辑"
                        color: "#888"
                        Layout.preferredWidth: 150
                    }
                    Label {
                        text: "喜欢"
                        color: "#888"
                        Layout.preferredWidth: 30
                    }
                    Label {
                        text: "时长"
                        color: "#888"
                        Layout.preferredWidth: 50
                    }
                }

                // --- 4. 歌曲列表 ---
                ListView {
                    id: songListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: songModel
                    spacing: 5
                    clip: true

                    delegate: SongItem1 {
                        // 将模型数据绑定到 delegate
                        width: parent.width
                        required property int index
                        required property string rank1
                        required property string title1
                        required property string album1
                        required property string artist1
                        required property string duration1
                        required property string coverSource1
                        rank: rank1
                        title: title1
                        artist: artist1
                        album: album1
                        duration: duration1
                        coverSource: coverSource1
                        Component.onCompleted: {
                            // 这里可以执行一些初始化代码
                            console.log("SongItem1 created for:", title, "by", artist, "at index", index);
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }
        // --- 3b. 第二个页面：评论 (占位符) ---
        Label {
            text: "评论页面 - 待实现"
            color: "white"
            Layout.alignment: Qt.AlignCenter
        }

        // --- 3c. 第三个页面：收藏者 (占位符) ---
        Label {
            text: "收藏者页面 - 待实现"
            color: "white"
            Layout.alignment: Qt.AlignCenter
        }
    }
}
