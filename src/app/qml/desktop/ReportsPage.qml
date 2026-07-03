import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

Item {
    id: page

    property var rows: []
    property real maxValue: 1

    function reload() {
        rows = App.expenseByCategory()
        var m = 1
        for (var i = 0; i < rows.length; ++i)
            if (rows[i].value > m) m = rows[i].value
        maxValue = m
    }

    Component.onCompleted: reload()
    Connections { target: App; function onCurrentMonthChanged() { page.reload() } }
    Connections { target: App; function onDataChanged() { page.reload() } }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: page.width - Theme.spacingL * 2
            x: Theme.spacingL
            y: Theme.spacingL
            spacing: Theme.spacingM

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(220, contentCol.implicitHeight + Theme.spacingL * 2)

                ColumnLayout {
                    id: contentCol
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingM

                    Text {
                        text: I18n.text("المصروفات حسب التصنيف", "Expenses by category", I18n.revision) + " — " + App.currentMonth
                        font.pixelSize: Theme.fontM
                        font.bold: true
                        color: Theme.text
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                    Text {
                        visible: page.rows.length === 0
                        text: I18n.text("لا توجد مصروفات لهذا الشهر", "No expenses for this month", I18n.revision)
                        color: Theme.textMuted
                    }

                    Repeater {
                        model: page.rows
                        delegate: ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 4
                            RowLayout {
                                Layout.fillWidth: true
                                Rectangle { width: 12; height: 12; radius: 3; color: modelData.color }
                                Text { text: modelData.name; color: Theme.text; font.pixelSize: Theme.fontM }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: modelData.amountText + " " + App.dashboard.currency
                                    color: Theme.text
                                    font.pixelSize: Theme.fontM
                                    font.bold: true
                                }
                            }
                            // bar
                            Rectangle {
                                Layout.fillWidth: true
                                height: 10
                                radius: 5
                                color: Theme.surfaceAlt
                                Rectangle {
                                    height: parent.height
                                    radius: 5
                                    color: modelData.color
                                    width: parent.width * (modelData.value / page.maxValue)
                                }
                            }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: Theme.textMuted
                font.pixelSize: Theme.fontS
                text: I18n.text("ملاحظة: الرسوم البيانية هنا مرسومة يدويًا بـ QML (بدون QtCharts) لتبقى تحت رخصة LGPL. راجع docs/DESIGN.md.",
                                "Note: Charts here are drawn manually in QML (without QtCharts) to stay under LGPL. See docs/DESIGN.md.",
                                I18n.revision)
            }
        }
    }
}
