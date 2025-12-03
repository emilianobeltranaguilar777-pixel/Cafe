import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import quantum 1.0

Item {
    id: root
    
    property alias text: textField.text
    property alias placeholderText: label.text
    property alias echoMode: textField.echoMode
    property bool esFoco: textField.activeFocus
    
    implicitWidth: 300
    implicitHeight: 60
    
    Column {
        anchors.fill: parent
        spacing: 5
        
        // Label flotante
        Text {
            id: label
            text: "Campo"
            font.family: PaletaNeon.fuentePrincipal
            font.pixelSize: esFoco || textField.text ? 11 : 14
            color: esFoco ? PaletaNeon.primario : PaletaNeon.textoSecundario
            
            Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
            Behavior on color { ColorAnimation { duration: 200 } }
        }
        
        // Campo de texto
        TextField {
            id: textField
            width: parent.width
            height: 40
            
            font.family: PaletaNeon.fuentePrincipal
            font.pixelSize: PaletaNeon.tamañoFuenteNormal
            color: PaletaNeon.texto
            
            background: Rectangle {
                color: "transparent"
                border.color: textField.activeFocus ? PaletaNeon.primario : PaletaNeon.textoSecundario
                border.width: 2
                radius: PaletaNeon.radioBorde
                
                Behavior on border.color { ColorAnimation { duration: 200 } }
                
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: textField.activeFocus ? parent.width : 0
                    height: 3
                    color: PaletaNeon.primario
                    radius: 2
                    
                    layer.enabled: true
                    layer.effect: Glow {
                        samples: 17
                        color: PaletaNeon.primario
                        spread: 0.5
                        radius: 8
                    }
                    
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }
        }
    }
}
