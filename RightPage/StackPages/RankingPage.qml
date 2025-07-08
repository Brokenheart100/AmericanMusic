// RankingPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: page
    color: "#1E1E1E"
    Layout.preferredWidth: 700
    Layout.preferredHeight: 500
    radius: 30
    // --- 榜单数据模型 (使用嵌套 ListModel) ---
    ListModel {
        id: rankingModel

        ListElement {
            cardTitle: "飙升榜"
            updateInfo: "更新56首"
        }
    }

    // --- 整体滚动和布局 ---
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        GridLayout {
            id: grid
            width: parent.width // 让 GridLayout 宽度与 ScrollView 视口一致
            columns: 2
            columnSpacing: 20
            rowSpacing: 20

            Repeater {
                model: rankingModel
                delegate: RankingCard {
                    Layout.fillWidth: true // 让卡片填充网格列的宽度
                    cardTitle: model.cardTitle
                    updateInfo: model.updateInfo
                    coverImages: model.coverImages
                    songList: model.songList
                }
            }
        }
    }
}
