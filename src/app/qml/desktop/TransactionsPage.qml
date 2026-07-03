import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

Item {
    id: page
    signal requestAdd()
    property var pendingDeleteId: 0

    // shared column widths (header + rows stay aligned)
    readonly property int wDate: 110
    readonly property int wPerson: 140
    readonly property int wAmount: 150
    readonly property int wAction: 44

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        // ---- filters ----
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingM

            Label { text: qsTr("النوع:"); color: Theme.textMuted }
            ComboBox {
                id: typeFilter
                Layout.preferredWidth: 160
                model: [qsTr("الكل"), qsTr("مصروف"), qsTr("دخل")]
                onCurrentIndexChanged: App.setTransactionTypeFilter(currentIndex - 1)
            }
            Item { Layout.fillWidth: true }
            Button { text: qsTr("＋ إضافة عملية"); highlighted: true; onClicked: page.requestAdd() }
        }

        // ---- table ----
        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingS
                spacing: 0

                // header
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: Theme.surfaceAlt
                    radius: Theme.radiusS
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingM
                        anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingM
                        Text { text: qsTr("التاريخ");  Layout.preferredWidth: page.wDate;   color: Theme.textMuted; font.bold: true }
                        Text { text: qsTr("التصنيف");   Layout.fillWidth: true;              color: Theme.textMuted; font.bold: true }
                        Text { text: qsTr("الشخص");    Layout.preferredWidth: page.wPerson; color: Theme.textMuted; font.bold: true }
                        Text { text: qsTr("المبلغ");    Layout.preferredWidth: page.wAmount; color: Theme.textMuted; font.bold: true; horizontalAlignment: Text.AlignRight }
                        Item { Layout.preferredWidth: page.wAction }
                    }
                }

                ListView {
                    id: table
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: App.transactions

                    delegate: Rectangle {
                        id: rowDel
                        width: ListView.view.width
                        height: 50
                        color: rowHover.hovered ? Theme.surfaceAlt : "transparent"

                        required property int    index
                        required property var     txId
                        required property string  dateText
                        required property string  categoryName
                        required property string  categoryColor
                        required property string  personName
                        required property string  note
                        required property string  signedAmount
                        required property string  currency
                        required property bool    isExpense

                        HoverHandler { id: rowHover }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingM

                            Text {
                                text: dateText
                                Layout.preferredWidth: page.wDate
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontS
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Theme.spacingS
                                Rectangle { width: 10; height: 10; radius: 5; color: categoryColor }
                                ColumnLayout {
                                    spacing: 0
                                    Layout.fillWidth: true
                                    Text { text: categoryName; color: Theme.text; font.pixelSize: Theme.fontM }
                                    Text {
                                        text: note
                                        visible: note.length > 0
                                        color: Theme.textMuted
                                        font.pixelSize: Theme.fontS
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                            Text {
                                text: personName.length ? personName : "—"
                                Layout.preferredWidth: page.wPerson
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontS
                                elide: Text.ElideRight
                            }
                            MoneyText {
                                Layout.preferredWidth: page.wAmount
                                horizontalAlignment: Text.AlignRight
                                amount: rowDel.signedAmount
                                currency: rowDel.currency
                                kind: rowDel.isExpense ? 0 : 1
                            }
                            ToolButton {
                                Layout.preferredWidth: page.wAction
                                text: "🗑"
                                onClicked: {
                                    page.pendingDeleteId = rowDel.txId
                                    confirmDeleteDialog.open()
                                }
                            }
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width; height: 1; color: Theme.border
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: table.count === 0
                        text: qsTr("لا توجد عمليات — اضغط “+ إضافة عملية”")
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontM
                    }
                }

                // footer
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingM
                        text: qsTr("عدد العمليات: ") + table.count
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontS
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
            App.removeTransaction(page.pendingDeleteId)
            page.pendingDeleteId = 0
        }
        onRejected: page.pendingDeleteId = 0

        contentItem: Label {
            text: qsTr("هل أنت متأكد من حذف هذه العملية؟")
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
