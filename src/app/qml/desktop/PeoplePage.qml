import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

Item {
    id: page
    property var pendingDeleteId: 0

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        // ---- add form ----
        Card {
            Layout.preferredWidth: 320
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS
                Text { text: I18n.text("إضافة شخص", "Add person", I18n.revision); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                Label { text: I18n.text("الاسم", "Name", I18n.revision) }
                TextField { id: nameField; Layout.fillWidth: true; placeholderText: I18n.text("مثال: أحمد", "Example: Ahmad", I18n.revision) }
                Label { text: I18n.text("الهاتف (اختياري)", "Phone (optional)", I18n.revision) }
                TextField { id: phoneField; Layout.fillWidth: true; inputMethodHints: Qt.ImhDialableCharactersOnly }
                Button {
                    text: I18n.text("حفظ", "Save", I18n.revision)
                    highlighted: true
                    enabled: nameField.text.trim().length > 0
                    onClicked: {
                        App.addPerson(nameField.text, phoneField.text)
                        nameField.clear()
                        phoneField.clear()
                        statusLabel.text = ""
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }

        // ---- list ----
        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS
                Text { text: I18n.text("الأشخاص", "People", I18n.revision); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                Text {
                    id: statusLabel
                    visible: text.length > 0
                    text: ""
                    color: Theme.expense
                    font.pixelSize: Theme.fontS
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: App.people
                    delegate: Rectangle {
                        id: rowDel
                        width: ListView.view.width
                        height: 48
                        color: "transparent"
                        required property var personId
                        required property string name
                        required property string phone
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingS
                            anchors.rightMargin: Theme.spacingS
                            spacing: Theme.spacingM
                            Text { text: name; color: Theme.text; font.pixelSize: Theme.fontM; Layout.fillWidth: true }
                            Text { text: phone; color: Theme.textMuted; font.pixelSize: Theme.fontS }
                            ToolButton {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 32
                                text: "×"
                                font.pixelSize: 18
                                font.bold: true
                                ToolTip.text: I18n.text("حذف", "Delete", I18n.revision)
                                ToolTip.visible: hovered
                                onClicked: {
                                    if (!App.canDeletePerson(rowDel.personId)) {
                                        statusLabel.text = I18n.text("لا يمكن حذف هذا الشخص لأنه مرتبط بعمليات.", "This person cannot be deleted because they are linked to transactions.", I18n.revision)
                                        return
                                    }
                                    page.pendingDeleteId = rowDel.personId
                                    statusLabel.text = ""
                                    confirmDeleteDialog.open()
                                }
                            }
                        }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        text: I18n.text("لا يوجد أشخاص بعد", "No people yet", I18n.revision)
                        color: Theme.textMuted
                    }
                }
            }
        }
    }

    Dialog {
        id: confirmDeleteDialog
        title: I18n.text("تأكيد الحذف", "Confirm deletion", I18n.revision)
        modal: true
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape

        onAccepted: {
            if (!App.deletePerson(page.pendingDeleteId))
                statusLabel.text = I18n.text("لا يمكن حذف هذا الشخص لأنه مرتبط بعمليات.", "This person cannot be deleted because they are linked to transactions.", I18n.revision)
            page.pendingDeleteId = 0
        }
        onRejected: page.pendingDeleteId = 0

        contentItem: Label {
            text: I18n.text("هل أنت متأكد من حذف هذا الشخص؟", "Are you sure you want to delete this person?", I18n.revision)
            color: Theme.text
            wrapMode: Text.WordWrap
            width: 320
        }

        footer: DialogButtonBox {
            Button {
                text: I18n.text("حذف", "Delete", I18n.revision)
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                highlighted: true
            }
            Button {
                text: I18n.text("إلغاء", "Cancel", I18n.revision)
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
        }
    }
}
