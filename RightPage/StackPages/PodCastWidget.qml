import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: mainContainer
    // anchors.centerIn: parent
    Layout.preferredWidth: 720
    Layout.preferredHeight: 280
    // color: "#2C2C34" // 深灰色背景
    // radius: 16 // 圆角

    // --- 1. 定义可复用的圆形按钮组件 ---
    // 我们将组件定义在这里，并给它一个 ID，以便后续使用
    Component {
        id: roundButtonComponent

        Button {
            // 默认属性，可以在实例化时覆盖
            property string iconSource: ""
            width: 32
            height: 32
            flat: true

            contentItem: Image {
                anchors.fill: parent
                anchors.margins: 8 // 给图标留点边距，让它不要填满整个圆
                source: parent.iconSource // 绑定到我们新加的属性
                fillMode: Image.PreserveAspectFit
            }

            background: Rectangle {
                // 使用 control.down 和 control.hovered 来引用 Button 的状态
                color: control.down ? "#202020" : (control.hovered ? "#454545" : "#3A3A3A")
                radius: width / 5 // 保持圆形
            }
        }
    }

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
                spacing: 8

                // --- 2. 使用上面定义的组件创建实例 ---
                // 通过 Component 的 ID 来创建两个按钮实例
                // 并为每个实例设置不同的 iconText 属性
                Loader {
                    sourceComponent: roundButtonComponent
                    // 我们可以通过 onLoaded 来设置属性
                    onLoaded: {
                        item.iconSource = "file:///E:/Computer/Qt6/AmericanMusic/svg/arrow-left-line.svg";
                    }
                }
                Loader {
                    sourceComponent: roundButtonComponent
                    onLoaded: {
                        item.iconSource = "file:///E:/Computer/Qt6/AmericanMusic/svg/arrow-right-line.svg";
                    }
                }
            }
        }

        // --- 播客封面行 ---
        RowLayout {
            id: coverRow
            spacing: 20
            Layout.topMargin: 20 // 与标题行的间距

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
