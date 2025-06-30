import QtQuick 2.15
import QtQuick.Controls 2.15

// 根元素使用 Item，因为它是一个轻量级的容器，不带任何视觉效果，适合封装组件
Item {
    // 组件ID，方便内部元素引用
    id: root

    // ----------------- 公共属性 (Properties) -----------------
    // 这些属性允许使用者从外部配置轮播图的行为

    // 属性别名，用于从外部设置轮播图的数据源 (model)
    // model 应该是一个包含图片路径的列表模型，例如 ListModel
    property alias model: imageRepeater.model

    // 当前显示的图片索引，可以从外部读取或设置
    property int currentIndex: 0

    // 是否开启自动播放
    property bool autoPlay: true

    // 自动播放的间隔时间（毫秒）
    property int interval: 3000

    // 默认组件大小，使用者可以覆盖
    width: 400
    height: 300

    // 设置内容裁剪，确保 Flicable 内部的图片不会超出 root 的边界
    clip: true

    // ----------------- 核心UI与逻辑 -----------------

    // Flickable 组件提供了可滑动的功能
    // 它是实现手动拖动切换的核心
    Flickable {
        id: flickable

        // 锚定到父容器（root）
        anchors.fill: parent

        // 内容宽度等于所有图片宽度的总和
        contentWidth: parent.width * imageRepeater.count
        contentHeight: parent.height

        // 设置可滑动的方向为水平
        flickableDirection: Flickable.HorizontalFlick

        // 当滑动停止在边界时，不要有回弹效果
        boundsBehavior: Flickable.StopAtBounds

        // 当用户手动滑动结束时触发
        onMovementEnded: {
            // 根据滑动停止时的位置 (contentX)，计算出当前应该显示的图片索引
            // Math.round 用于四舍五入，确保定位到最近的一张图片
            root.currentIndex = Math.round(contentX / root.width);
        }

        // --- 图片列表 ---
        // Repeater 用于根据 model 动态生成一系列的图片项
        Repeater {
            id: imageRepeater

            // Repeater 的 delegate 会为 model 中的每一个元素创建一个实例
            delegate: Image {
                // 图片的宽度和高度与轮播图组件一致
                width: root.width
                height: root.height
                // x 坐标根据其在 repeater 中的索引来确定，实现水平排列
                x: index * root.width
                // 图片填充模式，保持宽高比并填充整个区域，可能会裁剪部分图像
                fillMode: Image.PreserveAspectCrop
                // 图片来源。modelData 是 Repeater 提供的，代表当前项的数据
                // 这里我们假设 model 的每个元素都有一个名为 "imageSource" 的角色
                source: model.imageSource
            }
        }

        // --- 动画效果 ---
        // 使用 Behavior 为 contentX 属性添加动画
        // 当 currentIndex 改变时，flickable.contentX 也会改变
        // 这个 Behavior 会让 contentX 的变化变得平滑，从而产生滑动的动画效果
        Behavior on contentX {
            // 使用 SpringAnimation 可以创造出带有一点弹性的动画效果，比 NumberAnimation 更自然
            SpringAnimation {
                spring: 2
                damping: 0.2
            }
        }
    }

    // ----------------- 指示器 (Indicator) -----------------

    // 使用 Row 布局来水平排列指示器的小圆点
    Row {
        id: indicatorRow

        // 放置在轮播图底部中心
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10 // 距离底部的边距
        spacing: 8 // 小圆点之间的间距

        // 同样使用 Repeater 来根据 model 的数量生成对应数量的小圆点
        Repeater {
            model: imageRepeater.model

            // 每个小圆点的实现
            delegate: Rectangle {
                width: 10
                height: 10
                // 设置圆角半径为宽高的一半，使其成为一个圆形
                radius: width / 2

                // 核心逻辑：根据当前圆点的索引 (index) 是否等于轮播图的当前索引 (root.currentIndex)
                // 来决定其颜色。当前页的圆点高亮显示。
                color: index === root.currentIndex ? "orange" : "lightgray"
                opacity: 0.8 // 给一点透明度，让其不那么突兀

                // 为每个小圆点添加点击区域
                MouseArea {
                    anchors.fill: parent
                    // 当点击时，直接将轮播图的 currentIndex 设置为被点击圆点的索引
                    onClicked: {
                        root.currentIndex = index;
                    }
                }
            }
        }
    }

    // ----------------- 自动播放定时器 -----------------

    Timer {
        id: autoPlayTimer

        // 定时器的间隔时间，绑定到 root 的 interval 属性
        interval: root.interval
        // 是否重复执行
        repeat: true
        // 是否正在运行，绑定到 root 的 autoPlay 属性
        running: root.autoPlay

        // 每次定时器触发时执行的逻辑
        onTriggered: {
            // 将 currentIndex 加 1。使用模 (%) 运算，实现循环播放
            // 例如，如果有3张图 (count=3)，索引是0, 1, 2
            // 当 currentIndex=2 时, (2+1)%3 = 0，自动回到第一张
            root.currentIndex = (root.currentIndex + 1) % imageRepeater.count;
        }
    }

    // ----------------- 响应 currentIndex 变化 -----------------

    // 当 currentIndex 发生变化时，我们需要更新 Flickable 的 contentX
    // 这样无论是自动播放、点击指示器还是手动滑动，视图都能正确更新
    onCurrentIndexChanged: {
        // 将 flickable 的内容位置移动到当前索引对应的图片位置
        flickable.contentX = root.currentIndex * root.width;
    }
}
