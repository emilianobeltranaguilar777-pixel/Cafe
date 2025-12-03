import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import quantum 1.0
import "../componentes"

Item {
    id: root

    property var logsData: null
    property string filtroActual: "todos"
    property string busqueda: ""

    Column {
        anchors.fill: parent
        spacing: 20

        // Título
        Row {
            width: parent.width
            spacing: 15

            Text {
                text: "📋"
                font.pixelSize: 40
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Sistema de Auditoría"
                font.family: PaletaNeon.fuentePrincipal
                font.pixelSize: PaletaNeon.tamañoFuenteTitulo
                font.bold: true
                color: PaletaNeon.primario
                anchors.verticalCenter: parent.verticalCenter

                layer.enabled: true
                layer.effect: Glow {
                    samples: 17
                    color: PaletaNeon.primario
                    spread: 0.5
                    radius: PaletaNeon.radioGlow
                }
            }
        }

        // Controles de filtro
        TarjetaGlow {
            width: parent.width
            height: 80

            contenido: Row {
                anchors.fill: parent
                spacing: 15

                // Filtros por tipo
                Column {
                    width: parent.width * 0.4
                    spacing: 8

                    Text {
                        text: "Tipo de Log"
                        font.family: PaletaNeon.fuentePrincipal
                        font.pixelSize: PaletaNeon.tamañoFuentePequeña
                        color: PaletaNeon.textoSecundario
                    }

                    Row {
                        spacing: 10

                        BotonNeon {
                            text: "Todos"
                            width: 80
                            height: 35
                            variante: filtroActual === "todos" ? "primary" : "ghost"
                            onClicked: {
                                filtroActual = "todos"
                                cargarLogs()
                            }
                        }

                        BotonNeon {
                            text: "Sesiones"
                            width: 90
                            height: 35
                            variante: filtroActual === "sesion" ? "primary" : "ghost"
                            onClicked: {
                                filtroActual = "sesion"
                                cargarLogs()
                            }
                        }

                        BotonNeon {
                            text: "Inventario"
                            width: 100
                            height: 35
                            variante: filtroActual === "movimiento" ? "primary" : "ghost"
                            onClicked: {
                                filtroActual = "movimiento"
                                cargarLogs()
                            }
                        }
                    }
                }

                // Búsqueda
                Column {
                    width: parent.width * 0.5
                    spacing: 8

                    Text {
                        text: "Buscar"
                        font.family: PaletaNeon.fuentePrincipal
                        font.pixelSize: PaletaNeon.tamañoFuentePequeña
                        color: PaletaNeon.textoSecundario
                    }

                    InputAnimado {
                        id: inputBusqueda
                        width: parent.width
                        placeholderText: "Buscar por usuario, acción..."
                        onTextChanged: busqueda = text
                    }
                }
            }
        }

        // Estadísticas rápidas
        Row {
            width: parent.width
            spacing: 15

            Rectangle {
                width: (parent.width - 30) / 3
                height: 60
                color: Qt.rgba(0, 1, 1, 0.05)
                radius: PaletaNeon.radioBorde
                border.color: PaletaNeon.primario
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "📊"
                        font.pixelSize: 28
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        spacing: 2

                        Text {
                            text: logsData ? logsData.total.toString() : "0"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 20
                            font.bold: true
                            color: PaletaNeon.primario
                        }

                        Text {
                            text: "Total Registros"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 10
                            color: PaletaNeon.textoSecundario
                        }
                    }
                }
            }

            Rectangle {
                width: (parent.width - 30) / 3
                height: 60
                color: Qt.rgba(0, 1, 0.5, 0.05)
                radius: PaletaNeon.radioBorde
                border.color: PaletaNeon.exito
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "✅"
                        font.pixelSize: 28
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        spacing: 2

                        Text {
                            text: contarPorTipo("sesion")
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 20
                            font.bold: true
                            color: PaletaNeon.exito
                        }

                        Text {
                            text: "Sesiones"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 10
                            color: PaletaNeon.textoSecundario
                        }
                    }
                }
            }

            Rectangle {
                width: (parent.width - 30) / 3
                height: 60
                color: Qt.rgba(1, 0.65, 0, 0.05)
                radius: PaletaNeon.radioBorde
                border.color: PaletaNeon.advertencia
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "📦"
                        font.pixelSize: 28
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        spacing: 2

                        Text {
                            text: contarPorTipo("movimiento")
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 20
                            font.bold: true
                            color: PaletaNeon.advertencia
                        }

                        Text {
                            text: "Movimientos"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 10
                            color: PaletaNeon.textoSecundario
                        }
                    }
                }
            }
        }

        // Lista de logs
        TarjetaGlow {
            width: parent.width
            height: parent.height - 340

            contenido: Column {
                anchors.fill: parent
                spacing: 10

                // Cabecera
                Row {
                    width: parent.width
                    spacing: 10

                    Text {
                        text: "Registros de Auditoría"
                        font.family: PaletaNeon.fuentePrincipal
                        font.pixelSize: 16
                        font.bold: true
                        color: PaletaNeon.texto
                    }

                    Item { Layout.fillWidth: true }

                    BotonNeon {
                        text: "🔄 Actualizar"
                        width: 120
                        height: 30
                        variante: "ghost"
                        onClicked: cargarLogs()
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: PaletaNeon.primario
                    opacity: 0.3
                }

                // Lista scrolleable
                ListView {
                    id: listaLogs
                    width: parent.width
                    height: parent.height - 60
                    clip: true
                    spacing: 8

                    model: logsFiltrados()

                    delegate: Rectangle {
                        width: parent.width
                        height: 70
                        color: Qt.rgba(0, 0, 0, 0.3)
                        radius: PaletaNeon.radioBorde
                        border.color: modelData.tipo === "sesion" ? PaletaNeon.info : PaletaNeon.advertencia
                        border.width: 1

                        Rectangle {
                            anchors.left: parent.left
                            width: 4
                            height: parent.height
                            radius: 2
                            color: modelData.tipo === "sesion" ? PaletaNeon.info : PaletaNeon.advertencia
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 15

                            // Icono
                            Text {
                                text: modelData.tipo === "sesion" ? "🔐" : "📦"
                                font.pixelSize: 32
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Información principal
                            Column {
                                width: parent.width * 0.35
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: modelData.usuario
                                    font.family: PaletaNeon.fuentePrincipal
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: PaletaNeon.texto
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: modelData.accion
                                    font.family: PaletaNeon.fuentePrincipal
                                    font.pixelSize: 12
                                    color: PaletaNeon.secundario
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            // Detalles
                            Column {
                                width: parent.width * 0.35
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: obtenerDetallesPrincipales(modelData)
                                    font.family: PaletaNeon.fuentePrincipal
                                    font.pixelSize: 11
                                    color: PaletaNeon.textoSecundario
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: obtenerDetallesSecundarios(modelData)
                                    font.family: PaletaNeon.fuentePrincipal
                                    font.pixelSize: 10
                                    color: PaletaNeon.textoSecundario
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            // Fecha
                            Column {
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: formatearFecha(modelData.fecha)
                                    font.family: PaletaNeon.fuentePrincipal
                                    font.pixelSize: 11
                                    color: PaletaNeon.primario
                                }

                                Text {
                                    text: formatearHora(modelData.fecha)
                                    font.family: PaletaNeon.fuentePrincipal
                                    font.pixelSize: 10
                                    color: PaletaNeon.textoSecundario
                                }
                            }
                        }

                        // Efecto hover
                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                        }

                        layer.enabled: hoverArea.containsMouse
                        layer.effect: Glow {
                            samples: 17
                            color: modelData.tipo === "sesion" ? PaletaNeon.info : PaletaNeon.advertencia
                            spread: 0.3
                            radius: 8
                        }
                    }

                    // Mensaje cuando no hay logs
                    Text {
                        visible: listaLogs.count === 0
                        anchors.centerIn: parent
                        text: "📋 No hay registros para mostrar"
                        font.family: PaletaNeon.fuentePrincipal
                        font.pixelSize: 16
                        color: PaletaNeon.textoSecundario
                    }

                    // ScrollBar con estilo neon
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 10

                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: PaletaNeon.primario
                            opacity: parent.active ? 0.8 : 0.4

                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== FUNCIONES ====================

    Component.onCompleted: {
        cargarLogs()
    }

    function cargarLogs() {
        var endpoint = "/logs?tipo=" + filtroActual + "&limit=100"

        GestorAuth.request("GET", endpoint, null, function(exito, datos) {
            if (exito) {
                logsData = datos
            } else {
                console.log("Error cargando logs:", datos)
            }
        })
    }

    function logsFiltrados() {
        if (!logsData || !logsData.logs) return []

        if (busqueda === "") {
            return logsData.logs
        }

        var filtrados = []
        var busquedaLower = busqueda.toLowerCase()

        for (var i = 0; i < logsData.logs.length; i++) {
            var log = logsData.logs[i]
            if (log.usuario.toLowerCase().indexOf(busquedaLower) !== -1 ||
                log.accion.toLowerCase().indexOf(busquedaLower) !== -1) {
                filtrados.push(log)
            }
        }

        return filtrados
    }

    function contarPorTipo(tipo) {
        if (!logsData || !logsData.logs) return "0"

        var count = 0
        for (var i = 0; i < logsData.logs.length; i++) {
            if (logsData.logs[i].tipo === tipo) {
                count++
            }
        }
        return count.toString()
    }

    function obtenerDetallesPrincipales(log) {
        if (log.tipo === "sesion") {
            var exito = log.detalles.exito ? "✅ Exitoso" : "❌ Fallido"
            return exito + " • IP: " + (log.detalles.ip || "N/A")
        } else {
            return "📦 " + log.detalles.ingrediente + " • Cantidad: " + log.detalles.cantidad
        }
    }

    function obtenerDetallesSecundarios(log) {
        if (log.tipo === "sesion") {
            return "User Agent: " + (log.detalles.user_agent || "N/A")
        } else {
            return "Referencia: " + (log.detalles.referencia || "Sistema automático")
        }
    }

    function formatearFecha(fechaISO) {
        var fecha = new Date(fechaISO)
        var dia = fecha.getDate().toString().padStart(2, '0')
        var mes = (fecha.getMonth() + 1).toString().padStart(2, '0')
        var año = fecha.getFullYear()
        return dia + "/" + mes + "/" + año
    }

    function formatearHora(fechaISO) {
        var fecha = new Date(fechaISO)
        var horas = fecha.getHours().toString().padStart(2, '0')
        var minutos = fecha.getMinutes().toString().padStart(2, '0')
        var segundos = fecha.getSeconds().toString().padStart(2, '0')
        return horas + ":" + minutos + ":" + segundos
    }
}
