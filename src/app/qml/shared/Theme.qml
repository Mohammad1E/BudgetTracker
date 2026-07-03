pragma Singleton
import QtQuick

// Central design tokens. Use as:  import BudgetTrackerUi  ->  Theme.primary
QtObject {
    // ---- colors (light theme) ----
    readonly property color bg:        "#F1F5F9"
    readonly property color surface:   "#FFFFFF"
    readonly property color surfaceAlt:"#F8FAFC"
    readonly property color border:    "#E2E8F0"

    readonly property color text:      "#0F172A"
    readonly property color textMuted: "#64748B"
    readonly property color textOnDark:"#E2E8F0"

    readonly property color primary:   "#2563EB"
    readonly property color primaryDim:"#3B82F6"
    readonly property color income:    "#16A34A"
    readonly property color expense:   "#DC2626"

    // dark sidebar for the desktop shell
    readonly property color sidebarBg:     "#0F172A"
    readonly property color sidebarHover:  "#1E293B"
    readonly property color sidebarActive: "#2563EB"

    // ---- spacing / sizing ----
    readonly property int   spacingXs: 4
    readonly property int   spacingS:  8
    readonly property int   spacingM:  16
    readonly property int   spacingL:  24
    readonly property int   radius:    12
    readonly property int   radiusS:   8

    // ---- typography ----
    readonly property int   fontS:  13
    readonly property int   fontM:  15
    readonly property int   fontL:  20
    readonly property int   fontXL: 28
}
