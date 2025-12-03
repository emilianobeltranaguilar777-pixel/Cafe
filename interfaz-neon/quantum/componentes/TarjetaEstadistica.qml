import QtQuick 2.15
import QtGraphicalEffects 1.15
import quantum 1.0

TarjetaGlow {
    id: root
    
    property string titulo: "Título"
    property string valor: "0"
    property string subtitulo: ""
    property string icono: "📊"
    property color colorIcono: PaletaNeon.primario
    
    implicitWidth: 200
    implicitHeight: 120
    
    contenido: Item {
        Row {
            anchors.fill: parent
            spacing: 15
            
            // Icono
            Rectangle {
                width: 60
                height: 60
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(colorIcono.r, colorIcono.g, colorIcono.b, 0.2)
                radius: 30
                border.color: colorIcono
                border.width: 2
                
                Text {
                    anchors.centerIn: parent
                    text: icono
                    font.pixelSize: 30
                }
                
                layer.enabled: true
                layer.effect: Glow {
                    samples: 17
                    color: colorIcono
                    spread: 0.3
                    radius: 8
                }
            }
            
            // Datos
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                
                Text {
                    text: titulo
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuentePequeña
                    color: PaletaNeon.textoSecundario
                }
                
                Text {
                    text: valor
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuenteTitulo
                    font.bold: true
                    color: PaletaNeon.texto
                }
                
                Text {
                    text: subtitulo
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuentePequeña
                    color: PaletaNeon.textoSecundario
                    visible: subtitulo !== ""
                }
            }
        }
    }
}
