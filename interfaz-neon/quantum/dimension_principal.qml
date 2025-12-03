import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import quantum 1.0
import "componentes"

Rectangle {
    id: root
    
    signal cerrarSesion()
    
    color: PaletaNeon.fondo
    
    // Sidebar
    Rectangle {
        id: sidebar
        width: 250
        height: parent.height
        color: PaletaNeon.tarjeta
        border.color: PaletaNeon.primario
        border.width: 1
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10
            
            // Logo
            Column {
                width: parent.width
                spacing: 10
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "☕"
                    font.pixelSize: 50
                }
                
                Text {
                    width: parent.width
                    text: "EL CAFÉ SIN\nLÍMITES"
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: 18
                    font.bold: true
                    color: PaletaNeon.primario
                    horizontalAlignment: Text.AlignHCenter
                    
                    layer.enabled: true
                    layer.effect: Glow {
                        samples: 17
                        color: PaletaNeon.primario
                        spread: 0.5
                        radius: 8
                    }
                }
                
                // Info usuario
                Rectangle {
                    width: parent.width
                    height: 60
                    color: Qt.rgba(0, 1, 1, 0.1)
                    radius: 6
                    border.color: PaletaNeon.primario
                    border.width: 1
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: GestorAuth.datosUsuario ? GestorAuth.datosUsuario.username : ""
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 14
                            font.bold: true
                            color: PaletaNeon.texto
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: GestorAuth.datosUsuario ? GestorAuth.datosUsuario.rol : ""
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 11
                            color: PaletaNeon.secundario
                        }
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 2
                color: PaletaNeon.primario
                opacity: 0.3
            }
            
            // Menú de navegación
            ListView {
                width: parent.width
                height: parent.height - 400
                spacing: 5
                clip: true
                
                model: ListModel {
                    ListElement { nombre: "Dashboard"; icono: "📊"; pantalla: "pantalla_dashboard.qml"; recurso: "reportes" }
                    ListElement { nombre: "Clientes"; icono: "👥"; pantalla: "pantalla_clientes.qml"; recurso: "clientes" }
                    ListElement { nombre: "Ingredientes"; icono: "🥫"; pantalla: "pantalla_ingredientes.qml"; recurso: "inventario" }
                    ListElement { nombre: "Recetas"; icono: "🍰"; pantalla: "pantalla_recetas.qml"; recurso: "inventario" }
                    ListElement { nombre: "Ventas"; icono: "🛒"; pantalla: "pantalla_ventas.qml"; recurso: "ventas" }
                    ListElement { nombre: "Reportes"; icono: "📈"; pantalla: "pantalla_reportes.qml"; recurso: "reportes" }
                    ListElement { nombre: "Logs"; icono: "📋"; pantalla: "pantalla_logs.qml"; recurso: "reportes" }
                    ListElement { nombre: "Usuarios"; icono: "👤"; pantalla: "pantalla_usuarios.qml"; recurso: "usuarios" }
                }
                
                delegate: Rectangle {
                    width: parent.width
                    height: 50
                    color: mouseArea.containsMouse ? Qt.rgba(0, 1, 1, 0.2) : "transparent"
                    radius: 6
                    border.color: cargadorContenido.source.toString().indexOf(model.pantalla) !== -1 ? PaletaNeon.primario : "transparent"
                    border.width: 2
                    
                    visible: GestorAuth.tienePermiso(model.recurso, "ver")
                    
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 15
                        spacing: 15
                        
                        Text {
                            text: model.icono
                            font.pixelSize: 24
                        }
                        
                        Text {
                            text: model.nombre
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 14
                            color: PaletaNeon.texto
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            cargadorContenido.source = "pantallas/" + model.pantalla
                        }
                    }
                    
                    layer.enabled: mouseArea.containsMouse
                    layer.effect: Glow {
                        samples: 17
                        color: PaletaNeon.primario
                        spread: 0.3
                        radius: 8
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
            
            // Botón salir
            BotonNeon {
                width: parent.width
                text: "🚪 SALIR"
                variante: "danger"
                
                onClicked: root.cerrarSesion()
            }
        }
    }
    
    // Contenido principal
    Rectangle {
        anchors.left: sidebar.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 2
        color: PaletaNeon.fondo
        
        Loader {
            id: cargadorContenido
            anchors.fill: parent
            anchors.margins: 20
            source: "pantallas/pantalla_dashboard.qml"
        }
    }
}
