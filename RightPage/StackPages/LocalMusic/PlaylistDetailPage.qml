pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import QtQml.Models 2.15       // 2. 确保导入了 Models 模块
import Qt.labs.platform 1.1

Rectangle {
    id: page
    color: "#cba3a3" // 整体背景色
    property var fileQueue: [] // 这就是我们的“处理队列”，用来存放待处理的文件URL
    property string coverSource: {
        // 1. 生成 0 到 50 之间的随机整数
        var randomNumber = Math.floor(Math.random() * 51); // Math.random() * (max + 1)

        // 2. 构造文件路径字符串
        return "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/" + randomNumber + ".jpg";
    }
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
    Component.onCompleted: {
        //E:\Computer\Qt6\test2\music
        const fileUrl = "file:///E:/Computer/Qt6/test2/music";
        musicPlayer.addSongsFromFolder(fileUrl);
        console.log("Initial folder added:", fileUrl);
    }
    // --- 整体布局 ---
    ColumnLayout {
        id: rootLayout
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20
        function formatTime(ms) {
            const totalSeconds = Math.floor(ms / 1000);
            const minutes = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
            const seconds = (totalSeconds % 60).toString().padStart(2, '0');
            return minutes + ":" + seconds;
        }
        Component.onCompleted: {
            //E:\Computer\Qt6\test2\music
            const fileUrl = "file:///E:/Computer/Qt6/test2/music";
            musicPlayer.addSongsFromFolder(fileUrl);
            console.log("Initial folder added:", fileUrl);
        }
        FileDialog {
            id: folderDialog
            title: "请选择一个音乐文件夹"
            fileMode: FileDialog.OpenFile // 明确指定为打开单个文件模式
            nameFilters: ["音乐文件 (*.mp3 *.wav *.flac *.m4a)"]
            folder: Qt.resolvedUrl(".")
            onAccepted: {
                musicPlayer.addSongsFromFolder(fileUrl);
                // console.log("Selected folder:", fileUrl.toString());
            }
        }
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
                    id: songListHeader // 这个 id 至关重要！
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    spacing: 15 // 列之间的间距
                    // 计算可用于比例分配的总宽度
                    // 总宽度 = 父级宽度 - 所有固定列的宽度 - 所有间距
                    readonly property real availableWidth: page.width - 60

                    Component.onCompleted: {
                        console.log("Available width for proportionate columns:", availableWidth);
                    }
                    HeaderButton {
                        id: rankHeader // 序号列的 id
                        text: "#"
                        hoverable: false // 序号列不可交互
                        // Layout.preferredWidth: 40
                        Layout.preferredWidth: songListHeader.availableWidth * 0.03
                    }

                    HeaderButton {
                        id: titleHeader // 标题列的 id
                        text: "标题"
                        sortIndicatorText: "↓ 默认排序"
                        // 使用 fillWidth 让它自动填充剩余空间
                        // Layout.fillWidth: true
                        // Layout.preferredWidth: 400
                        Layout.preferredWidth: songListHeader.availableWidth * 0.54
                    }

                    HeaderButton {
                        id: albumHeader // 专辑列的 id
                        text: "专辑"
                        // Layout.preferredWidth: 200
                        Layout.preferredWidth: songListHeader.availableWidth * 0.25
                    }

                    HeaderButton {
                        id: likeHeader // 喜欢列的 id
                        text: "喜欢"
                        // Layout.preferredWidth: 40
                        Layout.preferredWidth: songListHeader.availableWidth * 0.05

                        hoverable: false // 喜欢列不可交互
                    }

                    HeaderButton {
                        id: durationHeader // 时长列的 id
                        text: "时长"
                        // Layout.preferredWidth: 60
                        Layout.preferredWidth: songListHeader.availableWidth * 0.08
                    }
                }

                // --- 4. 歌曲列表 ---
                ListView {
                    id: songListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: musicPlayer.playlistModel
                    spacing: 5
                    clip: true

                    delegate: SongItem1 {
                        // 将模型数据绑定到 delegate
                        width: parent.width
                        required property int index
                        required property string title
                        required property string album
                        required property string artist
                        required property string duration
                        required property string coverSource
                        rank: index + 1
                        title1: title
                        artist1: artist
                        album1: album
                        duration1: rootLayout.formatTime(duration)
                        coverSource1: coverSource
                        onClicked: {
                            musicPlayer.play(index);
                        }
                        Component.onCompleted: {
                            // 这里可以执行一些初始化代码
                            console.log("SongItem1 created for:", title1, "by", artist, "at index", index, coverSource);
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }
    }
}
