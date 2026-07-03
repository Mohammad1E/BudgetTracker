import QtQuick
import QtQuick.Layouts
import BudgetTrackerUi

// Dark navigation rail for the desktop layout.
Rectangle {
    id: root
    color: Theme.sidebarBg

    property int currentIndex: 0

    readonly property var entries: [
        { label: qsTr("لوحة المعلومات"), glyph: "▦" },
        { label: qsTr("العمليات"),       glyph: "≣" },
        { label: qsTr("التقارير"),        glyph: "▤" },
        { label: qsTr("الأشخاص"),         glyph: "☺" },
        { label: qsTr("التصنيفات"),       glyph: "❏" },
        { label: qsTr("الإعدادات"),       glyph: "⚙" }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        spacing: 2

        // brand
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingL
            Layout.rightMargin: Theme.spacingL
            Layout.bottomMargin: Theme.spacingL
            spacing: Theme.spacingS
            Text { text: "💰"; font.pixelSize: 22 }
            Text {
                text: "Budget Tracker"
                color: "white"
                font.pixelSize: Theme.fontM
                font.bold: true
            }
        }

        Repeater {
            model: root.entries
            delegate: Rectangle {
                id: row
                required property int index
                required property var modelData
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacingS
                Layout.rightMargin: Theme.spacingS
                height: 44
                radius: Theme.radiusS
                readonly property bool active: root.currentIndex === index
                color: active ? Theme.sidebarActive
                              : (hover.hovered ? Theme.sidebarHover : "transparent")

                HoverHandler { id: hover }
                TapHandler { onTapped: root.currentIndex = row.index }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingM
                    spacing: Theme.spacingM
                    Text {
                        text: row.modelData.glyph
                        color: row.active ? "white" : Theme.textOnDark
                        font.pixelSize: 18
                    }
                    Text {
                        text: row.modelData.label
                        color: row.active ? "white" : Theme.textOnDark
                        font.pixelSize: Theme.fontM
                        font.bold: row.active
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Theme.spacingM
            text: "v0.1.0"
            color: Theme.textMuted
            font.pixelSize: Theme.fontS
        }
    }
}
