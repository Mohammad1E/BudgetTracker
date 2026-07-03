import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

// Add-transaction dialog. Open with .open(). Calls App.addTransaction on accept.
Dialog {
    id: dlg
    title: I18n.text("إضافة عملية", "Add transaction", I18n.revision)
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

        Label { text: I18n.text("النوع", "Type", I18n.revision) }
        ComboBox {
            id: typeCombo
            Layout.fillWidth: true
            model: [I18n.text("مصروف", "Expense", I18n.revision), I18n.text("دخل", "Income", I18n.revision)]
        }

        Label { text: I18n.text("المبلغ", "Amount", I18n.revision) }
        TextField {
            id: amountField
            Layout.fillWidth: true
            placeholderText: "0.00"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { bottom: 0; decimals: 2; notation: DoubleValidator.StandardNotation }
        }

        Label { text: I18n.text("التاريخ", "Date", I18n.revision) }
        TextField {
            id: dateField
            Layout.fillWidth: true
            placeholderText: "yyyy-MM-dd"
        }

        Label { text: I18n.text("التصنيف", "Category", I18n.revision) }
        ComboBox {
            id: catCombo
            Layout.fillWidth: true
            model: App.categories
            textRole: "name"
            valueRole: "catId"
        }

        RowLayout {
            Layout.fillWidth: true
            CheckBox { id: linkPerson; text: I18n.text("ربط بشخص", "Link to person", I18n.revision) }
            ComboBox {
                id: personCombo
                Layout.fillWidth: true
                enabled: linkPerson.checked
                model: App.people
                textRole: "name"
                valueRole: "personId"
            }
        }

        Label { text: I18n.text("ملاحظة", "Note", I18n.revision) }
        TextField {
            id: noteField
            Layout.fillWidth: true
            placeholderText: I18n.text("اختياري", "Optional", I18n.revision)
        }
    }
}
