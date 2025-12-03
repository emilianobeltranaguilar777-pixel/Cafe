// ============================================
// PANTALLA: CLIENTES (OPTIMIZADA)
// Compatible con tu backend FastAPI
// ============================================
Component {
    id: pantallaClientes

    Item {
        anchors.fill: parent

        // Propiedades reactivas
        property var clientes: []
        property bool formularioVisible: false
        property var clienteEditando: null
        property bool cargando: false

        // Colores de tema NEON
        property color colorFondo: "#050510"
        property color colorPanel: "#0a0a1f"
        property color colorBorde: "#00ffff"
        property color colorTexto: "#e0e0ff"
        property color colorSecundario: "#8080a0"
        property color colorExito: "#00ff80"
        property color colorError: "#ff0055"
        property color colorAcento: "#ff0080"

        // Fondo con gradiente NEON
        Rectangle {
            anchors.fill: parent
            color: colorFondo

            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0)
                end: Qt.point(parent.width, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#050510" }
                    GradientStop { position: 0.5; color: "#0a0a1a" }
                    GradientStop { position: 1.0; color: "#050510" }
                }
                opacity: 0.3
            }
        }

        // Contenido principal
        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 25

            // CABECERA CON TÍTULO ANIMADO
            Row {
                id: cabecera
                width: parent.width
                height: 60

                // Título con efecto NEON
                Item {
                    width: 400
                    height: parent.height

                    Text {
                        id: titulo
                        text: "👥 GESTIÓN DE CLIENTES"
                        font.family: "Arial"
                        font.pixelSize: 28
                        font.bold: true
                        color: colorBorde

                        // Efecto NEON
                        layer.enabled: true
                        layer.effect: Glow {
                            color: colorBorde
                            radius: 8
                            samples: 17
                            spread: 0.3
                        }
                    }

                    // Animación de título
                    SequentialAnimation on opacity {
                        running: true
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.7; duration: 2000 }
                        NumberAnimation { to: 1; duration: 2000 }
                    }
                }

                // Espaciador dinámico
                Item {
                    width: parent.width - 700
                    height: parent.height
                }

                // Botón flotante NEON
                Button {
                    id: btnNuevoCliente
                    width: 180
                    height: 45
                    anchors.verticalCenter: parent.verticalCenter
                    text: formularioVisible ? "✕ CANCELAR" : "＋ NUEVO CLIENTE"

                    // Fondo con efecto NEON
                    background: Rectangle {
                        color: formularioVisible ? colorError : colorBorde
                        radius: 8
                        border.color: formularioVisible ? colorError : colorBorde
                        border.width: 2

                        // Efecto de brillo
                        layer.enabled: true
                        layer.effect: Glow {
                            color: formularioVisible ? colorError : colorBorde
                            radius: 8
                            samples: 17
                            spread: 0.3
                        }

                        // Animación hover
                        states: State {
                            name: "hovered"
                            when: btnNuevoCliente.hovered
                            PropertyChanges {
                                target: btnNuevoCliente.background
                                scale: 1.05
                            }
                        }
                        transitions: Transition {
                            NumberAnimation { properties: "scale"; duration: 200 }
                        }
                    }

                    // Texto del botón
                    contentItem: Text {
                        text: btnNuevoCliente.text
                        color: formularioVisible ? "#ffffff" : colorFondo
                        font.bold: true
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Acción al hacer clic
                    onClicked: {
                        formularioVisible = !formularioVisible
                        if (!formularioVisible) {
                            clienteEditando = null
                            limpiarFormulario()
                        }
                    }
                }
            }

            // FORMULARIO FLOTANTE (solo visible cuando se necesita)
            Rectangle {
                id: formulario
                width: parent.width
                height: formularioVisible ? 280 : 0
                visible: formularioVisible
                color: colorPanel
                border.color: clienteEditando ? colorExito : colorBorde
                border.width: 3
                radius: 12
                clip: true

                // Animación suave de altura
                Behavior on height {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 20

                    // Título del formulario
                    Text {
                        text: clienteEditando ? "✏️ EDITAR CLIENTE" : "➕ NUEVO CLIENTE"
                        font.pixelSize: 20
                        font.bold: true
                        color: clienteEditando ? colorExito : colorBorde
                    }

                    // Campos del formulario en grid responsive
                    Grid {
                        width: parent.width
                        columns: window.width > 1200 ? 3 : 2
                        columnSpacing: 20
                        rowSpacing: 15

                        // Campo: Nombre
                        Column {
                            width: (parent.width - (parent.columns - 1) * parent.columnSpacing) / parent.columns
                            spacing: 5

                            Text {
                                text: "Nombre completo:"
                                font.pixelSize: 12
                                color: colorSecundario
                            }

                            TextField {
                                id: inputNombre
                                width: parent.width
                                height: 40
                                color: colorTexto
                                placeholderText: "Ej: Juan Pérez"
                                font.pixelSize: 14

                                background: Rectangle {
                                    color: "transparent"
                                    border.color: inputNombre.activeFocus ? colorBorde : "#404060"
                                    border.width: 2
                                    radius: 6
                                }
                            }
                        }

                        // Campo: Correo
                        Column {
                            width: (parent.width - (parent.columns - 1) * parent.columnSpacing) / parent.columns
                            spacing: 5

                            Text {
                                text: "Correo electrónico:"
                                font.pixelSize: 12
                                color: colorSecundario
                            }

                            TextField {
                                id: inputCorreo
                                width: parent.width
                                height: 40
                                color: colorTexto
                                placeholderText: "ejemplo@email.com"
                                font.pixelSize: 14

                                background: Rectangle {
                                    color: "transparent"
                                    border.color: inputCorreo.activeFocus ? colorBorde : "#404060"
                                    border.width: 2
                                    radius: 6
                                }
                            }
                        }

                        // Campo: Teléfono
                        Column {
                            width: (parent.width - (parent.columns - 1) * parent.columnSpacing) / parent.columns
                            spacing: 5

                            Text {
                                text: "Teléfono:"
                                font.pixelSize: 12
                                color: colorSecundario
                            }

                            TextField {
                                id: inputTelefono
                                width: parent.width
                                height: 40
                                color: colorTexto
                                placeholderText: "Ej: 442-123-4567"
                                font.pixelSize: 14

                                background: Rectangle {
                                    color: "transparent"
                                    border.color: inputTelefono.activeFocus ? colorBorde : "#404060"
                                    border.width: 2
                                    radius: 6
                                }
                            }
                        }
                    }

                    // Botones de acción
                    Row {
                        spacing: 15
                        anchors.horizontalCenter: parent.horizontalCenter

                        // Botón GUARDAR
                        Button {
                            id: btnGuardar
                            width: 160
                            height: 45
                            enabled: inputNombre.text.trim() !== ""
                            text: clienteEditando ? "💾 ACTUALIZAR" : "💾 GUARDAR"

                            background: Rectangle {
                                color: btnGuardar.enabled ? colorExito : "#404050"
                                radius: 8
                                border.color: btnGuardar.enabled ? colorExito : "#404050"
                                border.width: 2

                                layer.enabled: btnGuardar.enabled
                                layer.effect: Glow {
                                    color: colorExito
                                    radius: 6
                                    samples: 13
                                }
                            }

                            contentItem: Text {
                                text: btnGuardar.text
                                color: btnGuardar.enabled ? colorFondo : colorSecundario
                                font.bold: true
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                guardarCliente()
                            }
                        }

                        // Botón CANCELAR (solo en edición)
                        Button {
                            width: 160
                            height: 45
                            visible: clienteEditando
                            text: "✕ CANCELAR"

                            background: Rectangle {
                                color: colorError
                                radius: 8
                                border.color: colorError
                                border.width: 2
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                clienteEditando = null
                                formularioVisible = false
                                limpiarFormulario()
                            }
                        }
                    }
                }
            }

            // LISTA DE CLIENTES CON DISEÑO MEJORADO
            Rectangle {
                width: parent.width
                height: parent.height - (formularioVisible ? 350 : 120)
                color: "transparent"

                // Encabezados de tabla con diseño NEON
                Rectangle {
                    id: encabezados
                    width: parent.width
                    height: 50
                    color: "transparent"
                    border.color: colorBorde
                    border.width: 1
                    radius: 8

                    Row {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20

                        // Columna NOMBRE
                        Text {
                            width: 280
                            text: "NOMBRE"
                            font.pixelSize: 14
                            font.bold: true
                            color: colorBorde
                        }

                        // Columna CORREO
                        Text {
                            width: 300
                            text: "CORREO"
                            font.pixelSize: 14
                            font.bold: true
                            color: colorBorde
                        }

                        // Columna TELÉFONO
                        Text {
                            width: 200
                            text: "TELÉFONO"
                            font.pixelSize: 14
                            font.bold: true
                            color: colorBorde
                        }

                        // Espaciador dinámico
                        Item { width: parent.width - 900 }

                        // Columna ACCIONES
                        Text {
                            width: 120
                            text: "ACCIONES"
                            font.pixelSize: 14
                            font.bold: true
                            color: colorBorde
                        }
                    }
                }

                // Lista de clientes con scroll suave
                ScrollView {
                    anchors.top: encabezados.bottom
                    anchors.topMargin: 10
                    width: parent.width
                    height: parent.height - encabezados.height - 10
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        active: true
                        policy: ScrollBar.AlwaysOn

                        background: Rectangle {
                            color: colorPanel
                            radius: 3
                        }

                        contentItem: Rectangle {
                            color: colorBorde
                            radius: 3
                            implicitWidth: 6
                        }
                    }

                    // Lista principal
                    ListView {
                        id: listaClientes
                        width: parent.width
                        height: parent.height
                        spacing: 12
                        model: clientes

                        // Placeholder cuando no hay clientes
                        Rectangle {
                            visible: clientes.length === 0 && !cargando
                            width: parent.width
                            height: 200
                            color: "transparent"

                            Column {
                                anchors.centerIn: parent
                                spacing: 15

                                Text {
                                    text: "📭 No hay clientes registrados"
                                    font.pixelSize: 18
                                    color: colorSecundario
                                }

                                Text {
                                    text: "Presiona 'NUEVO CLIENTE' para agregar el primero"
                                    font.pixelSize: 14
                                    color: colorSecundario
                                }
                            }
                        }

                        // Indicador de carga
                        BusyIndicator {
                            anchors.centerIn: parent
                            running: cargando
                            width: 50
                            height: 50

                            contentItem: Item {
                                RotationAnimator on rotation {
                                    loops: Animation.Infinite
                                    from: 0
                                    to: 360
                                    duration: 1000
                                }

                                Repeater {
                                    model: 8

                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: colorBorde
                                        x: parent.width / 2 - width / 2
                                        y: 0

                                        transform: Rotation {
                                            origin.x: 4
                                            origin.y: 25
                                            angle: index * 45
                                        }
                                    }
                                }
                            }
                        }

                        // Delegado para cada cliente
                        delegate: Rectangle {
                            id: clienteDelegate
                            width: listaClientes.width
                            height: 70
                            color: index % 2 === 0 ? "#0a0a1f" : "#111122"
                            border.color: colorBorde
                            border.width: 1
                            radius: 8

                            // Efecto hover
                            states: State {
                                name: "hovered"
                                when: mouseArea.containsMouse
                                PropertyChanges {
                                    target: clienteDelegate
                                    scale: 1.01
                                    border.color: colorExito
                                }
                            }
                            transitions: Transition {
                                NumberAnimation { properties: "scale, border.color"; duration: 200 }
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 20

                                // Columna: Nombre
                                Column {
                                    width: 280
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 3

                                    Text {
                                        text: modelData.nombre || "Sin nombre"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: colorTexto
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Text {
                                        text: "ID: " + (modelData.id || "N/A")
                                        font.pixelSize: 11
                                        color: colorSecundario
                                    }
                                }

                                // Columna: Correo
                                Text {
                                    width: 300
                                    text: modelData.correo || "Sin correo"
                                    font.pixelSize: 14
                                    color: colorTexto
                                    anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideMiddle
                                }

                                // Columna: Teléfono
                                Text {
                                    width: 200
                                    text: modelData.telefono || "Sin teléfono"
                                    font.pixelSize: 14
                                    color: colorBorde
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Espaciador dinámico
                                Item { width: parent.width - 900 }

                                // Columna: Acciones
                                Row {
                                    spacing: 10
                                    anchors.verticalCenter: parent.verticalCenter

                                    // Botón EDITAR
                                    Button {
                                        id: btnEditar
                                        width: 40
                                        height: 40
                                        text: "✏️"

                                        background: Rectangle {
                                            color: "#00ffff"
                                            radius: 6

                                            layer.enabled: btnEditar.hovered
                                            layer.effect: Glow {
                                                color: "#00ffff"
                                                radius: 4
                                                samples: 9
                                            }
                                        }

                                        contentItem: Text {
                                            text: btnEditar.text
                                            font.pixelSize: 16
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            clienteEditando = modelData
                                            inputNombre.text = modelData.nombre || ""
                                            inputCorreo.text = modelData.correo || ""
                                            inputTelefono.text = modelData.telefono || ""
                                            formularioVisible = true
                                        }
                                    }

                                    // Botón ELIMINAR
                                    Button {
                                        id: btnEliminar
                                        width: 40
                                        height: 40
                                        text: "🗑️"

                                        background: Rectangle {
                                            color: colorError
                                            radius: 6
                                        }

                                        contentItem: Text {
                                            text: btnEliminar.text
                                            font.pixelSize: 16
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            confirmarEliminacion(modelData.id, modelData.nombre || "Cliente")
                                        }
                                    }
                                }
                            }

                            // Área de clic
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Podrías agregar aquí ver detalles
                                }
                            }
                        }
                    }
                }
            }
        }

        // Diálogo de confirmación para eliminar
        Popup {
            id: confirmDialog
            width: 400
            height: 200
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            background: Rectangle {
                color: colorPanel
                border.color: colorError
                border.width: 3
                radius: 12
            }

            property int clienteId: -1
            property string clienteNombre: ""

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width - 40

                Text {
                    text: "⚠️ ELIMINAR CLIENTE"
                    font.pixelSize: 20
                    font.bold: true
                    color: colorError
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "¿Estás seguro de eliminar a:\n\n<font color='#00ffff'>" + confirmDialog.clienteNombre + "</font>?"
                    font.pixelSize: 14
                    color: colorTexto
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                    wrapMode: Text.WordWrap
                }

                Row {
                    spacing: 15
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        width: 120
                        height: 40
                        text: "CONFIRMAR"

                        background: Rectangle {
                            color: colorError
                            radius: 6
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        onClicked: {
                            eliminarCliente(confirmDialog.clienteId)
                            confirmDialog.close()
                        }
                    }

                    Button {
                        width: 120
                        height: 40
                        text: "CANCELAR"

                        background: Rectangle {
                            color: colorSecundario
                            radius: 6
                        }

                        contentItem: Text {
                            text: parent.text
                            color: colorFondo
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        onClicked: confirmDialog.close()
                    }
                }
            }
        }

        // FUNCIONES
        function limpiarFormulario() {
            inputNombre.text = ""
            inputCorreo.text = ""
            inputTelefono.text = ""
        }

        function cargarClientes() {
            cargando = true
            api.get("/clientes/", function(exito, datos) {
                cargando = false
                if (exito) {
                    clientes = datos
                } else {
                    mostrarError("Error al cargar clientes")
                }
            })
        }

        function guardarCliente() {
            var datos = {
                nombre: inputNombre.text.trim(),
                correo: inputCorreo.text.trim(),
                telefono: inputTelefono.text.trim()
            }

            if (!datos.nombre) {
                mostrarError("El nombre es obligatorio")
                return
            }

            if (clienteEditando) {
                // Actualizar cliente existente
                api.post("/clientes/" + clienteEditando.id, datos, function(exito, respuesta) {
                    if (exito) {
                        notificacion.mostrar("✅ Cliente actualizado")
                        clienteEditando = null
                        formularioVisible = false
                        limpiarFormulario()
                        cargarClientes()
                    } else {
                        mostrarError("Error al actualizar cliente")
                    }
                })
            } else {
                // Crear nuevo cliente
                api.post("/clientes/", datos, function(exito, respuesta) {
                    if (exito) {
                        notificacion.mostrar("✅ Cliente creado exitosamente")
                        formularioVisible = false
                        limpiarFormulario()
                        cargarClientes()
                    } else {
                        mostrarError("Error al crear cliente")
                    }
                })
            }
        }

        function confirmarEliminacion(id, nombre) {
            confirmDialog.clienteId = id
            confirmDialog.clienteNombre = nombre
            confirmDialog.open()
        }

        function eliminarCliente(id) {
            api.del("/clientes/" + id, function(exito, respuesta) {
                if (exito) {
                    notificacion.mostrar("🗑️ Cliente eliminado")
                    cargarClientes()
                } else {
                    mostrarError("Error al eliminar cliente")
                }
            })
        }

        function mostrarError(mensaje) {
            notificacion.mostrar("❌ " + mensaje)
        }

        // Inicializar al cargar el componente
        Component.onCompleted: {
            cargarClientes()
        }
    }
}