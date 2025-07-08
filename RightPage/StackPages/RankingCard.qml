pragma ComponentBehavior: Bound
// RankingCard.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: root

    // --- 卡片数据属性 ---
    property string cardTitle: "飙升榜"
    property string updateInfo: "更新56首"
    property var coverImages: ["file:///E:/Computer/Qt6/AmericanMusic/image/1.jpg", "file:///E:/Computer/Qt6/AmericanMusic/image/2.jpg", "file:///E:/Computer/Qt6/AmericanMusic/image/3.jpg"]
    property var songList: [
        {
            rank: 1,
            title: "准备好就出发",
            artist: "黄子弘凡",
            status: "新",
            statusColor: "#4CAF50"
        },
        {
            rank: 2,
            title: "两难",
            artist: "加木",
            status: "新",
            statusColor: "#4CAF50"
        },
        {
            rank: 3,
            title: "神的说唱",
            artist: "小帅不跑调",
            status: "▲",
            statusColor: "#F44336"
        }
    ]

    // --- 卡片视觉属性 ---
    // 尺寸由 GridLayout 控制，但可以提供建议尺寸
    Layout.preferredWidth: 400
    Layout.preferredHeight: 220
    color: "#2C2C2C" // 深灰色背景
    radius: 12

    // --- 整体布局：使用 ColumnLayout 垂直排列 ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // --- 1. 顶部标题行 ---
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: root.cardTitle
                color: "white"
                font.pixelSize: 20
                font.bold: true
            }
            Item {
                Layout.fillWidth: true
            } // 弹簧
            Label {
                text: root.updateInfo
                color: "#AAAAAA"
                font.pixelSize: 14
            }
        }

        // --- 2. 内容行 (封面 + 歌曲列表) ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            // 封面图片 (层叠效果)
            Item {
                id: coverContainer
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100

                // 使用 Repeater 创建层叠图片
                Repeater {
                    model: root.coverImages.slice(0, 3).reverse() // 最多3张，并反转顺序让第一张在最上面
                    delegate: Image {
                        // 声明所需的属性
                        required property int index
                        required property string modelData

                        x: index * 4 // 每张图片向右偏移
                        y: index * 4 // 每张图片向下偏移
                        width: 50 // 动态调整大小以适应偏移
                        height: 50
                        source: modelData // 使用 modelData 而不是 coverImages
                        fillMode: Image.PreserveAspectCrop
                        Rectangle {
                            // 添加圆角
                            anchors.fill: parent
                            radius: 8
                            color: "transparent"
                            border.color: "#FFFFFF1A" // 加个细微的边框
                            border.width: 1
                        }
                    }
                }
            }

            // 歌曲列表
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    id: repeater
                    model: root.songList
                    delegate: RowLayout {
                        id: songItem
                        spacing: 10
                        required property int index

                        // 序号
                        Label {
                            text: `${songItem.index + 1}`
                            color: "#AAAAAA"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        // 歌曲名和歌手
                        Label {
                            Layout.fillWidth: true
                            text: "神的说唱 - " + "小帅不跑调"
                            color: "white"
                            font.pixelSize: 16
                            elide: Text.ElideRight // 超出部分显示省略号
                        }
                        // 状态 (新/上升/下降)
                        Label {
                            text: " " + "▲"
                            color: "#F44336"
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }
                }
            }
        }
    }
}
