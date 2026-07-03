import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import BudgetTrackerUi

Item {
    id: page

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
                Text { text: qsTr("إضافة شخص"); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                Label { text: qsTr("الاسم") }
                TextField { id: nameField; Layout.fillWidth: true; placeholderText: qsTr("مثال: أحمد") }
                Label { text: qsTr("الهاتف (اختياري)") }
                TextField { id: phoneField; Layout.fillWidth: true; inputMethodHints: Qt.ImhDialableCharactersOnly }
                Button {
                    text: qsTr("حفظ")
                    highlighted: true
                    enabled: nameField.text.trim().length > 0
                    onClicked: { App.addPerson(nameField.text, phoneField.text); nameField.clear(); phoneField.clear() }
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
                Text { text: qsTr("الأشخاص"); font.pixelSize: Theme.fontM; font.bold: true; color: Theme.text }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: App.people
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 48
                        color: "transparent"
                        required property string name
                        required property string phone
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingS
                            spacing: Theme.spacingM
                            Text { text: name; color: Theme.text; font.pixelSize: Theme.fontM; Layout.fillWidth: true }
                            Text { text: phone; color: Theme.textMuted; font.pixelSize: Theme.fontS }
                        }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        text: qsTr("لا يوجد أشخاص بعد")
                        color: Theme.textMuted
                    }
                }
            }
        }
    }
}
