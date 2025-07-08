import QtQuick
import QtQuick.Controls // ScrollView 在这里
import QtQuick.Layouts 1.15
import QtMultimedia 6.2
import Qt.labs.platform 1.1 // 导入平台对话框模块
import AmericanMusic 1.0

ScrollView {
    id: scrollView
    anchors.fill: parent
    clip: true // 裁剪内容，防止溢出
    anchors.topMargin: 30

    Item {
        id: contentContainer
        width: parent.width // 让内容容器的宽度与父容器一致
        implicitHeight: mainColumn.implicitHeight
        ColumnLayout {
            id: mainColumn
            width: Math.min(parent.width - 60, 1200) // 例如，最多1200px宽，同时左右留边距
            spacing: 20 // ColumnLayout 的 spacing 属性

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Carousel {
                    id: myCarousel
                    Layout.preferredWidth: 400 // 设置 PodCastWidget 的宽度
                    Layout.preferredHeight: 150
                }

                PodCastWidget {
                    Layout.preferredWidth: 400 // 设置 PodCastWidget 的宽度
                    Layout.preferredHeight: 150
                }
            }
            Label {
                text: "精选歌单>"
                font {
                    bold: true
                    family: "黑体"
                    pixelSize: 24
                }
                color: "white"
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                spacing: 20
                Layout.fillWidth: true
                HoverCard {
                    Layout.preferredWidth: 150 // 给一个建议宽度
                    Layout.preferredHeight: 200 // 和建议高度
                }
                HoverCard {
                    Layout.preferredWidth: 150 // 给一个建议宽度
                    Layout.preferredHeight: 200 // 和建议高度
                }
                HoverCard {
                    Layout.preferredWidth: 150 // 给一个建议宽度
                    Layout.preferredHeight: 200 // 和建议高度
                }
                HoverCard {
                    Layout.preferredWidth: 150 // 给一个建议宽度
                    Layout.preferredHeight: 200 // 和建议高度
                }
                HoverCard {
                    Layout.preferredWidth: 150 // 给一个建议宽度
                    Layout.preferredHeight: 200 // 和建议高度
                }
            }
            Label {
                text: "榜单精选>"
                font {
                    bold: true
                    family: "黑体"
                    pixelSize: 24
                }
                color: "white"
            }
            GridLayout {
                id: grid1
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 20
                rowSpacing: 20
                RankingCard {}
                RankingCard {}
                RankingCard {}
                RankingCard {}
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Label {
                    text: "为你推荐的歌曲>"
                    font {
                        bold: true
                        family: "黑体"
                        pixelSize: 24
                    }
                    color: "white"
                }
                Button {
                    background: Rectangle {
                        color: "#AAAAAA"
                        radius: 4
                    }

                    // 完全自定义内容
                    contentItem: RowLayout {
                        spacing: 8 // 图标和文字的间距

                        Image {
                            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-line.svg"
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            fillMode: Image.PreserveAspectFit
                        }

                        Label {
                            text: "播放" // 文字在这里定义
                            color: "white"
                            font.pixelSize: 16
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true // 这个 Item 会占据所有剩余的水平空间
                }
                Button {
                    text: "更多"
                    icon.source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-line.svg"
                    Layout.rightMargin: 30
                    background: Rectangle {
                        color: "#AAAAAA"
                        radius: 4
                    }
                }
            }
            GridLayout {
                id: grid2
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 20
                rowSpacing: 20

                SongItem {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                }
                SongItem {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                }
                SongItem {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                }
                SongItem {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Label {
                    text: "为你推荐的歌曲>"
                    font {
                        bold: true
                        family: "黑体"
                        pixelSize: 24
                    }
                    color: "white"
                }
                Button {
                    background: Rectangle {
                        color: "#AAAAAA"
                        radius: 4
                    }

                    // 完全自定义内容
                    contentItem: RowLayout {
                        spacing: 8 // 图标和文字的间距

                        Image {
                            source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-line.svg"
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            fillMode: Image.PreserveAspectFit
                        }

                        Label {
                            text: "播放" // 文字在这里定义
                            color: "white"
                            font.pixelSize: 16
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true // 这个 Item 会占据所有剩余的水平空间
                }
                Button {
                    text: "更多"
                    icon.source: "file:///E:/Computer/Qt6/AmericanMusic/svg/play-line.svg"
                    Layout.rightMargin: 30
                    background: Rectangle {
                        color: "#AAAAAA"
                        radius: 4
                    }
                }
            }
            GridLayout {
                id: grid3
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 20
                rowSpacing: 20
                ArticleCard {}
                ArticleCard {}
                ArticleCard {}
                ArticleCard {}
            }
        }
    }
}
