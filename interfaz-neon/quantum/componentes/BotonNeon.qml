import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import quantum 1.0

Button {
    id: root
    
    property string variante: "primary" // primary, ghost, danger
    property color colorPersonalizado: "transparent"
    
    implicitWidth: 120
    implicitHeight: 40
    
    background: Rectangle {
        color: {
            if (colorPersonalizado !== "transparent") return colorPersonalizado
            if (variante === "ghost") return "transparent"
            if (variante === "danger") return PaletaNeon.error
            return PaletaNeon.primario
        }
        border.color: {
            if (variante === "ghost") return PaletaNeon.primario
            return "transparent"
        }
        border.width: variante === "ghost" ? 2 : 0
        radius: PaletaNeon.radioBorde
        
        Behavior on color { ColorAnimation { duration: PaletaNeon.duracionAnimacion } }
        
        layer.enabled: root.hovered || root.pressed
        layer.effect: Glow {
            samples: 17
            color: root.background.color
            spread: 0.5
            radius: PaletaNeon.radioGlow
        }
    }
    
    contentItem: Text {
        text: root.text
        font.family: PaletaNeon.fuentePrincipal
        font.pixelSize: PaletaNeon.tamañoFuenteNormal
        font.bold: true
        color: variante === "ghost" ? PaletaNeon.primario : PaletaNeon.fondo
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    
    scale: pressed ? 0.95 : (hovered ? 1.05 : 1.0)
    Behavior on scale { NumberAnimation { duration: 150 } }
}
