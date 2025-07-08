import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// 卡片的根容器
Rectangle {
    id: root

    // --- 数据属性 ---
    property string coverSource: "file:///E:/Computer/Qt6/AmericanMusic/image/1.jpg"
    property string articleTitle: "DJ阿智，别管我啦！DJ开启！“摆烂式”蹦迪狂欢，拒绝“精神内耗”～！"
    property string description: "包含「唯一（DJ阿智 remix）」等13首歌曲"

    // --- 视觉属性 ---
    // 尺寸由父布局（如GridLayout）决定，这里提供建议尺寸
    Layout.preferredWidth: 450
    implicitHeight: mainLayout.implicitHeight + 20 // 高度由内容自适应
    color: "transparent" // 卡片背景透明，由父容器控制

    // --- 鼠标悬浮区域和悬浮背景 ---
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#FFFFFF" // 白色
        opacity: mouseArea.containsMouse ? 0.05 : 0 // 悬浮时5%不透明度
        Behavior on opacity {
            OpacityAnimator {
                duration: 200
            }
        }
    }

    // --- 整体布局：使用 RowLayout ---
    RowLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        // Layout.margins:20
        spacing: 15

        // --- 1. 封面图区域 ---
        Item {
            id: coverContainer
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100

            Image {
                id: coverImage
                source: root.coverSource
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                Rectangle {
                    radius: 8
                    anchors.fill: parent
                    color: "transparent"
                }
            }

            // 悬浮播放按钮
            Image {
                id: playOverlayIcon
                anchors.centerIn: parent
                width: 40
                height: 40
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
                opacity: 0 // 初始透明
            }
        }

        // --- 2. 文本信息区域 ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter // 垂直居中
            spacing: 10

            // 文章标题 (多行省略)
            Label {
                text: root.articleTitle
                color: "white"
                font.pixelSize: 18
                wrapMode: Text.Wrap // 允许换行
                maximumLineCount: 2 // 最多显示2行
                elide: Text.ElideRight // 超出部分显示省略号
                Layout.fillWidth: true
            }
            RowLayout {
                Rectangle {
                    height: 20
                    // 宽度由内部的 Label 决定
                    width: tagLabel.width + 12
                    color: "transparent"
                    radius: 4
                    border.color: "#FFD700"
                    border.width: 1

                    Label {
                        id: tagLabel
                        anchors.centerIn: parent
                        text: "超清母带"
                        color: "#FFD700"
                        font.pixelSize: 12
                    }
                }
                // 描述文本 (单行省略)
                Label {
                    text: root.description
                    color: "#AAAAAA"
                    font.pixelSize: 14
                    elide: Text.ElideRight // 单行，超出部分显示省略号
                    Layout.fillWidth: true
                }
            }
        }

        // --- 3. 右侧悬浮操作按钮 ---
        RowLayout {
            id: actionButtons
            Layout.alignment: Qt.AlignVCenter // 垂直居中
            spacing: 15
            opacity: 0 // 初始透明

            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
                width: 24
                height: 24
            }
            Image {
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-line.svg"
                width: 24
                height: 24
            }
        }
    }

    // --- 核心：状态和过渡动画 ---
    states: [
        State {
            name: "hovered"
            when: mouseArea.containsMouse

            PropertyChanges {
                target: playOverlayIcon
                opacity: 1
            }
            PropertyChanges {
                target: actionButtons
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                property: "opacity"
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    ]
}
