// 您的主文件名，例如 MusicLibraryPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts // [关键] 导入布局模块

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        // 使用布局的内边距，替代原来复杂的、依赖窗口宽度的 margin 计算
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        spacing: 0 // 布局内的垂直间距设为0，由子项的 margin 控制

        // --- 顶部栏 (第一行) ---
        // [优化] 使用 RowLayout 轻松实现左右对齐布局
        RowLayout {
            width: parent.width
            height: indeicator.implicitHeight

            // 左侧的指示器
            PageIndicator {
                id: indeicator
                spacing: 20
                options: ['单曲', '播客', '有声书', "歌单", "专辑"]
                type: 2
                // [优化] 位置由布局管理，不再需要 anchors
            }

            // [优化] “弹簧”：一个占位的 Item，自动填充所有可用空间，将右侧内容推到边缘
            Item {
                Layout.fillWidth: true
            }

            // 右侧的按钮行
            Row {
                spacing: 10 // 按钮间的水平间距

                // [优化] 使用我们创建的可复用 AppButton 组件
                Button {
                    text: "播放全部"
                    icon: "file:///E:/Computer/Qt6/AmericanMusic/svg/computer-line.svg"
                    background: "#e84f50"
                }
                Button {
                    text: "收藏全部"
                    iconSource: "qrc:/Resources/recent/collect.png"
                }
                Button {
                    text: "···" // “更多”按钮，不提供图标
                }
            }
        }

        // --- 列表视图 (第二行) ---
        ListView {
            // [优化] 使用 Layout 的附加属性来填充父布局的剩余空间
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 30 // 与顶部栏的间距

            // [优化] 列表头使用 RowLayout，实现健壮的、响应式的列布局
            header: RowLayout {
                width: parent.width // 宽度与 ListView 保持一致
                height: 50

                Label {
                    text: '#'
                    color: "#a1a1a3"
                    font.pixelSize: 20
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    text: '标题'
                    color: "#a1a1a3"
                    font.pixelSize: 20
                    Layout.fillWidth: true
                    Layout.minimumWidth: 150
                } // [核心] 弹性列
                Label {
                    text: '专辑'
                    color: "#a1a1a3"
                    font.pixelSize: 20
                    Layout.fillWidth: true
                    Layout.minimumWidth: 150
                } // [核心] 弹性列
                Label {
                    text: '喜欢'
                    color: "#a1a1a3"
                    font.pixelSize: 20
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    text: '播放时间'
                    color: "#a1a1a3"
                    font.pixelSize: 20
                    Layout.preferredWidth: 120
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // model 和 delegate 部分等待您填充
            // model: yourDataModel
            // delegate: yourItemDelegate
        }
    }
}
