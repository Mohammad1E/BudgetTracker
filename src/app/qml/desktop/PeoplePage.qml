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
                Text { text: qsTr("إضافة شخص"); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                Label { text: qsTr("الاسم") }
                TextField { id: nameField; Layout.fillWidth: true; placeholderText: qsTr("مثال: أحمد") }
                Label { text: qsTr("الهاتف (اختياري)") }
                TextField { id: phoneField; Layout.fillWidth: true; inputMethodHints: Qt.ImhDialableCharactersOnly }
                Button {
                    text: qsTr("حفظ")
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
                Text { text: qsTr("الأشخاص"); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
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
                                ToolTip.text: qsTr("حذف")
                                ToolTip.visible: hovered
                                onClicked: {
                                    if (!App.canDeletePerson(rowDel.personId)) {
                                        statusLabel.text = qsTr("لا يمكن حذف هذا الشخص لأنه مرتبط بعمليات.")
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
                        text: qsTr("لا يوجد أشخاص بعد")
                        color: Theme.textMuted
                    }
                }
            }
        }
    }

    Dialog {
        id: confirmDeleteDialog
        title: qsTr("تأكيد الحذف")
        modal: true
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape

        onAccepted: {
            if (!App.deletePerson(page.pendingDeleteId))
                statusLabel.text = qsTr("لا يمكن حذف هذا الشخص لأنه مرتبط بعمليات.")
            page.pendingDeleteId = 0
        }
        onRejected: page.pendingDeleteId = 0

        contentItem: Label {
            text: qsTr("هل أنت متأكد من حذف هذا الشخص؟")
            color: Theme.text
            wrapMode: Text.WordWrap
            width: 320
        }

        footer: DialogButtonBox {
            Button {
                text: qsTr("حذف")
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                highlighted: true
            }
            Button {
                text: qsTr("إلغاء")
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
        }
    }
}
