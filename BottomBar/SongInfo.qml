import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

RowLayout {
    id: root
    spacing: 15
    property url coverSource: "file:///E:/Computer/Qt6/AmericanMusic/image/4.jpg"
    property string title: "87、百变芭比，我们..."
    property string artist: "浪radio"
    Image {
        source: parent.coverSource
        fillMode: Image.PreserveAspectCrop
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
            text: root.title
            color: "white"
            font.pixelSize: 16
            elide: Text.ElideRight
        }
        Label {
            text: root.artist
            color: "#A9A9C4"
            font.pixelSize: 13
        }
    }
}
