import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0
import quantum 1.0
import "../componentes"

Item {
    id: pantallaPermisos
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#050510"
        z: -1
    }

    property string tabActual: "usuario" // usuario | rol
    property string debugInfo: "" // DEBUG: URL, status, body

    // Usuario
    property string usuarioId: ""
    property var permisosUsuario: []
    property bool cargandoUsuario: false

    // Rol
    property string rolSeleccionado: "ADMIN"
    property var permisosRol: []
    property bool cargandoRol: false

    // Modal permiso
    property bool mostrandoModal: false
    property string recursoInput: ""
    property string accionInput: "ver"
    property bool permitidoInput: true
    property bool guardandoPermiso: false

    property bool recursoInvalido: false
    property bool accionInvalida: false

    // Mensajes rápidos
    property string mensajeFlotante: ""

    function mostrarMensaje(texto) {
        mensajeFlotante = texto
        toast.visible = true
        toastTimer.restart()
    }

    function limpiarFormularioPermiso() {
        recursoInput = ""
        accionInput = "ver"
        permitidoInput = true
        recursoInvalido = false
        accionInvalida = false
    }

    function abrirModal() {
        limpiarFormularioPermiso()
        mostrandoModal = true
    }

    function cerrarModal() {
        mostrandoModal = false
        guardandoPermiso = false
    }

    function cargarPermisosUsuario() {
        if (!usuarioId || usuarioId.trim() === "") {
            mostrarMensaje("Ingresa un ID de usuario")
            return
        }
        cargandoUsuario = true
        var endpoint = "/permisos/usuario/" + usuarioId.trim()
        debugInfo = "GET " + GestorAuth.urlBackend + endpoint

        GestorAuth.request("GET", endpoint, null, function(exito, resp) {
            cargandoUsuario = false
            if (exito) {
                permisosUsuario = resp || []
                mostrarMensaje("Permisos del usuario cargados: " + permisosUsuario.length)
                debugInfo = "OK: " + permisosUsuario.length + " permisos"
            } else {
                mostrarMensaje("Error: " + resp)
                debugInfo = "ERROR: " + resp
                permisosUsuario = []
            }
        })
    }

    function cargarPermisosRol() {
        cargandoRol = true
        var endpoint = "/permisos/rol/" + rolSeleccionado
        debugInfo = "GET " + GestorAuth.urlBackend + endpoint

        GestorAuth.request("GET", endpoint, null, function(exito, resp) {
            cargandoRol = false
            if (exito) {
                permisosRol = resp || []
                mostrarMensaje("Permisos del rol cargados: " + permisosRol.length)
                debugInfo = "OK: " + permisosRol.length + " permisos"
            } else {
                mostrarMensaje("Error: " + resp)
                debugInfo = "ERROR: " + resp
                permisosRol = []
            }
        })
    }

    function guardarPermiso() {
        recursoInvalido = !recursoInput || recursoInput.trim() === ""
        accionInvalida = !accionInput || accionInput.trim() === ""

        if (recursoInvalido || accionInvalida) {
            mostrarMensaje("Faltan campos")
            return
        }

        var payload = {
            recurso: recursoInput,
            accion: accionInput,
            permitido: permitidoInput
        }

        if (tabActual === "usuario") {
            if (!usuarioId || usuarioId.trim() === "") {
                mostrarMensaje("Ingresa un ID de usuario")
                return
            }
            guardandoPermiso = true
            GestorAuth.request("POST", "/permisos/usuario/" + usuarioId.trim(), payload, function(exito, resp) {
                guardandoPermiso = false
                if (exito) {
                    mostrarMensaje("Permiso guardado")
                    cerrarModal()
                    cargarPermisosUsuario()
                } else {
                    mostrarMensaje("Error: " + resp)
                }
            })
        } else {
            guardandoPermiso = true
            GestorAuth.request("POST", "/permisos/rol/" + rolSeleccionado, payload, function(exito, resp) {
                guardandoPermiso = false
                if (exito) {
                    mostrarMensaje("Permiso guardado")
                    cerrarModal()
                    cargarPermisosRol()
                } else {
                    mostrarMensaje("Error: " + resp)
                }
            })
        }
    }

    function eliminarPermisoUsuario(dato) {
        if (!usuarioId || usuarioId.trim() === "") {
            mostrarMensaje("Ingresa un ID de usuario")
            return
        }
        var endpoint = "/permisos/usuario/" + usuarioId.trim()
                + "?recurso=" + encodeURIComponent(dato.recurso)
                + "&accion=" + encodeURIComponent(dato.accion)
        GestorAuth.request("DELETE", endpoint, null, function(exito, resp) {
            if (exito) {
                mostrarMensaje("Permiso eliminado")
                cargarPermisosUsuario()
            } else {
                mostrarMensaje("Error: " + resp)
            }
        })
    }

    function eliminarPermisoRol(dato) {
        var endpoint = "/permisos/rol/" + rolSeleccionado
                + "?recurso=" + encodeURIComponent(dato.recurso)
                + "&accion=" + encodeURIComponent(dato.accion)
        GestorAuth.request("DELETE", endpoint, null, function(exito, resp) {
            if (exito) {
                mostrarMensaje("Permiso eliminado")
                cargarPermisosRol()
            } else {
                mostrarMensaje("Error: " + resp)
            }
        })
    }

    Rectangle {
        id: toast
        width: 320
        height: 40
        radius: PaletaNeon.radioBorde
        color: PaletaNeon.tarjeta
        border.color: PaletaNeon.primario
        anchors.horizontalCenter: parent.horizontalCenter
        y: 20
        visible: false
        z: 100

        Text {
            anchors.centerIn: parent
            text: mensajeFlotante
            color: PaletaNeon.texto
            font.family: PaletaNeon.fuentePrincipal
            font.pixelSize: PaletaNeon.tamañoFuenteNormal
        }

        Timer {
            id: toastTimer
            interval: 2500
            onTriggered: toast.visible = false
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        Row {
            width: parent.width
            spacing: 10

            Text {
                text: "🔑"
                font.pixelSize: 34
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "Gestor de Permisos"
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuenteTitulo
                    font.bold: true
                    color: PaletaNeon.primario

                    layer.enabled: true
                    layer.effect: Glow {
                        color: PaletaNeon.primario
                        samples: 12
                        radius: 8
                        spread: 0.3
                    }
                }

                Text {
                    text: debugInfo
                    color: PaletaNeon.textoSecundario
                    font.pixelSize: PaletaNeon.tamañoFuentePequeña
                    visible: debugInfo !== ""
                }
            }
        }

        Row {
            spacing: 10

            BotonNeon {
                text: "Permisos por Usuario"
                variante: tabActual === "usuario" ? "primary" : "ghost"
                onClicked: tabActual = "usuario"
            }

            BotonNeon {
                text: "Permisos por Rol"
                variante: tabActual === "rol" ? "primary" : "ghost"
                onClicked: tabActual = "rol"
            }
        }

        Loader {
            width: parent.width
            height: parent.height - 150
            active: true
            sourceComponent: tabActual === "usuario" ? vistaUsuario : vistaRol
        }
    }

    Component {
        id: vistaUsuario

        Column {
            anchors.fill: parent
            spacing: 16

            Item {
                width: parent.width
                height: 110
                HoverHandler { id: hoverUsuarioEncabezado }

                layer.enabled: hoverUsuarioEncabezado.active
                layer.effect: Glow {
                    color: PaletaNeon.primario
                    samples: 12
                    radius: 10
                    spread: 0.2
                }

                TarjetaGlow {
                    anchors.fill: parent

                    contenido: Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: "Permisos por Usuario"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: PaletaNeon.tamañoFuenteGrande
                            color: PaletaNeon.texto
                        }

                        Row {
                            spacing: 10
                            width: parent.width

                            InputAnimado {
                                id: campoUsuario
                                width: parent.width * 0.35
                                placeholderText: "ID usuario"
                                text: usuarioId
                                onTextChanged: usuarioId = text
                            }

                            BotonNeon {
                                text: cargandoUsuario ? "Cargando..." : "Consultar"
                                enabled: !cargandoUsuario && !guardandoPermiso
                                onClicked: cargarPermisosUsuario()
                            }

                            Item { width: 10 }

                            BotonNeon {
                                text: "Agregar permiso"
                                variante: "ghost"
                                enabled: !cargandoUsuario && !guardandoPermiso
                                onClicked: {
                                    if (!usuarioId || usuarioId.trim() === "") {
                                        mostrarMensaje("Ingresa un ID de usuario")
                                        return
                                    }
                                    abrirModal()
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: parent.height - 140
                HoverHandler { id: hoverUsuarioLista }

                layer.enabled: hoverUsuarioLista.active
                layer.effect: Glow {
                    color: PaletaNeon.secundario
                    samples: 12
                    radius: 10
                    spread: 0.2
                }

                TarjetaGlow {
                    anchors.fill: parent

                    contenido: Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Row {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Lista de permisos"
                                font.family: PaletaNeon.fuentePrincipal
                                font.pixelSize: PaletaNeon.tamañoFuenteGrande
                                color: PaletaNeon.texto
                            }

                        Rectangle {
                            width: 10
                            height: 10
                            color: cargandoUsuario ? PaletaNeon.info : "transparent"
                            radius: 5
                            anchors.verticalCenter: parent.verticalCenter

                            NumberAnimation on opacity {
                                id: animUsuarioCarga
                                from: 0.3
                                to: 1
                                duration: 500
                                loops: Animation.Infinite
                                running: cargandoUsuario
                            }
                        }
                        }

                        ScrollView {
                            anchors.fill: parent
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                            Column {
                                width: parent.width - 20
                                spacing: 10

                                Repeater {
                                    model: permisosUsuario

                                    Item {
                                        width: parent.width
                                        height: 90
                                        HoverHandler { id: hoverPermisoUsuario }

                                        layer.enabled: hoverPermisoUsuario.active
                                        layer.effect: Glow {
                                            color: PaletaNeon.primario
                                            samples: 10
                                            radius: 8
                                            spread: 0.15
                                        }

                                        TarjetaGlow {
                                            anchors.fill: parent

                                            contenido: Row {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 14

                                                Column {
                                                    width: parent.width * 0.35
                                                    spacing: 6

                                                    Text {
                                                        text: "Recurso"
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuentePequeña
                                                        color: PaletaNeon.textoSecundario
                                                    }

                                                    Text {
                                                        text: modelData.recurso
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuenteGrande
                                                        color: PaletaNeon.texto
                                                    }
                                                }

                                                Column {
                                                    width: parent.width * 0.25
                                                    spacing: 6

                                                    Text {
                                                        text: "Acción"
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuentePequeña
                                                        color: PaletaNeon.textoSecundario
                                                    }

                                                    Text {
                                                        text: modelData.accion
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuenteGrande
                                                        color: PaletaNeon.primario
                                                    }
                                                }

                                                Column {
                                                    width: parent.width * 0.2
                                                    spacing: 6

                                                    Text {
                                                        text: "Permitido"
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuentePequeña
                                                        color: PaletaNeon.textoSecundario
                                                    }

                                                    Switch {
                                                        id: switchUsuario
                                                        checked: modelData.permitido
                                                        enabled: !cargandoUsuario && !guardandoPermiso
                                                        onCheckedChanged: {
                                                            var copia = permisosUsuario.slice()
                                                            if (copia[index]) {
                                                                copia[index].permitido = checked
                                                                permisosUsuario = copia
                                                            }
                                                        }
                                                    }
                                                }

                                                Item { width: 10; height: 1 }

                                                BotonNeon {
                                                    text: "Eliminar"
                                                    variante: "danger"
                                                    width: 110
                                                    enabled: !cargandoUsuario && !guardandoPermiso
                                                    onClicked: eliminarPermisoUsuario(modelData)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                Rectangle {
                    anchors.fill: parent
                    color: "#050510AA"
                    visible: cargandoUsuario

                    MouseArea {
                        anchors.fill: parent
                        visible: cargandoUsuario
                    }
                }
            }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                visible: cargandoUsuario || guardandoPermiso

                MouseArea {
                    anchors.fill: parent
                    visible: parent.visible
                }
            }
        }
    }
    }

    Component {
        id: vistaRol

        Column {
            anchors.fill: parent
            spacing: 16

            Item {
                width: parent.width
                height: 110
                HoverHandler { id: hoverRolEncabezado }

                layer.enabled: hoverRolEncabezado.active
                layer.effect: Glow {
                    color: PaletaNeon.primario
                    samples: 12
                    radius: 10
                    spread: 0.2
                }

                TarjetaGlow {
                    anchors.fill: parent

                    contenido: Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: "Permisos por Rol"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: PaletaNeon.tamañoFuenteGrande
                            color: PaletaNeon.texto
                        }

                        Row {
                            spacing: 10
                            width: parent.width

                            ComboBox {
                                id: comboRol
                                width: parent.width * 0.35
                                model: ["ADMIN", "DUENO", "GERENTE", "VENDEDOR"]
                                currentIndex: model.indexOf(rolSeleccionado)
                                enabled: !cargandoRol && !guardandoPermiso
                                onActivated: function(idx) {
                                    rolSeleccionado = model[idx]
                                    cargarPermisosRol()
                                }
                            }

                            BotonNeon {
                                text: cargandoRol ? "Cargando..." : "Consultar"
                                enabled: !cargandoRol && !guardandoPermiso
                                onClicked: cargarPermisosRol()
                            }

                            Item { width: 10 }

                            BotonNeon {
                                text: "Agregar permiso"
                                variante: "ghost"
                                enabled: !cargandoRol && !guardandoPermiso
                                onClicked: abrirModal()
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: parent.height - 140
                HoverHandler { id: hoverRolLista }

                layer.enabled: hoverRolLista.active
                layer.effect: Glow {
                    color: PaletaNeon.secundario
                    samples: 12
                    radius: 10
                    spread: 0.2
                }

                TarjetaGlow {
                    anchors.fill: parent

                    contenido: Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Row {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Lista de permisos"
                                font.family: PaletaNeon.fuentePrincipal
                                font.pixelSize: PaletaNeon.tamañoFuenteGrande
                                color: PaletaNeon.texto
                            }

                        Rectangle {
                            width: 10
                            height: 10
                            color: cargandoRol ? PaletaNeon.info : "transparent"
                            radius: 5
                            anchors.verticalCenter: parent.verticalCenter

                            NumberAnimation on opacity {
                                id: animRolCarga
                                from: 0.3
                                to: 1
                                duration: 500
                                loops: Animation.Infinite
                                running: cargandoRol
                            }
                        }
                        }

                        ScrollView {
                            anchors.fill: parent
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                            Column {
                                width: parent.width - 20
                                spacing: 10

                                Repeater {
                                    model: permisosRol

                                    Item {
                                        width: parent.width
                                        height: 90
                                        HoverHandler { id: hoverPermisoRol }

                                        layer.enabled: hoverPermisoRol.active
                                        layer.effect: Glow {
                                            color: PaletaNeon.primario
                                            samples: 10
                                            radius: 8
                                            spread: 0.15
                                        }

                                        TarjetaGlow {
                                            anchors.fill: parent

                                            contenido: Row {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 14

                                                Column {
                                                    width: parent.width * 0.35
                                                    spacing: 6

                                                    Text {
                                                        text: "Recurso"
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuentePequeña
                                                        color: PaletaNeon.textoSecundario
                                                    }

                                                    Text {
                                                        text: modelData.recurso
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuenteGrande
                                                        color: PaletaNeon.texto
                                                    }
                                                }

                                                Column {
                                                    width: parent.width * 0.25
                                                    spacing: 6

                                                    Text {
                                                        text: "Acción"
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuentePequeña
                                                        color: PaletaNeon.textoSecundario
                                                    }

                                                    Text {
                                                        text: modelData.accion
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuenteGrande
                                                        color: PaletaNeon.primario
                                                    }
                                                }

                                                Column {
                                                    width: parent.width * 0.2
                                                    spacing: 6

                                                    Text {
                                                        text: "Permitido"
                                                        font.family: PaletaNeon.fuentePrincipal
                                                        font.pixelSize: PaletaNeon.tamañoFuentePequeña
                                                        color: PaletaNeon.textoSecundario
                                                    }

                                                    Switch {
                                                        id: switchRol
                                                        checked: modelData.permitido
                                                        enabled: !cargandoRol && !guardandoPermiso
                                                        onCheckedChanged: {
                                                            var copia = permisosRol.slice()
                                                            if (copia[index]) {
                                                                copia[index].permitido = checked
                                                                permisosRol = copia
                                                            }
                                                        }
                                                    }
                                                }

                                                Item { width: 10; height: 1 }

                                                BotonNeon {
                                                    text: "Eliminar"
                                                    variante: "danger"
                                                    width: 110
                                                    enabled: !cargandoRol && !guardandoPermiso
                                                    onClicked: eliminarPermisoRol(modelData)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                Rectangle {
                    anchors.fill: parent
                    color: "#050510AA"
                    visible: cargandoRol

                    MouseArea {
                        anchors.fill: parent
                        visible: cargandoRol
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                visible: cargandoRol || guardandoPermiso

                MouseArea {
                    anchors.fill: parent
                    visible: parent.visible
                }
            }
        }
    }

    // Modal agregar permiso
    Rectangle {
        anchors.fill: parent
        color: "#00000080"
        visible: mostrandoModal
        z: 200

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!guardandoPermiso)
                    cerrarModal()
            }
        }

        Item {
            anchors.centerIn: parent
            width: 480
            height: 360

            TarjetaGlow {
                anchors.fill: parent

                contenido: Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "Nuevo permiso"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: PaletaNeon.tamañoFuenteGrande
                            color: PaletaNeon.texto
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: PaletaNeon.primario
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: campoRecurso.implicitHeight
                        radius: PaletaNeon.radioBorde
                        color: "transparent"
                        border.color: recursoInvalido ? PaletaNeon.error : "transparent"
                        border.width: recursoInvalido ? 2 : 0

                        InputAnimado {
                            id: campoRecurso
                            anchors.fill: parent
                            anchors.margins: 0
                            placeholderText: "Recurso"
                            text: recursoInput
                            onTextChanged: {
                                recursoInput = text
                                recursoInvalido = false
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: comboAccion.implicitHeight
                        radius: PaletaNeon.radioBorde
                        color: "transparent"
                        border.color: accionInvalida ? PaletaNeon.error : "transparent"
                        border.width: accionInvalida ? 2 : 0

                        ComboBox {
                            id: comboAccion
                            width: parent.width
                            model: ["ver", "crear", "editar", "borrar"]
                            currentIndex: model.indexOf(accionInput)
                            enabled: !guardandoPermiso
                            onActivated: function(idx) {
                                accionInput = model[idx]
                                accionInvalida = false
                            }
                        }
                    }

                    Row {
                        spacing: 10
                        anchors.left: parent.left

                        Text {
                            text: "Permitido"
                            font.family: PaletaNeon.fuentePrincipal
                            font.pixelSize: PaletaNeon.tamañoFuenteNormal
                            color: PaletaNeon.texto
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Switch {
                            checked: permitidoInput
                            enabled: !guardandoPermiso
                            onCheckedChanged: permitidoInput = checked
                        }
                    }

                    Item { height: 10; width: 1 }

                    Row {
                        spacing: 10
                        BotonNeon {
                            text: guardandoPermiso ? "Guardando…" : "Guardar"
                            enabled: !guardandoPermiso
                            onClicked: guardarPermiso()
                        }

                        BotonNeon {
                            text: "Cancelar"
                            variante: "ghost"
                            enabled: !guardandoPermiso
                            onClicked: cerrarModal()
                        }
                    }
                }
            }
        }
    }
}
