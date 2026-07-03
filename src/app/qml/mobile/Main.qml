import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

// Mobile shell: content + bottom tab navigation. Compiled only on Android/iOS.
// Reuses the SAME App controller and view-models as desktop — only layout differs.
ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 820
    title: qsTr("Budget Tracker")

    StackLayout {
        id: pages
        anchors.fill: parent
        currentIndex: bar.currentIndex
        HomePage         {}
        QuickAddPage     {}
        TransactionsPage {}
        SettingsPage     {}
    }

    footer: TabBar {
        id: bar
        TabButton { text: qsTr("الرئيسية") }
        TabButton { text: qsTr("إضافة") }
        TabButton { text: qsTr("العمليات") }
        TabButton { text: qsTr("الإعدادات") }
    }
}
