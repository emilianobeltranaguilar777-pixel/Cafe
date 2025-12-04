import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0
import quantum 1.0
import "../componentes"

Item {
    id: pantallaUsuarios
    anchors.fill: parent

    property var usuarios: []
    property bool cargando: false
    property string mensaje: ""

    // Expose controls for tests
    property alias btnNuevo: btnNuevo
    property alias listaUsuarios: listaUsuarios

    // Modal
    property bool mostrandoModal: false
    property bool modoEdicion: false
    property var usuarioActual: null

    // Formulario
    property string formUsername: ""
    property string formNombre: ""
    property string formPassword: ""
    property string formRol: "ADMIN"

    readonly property var rolesDisponibles: ["DUENO", "ADMIN", "GERENTE", "VENDEDOR"]

    function limpiarFormulario() {
        modoEdicion = false
        usuarioActual = null
        formUsername = ""
        formNombre = ""
        formPassword = ""
        formRol = rolesDisponibles[0]
    }

    function abrirModalNuevo() {
        limpiarFormulario()
        mostrandoModal = true
    }

    function abrirModalEditar(usuario) {
        if (!usuario)
            return
        modoEdicion = true
        usuarioActual = usuario
        formUsername = usuario.username || ""
        formNombre = usuario.nombre || ""
        formPassword = ""
        formRol = usuario.rol || rolesDisponibles[0]
        mostrandoModal = true
    }

    function cerrarModal() {
        mostrandoModal = false
    }

    function cargarUsuarios() {
        cargando = true
        mensaje = ""
        GestorAuth.request("GET", "/usuarios/", null, function(exito, resp) {
            cargando = false
            if (exito) {
                usuarios = resp || []
            } else {
                mensaje = resp || "No se pudieron cargar usuarios"
            }
        })
    }

    function guardarUsuario() {
        var payload = {
            nombre: formNombre,
            rol: formRol
        }

        if (!modoEdicion) {
            payload.username = formUsername
            payload.password = formPassword

            if (!payload.username || !payload.password) {
                mensaje = "Username y contraseña son obligatorios"
                return
            }

            GestorAuth.request("POST", "/usuarios/", payload, function(exito) {
                mensaje = exito ? "Usuario creado" : "Error al crear usuario"
                if (exito) {
                    cerrarModal()
                    cargarUsuarios()
                }
            })
        } else {
            if (!usuarioActual)
                return

            if (formPassword && formPassword.length > 0)
                payload.password = formPassword

            GestorAuth.request("PUT", "/usuarios/" + usuarioActual.id, payload, function(exito) {
                mensaje = exito ? "Usuario actualizado" : "Error al actualizar usuario"
                if (exito) {
                    cerrarModal()
                    cargarUsuarios()
                }
            })
        }
    }

    function alternarEstado(usuario) {
        if (!usuario)
            return

        var endpoint = usuario.activo ? "/usuarios/" + usuario.id + "/desactivar" : "/usuarios/" + usuario.id + "/activar"
        GestorAuth.request("PATCH", endpoint, {}, function(exito) {
            mensaje = exito ? "Estado actualizado" : "No se pudo cambiar estado"
            if (exito)
                cargarUsuarios()
        })
    }

    Rectangle {
        anchors.fill: parent
        color: PaletaNeon.fondo
    }

    Column {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        Row {
            width: parent.width
            spacing: 12

            Text {
                text: "👤"
                font.pixelSize: 36
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "Gestión de Usuarios"
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuenteTitulo
                    font.bold: true
                    color: PaletaNeon.primario
                    layer.enabled: true
                    layer.effect: Glow {
                        samples: 9
                        color: PaletaNeon.primario
                        spread: 0.2
                        radius: 4
                    }
                }

                Text {
                    text: cargando ? "Cargando usuarios..." : (mensaje || "")
                    color: mensaje ? PaletaNeon.advertencia : PaletaNeon.textoSecundario
                    font.pixelSize: PaletaNeon.tamañoFuentePequeña
                }
            }

            Item { width: 1; Layout.fillWidth: true }

            BotonNeon {
                id: btnNuevo
                objectName: "btnNuevoUsuario"
                text: "＋ Nuevo Usuario"
                enabled: GestorAuth.tienePermiso("usuarios", "crear")
                onClicked: abrirModalNuevo()
            }

            BotonNeon {
                id: btnRecargar
                text: "Actualizar"
                variante: "ghost"
                onClicked: cargarUsuarios()
            }
        }

        TarjetaGlow {
            height: 60
            width: parent.width
            contenido: Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 18

                Text {
                    text: "Total usuarios: " + usuarios.length
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuenteNormal
                    color: PaletaNeon.texto
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 2
                    height: parent.height - 16
                    color: PaletaNeon.primario
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.3
                }

                Text {
                    text: "Rol activo: " + (GestorAuth.datosUsuario ? GestorAuth.datosUsuario.rol : "")
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: PaletaNeon.tamañoFuenteNormal
                    color: PaletaNeon.textoSecundario
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle {
            width: parent.width
            height: parent.height - 180
            color: PaletaNeon.tarjeta
            radius: PaletaNeon.radioBorde
            border.color: PaletaNeon.primario
            border.width: 2

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Row {
                    width: parent.width
                    spacing: 10
                    Text { text: "Usuario"; color: PaletaNeon.textoSecundario; font.pixelSize: PaletaNeon.tamañoFuentePequeña; width: parent.width * 0.22 }
                    Text { text: "Nombre"; color: PaletaNeon.textoSecundario; font.pixelSize: PaletaNeon.tamañoFuentePequeña; width: parent.width * 0.28 }
                    Text { text: "Rol"; color: PaletaNeon.textoSecundario; font.pixelSize: PaletaNeon.tamañoFuentePequeña; width: parent.width * 0.15 }
                    Text { text: "Estado"; color: PaletaNeon.textoSecundario; font.pixelSize: PaletaNeon.tamañoFuentePequeña; width: parent.width * 0.15 }
                    Text { text: "Acciones"; color: PaletaNeon.textoSecundario; font.pixelSize: PaletaNeon.tamañoFuentePequeña; width: parent.width * 0.2 }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: PaletaNeon.primario
                    opacity: 0.25
                }

                ListView {
                    id: listaUsuarios
                    objectName: "listaUsuarios"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height - 40
                    model: usuarios
                    spacing: 8
                    clip: true

                    delegate: Rectangle {
                        width: parent ? parent.width : 0
                        height: 64
                        radius: PaletaNeon.radioBorde
                        color: Qt.rgba(0, 1, 1, 0.05)
                        border.color: PaletaNeon.primario
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Text {
                                width: listaUsuarios.width * 0.22
                                text: model.username
                                color: PaletaNeon.texto
                                font.family: PaletaNeon.fuentePrincipal
                                font.pixelSize: PaletaNeon.tamañoFuenteNormal
                                elide: Text.ElideRight
                            }

                            Text {
                                width: listaUsuarios.width * 0.28
                                text: model.nombre || "—"
                                color: PaletaNeon.textoSecundario
                                font.pixelSize: PaletaNeon.tamañoFuenteNormal
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                width: listaUsuarios.width * 0.15
                                height: 32
                                radius: PaletaNeon.radioBorde
                                color: Qt.rgba(1, 0, 0.5, 0.12)
                                border.color: PaletaNeon.secundario
                                Text {
                                    anchors.centerIn: parent
                                    text: model.rol
                                    font.family: PaletaNeon.fuentePrincipal
                                    font.bold: true
                                    color: PaletaNeon.secundario
                                }
                            }

                            Row {
                                width: listaUsuarios.width * 0.15
                                spacing: 8
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: model.activo ? PaletaNeon.exito : PaletaNeon.error
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: model.activo ? "Activo" : "Inactivo"
                                    color: model.activo ? PaletaNeon.exito : PaletaNeon.error
                                    font.pixelSize: PaletaNeon.tamañoFuentePequeña
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Row {
                                width: listaUsuarios.width * 0.2
                                spacing: 8
                                anchors.verticalCenter: parent.verticalCenter

                                BotonNeon {
                                    id: btnEditar
                                    objectName: "btnEditarUsuario"
                                    text: "Editar"
                                    enabled: GestorAuth.tienePermiso("usuarios", "editar")
                                    onClicked: abrirModalEditar(model)
                                }

                                BotonNeon {
                                    text: model.activo ? "Desactivar" : "Activar"
                                    variante: model.activo ? "danger" : "ghost"
                                    enabled: GestorAuth.tienePermiso("usuarios", "editar")
                                    onClicked: alternarEstado(model)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Modal de creación/edición
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        visible: mostrandoModal
        z: 10

        Rectangle {
            width: 520
            height: 380
            radius: PaletaNeon.radioBorde
            color: PaletaNeon.tarjeta
            border.color: PaletaNeon.primario
            border.width: 2
            anchors.centerIn: parent

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Row {
                    width: parent.width
                    spacing: 10

                    Text {
                        text: modoEdicion ? "Editar usuario" : "Nuevo usuario"
                        font.family: PaletaNeon.fuentePrincipal
                        font.pixelSize: PaletaNeon.tamañoFuenteGrande
                        font.bold: true
                        color: PaletaNeon.primario
                    }

                    Item { Layout.fillWidth: true }

                    BotonNeon {
                        text: "Cerrar"
                        variante: "ghost"
                        onClicked: cerrarModal()
                    }
                }

                InputAnimado {
                    id: inputUser
                    objectName: "inputUsername"
                    width: parent.width
                    placeholderText: "Username"
                    enabled: !modoEdicion
                    text: formUsername
                    onTextChanged: formUsername = text
                }

                InputAnimado {
                    id: inputNombre
                    objectName: "inputNombre"
                    width: parent.width
                    placeholderText: "Nombre completo"
                    text: formNombre
                    onTextChanged: formNombre = text
                }

                ComboBox {
                    id: comboRol
                    objectName: "comboRol"
                    width: parent.width
                    model: rolesDisponibles
                    currentIndex: Math.max(0, rolesDisponibles.indexOf(formRol))
                    onActivated: formRol = currentText
                }

                InputAnimado {
                    id: inputPassword
                    objectName: "inputPassword"
                    width: parent.width
                    placeholderText: modoEdicion ? "Dejar vacío para mantener" : "Contraseña"
                    echoMode: TextInput.Password
                    text: formPassword
                    onTextChanged: formPassword = text
                }

                Row {
                    spacing: 10

                    BotonNeon {
                        text: modoEdicion ? "Actualizar" : "Crear"
                        enabled: modoEdicion ? GestorAuth.tienePermiso("usuarios", "editar") : GestorAuth.tienePermiso("usuarios", "crear")
                        onClicked: guardarUsuario()
                    }

                    BotonNeon {
                        text: "Cancelar"
                        variante: "ghost"
                        onClicked: cerrarModal()
                    }
                }
            }
        }
    }

    Component.onCompleted: cargarUsuarios()
}
