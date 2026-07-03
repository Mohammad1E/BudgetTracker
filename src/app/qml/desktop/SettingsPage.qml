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

        // ---- backup / sync ----
        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS
                Text { text: qsTr("النسخ الاحتياطي والمزامنة (JSON)"); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                Text {
                    text: qsTr("صدّر بياناتك إلى ملف JSON لنقلها أو الاحتفاظ بنسخة، أو استورد ملفًا سابقًا (سيستبدل البيانات الحالية).")
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontS
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                RowLayout {
                    spacing: Theme.spacingM
                    Button { text: qsTr("تصدير JSON"); highlighted: true; onClicked: exportDlg.open() }
                    Button { text: qsTr("استيراد JSON"); onClicked: importDlg.open() }
                    Item { Layout.fillWidth: true }
                }
                Text {
                    id: statusLabel
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontS
                }
            }
        }

        // ---- about ----
        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingXs
                Text { text: qsTr("عن التطبيق"); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                Text { text: "Budget Tracker v0.1.0"; color: Theme.text; font.pixelSize: Theme.fontM }
                Text { text: qsTr("العملة الحالية: ") + App.currency; color: Theme.textMuted; font.pixelSize: Theme.fontS }
                Text { text: "C++20 · Qt 6 · SQLite · CMake"; color: Theme.textMuted; font.pixelSize: Theme.fontS }
            }
        }

        Item { Layout.fillHeight: true }
    }

    FileDialog {
        id: exportDlg
        title: qsTr("حفظ نسخة JSON")
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON (*.json)"]
        defaultSuffix: "json"
        onAccepted: statusLabel.text = App.exportJson(selectedFile)
            ? qsTr("تم التصدير بنجاح ✓") : qsTr("فشل التصدير ✗")
    }
    FileDialog {
        id: importDlg
        title: qsTr("اختيار ملف JSON")
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON (*.json)"]
        onAccepted: statusLabel.text = App.importJson(selectedFile)
            ? qsTr("تم الاستيراد بنجاح ✓") : qsTr("فشل الاستيراد ✗")
    }
}
