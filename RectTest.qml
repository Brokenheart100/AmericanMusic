// File: RectTest.qml

import QtQuick
import QtQuick.Controls

Item {
    width: 400
    height: 400

    // 定义 Rectangle 组件模板
    Component {
        id: rectComponent
        Rectangle {
            id: self // 给自己一个id，方便内部引用
            width: 50
            height: 50
            radius: 5
            color: "transparent"
            border.color: "black"
            border.width: 1

            // 随机颜色生成
            Component.onCompleted: {
                color = Qt.rgba(Math.random(), Math.random(), Math.random(), 0.7);

                // 启动内部的自毁计时器
                destroyTimer.start();
            }

            // 将 Timer 作为 Rectangle 的一部分
            Timer {
                id: destroyTimer
                interval: 30000
                repeat: false
                // running: false // 初始不运行，在 onCompleted 中启动
                onTriggered: {
                    console.log("Destroying rectangle at:", x.toFixed(0), y.toFixed(0));
                    self.destroy(); // 销毁自己
                }
            }
        }
    }

    // 按钮：点击生成随机矩形
    Button {
        id: createButton
        text: "生成随机矩形"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            // 创建矩形实例，不再需要处理 Timer
            rectComponent.createObject(parent, {
                x: Math.random() * (parent.width - 50),
                y: Math.random() * (parent.height - 50)
            });
        }
    }
}
