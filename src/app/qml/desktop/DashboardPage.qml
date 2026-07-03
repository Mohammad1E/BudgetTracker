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
                    title: qsTr("إجمالي الدخل")
                    value: App.dashboard.incomeText
                    currency: App.dashboard.currency
                    tone: Theme.income
                }
                KpiCard {
                    Layout.fillWidth: true
                    title: qsTr("إجمالي المصروف")
                    value: App.dashboard.expenseText
                    currency: App.dashboard.currency
                    tone: Theme.expense
                }
                KpiCard {
                    Layout.fillWidth: true
                    title: qsTr("المتبقي من الراتب")
                    value: App.dashboard.remainingText
                    currency: App.dashboard.currency
                    tone: App.dashboard.isNegative ? Theme.expense : Theme.primary
                }
            }

            // ---- recent transactions ----
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 420

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingS

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: qsTr("أحدث العمليات")
                            font.pixelSize: Theme.fontM
                            font.bold: true
                            color: Theme.text
                        }
                        Item { Layout.fillWidth: true }
                        Button { text: qsTr("＋ إضافة"); onClicked: page.requestAdd() }
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
                            required property string signedAmount
                            required property string currency
                            required property bool   isExpense

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingS
                                anchors.rightMargin: Theme.spacingS
                                spacing: Theme.spacingM

                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    color: rowItem.categoryColor
                                }
                                ColumnLayout {
                                    spacing: 0
                                    Layout.fillWidth: true
                                    Text {
                                        text: rowItem.categoryName
                                        color: Theme.text
                                        font.pixelSize: Theme.fontM
                                    }
                                    Text {
                                        text: rowItem.note.length ? rowItem.note : rowItem.dateText
                                        color: Theme.textMuted
                                        font.pixelSize: Theme.fontS
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                                Text {
                                    text: rowItem.dateText
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontS
                                }
                                MoneyText {
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
                            text: qsTr("لا توجد عمليات لهذا الشهر")
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontM
                        }
                    }
                }
            }
        }
    }
}
