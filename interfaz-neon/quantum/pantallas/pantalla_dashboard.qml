import QtQuick 2.15
import QtQuick.Layouts 1.15
import quantum 1.0
import "../componentes"

Item {
    id: root
    
    property var datosdashboard: null
    
    Column {
        anchors.fill: parent
        spacing: 20
        
        // Título
        Text {
            text: "📊 Dashboard"
            font.family: PaletaNeon.fuentePrincipal
            font.pixelSize: PaletaNeon.tamañoFuenteTitulo
            font.bold: true
            color: PaletaNeon.primario
        }
        
        // Tarjetas de estadísticas
        GridLayout {
            width: parent.width
            columns: 4
            rowSpacing: 20
            columnSpacing: 20
            
            TarjetaEstadistica {
                Layout.fillWidth: true
                titulo: "Ventas Hoy"
                valor: datosdashboard ? "$" + datosDashboard.ventas_hoy.toFixed(2) : "$0.00"
                subtitulo: datosD ashboard ? datosD ashboard.num_ventas_hoy + " ventas" : ""
                icono: "💰"
                colorIcono: PaletaNeon.exito
            }
            
            TarjetaEstadistica {
                Layout.fillWidth: true
                titulo: "Ventas Mes"
                valor: datosD ashboard ? "$" + datosD ashboard.ventas_mes.toFixed(2) : "$0.00"
                icono: "📈"
                colorIcono: PaletaNeon.info
            }
            
            TarjetaEstadistica {
                Layout.fillWidth: true
                titulo: "Alertas Stock"
                valor: datosD ashboard ? datosD ashboard.alertas_stock.toString() : "0"
                subtitulo: "Ingredientes bajos"
                icono: "⚠️"
                colorIcono: PaletaNeon.advertencia
            }
            
            TarjetaEstadistica {
                Layout.fillWidth: true
                titulo: "Estado Sistema"
                valor: "Activo"
                subtitulo: "Operando"
                icono: "✅"
                colorIcono: PaletaNeon.exito
            }
        }
        
        // Ingredientes con stock bajo
        TarjetaGlow {
            width: parent.width
            height: 300
            
            contenido: Column {
                anchors.fill: parent
                spacing: 10
                
                Text {
                    text: "⚠️ Ingredientes con Stock Bajo"
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: 18
                    font.bold: true
                    color: PaletaNeon.advertencia
                }
                
                ListView {
                    width: parent.width
                    height: parent.height - 40
                    clip: true
                    spacing: 5
                    
                    model: datosD ashboard ? datosD ashboard.ingredientes_bajo_stock : []
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: Qt.rgba(1, 0.65, 0, 0.1)
                        radius: 6
                        border.color: PaletaNeon.advertencia
                        border.width: 1
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15
                            
                            Text {
                                text: modelData.nombre
                                font.family: PaletaNeon.fuentePrincipal
                                font.pixelSize: 14
                                color: PaletaNeon.texto
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: "Stock: " + modelData.stock + " / Mínimo: " + modelData.min_stock
                                font.family: PaletaNeon.fuentePrincipal
                                font.pixelSize: 12
                                color: PaletaNeon.advertencia
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
    
    Component.onCompleted: {
        cargarDatos()
    }
    
    function cargarDatos() {
        GestorAuth.request("GET", "/reportes/dashboard", null, function(exito, datos) {
            if (exito) {
                datosD ashboard = datos
            }
        })
    }
}
