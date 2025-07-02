import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

import AmericanMusic 1.0

// 整个“精选”页面内容较多，需要滚动才能完整浏览。
Flickable {
    // 为根元素设置一个 id，方便内部引用。
    id: flick
    anchors.fill: parent

    contentHeight: mainColumn.implicitHeight
    contentWidth: mainColumn.implicitWidth

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
    ColumnLayout {
        id: mainColumn
        width: parent.width // 2. 明确让 ColumnLayout 的宽度等于 Flickable 的宽度
        // spacing: 30 // ColumnLayout 的 spacing 属性

        PodCastWidget {
            Layout.fillWidth: true
        }
        OfficialMusic {
            Layout.fillWidth: true
        }
    }
}
