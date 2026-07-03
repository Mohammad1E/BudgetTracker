import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

Item {
    id: page

    readonly property var palette: ["#3B82F6","#16A34A","#DC2626","#F59E0B",
                                    "#A855F7","#06B6D4","#EC4899","#64748B"]
    property var editingCategoryId: 0
    property var pendingDeleteId: 0
    property int pendingEditCount: 0

    function colorIndex(color) {
        for (var i = 0; i < palette.length; ++i) {
            if (palette[i].toLowerCase() === String(color).toLowerCase())
                return i
        }
        return 0
    }

    function clearForm() {
        editingCategoryId = 0
        nameField.clear()
        typeCombo.currentIndex = 0
        colorGroup.selected = 0
    }

    function startEdit(catId, name, catType, color) {
        editingCategoryId = catId
        nameField.text = name
        typeCombo.currentIndex = catType
        colorGroup.selected = colorIndex(color)
        statusLabel.text = ""
    }

    function applyCategoryUpdate() {
        if (App.updateCategory(editingCategoryId, nameField.text, typeCombo.currentIndex, palette[colorGroup.selected])) {
            clearForm()
            statusLabel.text = ""
        }
    }

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
                Text {
                    text: page.editingCategoryId > 0 ? qsTr("تعديل تصنيف") : qsTr("إضافة تصنيف")
                    font.pixelSize: Theme.fontM
                    font.bold: true
                    color: Theme.text
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                Label { text: qsTr("الاسم") }
                TextField { id: nameField; Layout.fillWidth: true; placeholderText: qsTr("مثال: مطاعم") }

                Label { text: qsTr("النوع") }
                ComboBox { id: typeCombo; Layout.fillWidth: true; model: [qsTr("مصروف"), qsTr("دخل")] }

                Label { text: qsTr("اللون") }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: page.palette
                        delegate: Rectangle {
                            required property int index
                            required property var modelData
                            width: 26; height: 26; radius: 13
                            color: modelData
                            border.width: colorGroup.selected === index ? 3 : 0
                            border.color: Theme.text
                            TapHandler { onTapped: colorGroup.selected = index }
                        }
                    }
                    QtObject { id: colorGroup; property int selected: 0 }
                }

                Button {
                    text: page.editingCategoryId > 0 ? qsTr("تعديل") : qsTr("حفظ")
                    highlighted: true
                    enabled: nameField.text.trim().length > 0
                    onClicked: {
                        if (page.editingCategoryId > 0) {
                            page.pendingEditCount = App.categoryTransactionCount(page.editingCategoryId)
                            if (page.pendingEditCount > 0)
                                confirmEditDialog.open()
                            else
                                page.applyCategoryUpdate()
                        } else {
                            App.addCategory(nameField.text, typeCombo.currentIndex, page.palette[colorGroup.selected])
                            page.clearForm()
                            statusLabel.text = ""
                        }
                    }
                }
                Button {
                    text: qsTr("إلغاء")
                    visible: page.editingCategoryId > 0
                    onClicked: page.clearForm()
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
                Text { text: qsTr("التصنيفات"); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
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
                    model: App.categories
                    delegate: Item {
                        id: del
                        width: ListView.view.width
                        height: 46
                        required property var catId
                        required property string name
                        required property string color
                        required property int    catType
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingS
                            anchors.rightMargin: Theme.spacingS
                            spacing: Theme.spacingM
                            Rectangle { width: 14; height: 14; radius: 4; color: del.color }
                            Text { text: del.name; color: Theme.text; font.pixelSize: Theme.fontM; Layout.fillWidth: true }
                            Text {
                                text: del.catType === 1 ? qsTr("دخل") : qsTr("مصروف")
                                color: del.catType === 1 ? Theme.income : Theme.expense
                                font.pixelSize: Theme.fontS
                            }
                            ToolButton {
                                Layout.preferredWidth: 72
                                Layout.preferredHeight: 32
                                text: qsTr("تعديل")
                                onClicked: page.startEdit(del.catId, del.name, del.catType, del.color)
                            }
                            ToolButton {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                text: "×"
                                font.pixelSize: 18
                                font.bold: true
                                ToolTip.text: qsTr("حذف")
                                ToolTip.visible: hovered
                                onClicked: {
                                    if (App.categoryTransactionCount(del.catId) > 0) {
                                        statusLabel.text = qsTr("لا يمكن حذف هذا التصنيف لأنه مرتبط بعمليات.")
                                        return
                                    }
                                    page.pendingDeleteId = del.catId
                                    statusLabel.text = ""
                                    confirmDeleteDialog.open()
                                }
                            }
                        }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
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
            if (!App.deleteCategory(page.pendingDeleteId))
                statusLabel.text = qsTr("لا يمكن حذف هذا التصنيف لأنه مرتبط بعمليات.")
            page.pendingDeleteId = 0
        }
        onRejected: page.pendingDeleteId = 0

        contentItem: Label {
            text: qsTr("هل أنت متأكد من حذف هذا التصنيف؟")
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

    Dialog {
        id: confirmEditDialog
        title: qsTr("تأكيد تعديل التصنيف")
        modal: true
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape

        onAccepted: page.applyCategoryUpdate()

        contentItem: Label {
            text: qsTr("هذا التصنيف مرتبط بـ ") + page.pendingEditCount
                  + qsTr(" عمليات. تعديل التصنيف سيؤثر على هذه العمليات. هل تريد المتابعة؟")
            color: Theme.text
            wrapMode: Text.WordWrap
            width: 360
        }

        footer: DialogButtonBox {
            Button {
                text: qsTr("تعديل")
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
