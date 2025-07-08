import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 轮播图的根容器
Rectangle {
    id: root

    // --- 可配置属性 ---
    // 允许从外部设置尺寸和图片列表
    property int itemWidth: 500
    property int itemHeight: 250
    property var imageSources: ["file:///E:/Computer/Qt6/AmericanMusic/image/1.jpg", "file:///E:/Computer/Qt6/AmericanMusic/image/2.jpg", "file:///E:/Computer/Qt6/AmericanMusic/image/3.jpg", "file:///E:/Computer/Qt6/AmericanMusic/image/4.jpg"]
    property int autoPlayInterval: 3000 // 自动播放间隔（毫秒）
    radius: 12 // 圆角
    clip: true // 裁剪子元素，确保图片不会画到圆角外面

    // --- 1. 图片滑动视图 ---
    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: 0 // 默认显示第一张

        // 使用 Repeater 根据图片列表动态创建页面
        Repeater {
            model: root.imageSources
            delegate: Image {
                // modelData 就是 imageSources 数组中的当前项（即图片路径）
                source: modelData
                fillMode: Image.PreserveAspectCrop // 裁剪并填充，保持图片比例
            }
        }
    }

    // --- 2. 页面指示器 (小圆点) ---
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        // 根据 SwipeView 的页面数量创建对应数量的圆点
        Repeater {
            model: swipeView.count

            delegate: Rectangle {
                width: 8
                height: 8
                radius: width / 2 // 保持圆形

                // 核心：根据当前圆点的索引(index)是否等于SwipeView的当前页面索引(currentIndex)来决定颜色
                color: swipeView.currentIndex === index ? "white" : "rgba(255, 255, 255, 0.5)"

                // 添加一个平滑的颜色过渡动画
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }
        }
    }

    // --- 3. 自动轮播计时器 ---
    Timer {
        id: autoPlayTimer
        interval: root.autoPlayInterval
        repeat: true
        running: true // 默认启动

        onTriggered: {
            // 索引加1，如果到了末尾，通过取模(%)操作回到开头
            swipeView.currentIndex = (swipeView.currentIndex + 1) % swipeView.count;
        }
    }

    // --- 4. (优化) 用户交互时暂停自动播放 ---
    MouseArea {
        anchors.fill: parent
        // 当用户按下时，停止计时器
        onPressed: autoPlayTimer.stop()
        // 当用户松开时，重新启动计时器
        onReleased: autoPlayTimer.start()
    }
}
