import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import BudgetTrackerUi

Item {
    id: page

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        Text { text: qsTr("الإعدادات"); font.pixelSize: Theme.fontL; font.bold: true; color: Theme.text }

        Button { Layout.fillWidth: true; text: qsTr("تصدير نسخة JSON"); onClicked: exportDlg.open() }
        Button { Layout.fillWidth: true; text: qsTr("استيراد JSON"); onClicked: importDlg.open() }

        Text { id: statusLabel; color: Theme.textMuted; font.pixelSize: Theme.fontS }

        Item { Layout.fillHeight: true }
        Text { text: "Budget Tracker v0.1.0"; color: Theme.textMuted; font.pixelSize: Theme.fontS }
    }

    FileDialog {
        id: exportDlg
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON (*.json)"]
        defaultSuffix: "json"
        onAccepted: statusLabel.text = App.exportJson(selectedFile) ? qsTr("تم ✓") : qsTr("فشل ✗")
    }
    FileDialog {
        id: importDlg
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON (*.json)"]
        onAccepted: statusLabel.text = App.importJson(selectedFile) ? qsTr("تم ✓") : qsTr("فشل ✗")
    }
}
