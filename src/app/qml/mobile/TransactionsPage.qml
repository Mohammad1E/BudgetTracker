import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

// Mobile transactions list (cards, swipe-to-delete-ready).
Item {
    id: page

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingS

        Text { text: qsTr("العمليات — ") + App.currentMonth; font.bold: true; color: Theme.text }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Theme.spacingS
            model: App.transactions
            delegate: Card {
                id: c
                width: ListView.view.width
                height: 70
                required property var    txId
                required property string categoryName
                required property string note
                required property string dateText
                required property string signedAmount
                required property string currency
                required property bool   isExpense

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingM
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text { text: c.categoryName; color: Theme.text; font.pixelSize: Theme.fontM }
                        Text { text: c.note.length ? c.note : c.dateText; color: Theme.textMuted; font.pixelSize: Theme.fontS }
                    }
                    MoneyText { amount: c.signedAmount; currency: c.currency; kind: c.isExpense ? 0 : 1 }
                }
            }
            Text {
                anchors.centerIn: parent
                visible: list.count === 0
                text: qsTr("لا توجد عمليات")
                color: Theme.textMuted
            }
        }
    }
}
