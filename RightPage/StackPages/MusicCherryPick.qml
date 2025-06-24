import QtQuick
import QtQuick.Controls
import AmericanMusic 1.0

Item {
    // 为根元素设置一个 id，方便在 QML 内部进行引用。
    id: cherryPick
    // 组件名 "CloudMusicCherryPick" 表明这是“网易云音乐精选”页面。
    objectName: "CloudMusicCherryPick"
    // 定义一个只读的 variant 类型属性 'types'。
    // 'variant' 类型可以存储任何基本类型，这里它存储了一个字符串数组。
    // 这个数组定义了顶部导航栏的各个选项卡标题。
    // "VIP" 被注释掉了，可能是未来计划加入的功能。
    readonly property var types: ["精选", "歌单广场", "排行榜", "歌手"]

    // 创建一个内部 Item 作为布局容器，用于管理边距。
    Item {
        // 使用 anchors（锚）布局，使其完全填充父元素（即根元素 q）。
        anchors.fill: parent
        // 设置左边距。这个边距是动态计算的，以适应不同宽度的窗口。
        // window.width 是整个窗口的宽度。
        // BasicConfig.wScale 是一个缩放因子，用于实现响应式布局。
        // (36 / 1317) 是一个基于设计稿（比如设计稿宽度为 1317px，边距为 36px）计算出的比例。
        anchors.leftMargin: 15
        // 设置上边距，同样使用了缩放因子。
        anchors.topMargin: 15

        // 标题中的选择器，这是一个自定义组件 ZYYUnderLineIndicator。
        // 从名字推断，它可能是一个带有下划线指示器的标签栏。
        // ZYYUnderLineIndicator {
        //     id: titleFlow // 为该组件设置 id，方便引用。
        //     anchors.left: parent.left // 左侧与父元素左侧对齐。
        //     anchors.top: parent.top // 顶部与父元素顶部对齐。
        //     height: 25 // 设置组件高度。
        //     spacing: 20 // 设置选项卡之间的间距。
        //     options: types // 将上面定义的 'types' 数组作为该组件的选项数据。它会根据这个数组生成标签。
        //     type: 0 // 'type' 属性可能用于设置初始选中的项，这里设置为 0，即默认选中第一个 "精选"。
        //     // (注意: 属性名 'type' 可能不如 'currentIndex' 或 'selectedIndex' 清晰)
        // }

        StackView {
            id: musicCherryPickStackView // 为 StackView 设置 id。
            // 锚布局：使其位于标题栏下方，并填充剩余空间。
            //anchors.top: titleFlow.bottom // 顶部紧贴标题栏 'titleFlow' 的底部。
            anchors.left: parent.left // 左侧与父元素左侧对齐。
            anchors.right: parent.right // 右侧与父元素右侧对齐。
            anchors.bottom: parent.bottom // 底部与父元素底部对齐。

            // 设置一个负的左边距。这是一个布局技巧。
            // 因为其父元素有一个正的左边距，这里设置一个大小相等方向相反的负边距，
            // 可以抵消父元素的边距，使得 StackView 内部的页面内容可以从窗口的边缘开始布局，实现全宽显示。
            // anchors.leftMargin: -window.width * (36 * BasicConfig.wScale / 1317)

            // 启用裁剪。如果 StackView 中的内容超出了其边界，超出部分将被隐藏。
            clip: true

            // 设置顶部边距，在标题栏和页面内容之间留出 20 像素的垂直间距。
            anchors.topMargin: 20

            // 设置初始加载的页面。当 StackView 第一次显示时，会加载并显示这个 QML 文件。
            initialItem: CherryPick {
                anchors.fill: parent
                clip: true
            }
        }
    }
}
