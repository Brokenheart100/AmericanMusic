import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 1000
    height: 300

    // 数据模型
    ListModel {
        id: singDetailModel
        ListElement {
            src: "file:///E:/Computer/Qt6/AmericanMusic/image/1.jpg"
            gColor: "#ff7c6362"
            titleText: "欧美热播2004|和Aicia Keys重温2004流行经典"
            sing1: "1 REAL GANGSTALOVE"
            sing2: "2 Devuelve..."
            sing3: "3 Soy No"
        }
        ListElement {
            src: "file:///E:/Computer/Qt6/AmericanMusic/image/2.jpg"
            gColor: "#ff7c6362"
            titleText: "Waterbomb音乐节|夏日女王娜莲激情开唱"
            sing1: "1 POP1"
            sing2: "2 ABCD"
            sing3: "3 Love Count"
        }
        ListElement {
            src: "file:///E:/Computer/Qt6/AmericanMusic/image/3.jpg"
            gColor: "#e4332d"
            titleText: "Waterbomb音乐节|夏日女王娜莲激情开唱"
            sing1: "1 POP1"
            sing2: "2 ABCD"
            sing3: "3 Love Count"
        }
        ListElement {
            src: "file:///E:/Computer/Qt6/AmericanMusic/image/4.jpg"
            gColor: "#e4332d"
            titleText: "Waterbomb音乐节|夏日女王娜莲激情开唱"
            sing1: "1 POP1"
            sing2: "2 ABCD"
            sing3: "3 Love Count"
        }
        ListElement {
            src: "file:///E:/Computer/Qt6/AmericanMusic/image/5.jpeg"
            gColor: "#e4332d"
            titleText: "Waterbomb音乐节|夏日女王娜莲激情开唱"
            sing1: "1 POP1"
            sing2: "2 ABCD"
            sing3: "3 Love Count"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // 标题部分
        Label {
            text: "官方歌单>"
            font {
                bold: true
                family: "黑体"
                pixelSize: 24
            }
            color: "white"
            Layout.leftMargin: 20
        }

        // 列表和箭头容器
        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 优化：使用单独的 Item 处理鼠标事件，避免嵌套更新
            Item {
                id: mouseHandler
                anchors.fill: parent

                property bool isHovered: false
            }

            // 水平滚动列表
            ListView {
                id: listView
                anchors {
                    fill: parent
                    leftMargin: 40
                    rightMargin: 40
                }

                clip: true
                orientation: ListView.Horizontal
                model: singDetailModel
                spacing: 20
                interactive: false

                // 为 contentX 添加平滑滚动动画
                Behavior on contentX {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }

                // 优化：使用更复杂的委托，展示音乐卡片
                delegate: Item {
                    id: delegateItem
                    width: 200
                    height: 250

                    // 卡片背景
                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        clip: true

                        // 封面图片
                        Image {
                            id: coverImage
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                            }
                            height: 150
                            source: src
                            fillMode: Image.PreserveAspectCrop
                        }

                        // 标题文本
                        Label {
                            id: titleLabel
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: coverImage.bottom
                                margins: 10
                            }
                            text: titleText
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                            elide: Label.ElideRight
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 2
                        }

                        // 歌曲列表
                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: titleLabel.bottom
                                margins: 10
                            }
                            spacing: 5

                            Label {
                                text: sing1
                                font.pixelSize: 12
                                color: "#666666"
                            }
                            Label {
                                text: sing2
                                font.pixelSize: 12
                                color: "#666666"
                            }
                            Label {
                                text: sing3
                                font.pixelSize: 12
                                color: "#666666"
                            }
                        }
                    }
                }
            }

            // 左箭头
            Image {
                id: leftArrow
                visible: false
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-fill.svg"
                width: 30
                height: 30
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: 5
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // 优化：添加边界检查，防止过度滚动
                        var pageWidth = listView.width - listView.leftMargin - listView.rightMargin;
                        listView.contentX = Math.max(0, listView.contentX - pageWidth);
                    }
                }
            }

            // 右箭头
            Image {
                id: rightArrow
                visible: false
                source: "file:///E:/Computer/Qt6/AmericanMusic/svg/heart-2-fill.svg"
                width: 30
                height: 30
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 5
                }
                transform: Scale {
                    origin.x: root.width / 2
                    origin.y: root.height / 2
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // 优化：添加边界检查，防止过度滚动
                        var pageWidth = listView.width - listView.leftMargin - listView.rightMargin;
                        var maxScroll = listView.contentWidth - pageWidth;
                        listView.contentX = Math.min(maxScroll, listView.contentX + pageWidth);
                    }
                }
            }
        }
    }
}
