import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

// Fast add screen tuned for one-handed phone use.
Item {
    id: page

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        Text { text: qsTr("إضافة سريعة"); font.pixelSize: Theme.fontL; font.bold: true; color: Theme.text }

        // amount
        TextField {
            id: amount
            Layout.fillWidth: true
            font.pixelSize: 36
            horizontalAlignment: Text.AlignHCenter
            placeholderText: "0.00"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { bottom: 0; decimals: 2 }
        }

        // type toggle
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingS
            Button { id: expBtn; text: qsTr("مصروف"); checkable: true; checked: true; Layout.fillWidth: true
                     onClicked: { checked = true; incBtn.checked = false } }
            Button { id: incBtn; text: qsTr("دخل"); checkable: true; Layout.fillWidth: true
                     onClicked: { checked = true; expBtn.checked = false } }
        }

        Label { text: qsTr("التصنيف") }
        ComboBox { id: cat; Layout.fillWidth: true; model: App.categories; textRole: "name"; valueRole: "catId" }

        Label { text: qsTr("ملاحظة") }
        TextField { id: note; Layout.fillWidth: true; placeholderText: qsTr("اختياري") }

        Button {
            Layout.fillWidth: true
            text: qsTr("حفظ")
            highlighted: true
            enabled: amount.text.length > 0
            onClicked: {
                App.addTransaction(incBtn.checked ? 1 : 0,
                                   parseFloat(amount.text), "",
                                   cat.currentValue ? cat.currentValue : 0, 0, note.text)
                amount.clear(); note.clear()
            }
        }
        Item { Layout.fillHeight: true }
    }
}
