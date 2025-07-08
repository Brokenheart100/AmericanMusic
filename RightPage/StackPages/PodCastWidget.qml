import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: mainContainer

    // --- 整体布局：使用ColumnLayout垂直排列 ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25 // 容器的内边距

        // --- 顶部标题和导航行 ---
        RowLayout {
            id: titleRow
            Layout.fillWidth: true // 占满父容器宽度

            Label {
                text: "下午好，猜你最近喜欢听"
                color: "white"
                font.pixelSize: 22
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            } // 弹簧/伸缩项

            // 导航按钮容器
            RowLayout {
                spacing: 5
                Image {
                    id: coverImage1
                    source: "file:///E:/Computer/Qt6/AmericanMusic/svg/arrow-left-line.svg" // 确保 Image 的 source 是绑定的
                    fillMode: Image.PreserveAspectCrop
                }
                Image {
                    id: coverImage2
                    source: "file:///E:/Computer/Qt6/AmericanMusic/svg/arrow-left-line.svg" // 确保 Image 的 source 是绑定的
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }

        // --- 播客封面行 ---
        RowLayout {
            id: coverRow
            spacing: 20
            // Layout.topMargin: 20 // 与标题行的间距
            Layout.fillWidth: true // <--- 设置这个

            PodCastCover {
                imageSource: "https://picsum.photos/id/10/150"
                tagText1: "凹凸电波"
                tagText2: "播客"
            }
            PodCastCover {
                imageSource: "https://picsum.photos/id/20/150"
                tagText1: "浪里个浪"
                tagText2: "音乐"
            }
            PodCastCover {
                imageSource: "https://picsum.photos/id/30/150"
                tagText1: "呼叫仙贝"
                tagText2: "古典"
            }
            PodCastCover {
                imageSource: "file:///E:/Computer/Qt6/AmericanMusic/image/2.jpg"
                tagText1: "美国人"
                tagText2: "流行"
            }
        }
    }
}
