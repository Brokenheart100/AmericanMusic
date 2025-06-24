import QtQuick
import QtQuick.Controls

Rectangle {
    id: titleBar
    property string svgAbsolutePath: "file:///D:/BaiduSyncdisk/Qt/AmericanMusic/svg"
    // 背景颜色
    Row {
        anchors.right: miniRow.left // 整体右对齐父容器
        anchors.verticalCenter: miniRow.verticalCenter

        spacing: 10
        Image {
            id: userIcon
            // 垂直居中对齐
            anchors.verticalCenter: parent.verticalCenter
            // 从指定路径加载SVG图标
            source: titleBar.svgAbsolutePath + "/send-plane-fill.svg"
            // 鼠标区域 - 处理悬停效果
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                // 鼠标进入时改变图标颜色为白色
                onEntered: {
                    miniImag.color = "white";
                }
                // 鼠标离开时恢复图标颜色为灰色
                onExited: {
                    miniImag.color = "#75777f";
                }
            }
        }
        Text {
            id: loadStateText
            anchors.verticalCenter: parent.verticalCenter
            text: "not login"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                // 鼠标进入时改变图标颜色为白色
                onEntered: {
                    miniImag.color = "white";
                }
                // 鼠标离开时恢复图标颜色为灰色
                onExited: {
                    miniImag.color = "#75777f";
                }
            }
        }
        Item {
            height: userIcon.height
            width: loadStateText.implicitWidth
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                id: vipRect
                width: parent.width
                radius: height / 2
                color: "#0ae9f9"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    text: "NMDVIP"
                    anchors.left: parent.left
                    color: "#4e888c"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Rectangle {
                id: bgBordRect
                width: vipRect.height
                height: width
                radius: width / 2
                border.width: 1
                border.color: "#dadada"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Image {
            id: loginImg
            anchors.verticalCenter: parent.verticalCenter
            source: titleBar.svgAbsolutePath + "/terminal-box-fill.svg"
            layer.enabled: true
            layer.effect: {
                source: loginImg;
                color: "#0b9de6";
            }
        }
    }
    Row {
        id: searchRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 15
        // anchors.verticalCenter: parent.verticalCenter
        spacing: 15
        //页面回退到上一步 backForwardItem
        Connections {}
        // 后退按钮的背景矩形
        Rectangle {
            id: backForwardRect
            radius: 4 // 圆角半径
            color: "transparent" // 默认透明
            border.color: "#48ec16"// 边框颜色
            border.width: 1 // 边框宽度
            anchors.fill: parent // 填充父容器

        }
        // 后退按钮的箭头图标
        Image {
            id: backForwardIcon
            source: titleBar.svgAbsolutePath + "/add-circle-fill.svg"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
        }

        // 搜索框（示例）
        TextField {
            id: searchTextField // 控件的唯一标识符
            width: 240
            height: backForwardIcon.height
            anchors.left: backForwardIcon.right
            anchors.verticalCenter: parent.verticalCenter

            // 自定义输入框的背景
            background: Item {
                anchors.fill: parent // 背景项填充整个TextField区域

                // 边框渐变层：这是一个矩形，用作输入框的渐变色边框
                Rectangle {
                    id: searchBoxBordLine
                    anchors.fill: parent // 填充父项（即background Item）
                    radius: 8 // 圆角半径，使边框变圆滑

                    // 自定义一个属性，用于控制渐变动画。值从0到1。
                    property real gradientStopPos: 1 // 渐变终点位置，初始为1（完全显示）

                    // 边框的渐变色效果
                    gradient: Gradient {
                        orientation: Gradient.Horizontal // 水平方向渐变

                        // 渐变色的起点
                        GradientStop {
                            color: "#21283d" // 起始颜色
                            position: 0 // 位置在最左边
                        }
                        // 渐变色的终点
                        GradientStop {
                            color: "#382635" // 结束颜色
                            position: searchBoxBordLine.gradientStopPos // 结束位置由自定义属性控制
                        }
                    }
                }

                // 内部框体渐变层：这是输入框的主要背景
                Rectangle {
                    id: searchBox
                    anchors.fill: parent // 填充父项
                    anchors.margins: 1 // 设置1像素的边距，这样外层的searchBoxBordLine就能作为1像素的边框显示出来
                    radius: 8 // 圆角半径，与边框保持一致

                    // 同样为内部框体定义一个属性，用于控制点击时的渐变动画
                    property real gradientStopPos: 1 // 渐变终点位置，初始为1

                    // 内部框体的渐变色效果
                    gradient: Gradient {
                        orientation: Gradient.Horizontal // 水平方向渐变
                        GradientStop {
                            color: "#1a1d29" // 起始颜色
                            position: 0
                        }
                        GradientStop {
                            color: "#241c26" // 结束颜色
                            position: searchBox.gradientStopPos // 结束位置由自定义属性控制
                        }
                    }

                    // 搜索图标
                    Image {
                        id: searchIcon
                        scale: 0.7 // 缩放图标大小为原来的70%
                        anchors.verticalCenter: parent.verticalCenter // 垂直居中
                        anchors.left: parent.left // 左对齐
                        //anchors.leftMargin: 16 * BasicConfig.wScale * scale // 左边距，同样进行缩放适配
                        source: titleBar.svgAbsolutePath + "/add-circle-fill.svg"
                    }
                }
            }
            // 当TextField的焦点状态改变时触发
            onFocusChanged: {
                // 如果输入框失去了焦点
                if (!focus)
                    // 将内部框体的渐变恢复到初始状态
                    searchBox.gradientStopPos = 1;
            }
        }
        // --- 听歌识曲按钮 ---
        Item {
            id: soundHoundItem
            height: searchTextField.height // 高度与搜索框一致
            width: height // 宽高相等，使其为正方形
            anchors.left: searchTextField.right
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                id: soundHoundRect
                radius: 8
                color: "#241c26"
                border.color: "#36262f"
                border.width: 1
                anchors.fill: parent
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onExited: {
                        soundHoundRect.color = "#241c26"; // 恢复默认背景色
                    }
                    onEntered: {
                        soundHoundRect.color = "#312231"; // 悬停时改变背景色
                    }
                    onClicked: {
                        console.log("听歌识曲"); // 点击时打印日志
                    }
                }
            }
            Image {
                id: soundHoundIcon
                anchors.centerIn: soundHoundItem // 在容器中居中
                source: titleBar.svgAbsolutePath + "/home-2-fill.svg" // 图标资源
            }
        }
    }
    // 包含图标和按钮的水平布局
    Row {
        id: miniRow
        // 顶部对齐
        anchors.top: parent.top
        // 右对齐
        anchors.right: parent.right
        anchors.topMargin: 10 // 距离顶部10像素
        anchors.rightMargin: 15 // 距离右边15像素
        // 元素间距
        spacing: 15
        // 第一个图标 - 可能用于最小化功能
        Image {
            id: miniImag
            // 垂直居中对齐
            anchors.verticalCenter: parent.verticalCenter
            // 从指定路径加载SVG图标
            source: titleBar.svgAbsolutePath + "/restaurant-2-fill.svg"

            // 鼠标区域 - 处理悬停效果
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                // 鼠标进入时改变图标颜色为白色
                onEntered: {
                    miniImag.color = "white";
                }
                // 鼠标离开时恢复图标颜色为灰色
                onExited: {
                    miniImag.color = "#75777f";
                }
            }
        }

        // 第二个元素 - 小矩形，可能用于表示某种状态
        Rectangle {
            id: miniRect
            width: 20
            height: 2
            // 垂直居中对齐
            anchors.verticalCenter: parent.verticalCenter
            // 默认颜色为灰色
            color: "#75777f"

            // 鼠标区域 - 处理悬停效果
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                // 鼠标进入时改变颜色为白色
                onEntered: {
                    miniRect.color = "white";
                }

                // 鼠标离开时恢复颜色为灰色
                onExited: {
                    miniRect.color = "#75777f";
                }
            }
        }

        // 第三个元素 - 可能用于最大化功能的矩形按钮
        Rectangle {
            id: maxRect
            width: 20
            height: width
            radius: 2
            border.width: 1
            // 默认边框颜色为灰色
            border.color: "#75777f"
            // 垂直居中对齐
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"

            // 鼠标区域 - 处理悬停效果和点击事件
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                // 鼠标进入时改变边框颜色为白色
                onEntered: {
                    maxRect.border.color = "white";
                }

                // 鼠标离开时恢复边框颜色为灰色
                onExited: {
                    maxRect.border.color = "#75777f";
                }

                // 点击事件处理函数（当前为空）
                onClicked: {}
            }
        }

        // 第四个元素 - 关闭图标
        Image {
            id: closeImag
            // 垂直居中对齐
            anchors.verticalCenter: parent.verticalCenter
            // 从指定路径加载SVG图标（路径中存在双斜杠，可能是笔误）
            source: "file:///D:/BaiduSyncdisk/Qt/AmericanMusic//svg/restaurant-2-fill.svg"
        }
    }
    // --- 搜索历史数据模型 ---
    ListModel {
        id: searchSingModel
        ListElement {
            singName: "想象之中"
        }
        ListElement {
            singName: "雨道"
        }
        ListElement {
            singName: "哪里都是你"
        }
        ListElement {
            singName: "入戏太深"
        }
        ListElement {
            singName: "That girl"
        }
        ListElement {
            singName: "素颜"
        }
        ListElement {
            singName: "她说"
        }
        ListElement {
            singName: "ABC"
        }
        ListElement {
            singName: "daylight"
        }
        ListElement {
            singName: "其他"
        }
    }
    // --- 热搜榜数据模型 ---
    ListModel {
        id: hotSearchSingModel
        ListElement {
            singName: "想象之中"
        }
        ListElement {
            singName: "雨道"
        }
        ListElement {
            singName: "哪里都是你"
        }
    }

    Popup {
        id: searchPop
        width: searchRow.implicitWidth // 宽度与整个搜索行相同
        height: 600 // 固定高度
        x: 0 // 相对于 searchRow 的 x 坐标
        y: searchTextField.height + 10
        background: Rectangle {
            anchors.fill: parent
            radius: 10 // 圆角
            color: "#2d2d37" // 背景色
            clip: true // 裁剪超出边界的内容
            Flickable {
                anchors.fill: parent
                contentHeight: 1200 // 内容的虚拟高度，应大于 Flickable 的实际高度以实现滚动

                Column {
                    anchors.fill: parent
                    spacing: 40 // 子项之间的垂直间距
                }
            }
        }
    }
}
