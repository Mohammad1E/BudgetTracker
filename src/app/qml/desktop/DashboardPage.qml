import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

Item {
    id: page
    signal requestAdd()

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: page.width - Theme.spacingL * 2
            x: Theme.spacingL
            y: Theme.spacingL
            spacing: Theme.spacingM

            // ---- KPI cards ----
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingM

                KpiCard {
                    Layout.fillWidth: true
                    title: I18n.text("إجمالي الدخل", "Total income", I18n.revision)
                    value: App.dashboard.incomeText
                    currency: App.dashboard.currency
                    tone: Theme.income
                }
                KpiCard {
                    Layout.fillWidth: true
                    title: I18n.text("إجمالي المصروف", "Total expenses", I18n.revision)
                    value: App.dashboard.expenseText
                    currency: App.dashboard.currency
                    tone: Theme.expense
                }
                KpiCard {
                    Layout.fillWidth: true
                    title: I18n.text("المتبقي من الراتب", "Salary remaining", I18n.revision)
                    value: App.dashboard.remainingText
                    currency: App.dashboard.currency
                    tone: App.dashboard.isNegative ? Theme.expense : Theme.primary
                }
            }

            // ---- recent transactions ----
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 420

                readonly property int recentDateWidth: 110
                readonly property int recentPersonWidth: 140
                readonly property int recentAmountWidth: 150

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingS

                    RowLayout {
                        Layout.fillWidth: true
                        layoutDirection: I18n.rtl ? Qt.RightToLeft : Qt.LeftToRight
                        Text {
                            text: I18n.text("أحدث العمليات", "Recent transactions", I18n.revision)
                            font.pixelSize: Theme.fontM
                            font.bold: true
                            color: Theme.text
                        }
                        Item { Layout.fillWidth: true }
                        Button { text: I18n.text("＋ إضافة", "+ Add", I18n.revision); onClicked: page.requestAdd() }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                    ListView {
                        id: list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: App.transactions
                        spacing: 0

                        delegate: Rectangle {
                            id: rowItem
                            width: ListView.view.width
                            height: 52
                            color: "transparent"
                            required property string categoryName
                            required property string categoryColor
                                required property string note
                                required property string dateText
                                required property string personName
                                required property string signedAmount
                                required property string currency
                                required property bool   isExpense

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingS
                                anchors.rightMargin: Theme.spacingS
                                layoutDirection: I18n.rtl ? Qt.RightToLeft : Qt.LeftToRight
                                spacing: Theme.spacingM

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 220
                                    spacing: Theme.spacingS

                                    Rectangle {
                                        width: 10; height: 10; radius: 5
                                        color: rowItem.categoryColor
                                        Layout.alignment: Qt.AlignTop
                                        Layout.topMargin: 7
                                    }
                                    ColumnLayout {
                                        spacing: 0
                                        Layout.fillWidth: true
                                        Text {
                                            text: rowItem.categoryName
                                            color: Theme.text
                                            font.pixelSize: Theme.fontM
                                            elide: Text.ElideRight
                                            horizontalAlignment: I18n.rtl ? Text.AlignRight : Text.AlignLeft
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: rowItem.note.length ? rowItem.note : I18n.text("بدون ملاحظة", "No note", I18n.revision)
                                            color: Theme.textMuted
                                            font.pixelSize: Theme.fontS
                                            elide: Text.ElideRight
                                            horizontalAlignment: I18n.rtl ? Text.AlignRight : Text.AlignLeft
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                                Text {
                                    text: rowItem.personName.length ? rowItem.personName : "—"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontS
                                    elide: Text.ElideRight
                                    horizontalAlignment: I18n.rtl ? Text.AlignRight : Text.AlignLeft
                                    Layout.preferredWidth: recentPersonWidth
                                }
                                Text {
                                    text: rowItem.dateText
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontS
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredWidth: recentDateWidth
                                }
                                MoneyText {
                                    Layout.preferredWidth: recentAmountWidth
                                    amount: rowItem.signedAmount
                                    currency: rowItem.currency
                                    kind: rowItem.isExpense ? 0 : 1
                                }
                            }
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width; height: 1; color: Theme.border
                            }
                        }

                        // empty state
                        Text {
                            anchors.centerIn: parent
                            visible: list.count === 0
                            text: I18n.text("لا توجد عمليات لهذا الشهر", "No transactions for this month", I18n.revision)
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontM
                        }
                    }
                }
            }
        }
    }
}
