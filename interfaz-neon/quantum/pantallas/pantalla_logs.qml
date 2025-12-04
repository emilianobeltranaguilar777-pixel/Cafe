import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0
import quantum 1.0
import "../componentes"

Item {
    id: root

    property var logsData: null
    property string filtroActual: "todos"
    property string busqueda: ""
    property bool cargando: false
    property bool usandoDatosEjemplo: false

    // Propiedad que se actualiza automáticamente
    property var logsActuales: []

    // Observadores para actualizar automáticamente
    onLogsDataChanged: actualizarLogs()
    onFiltroActualChanged: actualizarLogs()
    onBusquedaChanged: actualizarLogs()

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

                // Subtle readable glow
                layer.enabled: true
                layer.effect: Glow {
                    samples: 9
                    color: PaletaNeon.primario
                    spread: 0.2
                    radius: 4
                }
            }

            // Indicador de carga o modo
            Rectangle {
                visible: cargando || usandoDatosEjemplo
                width: usandoDatosEjemplo ? 160 : 100
                height: 28
                color: usandoDatosEjemplo ? Qt.rgba(1, 0.65, 0, 0.2) : Qt.rgba(0, 1, 1, 0.2)
                radius: 14
                border.color: usandoDatosEjemplo ? PaletaNeon.advertencia : PaletaNeon.info
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: usandoDatosEjemplo ? "📊" : "⏳"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter

                        RotationAnimator on rotation {
                            running: cargando && !usandoDatosEjemplo
                            from: 0
                            to: 360
                            duration: 1500
                            loops: Animation.Infinite
                        }
                    }

                    Text {
                        text: usandoDatosEjemplo ? "Modo Vista Previa" : "Cargando..."
                        font.family: PaletaNeon.fuentePrincipal
                        font.pixelSize: 11
                        font.bold: true
                        color: usandoDatosEjemplo ? PaletaNeon.advertencia : PaletaNeon.info
                        anchors.verticalCenter: parent.verticalCenter
                    }
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

                    Item { width: parent.width - 280 }

                    BotonNeon {
                        text: "📊 Vista Previa"
                        width: 130
                        height: 30
                        variante: "ghost"
                        onClicked: cargarDatosEjemplo()
                    }

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

                    model: logsActuales

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
                    Column {
                        visible: listaLogs.count === 0
                        anchors.centerIn: parent
                        spacing: 15

                        Text {
                            text: "📋"
                            font.pixelSize: 60
                            anchors.horizontalCenter: parent.horizontalCenter
                            opacity: 0.5
                        }

                        Text {
                            text: "No hay registros para mostrar"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 18
                            font.bold: true
                            color: PaletaNeon.texto
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Prueba cargando la vista previa con datos de ejemplo"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: 14
                            color: PaletaNeon.textoSecundario
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        BotonNeon {
                            text: "📊 Cargar Vista Previa"
                            width: 200
                            height: 40
                            variante: "primary"
                            anchors.horizontalCenter: parent.horizontalCenter
                            onClicked: cargarDatosEjemplo()
                        }
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
        // Intentar cargar datos reales, si falla cargar ejemplos
        cargarLogs()

        // Cargar datos de ejemplo después de 2 segundos si no hay datos
        timer.start()
    }

    Timer {
        id: timer
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            if (!logsData || !logsData.logs || logsData.logs.length === 0) {
                console.log("⏱️ Backend no respondió, cargando datos de ejemplo")
                cargarDatosEjemplo()
            }
        }
    }

    function cargarLogs() {
        console.log("🔄 Cargando logs con filtro:", filtroActual)
        cargando = true
        usandoDatosEjemplo = false

        var endpoint = "/logs?tipo=" + filtroActual + "&limit=100"

        GestorAuth.request("GET", endpoint, null, function(exito, datos) {
            cargando = false
            if (exito) {
                console.log("✓ Logs recibidos:", datos.total, "logs totales")
                console.log("✓ Logs en array:", datos.logs ? datos.logs.length : 0)
                logsData = datos
                usandoDatosEjemplo = false
            } else {
                console.log("❌ Error cargando logs:", datos)
                // Si falla, usar datos de ejemplo para visualización
                cargarDatosEjemplo()
            }
        })
    }

    function cargarDatosEjemplo() {
        console.log("📊 Cargando datos de ejemplo para visualización")
        cargando = false
        usandoDatosEjemplo = true

        var ahora = new Date()
        var ejemplos = []

        // Logs de sesión de ejemplo
        for (var i = 0; i < 15; i++) {
            var fecha = new Date(ahora.getTime() - (i * 3600000 * Math.random() * 48)) // Últimas 48 horas
            var usuarios = ["admin", "gerente", "vendedor1", "supervisor"]
            var acciones = ["LOGIN", "LOGOUT", "PASSWORD_CHANGE", "PROFILE_UPDATE"]
            var ips = ["192.168.1.100", "192.168.1.101", "192.168.1.102", "10.0.0.50"]

            if (filtroActual === "todos" || filtroActual === "sesion") {
                ejemplos.push({
                    "id": "sesion_" + i,
                    "tipo": "sesion",
                    "usuario": usuarios[Math.floor(Math.random() * usuarios.length)],
                    "accion": acciones[Math.floor(Math.random() * acciones.length)],
                    "detalles": {
                        "ip": ips[Math.floor(Math.random() * ips.length)],
                        "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
                        "exito": Math.random() > 0.2 // 80% exitoso
                    },
                    "fecha": fecha.toISOString()
                })
            }
        }

        // Logs de movimientos de ejemplo
        var ingredientes = ["Café Arábica", "Leche Entera", "Azúcar", "Chocolate", "Vainilla", "Canela"]
        var tipos_mov = ["ENTRADA", "SALIDA", "AJUSTE"]
        var referencias = [
            "Proveedor: Café Premium SA",
            "Staff: María García - Gerente",
            "Venta #1234",
            "Sistema automático",
            "Staff: Juan Pérez"
        ]

        for (var j = 0; j < 20; j++) {
            var fecha2 = new Date(ahora.getTime() - (j * 3600000 * Math.random() * 72)) // Últimas 72 horas

            if (filtroActual === "todos" || filtroActual === "movimiento") {
                ejemplos.push({
                    "id": "movimiento_" + j,
                    "tipo": "movimiento",
                    "usuario": referencias[Math.floor(Math.random() * referencias.length)],
                    "accion": tipos_mov[Math.floor(Math.random() * tipos_mov.length)],
                    "detalles": {
                        "ingrediente": ingredientes[Math.floor(Math.random() * ingredientes.length)],
                        "cantidad": (Math.random() * 50 + 5).toFixed(2),
                        "tipo_movimiento": tipos_mov[Math.floor(Math.random() * tipos_mov.length)],
                        "referencia": referencias[Math.floor(Math.random() * referencias.length)]
                    },
                    "fecha": fecha2.toISOString()
                })
            }
        }

        // Ordenar por fecha descendente
        ejemplos.sort(function(a, b) {
            return new Date(b.fecha) - new Date(a.fecha)
        })

        logsData = {
            "total": ejemplos.length,
            "logs": ejemplos
        }

        console.log("✅ Datos de ejemplo cargados:", ejemplos.length, "logs")
    }

    function actualizarLogs() {
        if (!logsData || !logsData.logs) {
            console.log("⚠️  logsData no disponible")
            logsActuales = []
            return
        }

        var logs = logsData.logs
        console.log("🔄 Actualizando vista con", logs.length, "logs")

        // Aplicar búsqueda si hay texto
        if (busqueda !== "") {
            var filtrados = []
            var busquedaLower = busqueda.toLowerCase()

            for (var i = 0; i < logs.length; i++) {
                var log = logs[i]
                if (log.usuario.toLowerCase().indexOf(busquedaLower) !== -1 ||
                    log.accion.toLowerCase().indexOf(busquedaLower) !== -1) {
                    filtrados.push(log)
                }
            }
            logsActuales = filtrados
            console.log("✓ Búsqueda aplicada:", filtrados.length, "resultados")
        } else {
            logsActuales = logs
            console.log("✓ Mostrando todos los logs")
        }
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
