import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

// Mobile home: a big "remaining" card + recent transactions as cards.
Item {
    id: page

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingM

        // remaining hero card
        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Theme.spacingXs
                Text {
                    text: qsTr("المتبقي — ") + App.currentMonth
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontS
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: App.dashboard.remainingText + " " + App.dashboard.currency
                    color: App.dashboard.isNegative ? Theme.expense : Theme.primary
                    font.pixelSize: Theme.fontXL
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.spacingL
                    Text { text: qsTr("دخل: ") + App.dashboard.incomeText; color: Theme.income; font.pixelSize: Theme.fontS }
                    Text { text: qsTr("مصروف: ") + App.dashboard.expenseText; color: Theme.expense; font.pixelSize: Theme.fontS }
                }
            }
        }

        Text { text: qsTr("أحدث العمليات"); font.bold: true; color: Theme.text }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Theme.spacingS
            model: App.transactions
            delegate: Card {
                id: c
                width: ListView.view.width
                height: 64
                required property string categoryName
                required property string signedAmount
                required property string currency
                required property string dateText
                required property bool   isExpense
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    Text { text: c.categoryName; color: Theme.text; Layout.fillWidth: true }
                    MoneyText { amount: c.signedAmount; currency: c.currency; kind: c.isExpense ? 0 : 1 }
                }
            }
        }
    }
}
