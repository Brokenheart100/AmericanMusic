import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

RowLayout {
    spacing: 15

    Image {
        // 封面
        source: "file:///E:/Computer/Qt6/AmericanMusic/image/4.jpg"
        Layout.preferredWidth: 56
        Layout.preferredHeight: 56
        Layout.alignment: Qt.AlignVCenter
        Rectangle {
            anchors.fill: parent
            radius: 8
            color: "transparent"
        }
    }

    ColumnLayout {
        // 歌曲名和作者
        spacing: 4
        Layout.alignment: Qt.AlignVCenter

        Label {
            text: "87、百变芭比，我们..."
            color: "white"
            font.pixelSize: 16
            elide: Text.ElideRight
        }
        Label {
            text: "浪radio"
            color: "#A9A9C4"
            font.pixelSize: 13
        }
    }
}
