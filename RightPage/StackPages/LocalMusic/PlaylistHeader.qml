import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls

RowLayout {
    spacing: 25
    //专辑封面
    Image {
        id: coverImage
        source: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/1.jpg"
        Layout.preferredWidth: 180
        Layout.preferredHeight: 180
        Rectangle {
            anchors.fill: parent
            radius: 12
            color: "transparent"
        }
    }

    ColumnLayout {
        Layout.fillHeight: true
        // Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        spacing: 15

        // --- 2a. 歌单标题行 ---
        RowLayout {
            spacing: 10

            // 返回箭头 (可选，如果这是在一个可以返回的页面)
            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/2.jpg"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                Layout.alignment: Qt.AlignVCenter
                // 可以用 ColorOverlay 改变颜色
            }

            Label {
                text: "<练习金曲>"
                color: "white"
                font.pixelSize: 24
                font.bold: true
            }

            // 编辑图标
            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/CoverImage/2.jpg"
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                Layout.alignment: Qt.AlignVCenter
            }
        }
        // --- 2b. 作者信息行 ---
        RowLayout {
            spacing: 10
            Layout.topMargin: 10 // 与标题行保持一点距离

            // 作者头像 (圆形)
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: Layout.preferredWidth / 2 // 圆形
                clip: true

                Image {
                    anchors.fill: parent
                    source: "file:///E:/Computer/Qt6/AmericanMusic/svg/arrow-right-line.svg" // 替换为作者头像
                    fillMode: Image.PreserveAspectCrop
                }
            }

            Label {
                text: "Brokenheart100"
                color: "#E0E0E0" // 亮灰色
                font.pixelSize: 14
            }

            Label {
                text: "2023-02-10创建"
                color: "#888888" // 暗灰色
                font.pixelSize: 14
            }
        }

        // --- 2c. 操作按钮行 (使用弹簧来推开空间) ---
        // Item {
        //     Layout.fillHeight: true
        // } // 垂直弹簧，将按钮推到底部
        RowLayout {
            spacing: 10
            Button {
                text: "▶ 播放全部"
                background: Rectangle {
                    color: "#EC4141"
                    radius: height / 5
                }
            }
            Button {
                text: "↓ 下载"
                background: Rectangle {
                    color: "#3A3A3A"
                    radius: height / 5
                }
            }
            Button {
                text: "..."
                background: Rectangle {
                    color: "#3A3A3A"
                    radius: height / 5
                }
            }
        }
    }
}
