import QtQuick
import QtQuick.Effects
import BudgetTrackerUi

// A white rounded surface with a subtle shadow. Put content inside as children.
Rectangle {
    id: root
    color: Theme.surface
    radius: Theme.radius
    border.color: Theme.border
    border.width: 1

    // soft shadow
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#22000000"
        shadowVerticalOffset: 2
        shadowBlur: 0.4
    }
}
