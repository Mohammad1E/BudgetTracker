import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

// Desktop shell: fixed sidebar on the left, top bar with month navigation,
// and a stacked content area on the right.
ApplicationWindow {
    id: window
    visible: true
    width: 1180
    height: 760
    minimumWidth: 920
    minimumHeight: 560
    title: qsTr("Budget Tracker")
    color: Theme.bg

    function pageTitle(i) {
        return [qsTr("لوحة المعلومات"), qsTr("العمليات"), qsTr("التقارير"),
                qsTr("الأشخاص"), qsTr("التصنيفات"), qsTr("الإعدادات")][i] || ""
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: 224
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ---- top bar ----
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 66
                color: Theme.surface

                Rectangle {  // bottom divider
                    anchors.bottom: parent.bottom
                    width: parent.width; height: 1; color: Theme.border
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingL
                    anchors.rightMargin: Theme.spacingL
                    spacing: Theme.spacingM

                    Text {
                        text: window.pageTitle(sidebar.currentIndex)
                        font.pixelSize: Theme.fontL
                        font.bold: true
                        color: Theme.text
                    }

                    Item { Layout.fillWidth: true }

                    // month navigator
                    ToolButton { text: "‹"; onClicked: App.goToPreviousMonth() }
                    Text {
                        text: App.currentMonth
                        font.pixelSize: Theme.fontM
                        font.bold: true
                        color: Theme.text
                        horizontalAlignment: Text.AlignHCenter
                        Layout.minimumWidth: 84
                    }
                    ToolButton { text: "›"; onClicked: App.goToNextMonth() }

                    Button {
                        text: qsTr("＋ إضافة عملية")
                        highlighted: true
                        onClicked: addDialog.open()
                    }
                }
            }

            // ---- pages ----
            StackLayout {
                id: pages
                currentIndex: sidebar.currentIndex
                Layout.fillWidth: true
                Layout.fillHeight: true

                DashboardPage  { onRequestAdd: addDialog.open() }
                TransactionsPage { onRequestAdd: addDialog.open() }
                ReportsPage    {}
                PeoplePage     {}
                CategoriesPage {}
                SettingsPage   {}
            }
        }
    }

    TransactionDialog { id: addDialog }
}
