pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

// 轮播图的主容器
Item {
    id: carouselContainer
    width: 400
    height: 200
    clip: true // 裁切掉超出边界的内容，对于 ListView 很重要

    // 1. 数据模型：定义轮播图的每一页内容
    ListModel {
        id: carouselModel
        ListElement {
            titleText: "探索北极光"
            description: "在冰岛追寻令人惊叹的自然奇观。"
            imagePath: "file:///E:/Computer/Qt6/AmericanMusic/image/1.jpg" // 请确保路径有效
            cardColor: "#0b3d61" // 深蓝色
        }
        ListElement {
            titleText: "漫步京都古寺"
            description: "感受千年古都的宁静与禅意。"
            imagePath: "file:///E:/Computer/Qt6/AmericanMusic/image/2.jpg"
            cardColor: "#8c2f2f" // 暗红色
        }
        ListElement {
            titleText: "享受马尔代夫的阳光"
            description: "在水晶般清澈的海水中放松身心。"
            imagePath: "file:///E:/Computer/Qt6/AmericanMusic/image/3.jpg"
            cardColor: "#007a8a" // 绿松石色
        }
        ListElement {
            titleText: "QML 简洁之道"
            description: "使用属性别名和自动映射构建UI。"
            imagePath: "file:///E:/Computer/Qt6/AmericanMusic/image/4.jpg"
            cardColor: "#41cd52" // Qt 绿色
        }
    }

    // 2. 委托组件：定义每一页的样式（使用最简洁的“无冒号”写法）
    Component {
        id: carouselPageDelegate
        Rectangle {
            id: delegateRoot

            width: carouselContainer.width
            height: carouselContainer.height

            // --- 简洁语法的核心 ---
            // a. 直接定义与 ListModel 角色名同名的属性。
            // Repeater/ListView 会自动将模型中的值填充到这里。
            property url imagePath:delegateRoot.imagePath
            property string titleText:delegateRoot.titleText
            property string description: delegateRoot.description

            // b. 使用“属性别名”，将外部的 "cardColor" 角色直接映射到 Rectangle 的 "color" 属性上。
            // 这样，当 ListView 设置 cardColor 时，就等于直接在设置这个 Rectangle 的 color。
            property alias cardColor: delegateRoot.color

            // --- 页面内部布局 ---
            Row {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Image {
                    id: icon
                    width: 100
                    height: 100
                    anchors.verticalCenter: parent.verticalCenter
                    // 直接使用由 ListView 自动填充的属性
                    source: delegateRoot.imagePath
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                }
                Column {
                    width: parent.width - icon.width - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Label {
                        text: delegateRoot.titleText
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        text: delegateRoot.description
                        font.pixelSize: 14
                        color: "white"
                        opacity: 0.9
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    // 3. 核心视图：使用 ListView 实现可滑动和吸附的页面容器
    ListView {
        id: listView
        anchors.fill: parent
        model: carouselModel
        delegate: carouselPageDelegate

        // 关键配置
        orientation: ListView.Horizontal // 水平方向
        snapMode: ListView.SnapToItem // 开启项目吸附，实现翻页效果
        boundsBehavior: Flickable.StopAtBounds// 拖到边缘时停止
        highlightMoveDuration: 300 // 程序切换页面时的动画时长

        // 鼠标滚轮控制
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel => {
                if (wheel.angleDelta.y > 0) {
                    listView.decrementCurrentIndex(); // 上一页
                } else if (wheel.angleDelta.y < 0) {
                    listView.incrementCurrentIndex(); // 下一页
                }
            }
        }
    }

    // 4. 页面指示器：显示当前页码的小圆点
    PageIndicator {
        id: pageIndicator
        count: listView.count
        currentIndex: listView.currentIndex

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10

        // 点击指示器跳转
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                let itemWidth = parent.width / parent.count;
                listView.currentIndex = Math.floor(mouse.x / itemWidth);
            }
        }
    }

    // 5. 自动播放定时器
    Timer {
        id: autoPlayTimer
        interval: 3000 // 3秒切换一次
        running: true
        repeat: true
        onTriggered: {
            // 当用户没有在拖动时，才自动翻页
            if (!listView.moving) {
                listView.incrementCurrentIndex();
            }
        }
    }
}