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

        // ---- language ----
        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS
                Text {
                    text: I18n.text("اللغة", "Language", I18n.revision)
                    font.pixelSize: Theme.fontM
                    font.bold: true
                    color: Theme.text
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingM
                    Label {
                        text: I18n.text("لغة التطبيق", "App language", I18n.revision)
                        color: Theme.textMuted
                    }
                    ComboBox {
                        id: languageCombo
                        Layout.preferredWidth: 180
                        model: [
                            I18n.text("English", "English", I18n.revision),
                            I18n.text("العربية", "Arabic", I18n.revision)
                        ]
                        currentIndex: I18n.language === "ar" ? 1 : 0
                        onActivated: {
                            I18n.setLanguage(index === 1 ? "ar" : "en")
                            languageStatusLabel.text = I18n.text("تم تغيير اللغة.", "Language changed.", I18n.revision)
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
                Text {
                    id: languageStatusLabel
                    text: I18n.text("يتم حفظ اختيار اللغة تلقائيًا.", "Language selection is saved automatically.", I18n.revision)
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontS
                }
            }
        }

        // ---- backup / sync ----
        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS
                Text { text: I18n.text("النسخ الاحتياطي والمزامنة (JSON)", "Backup and sync (JSON)", I18n.revision); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                Text {
                    text: I18n.text("صدّر بياناتك إلى ملف JSON لنقلها أو الاحتفاظ بنسخة، أو استورد ملفًا سابقًا (سيستبدل البيانات الحالية).",
                                    "Export your data to a JSON file for transfer or backup, or import a previous file (this will replace current data).",
                                    I18n.revision)
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontS
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                RowLayout {
                    spacing: Theme.spacingM
                    Button { text: I18n.text("تصدير JSON", "Export JSON", I18n.revision); highlighted: true; onClicked: exportDlg.open() }
                    Button { text: I18n.text("استيراد JSON", "Import JSON", I18n.revision); onClicked: importDlg.open() }
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
                Text { text: I18n.text("عن التطبيق", "About", I18n.revision); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                Text { text: "Budget Tracker v0.1.0"; color: Theme.text; font.pixelSize: Theme.fontM }
                Text { text: I18n.text("العملة الحالية: ", "Current currency: ", I18n.revision) + App.currency; color: Theme.textMuted; font.pixelSize: Theme.fontS }
                Text { text: "C++20 · Qt 6 · SQLite · CMake"; color: Theme.textMuted; font.pixelSize: Theme.fontS }
            }
        }

        Item { Layout.fillHeight: true }
    }

    FileDialog {
        id: exportDlg
        title: I18n.text("حفظ نسخة JSON", "Save JSON backup", I18n.revision)
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON (*.json)"]
        defaultSuffix: "json"
        onAccepted: statusLabel.text = App.exportJson(selectedFile)
            ? I18n.text("تم التصدير بنجاح ✓", "Export completed successfully ✓", I18n.revision)
            : I18n.text("فشل التصدير ✗", "Export failed ✗", I18n.revision)
    }
    FileDialog {
        id: importDlg
        title: I18n.text("اختيار ملف JSON", "Choose JSON file", I18n.revision)
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON (*.json)"]
        onAccepted: statusLabel.text = App.importJson(selectedFile)
            ? I18n.text("تم الاستيراد بنجاح ✓", "Import completed successfully ✓", I18n.revision)
            : I18n.text("فشل الاستيراد ✗", "Import failed ✗", I18n.revision)
    }
}
