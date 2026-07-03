import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

// Add-transaction dialog. Open with .open(). Calls App.addTransaction on accept.
Dialog {
    id: dlg
    title: qsTr("إضافة عملية")
    modal: true
    anchors.centerIn: Overlay.overlay
    width: 420
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Popup.CloseOnEscape

    onAboutToShow: {
        amountField.clear()
        noteField.clear()
        dateField.text = Qt.formatDate(new Date(), "yyyy-MM-dd")
        typeCombo.currentIndex = 0
        linkPerson.checked = false
    }

    onAccepted: {
        App.addTransaction(
            typeCombo.currentIndex,                       // 0 expense / 1 income
            parseFloat(amountField.text.length ? amountField.text : "0"),
            dateField.text,
            catCombo.currentValue ? catCombo.currentValue : 0,
            (linkPerson.checked && personCombo.currentValue) ? personCombo.currentValue : 0,
            noteField.text)
    }

    contentItem: ColumnLayout {
        spacing: Theme.spacingS

        Label { text: qsTr("النوع") }
        ComboBox {
            id: typeCombo
            Layout.fillWidth: true
            model: [qsTr("مصروف"), qsTr("دخل")]
        }

        Label { text: qsTr("المبلغ") }
        TextField {
            id: amountField
            Layout.fillWidth: true
            placeholderText: "0.00"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { bottom: 0; decimals: 2; notation: DoubleValidator.StandardNotation }
        }

        Label { text: qsTr("التاريخ") }
        TextField {
            id: dateField
            Layout.fillWidth: true
            placeholderText: "yyyy-MM-dd"
        }

        Label { text: qsTr("التصنيف") }
        ComboBox {
            id: catCombo
            Layout.fillWidth: true
            model: App.categories
            textRole: "name"
            valueRole: "catId"
        }

        RowLayout {
            Layout.fillWidth: true
            CheckBox { id: linkPerson; text: qsTr("ربط بشخص") }
            ComboBox {
                id: personCombo
                Layout.fillWidth: true
                enabled: linkPerson.checked
                model: App.people
                textRole: "name"
                valueRole: "personId"
            }
        }

        Label { text: qsTr("ملاحظة") }
        TextField {
            id: noteField
            Layout.fillWidth: true
            placeholderText: qsTr("اختياري")
        }
    }
}
