pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

// 整个轮播图组件的根容器
Item {
    id: carouselImage
    property string svgAbsolutePath: "file:///D:/BaiduSyncdisk/Qt/AmericanMusic/svg"

    // 锚定到父级的左右边缘，占据父级整个宽度
    anchors.left: parent.left
    anchors.right: parent.right
    // 高度是固定的200像素，但会根据 carouselRow 的 m_scale 属性进行缩放
    height: 200 * carouselRow.m_scale
    // 裁剪子项，任何超出此 Item 边界的内容都将被隐藏
    clip: true

    // 一个覆盖整个组件的鼠标区域，用于处理悬停效果
    MouseArea {
        anchors.fill: parent
        // 必须启用 hoverEnabled 才能接收 onEntered 和 onExited 事件
        hoverEnabled: true

        // 鼠标光标进入该区域时触发
        onEntered: {
            // 显示左右导航箭头
            leftIniImg.visible = true;
            rightIniImg.visible = true;
            // 将鼠标光标形状变为手形，提示用户可以点击
            cursorShape = Qt.PointingHandCursor;
        }

        // 鼠标光标离开该区域时触发
        onExited: {
            // 隐藏左右导航箭头
            leftIniImg.visible = false;
            rightIniImg.visible = false;
            // 恢复默认的箭头光标
            cursorShape = Qt.ArrowCursor;
        }
    }

    // 左导航箭头图片
    Image {
        id: leftIniImg
        visible: false // 默认隐藏
        anchors.left: parent.left // 锚定在父容器左侧
        anchors.verticalCenter: parent.verticalCenter // 垂直居中
        source: carouselImage.svgAbsolutePath + "/computer-fill.svg"// 图片资源路径

        // 箭头自身的鼠标区域，确保鼠标在箭头上时也能保持悬停效果
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            // 鼠标进入箭头区域，确保箭头和光标保持可见/手形
            // 这是为了防止当鼠标从外部区域移动到箭头上时，外部的 onExited 事件触发导致箭头消失
            onEntered: {
                leftIniImg.visible = true;
                rightIniImg.visible = true;
                cursorShape = Qt.PointingHandCursor;
            }
            // 鼠标离开箭头区域
            onExited: {
                leftIniImg.visible = false;
                rightIniImg.visible = false;
                cursorShape = Qt.ArrowCursor;
            }
            // 点击左箭头：向左滑动（播放“下一个”的动画）
            onClicked: {
                // 设置一个标志，让自动轮播计时器只再执行一次
                startTimer.onlyOnce = true;
                // 设置动画为正向播放 (reserveFlag = false)
                carouselIndicatorAnimtion.reserveFlag = false;
                // 将计时器间隔缩短，立即触发一次动画
                startTimer.interval = 100;
                startTimer.start(); // 启动（或重启）计时器
            }
        }
    }

    // 右导航箭头图片 (注意：ID 有个拼写错误 rightIniImg)
    Image {
        id: rightIniImg
        mirror: true // 水平翻转 leftArrow.png，复用同一个图片资源
        visible: false // 默认隐藏
        anchors.right: parent.right // 锚定在父容器右侧
        anchors.verticalCenter: parent.verticalCenter
        source: carouselImage.svgAbsolutePath + "/computer-fill.svg"// 图片资源路径

        // 箭头自身的鼠标区域，逻辑同左箭头
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                leftIniImg.visible = true;
                rightIniImg.visible = true;
                cursorShape = Qt.PointingHandCursor;
            }
            onExited: {
                leftIniImg.visible = false;
                rightIniImg.visible = false;
                cursorShape = Qt.ArrowCursor;
            }
            // 点击右箭头：向右滑动（播放“上一个”的动画）
            onClicked: {
                // 立即停止自动轮播
                startTimer.stop();
                carouselIndicatorAnimtion.stop();
                // 设置动画为反向播放
                carouselIndicatorAnimtion.reserveFlag = true;
                // 立即开始反向动画
                carouselIndicatorAnimtion.start();
                // 启动一个2秒的计时器，2秒后恢复自动轮播
                startAni.start();
            }
        }
    }

    // 用于手动点击右箭头后，延迟一段时间再恢复自动轮播的计时器
    Timer {
        id: startAni
        repeat: false // 只执行一次
        running: false // 默认不运行
        interval: 2000 // 间隔2秒
        // 2秒后触发
        onTriggered: {
            // 将动画方向设置回正向
            carouselIndicatorAnimtion.reserveFlag = false;
            // 重新启动自动轮播计时器（此时会使用其默认的3秒间隔）
            startTimer.start();
        }
    }

    // 轮播图内容（ListView和指示器）的容器
    Item {
        clip: true // 裁剪内容
        width: 20// 宽度可能是为了适应某种布局
        height: parent.height * carouselRow.m_scale
        anchors.left: parent.left
        anchors.top: parent.top
        // 左边距，看起来是根据窗口宽度进行动态计算，以实现响应式布局
        anchors.leftMargin: Window.width
        // 轮播图的数据模型
        ListModel {
            id: carouselModel
            // 每个ListElement代表一个轮播项，src是图片路径
            ListElement {
                src: carouselImage.svgAbsolutePath + "/computer-fill.svg"
                name: "list1"
            }
            ListElement {
                src: carouselImage.svgAbsolutePath + "/computer-fill.svg"
                name: "list2"
            }
            ListElement {
                src: carouselImage.svgAbsolutePath + "/computer-fill.svg"
                name: "list3"
            }
        }

        // 核心的水平列表视图，用于展示轮播图片
        ListView {
            id: carouselRow
            spacing: 30 // 列表项之间的间距
            orientation: ListView.Horizontal // 水平方向排列
            anchors.left: parent.left
            anchors.right: parent.right
            height: 160 * carouselRow.m_scale // 高度随 m_scale 变化
            model: carouselModel
            enabled: false // 禁用手动拖动/滑动，只能通过箭头和计时器控制

            // 自定义属性，用于根据视图宽度动态缩放内容。当宽度为950时，m_scale为1。
            property real m_scale: (carouselRow.width / 950 - 1) * 0.4 + 1

            // 委托（模板）：定义模型中每个数据项如何显示
            delegate: Rectangle {
                width: 460 * carouselRow.m_scale // 宽度动态缩放
                height: 160 * carouselRow.m_scale // 高度动态缩放
                radius: 10
                clip: true
                color: "transparent" // 背景透明
                // required property string src
                // required property string name
                Text {
                    anchors.centerIn: parent
                    text: name
                }
                Image {
                    id: carouselImg
                    anchors.centerIn: parent // 在父矩形中居中
                    source: src// 图片源来自模型
                    scale: carouselRow.m_scale // 图片本身也进行缩放
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        // 鼠标悬停在单个图片上时
                        onEntered: {
                            parent.opacity = 0.8; // 图片变半透明
                            // 同样显示左右箭头并改变光标
                            leftIniImg.visible = true;
                            rightIniImg.visible = true;
                            cursorShape = Qt.PointingHandCursor;
                        }
                        onExited: {
                            parent.opacity = 1; // 恢复不透明
                            // 隐藏箭头并恢复光标
                            leftIniImg.visible = false;
                            rightIniImg.visible = false;
                            cursorShape = Qt.ArrowCursor;
                        }
                    }
                }
            }

            // --- 列表视图的过渡动画 ---
            // 当模型中添加元素时，新出现的项的动画
            add: Transition {
                NumberAnimation {
                    property: "x"
                    duration: 1030 * (2 - carouselRow.m_scale)
                    from: -460
                    to: 0
                    easing.type: Easing.Linear
                }
            }
            // 当添加元素导致已有项需要移动位置时的动画
            addDisplaced: Transition {
                NumberAnimation {
                    property: "x"
                    duration: 1000 * (2 - carouselRow.m_scale)
                    easing.type: Easing.Linear
                }
            }
            // 当模型中移除元素时，被移除项的动画
            remove: Transition {
                NumberAnimation {
                    property: "x"
                    duration: 930 * (2 - carouselRow.m_scale)
                    from: 0
                    to: -460
                    easing.type: Easing.Linear
                }
            }
            // 当移除元素导致已有项需要移动位置时的动画
            removeDisplaced: Transition {
                NumberAnimation {
                    property: "x"
                    duration: 1000
                    easing.type: Easing.Linear
                }
            }
        }

        // 轮播指示器（小圆点）的容器
        Item {
            id: carouselIndicatorItem
            anchors.top: carouselRow.bottom // 位于图片列表下方
            anchors.topMargin: 20 * carouselRow.m_scale
            anchors.horizontalCenter: parent.horizontalCenter // 水平居中
            width: 95
            height: 10
            // 自定义属性，用于存储指示点的初始尺寸，方便动画后重置
            property var widthArray: [0, 6, 8, 10, 8, 6, 0]
            // 自定义属性，用于存储指示点的初始位置，方便动画后重置
            property var posArray: []

            // --- 一系列代表指示点的矩形 ---
            // indicator0 和 indicator6 的宽度为0，作为不可见的占位符，简化动画逻辑
            Rectangle {
                id: indicator0
                width: carouselIndicatorItem.widthArray[0]
                height: width
                radius: height / 2
                color: "#a1a1a3"
                anchors.verticalCenter: parent.verticalCenter
                // 组件加载完成后，记录下自己的x坐标到posArray
                Component.onCompleted: {
                    parent.posArray.push(x);
                    parent.posArray.reverse();
                }
            }
            Rectangle {
                id: indicator1
                width: carouselIndicatorItem.widthArray[1]
                height: width
                radius: height / 2
                color: "#a1a1a3"
                x: indicator0.x + 10 + indicator0.width
                anchors.verticalCenter: parent.verticalCenter
                Component.onCompleted: parent.posArray.push(x)
            }
            Rectangle {
                id: indicator2
                width: carouselIndicatorItem.widthArray[2]
                height: width
                radius: height / 2
                color: "#a1a1a3"
                x: indicator1.x + 10 + indicator1.width
                anchors.verticalCenter: parent.verticalCenter
                Component.onCompleted: parent.posArray.push(x)
            }
            // 中间的点，最大，表示当前项
            Rectangle {
                id: indicator3
                width: carouselIndicatorItem.widthArray[3]
                height: width
                radius: height / 2
                color: "#a1a1a3"
                x: indicator2.x + 10 + indicator2.width
                anchors.verticalCenter: parent.verticalCenter
                Component.onCompleted: parent.posArray.push(x)
            }
            Rectangle {
                id: indicator4
                width: carouselIndicatorItem.widthArray[4]
                height: width
                radius: height / 2
                color: "#a1a1a3"
                x: indicator3.x + 10 + indicator3.width
                anchors.verticalCenter: parent.verticalCenter
                Component.onCompleted: parent.posArray.push(x)
            }
            Rectangle {
                id: indicator5
                width: carouselIndicatorItem.widthArray[5]
                height: width
                radius: height / 2
                color: "#a1a1a3"
                x: indicator4.x + 10 + indicator4.width
                anchors.verticalCenter: parent.verticalCenter
                Component.onCompleted: parent.posArray.push(x)
            }
            Rectangle {
                id: indicator6
                width: carouselIndicatorItem.widthArray[6]
                height: width
                radius: height / 2
                color: "#a1a1a3"
                x: indicator5.x + 10 + indicator5.width
                anchors.verticalCenter: parent.verticalCenter
                Component.onCompleted: parent.posArray.push(x)
            }

            // 核心动画：控制指示器的移动和大小变化
            SequentialAnimation {
                id: carouselIndicatorAnimtion
                alwaysRunToEnd: true // 确保动画完整播放不被打断
                // 自定义标志，用于控制动画是正向(false)还是反向(true)播放
                property bool reserveFlag: false

                // 步骤1: 并行动画，所有指示点同时变化
                ParallelAnimation {
                    alwaysRunToEnd: true

                    // --- 每个指示点的位置和大小动画 ---
                    // from/to 的值根据 reserveFlag 动态确定，实现正反向动画
                    // 例如，正向时，indicator2 移动到 indicator1 的位置并采用其大小
                    // 反向时，indicator1 移动到 indicator2 的位置并采用其大小
                    PropertyAnimation {
                        target: indicator1
                        properties: "height,width"
                        from: carouselIndicatorAnimtion.reserveFlag ? 0 : 6
                        to: carouselIndicatorAnimtion.reserveFlag ? 6 : 0
                        duration: 1000
                        alwaysRunToEnd: true
                    }
                    NumberAnimation {
                        target: indicator1
                        properties: "x"
                        from: carouselIndicatorAnimtion.reserveFlag ? 0 : indicator1.x
                        to: carouselIndicatorAnimtion.reserveFlag ? indicator1.x : 0
                        duration: 1000
                        alwaysRunToEnd: true
                    }

                    // *** 关键部分：动画开始的同时，修改数据模型 ***
                    ScriptAction {
                        script: {
                            // 这个脚本动作与并行动画同时开始。
                            // 它的核心作用是修改数据模型（ListModel），这个修改会触发ListView的过渡动画（图片的滑动）。
                            // 从而实现了指示器动画和图片滑动的同步。
                            if (carouselIndicatorAnimtion.reserveFlag) {
                                // 如果是反向动画
                                // 将最后一个元素移动到最前面
                                carouselModel.insert(0, carouselModel.get(carouselModel.count - 1));
                                carouselModel.remove(carouselModel.count - 1);
                            } else {
                                // 如果是正向动画
                                // 将第一个元素移动到最后面
                                carouselModel.append(carouselModel.get(0));
                                carouselModel.remove(0);
                            }
                        }
                    }
                    PropertyAnimation {
                        target: indicator2
                        properties: "height,width"
                        from: carouselIndicatorAnimtion.reserveFlag ? 6 : 8
                        to: carouselIndicatorAnimtion.reserveFlag ? 8 : 6
                        duration: 1000
                        alwaysRunToEnd: true
                    }
                    NumberAnimation {
                        target: indicator2
                        properties: "x"
                        from: carouselIndicatorAnimtion.reserveFlag ? indicator1.x : indicator2.x
                        to: carouselIndicatorAnimtion.reserveFlag ? indicator2.x : indicator1.x
                        duration: 1000
                        alwaysRunToEnd: true
                    }

                    PropertyAnimation {
                        target: indicator3
                        properties: "height,width"
                        from: carouselIndicatorAnimtion.reserveFlag ? 8 : 10
                        to: carouselIndicatorAnimtion.reserveFlag ? 10 : 8
                        duration: 1000
                        alwaysRunToEnd: true
                    }
                    NumberAnimation {
                        target: indicator3
                        properties: "x"
                        from: carouselIndicatorAnimtion.reserveFlag ? indicator2.x : indicator3.x
                        to: carouselIndicatorAnimtion.reserveFlag ? indicator3.x : indicator2.x
                        duration: 1000
                        alwaysRunToEnd: true
                    }

                    PropertyAnimation {
                        target: indicator4
                        properties: "height,width"
                        from: carouselIndicatorAnimtion.reserveFlag ? 10 : 8
                        to: carouselIndicatorAnimtion.reserveFlag ? 8 : 10
                        duration: 1000
                        alwaysRunToEnd: true
                    }
                    NumberAnimation {
                        target: indicator4
                        properties: "x"
                        from: carouselIndicatorAnimtion.reserveFlag ? indicator3.x : indicator4.x
                        to: carouselIndicatorAnimtion.reserveFlag ? indicator4.x : indicator3.x
                        duration: 1000
                        alwaysRunToEnd: true
                    }

                    PropertyAnimation {
                        target: indicator5
                        properties: "height,width"
                        from: carouselIndicatorAnimtion.reserveFlag ? 8 : 6
                        to: carouselIndicatorAnimtion.reserveFlag ? 6 : 8
                        duration: 1000
                        alwaysRunToEnd: true
                    }
                    NumberAnimation {
                        id: mesuarFlag
                        target: indicator5
                        properties: "x"
                        from: carouselIndicatorAnimtion.reserveFlag ? indicator4.x : indicator5.x
                        to: carouselIndicatorAnimtion.reserveFlag ? indicator5.x : indicator4.x
                        duration: 1000
                        alwaysRunToEnd: true
                    }

                    PropertyAnimation {
                        target: indicator6
                        properties: "height,width"
                        from: carouselIndicatorAnimtion.reserveFlag ? 6 : 0
                        to: carouselIndicatorAnimtion.reserveFlag ? 0 : 6
                        duration: 1000
                        alwaysRunToEnd: true
                    }
                    NumberAnimation {
                        id: bbb
                        target: indicator6
                        properties: "x"
                        from: carouselIndicatorAnimtion.reserveFlag ? indicator5.x : indicator6.x
                        to: carouselIndicatorAnimtion.reserveFlag ? indicator6.x : indicator5.x
                        duration: 1000
                        alwaysRunToEnd: true
                    }
                }

                // 步骤2: 动画结束后，重置所有指示器的状态
                ScriptAction {
                    script: {
                        // 这个脚本在并行动画结束后执行。
                        // 它将所有指示器的大小和位置重置到它们的初始状态（从 widthArray 和 posArray 读取）。
                        // 这样做的效果是，虽然看起来是点在移动，但实际上每个点都只是在扮演下一个点的角色，
                        // 动画结束后，它们都“瞬间”恢复原样，为下一次动画做准备。
                        indicator0.width = carouselIndicatorItem.widthArray[0];
                        indicator1.width = carouselIndicatorItem.widthArray[1];
                        indicator2.width = carouselIndicatorItem.widthArray[2];
                        indicator3.width = carouselIndicatorItem.widthArray[3];
                        indicator4.width = carouselIndicatorItem.widthArray[4];
                        indicator5.width = carouselIndicatorItem.widthArray[5];
                        indicator6.width = carouselIndicatorItem.widthArray[6];
                        indicator0.x = carouselIndicatorItem.posArray[0];
                        indicator1.x = carouselIndicatorItem.posArray[1];
                        indicator2.x = carouselIndicatorItem.posArray[2];
                        indicator3.x = carouselIndicatorItem.posArray[3];
                        indicator4.x = carouselIndicatorItem.posArray[4];
                        indicator5.x = carouselIndicatorItem.posArray[5];
                        indicator6.x = carouselIndicatorItem.posArray[6];
                    }
                }
            }
        }

        // 主自动轮播计时器
        Timer {
            id: startTimer
            running: true // 组件加载后自动开始运行
            repeat: true // 重复触发
            interval: 3000 // 每3秒触发一次
            // 自定义属性，用于处理手动点击左箭头后的特殊逻辑
            property bool onlyOnce: false
            onTriggered: {
                // 每次触发都启动一次正向动画
                carouselIndicatorAnimtion.start();
                // 如果 onlyOnce 标志为 true (由点击左箭头设置)
                if (onlyOnce) {
                    // 将间隔恢复为正常的3秒
                    interval = 3000;
                    // 停止计时器
                    stop();
                    // 将标志位复原
                    startTimer.onlyOnce = false;
                    // 启动 startAni 计时器，它会在2秒后重新启动这个 startTimer，
                    // 从而实现“手动点击后，等待一段时间再恢复自动轮播”的效果。
                    startAni.start();
                }
            }
        }
    }
}
