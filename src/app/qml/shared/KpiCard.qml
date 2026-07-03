import QtQuick
import QtQuick.Layouts
import BudgetTrackerUi

// Headline metric card for the dashboard (e.g. Income / Expense / Remaining).
Card {
    id: root
    property string title: ""
    property string value: "0.00"
    property string currency: "JOD"
    property color  tone: Theme.text

    implicitHeight: 112
    implicitWidth: 200

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingXs

        Text {
            text: root.title
            color: Theme.textMuted
            font.pixelSize: Theme.fontS
        }
        Item { Layout.fillHeight: true }
        RowLayout {
            spacing: 6
            Text {
                text: root.value
                color: root.tone
                font.pixelSize: Theme.fontXL
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: root.currency
                color: Theme.textMuted
                font.pixelSize: Theme.fontM
                Layout.alignment: Qt.AlignBottom
                bottomPadding: 5
            }
        }
    }
}
