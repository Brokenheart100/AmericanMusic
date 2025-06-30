import QtQuick
import QtQuick.Controls
import AmericanMusic 1.0

// 整个“精选”页面内容较多，需要滚动才能完整浏览。
Flickable {
    // 为根元素设置一个 id，方便内部引用。
    id: flick

    // 设置可滚动内容的总高度。Flickable 需要知道内容有多高才能正确计算滚动。
    // 注意：这里硬编码了一个 2200 的高度。在响应式布局中，更好的做法是
    // 将 contentHeight 动态绑定到其子元素（如下面的 Column）的实际高度上，
    // 例如 `contentHeight: aColumn.height`。
    contentHeight: 2200

    // 启用裁剪。超出 Flickable 边界的内容将被隐藏，不会绘制到外面去。
    clip: true

    // 通过附加属性 `ScrollBar.vertical` 来访问并自定义垂直滚动条。
    // 原始代码注释提到“不然访问不到”，正是指需要通过这种方式来修改滚动条样式。
    ScrollBar.vertical: ScrollBar {
        id: cusScrollBar // 为滚动条设置 id。

        // 使用锚布局将滚动条定位在父元素（Flickable）的右侧。
        anchors.right: parent.right
        // 设置距离右侧边缘 5 像素的边距。
        anchors.rightMargin: 5
        // 设置滚动条的宽度为 10 像素。
        width: 10
        // 设置滚动条的显示策略为 AsNeeded，即“按需显示”。
        // 只有当内容高度 (contentHeight) 超过 Flickable 的可视高度时，滚动条才会出现。
        policy: ScrollBar.AsNeeded

        // `contentItem` 属性用于定义滚动条滑块（即用户拖动的那个矩形条）的视觉外观。
        contentItem: Rectangle {
            // `parent.active` 是一个布尔值，当用户正在滚动或鼠标悬停在滚动条上时为 true。
            // 这里用它来控制滑块的可见性，实现仅在活动时显示滑块的交互效果。
            //visible: parent.active
            // `implicitWidth` 和 `implicitHeight` 用于向布局系统提供尺寸提示。
            implicitWidth: 10
            implicitHeight: 10
            // 设置滑块的圆角半径，使其边角平滑。
            radius: 4
            // 设置滑块的颜色。
            color: "#4141ee"
        }
    }

    // 使用 Column 布局来垂直排列其内部的各个 UI 模块。
    // 这个 Column 是 Flickable 中实际滚动的内容。
    Column {
        // 使 Column 填充其父元素（Flickable）的整个内容区域。
        anchors.fill: parent
        // 在 Column 的顶部设置 30 像素的外边距，使其内容与页面顶部有一定距离。
        anchors.topMargin: 30
        // 同样启用裁剪，虽然在 Flickable 内部，这通常是多余的，但并无坏处。
        clip: true
        // 设置 Column 内部各个子项之间的垂直间距为 30 像素。
        spacing: 30

        // --- 以下是页面中包含的各个内容模块 ---

        // 轮播图模块。这是一个自定义组件，用于显示滚动的横幅图片。
        // CarouselImage {
        //     id: carouselImage
        //     // anchors.left: parent.left
        //     // anchors.top: parent.top
        // }

        OfficialMusic {}
        // // 最新音乐模块。用于展示最新发布的歌曲或专辑。
        OfficialMusic {}
        // RecentMusic {}

        // // 精选有声书模块。展示推荐的有声读物内容。
        // CherryPickAudioBook {}

        // // 热门播客模块。展示当前流行的播客节目。
        // HotPodcast {}
    }
}
