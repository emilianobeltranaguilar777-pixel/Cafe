import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import quantum 1.0
import "../componentes"

Rectangle {
    id: root
    
    signal loginExitoso()
    
    color: PaletaNeon.fondo
    
    // Fondo animado
    Canvas {
        anchors.fill: parent
        opacity: 0.3
        
        property real tiempo: 0
        
        Timer {
            interval: 50
            running: true
            repeat: true
            onTriggered: {
                parent.tiempo += 0.05
                parent.requestPaint()
            }
        }
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            ctx.strokeStyle = PaletaNeon.primario
            ctx.lineWidth = 2
            
            for (var i = 0; i < 5; i++) {
                ctx.beginPath()
                var y = height * (i / 5) + Math.sin(tiempo + i) * 20
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
        }
    }
    
    // Contenedor central
    Item {
        anchors.centerIn: parent
        width: 400
        height: 500
        
        Column {
            anchors.centerIn: parent
            spacing: 30
            width: parent.width
            
            // Logo y título
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "☕"
                    font.pixelSize: 80
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "EL CAFÉ SIN LÍMITES"
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuenteTitulo
                    font.bold: true
                    color: PaletaNeon.primario
                    
                    layer.enabled: true
                    layer.effect: Glow {
                        samples: 17
                        color: PaletaNeon.primario
                        spread: 0.5
                        radius: 12
                    }
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Sistema de Gestión v2.0"
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuenteNormal
                    color: PaletaNeon.textoSecundario
                }

                // Coffee shop slogan with neon effect
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Una experiencia celestial en cada taza"
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: 13
                    font.italic: true
                    color: PaletaNeon.primario

                    layer.enabled: true
                    layer.effect: Glow {
                        samples: 9
                        color: PaletaNeon.primario
                        spread: 0.3
                        radius: 6
                    }
                }
            }

            // Formulario with pulsing border
            Rectangle {
                id: formPanel
                width: parent.width
                height: formColumn.height + 40
                color: Qt.rgba(0.04, 0.04, 0.07, 0.6)
                radius: 12
                border.color: PaletaNeon.primario
                border.width: 2

                // Pulsing neon border opacity
                opacity: 1.0
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.7; duration: 2000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
                }

                // Subtle glow
                layer.enabled: true
                layer.effect: Glow {
                    samples: 13
                    color: PaletaNeon.primario
                    spread: 0.15
                    radius: 10
                }

                Column {
                    id: formColumn
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 20
                
                InputAnimado {
                    id: inputUsername
                    width: parent.width
                    placeholderText: "Usuario"
                    
                    Keys.onReturnPressed: inputPassword.forceActiveFocus()
                }
                
                InputAnimado {
                    id: inputPassword
                    width: parent.width
                    placeholderText: "Contraseña"
                    echoMode: TextInput.Password
                    
                    Keys.onReturnPressed: btnLogin.clicked()
                }
                
                Text {
                    id: mensajeError
                    width: parent.width
                    text: ""
                    color: PaletaNeon.error
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuentePequeña
                    horizontalAlignment: Text.AlignHCenter
                    visible: text !== ""
                }
                
                BotonNeon {
                    id: btnLogin
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    text: "INICIAR SESIÓN"
                    enabled: inputUsername.text && inputPassword.text

                    // Animated glow for button
                    property real glowIntensity: 0.5
                    SequentialAnimation on glowIntensity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.8; duration: 1500; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.5; duration: 1500; easing.type: Easing.InOutSine }
                    }

                    onClicked: {
                        mensajeError.text = ""
                        GestorAuth.login(inputUsername.text, inputPassword.text, function(exito, mensaje) {
                            if (exito) {
                                root.loginExitoso()
                            } else {
                                mensajeError.text = mensaje
                            }
                        })
                    }
                }
                }
            }
        }
    }
    
    Component.onCompleted: {
        inputUsername.forceActiveFocus()
    }
}
