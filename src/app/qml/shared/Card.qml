import QtQuick
import QtQuick.Effects
import BudgetTrackerUi

// A white rounded surface with a subtle shadow. Put content inside as children.
Item {
    id: root

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: Theme.radius
        border.color: Theme.border
        border.width: 1

        // Keep the shadow on the background only, so child text is not
        // rendered through the effect texture.
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#22000000"
            shadowVerticalOffset: 2
            shadowBlur: 0.4
        }
    }
}
