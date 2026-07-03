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
                    text: page.editingCategoryId > 0
                          ? I18n.text("تعديل تصنيف", "Edit category", I18n.revision)
                          : I18n.text("إضافة تصنيف", "Add category", I18n.revision)
                    font.pixelSize: Theme.fontM
                    font.bold: true
                    color: Theme.text
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                Label { text: I18n.text("الاسم", "Name", I18n.revision) }
                TextField { id: nameField; Layout.fillWidth: true; placeholderText: I18n.text("مثال: مطاعم", "Example: restaurants", I18n.revision) }

                Label { text: I18n.text("النوع", "Type", I18n.revision) }
                ComboBox { id: typeCombo; Layout.fillWidth: true; model: [I18n.text("مصروف", "Expense", I18n.revision), I18n.text("دخل", "Income", I18n.revision)] }

                Label { text: I18n.text("اللون", "Color", I18n.revision) }
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
                    text: page.editingCategoryId > 0 ? I18n.text("تعديل", "Edit", I18n.revision) : I18n.text("حفظ", "Save", I18n.revision)
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
                    text: I18n.text("إلغاء", "Cancel", I18n.revision)
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
                Text { text: I18n.text("التصنيفات", "Categories", I18n.revision); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
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
                                text: del.catType === 1 ? I18n.text("دخل", "Income", I18n.revision) : I18n.text("مصروف", "Expense", I18n.revision)
                                color: del.catType === 1 ? Theme.income : Theme.expense
                                font.pixelSize: Theme.fontS
                            }
                            ToolButton {
                                Layout.preferredWidth: 72
                                Layout.preferredHeight: 32
                                text: I18n.text("تعديل", "Edit", I18n.revision)
                                onClicked: page.startEdit(del.catId, del.name, del.catType, del.color)
                            }
                            ToolButton {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                text: "×"
                                font.pixelSize: 18
                                font.bold: true
                                ToolTip.text: I18n.text("حذف", "Delete", I18n.revision)
                                ToolTip.visible: hovered
                                onClicked: {
                                    if (App.categoryTransactionCount(del.catId) > 0) {
                                        statusLabel.text = I18n.text("لا يمكن حذف هذا التصنيف لأنه مرتبط بعمليات.", "This category cannot be deleted because it is linked to transactions.", I18n.revision)
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
        title: I18n.text("تأكيد الحذف", "Confirm deletion", I18n.revision)
        modal: true
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape

        onAccepted: {
            if (!App.deleteCategory(page.pendingDeleteId))
                statusLabel.text = I18n.text("لا يمكن حذف هذا التصنيف لأنه مرتبط بعمليات.", "This category cannot be deleted because it is linked to transactions.", I18n.revision)
            page.pendingDeleteId = 0
        }
        onRejected: page.pendingDeleteId = 0

        contentItem: Label {
            text: I18n.text("هل أنت متأكد من حذف هذا التصنيف؟", "Are you sure you want to delete this category?", I18n.revision)
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

    Dialog {
        id: confirmEditDialog
        title: I18n.text("تأكيد تعديل التصنيف", "Confirm category edit", I18n.revision)
        modal: true
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape

        onAccepted: page.applyCategoryUpdate()

        contentItem: Label {
            text: I18n.text("هذا التصنيف مرتبط بـ ", "This category is linked to ", I18n.revision) + page.pendingEditCount
                  + I18n.text(" عمليات. تعديل التصنيف سيؤثر على هذه العمليات. هل تريد المتابعة؟",
                              " transactions. Editing the category will affect these transactions. Do you want to continue?",
                              I18n.revision)
            color: Theme.text
            wrapMode: Text.WordWrap
            width: 360
        }

        footer: DialogButtonBox {
            Button {
                text: I18n.text("تعديل", "Edit", I18n.revision)
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
