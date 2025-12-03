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
                    text: "LUA's Place"
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: 20
                    font.bold: true
                    font.letterSpacing: 1.2
                    color: "#00eaff"
                    horizontalAlignment: Text.AlignHCenter

                    SequentialAnimation on color {
                        loops: Animation.Infinite
                        ColorAnimation { to: "#00ff95"; duration: 3000; easing.type: Easing.InOutSine }
                        ColorAnimation { to: "#00eaff"; duration: 3000; easing.type: Easing.InOutSine }
                    }

                    layer.enabled: true
                    layer.effect: Glow {
                        samples: 17
                        color: "#00eaff"
                        spread: 0.5
                        radius: 10
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
                    ListElement { nombre: "Command Bridge"; icono: ""; pantalla: "pantalla_dashboard.qml"; recurso: "reportes" }
                    ListElement { nombre: "Stellar Guests"; icono: ""; pantalla: "pantalla_clientes.qml"; recurso: "clientes" }
                    ListElement { nombre: "Core Supplies"; icono: ""; pantalla: "pantalla_ingredientes.qml"; recurso: "inventario" }
                    ListElement { nombre: "Alchemy Lab"; icono: ""; pantalla: "pantalla_recetas.qml"; recurso: "inventario" }
                    ListElement { nombre: "Cosmic Register"; icono: ""; pantalla: "pantalla_ventas.qml"; recurso: "ventas" }
                    ListElement { nombre: "Analytics Hub"; icono: ""; pantalla: "pantalla_reportes.qml"; recurso: "reportes" }
                    ListElement { nombre: "Digital Footprints"; icono: ""; pantalla: "pantalla_logs.qml"; recurso: "reportes" }
                    ListElement { nombre: "Crew Members"; icono: ""; pantalla: "pantalla_usuarios.qml"; recurso: "usuarios" }
                }
                
                delegate: Rectangle {
                    width: parent.width
                    height: 50
                    color: mouseArea.containsMouse ? Qt.rgba(0, 0.92, 1, 0.15) : "transparent"
                    radius: 6
                    border.color: cargadorContenido.source.toString().indexOf(model.pantalla) !== -1 ? "#00eaff" : "transparent"
                    border.width: 2

                    visible: GestorAuth.tienePermiso(model.recurso, "ver")
                    
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        spacing: 10

                        Rectangle {
                            width: 4
                            height: 20
                            radius: 2
                            color: cargadorContenido.source.toString().indexOf(model.pantalla) !== -1 ? "#00eaff" : "#00ff95"
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: cargadorContenido.source.toString().indexOf(model.pantalla) !== -1 ? 1.0 : 0.3

                            SequentialAnimation on color {
                                loops: Animation.Infinite
                                running: cargadorContenido.source.toString().indexOf(model.pantalla) !== -1
                                ColorAnimation { to: "#00ff95"; duration: 2000; easing.type: Easing.InOutSine }
                                ColorAnimation { to: "#00eaff"; duration: 2000; easing.type: Easing.InOutSine }
                            }
                        }

                        Text {
                            text: model.nombre
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 13
                            font.bold: cargadorContenido.source.toString().indexOf(model.pantalla) !== -1
                            font.letterSpacing: 0.5
                            color: cargadorContenido.source.toString().indexOf(model.pantalla) !== -1 ? "#00eaff" : PaletaNeon.texto
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
                        color: "#00eaff"
                        spread: 0.4
                        radius: 10
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
