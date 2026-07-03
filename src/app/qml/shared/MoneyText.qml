import QtQuick
import BudgetTrackerUi

// Colored money label. kind: 0 = expense (red), 1 = income (green), 2 = neutral.
Text {
    property string amount: "0.00"
    property string currency: "JOD"
    property int    kind: 2

    text: amount + " " + currency
    color: kind === 1 ? Theme.income
         : kind === 0 ? Theme.expense
                      : Theme.text
    font.pixelSize: Theme.fontM
    font.bold: true
    elide: Text.ElideRight
    horizontalAlignment: Text.AlignLeft
    verticalAlignment: Text.AlignVCenter
    textFormat: Text.PlainText
}
