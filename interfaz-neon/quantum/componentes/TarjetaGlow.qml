import QtQuick 2.15
import QtGraphicalEffects 1.15
import quantum 1.0

Rectangle {
    id: root
    
    property alias contenido: contentLoader.sourceComponent
    
    color: PaletaNeon.tarjeta
    radius: PaletaNeon.radioBorde
    border.color: PaletaNeon.primario
    border.width: 1
    
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12
        samples: 17
        color: Qt.rgba(0, 1, 1, 0.3)
    }
    
    scale: mouseArea.containsMouse ? 1.02 : 1.0
    Behavior on scale { NumberAnimation { duration: 200 } }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
    }
    
    Loader {
        id: contentLoader
        anchors.fill: parent
        anchors.margins: 15
    }
}
