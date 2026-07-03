import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

Item {
    id: page

    readonly property var palette: ["#3B82F6","#16A34A","#DC2626","#F59E0B",
                                    "#A855F7","#06B6D4","#EC4899","#64748B"]

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
                Text { text: qsTr("إضافة تصنيف"); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                Label { text: qsTr("الاسم") }
                TextField { id: nameField; Layout.fillWidth: true; placeholderText: qsTr("مثال: مطاعم") }

                Label { text: qsTr("النوع") }
                ComboBox { id: typeCombo; Layout.fillWidth: true; model: [qsTr("مصروف"), qsTr("دخل")] }

                Label { text: qsTr("اللون") }
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
                    text: qsTr("حفظ")
                    highlighted: true
                    enabled: nameField.text.trim().length > 0
                    onClicked: {
                        App.addCategory(nameField.text, typeCombo.currentIndex, page.palette[colorGroup.selected])
                        nameField.clear()
                    }
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
                Text { text: qsTr("التصنيفات"); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
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
                        required property string name
                        required property string color
                        required property int    catType
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingS
                            spacing: Theme.spacingM
                            Rectangle { width: 14; height: 14; radius: 4; color: del.color }
                            Text { text: del.name; color: Theme.text; font.pixelSize: Theme.fontM; Layout.fillWidth: true }
                            Text {
                                text: del.catType === 1 ? qsTr("دخل") : qsTr("مصروف")
                                color: del.catType === 1 ? Theme.income : Theme.expense
                                font.pixelSize: Theme.fontS
                            }
                        }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
                    }
                }
            }
        }
    }
}
