import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import quantum 1.0

Item {
    id: root

    property var usuarios: []
    property bool cargando: false
    property bool modalVisible: false
    property bool editando: false
    property var usuarioActual: ({
        id: null,
        username: "",
        nombre: "",
        password: "",
        rol: "DUENO",
        activo: true
    })

    property bool puedeVer: GestorAuth.tienePermiso("usuarios", "ver")
    property bool puedeCrear: GestorAuth.tienePermiso("usuarios", "crear")
    property bool puedeEditar: GestorAuth.tienePermiso("usuarios", "editar")

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Row {
            spacing: 12
            Text {
                text: "👥"
                font.pixelSize: 36
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Gestión de Usuarios"
                font.family: PaletaNeon.fuentePrincipal
                font.pixelSize: PaletaNeon.tamañoFuenteTitulo
                font.bold: true
                color: PaletaNeon.primario
                anchors.verticalCenter: parent.verticalCenter
                layer.enabled: true
                layer.effect: Glow {
                    samples: 9
                    color: PaletaNeon.primario
                    spread: 0.2
                    radius: 4
                }
            }
            Item { Layout.fillWidth: true }
            NeonButton {
                id: btnNuevo
                text: "Nuevo Usuario"
                enabled: root.puedeCrear
                onClicked: abrirModalNuevo()
            }
        }

        NeonTable {
            id: tablaUsuarios
            width: parent.width
            height: parent.height - 160

            Column {
                anchors.fill: parent
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 40
                    color: PaletaNeon.tarjeta
                    radius: 8
                    border.color: PaletaNeon.primario
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        Text { text: "Usuario"; color: PaletaNeon.texto; font.bold: true; width: 150 }
                        Text { text: "Nombre"; color: PaletaNeon.texto; font.bold: true; width: 200 }
                        Text { text: "Rol"; color: PaletaNeon.texto; font.bold: true; width: 120 }
                        Text { text: "Estado"; color: PaletaNeon.texto; font.bold: true; width: 120 }
                        Text { text: "Acciones"; color: PaletaNeon.texto; font.bold: true }
                    }
                }

                ListView {
                    id: listaUsuarios
                    width: parent.width
                    height: parent.height - 48
                    model: root.usuarios
                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        color: PaletaNeon.fondo
                        radius: 8
                        border.color: PaletaNeon.primario
                        border.width: 1
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            Text { text: modelData.username; color: PaletaNeon.texto; width: 150; elide: Text.ElideRight }
                            Text { text: modelData.nombre; color: PaletaNeon.texto; width: 200; elide: Text.ElideRight }
                            Text { text: modelData.rol; color: PaletaNeon.info; width: 120 }
                            Text { text: modelData.activo ? "Activo" : "Inactivo"; color: modelData.activo ? PaletaNeon.exito : PaletaNeon.advertencia; width: 120 }
                            Row {
                                spacing: 8
                                NeonButton {
                                    text: "Editar"
                                    enabled: root.puedeEditar
                                    onClicked: abrirModalEditar(modelData)
                                }
                                NeonButton {
                                    text: modelData.activo ? "Desactivar" : "Activar"
                                    enabled: root.puedeEditar
                                    onClicked: activarDesactivarUsuario(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: modal
        anchors.fill: parent
        visible: modalVisible
        color: Qt.rgba(0, 0, 0, 0.6)

        Rectangle {
            width: parent.width * 0.6
            height: parent.height * 0.7
            anchors.centerIn: parent
            color: PaletaNeon.tarjeta
            radius: 12
            border.color: PaletaNeon.primario
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Text {
                    text: editando ? "Editar Usuario" : "Nuevo Usuario"
                    font.family: PaletaNeon.fuentePrincipal
                    font.pixelSize: 20
                    font.bold: true
                    color: PaletaNeon.primario
                }

                NeonInput {
                    id: inputUsername
                    Layout.fillWidth: true
                    placeholderText: "Username"
                    text: root.usuarioActual.username
                    onTextChanged: root.usuarioActual.username = text
                }

                NeonInput {
                    id: inputNombre
                    Layout.fillWidth: true
                    placeholderText: "Nombre"
                    text: root.usuarioActual.nombre
                    onTextChanged: root.usuarioActual.nombre = text
                }

                NeonInput {
                    id: inputPassword
                    Layout.fillWidth: true
                    placeholderText: "Contraseña"
                    echoMode: TextInput.Password
                    text: root.usuarioActual.password
                    onTextChanged: root.usuarioActual.password = text
                }

                ComboBox {
                    id: rolCombo
                    Layout.fillWidth: true
                    model: ["DUENO", "ADMIN", "GERENTE", "VENDEDOR"]
                    currentIndex: Math.max(0, model.indexOf(root.usuarioActual.rol))
                    onCurrentTextChanged: root.usuarioActual.rol = currentText
                    enabled: root.puedeEditar || !editando ? root.puedeCrear : root.puedeEditar
                }

                CheckBox {
                    id: activoCheck
                    text: "Usuario activo"
                    checked: root.usuarioActual.activo
                    onCheckedChanged: root.usuarioActual.activo = checked
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 12
                    NeonButton {
                        text: "Cancelar"
                        onClicked: cerrarModal()
                    }
                    NeonButton {
                        text: editando ? "Actualizar" : "Crear"
                        enabled: editando ? root.puedeEditar : root.puedeCrear
                        onClicked: guardarUsuario()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        cargarUsuarios()
    }

    onPuedeVerChanged: {
        if (puedeVer) cargarUsuarios()
    }

    Connections {
        target: GestorAuth
        onTokenChanged: {
            if (GestorAuth.token === "") {
                root.usuarios = []
                modalVisible = false
                root.usuarioActual = ({ id: null, username: "", nombre: "", password: "", rol: "DUENO", activo: true })
            }
        }
    }

    function cargarUsuarios() {
        if (!root.puedeVer) {
            root.usuarios = []
            return
        }
        cargando = true
        GestorAuth.request("GET", "/usuarios/", null, function(exito, datos) {
            cargando = false
            if (exito && datos) {
                root.usuarios = datos
            }
        })
    }

    function abrirModalNuevo() {
        if (!root.puedeCrear)
            return
        editando = false
        root.usuarioActual = ({ id: null, username: "", nombre: "", password: "", rol: "DUENO", activo: true })
        modalVisible = true
    }

    function abrirModalEditar(usuario) {
        if (!root.puedeEditar)
            return
        editando = true
        root.usuarioActual = ({
            id: usuario.id,
            username: usuario.username,
            nombre: usuario.nombre,
            password: "",
            rol: usuario.rol,
            activo: usuario.activo
        })
        modalVisible = true
    }

    function cerrarModal() {
        modalVisible = false
    }

    function guardarUsuario() {
        if (editando) {
            var dataEditar = {
                username: root.usuarioActual.username,
                nombre: root.usuarioActual.nombre,
                rol: root.usuarioActual.rol,
                activo: root.usuarioActual.activo
            }
            if (root.usuarioActual.password && root.usuarioActual.password !== "") {
                dataEditar.password = root.usuarioActual.password
            }
            GestorAuth.request("PUT", "/usuarios/" + root.usuarioActual.id, dataEditar, function(exito) {
                if (exito) {
                    modalVisible = false
                    cargarUsuarios()
                }
            })
        } else {
            var dataCrear = {
                username: root.usuarioActual.username,
                nombre: root.usuarioActual.nombre,
                password: root.usuarioActual.password,
                rol: root.usuarioActual.rol,
                activo: root.usuarioActual.activo
            }
            GestorAuth.request("POST", "/usuarios/", dataCrear, function(exito) {
                if (exito) {
                    modalVisible = false
                    cargarUsuarios()
                }
            })
        }
    }

    function activarDesactivarUsuario(usuario) {
        if (!root.puedeEditar)
            return
        var endpoint = usuario.activo ? "/usuarios/" + usuario.id + "/desactivar" : "/usuarios/" + usuario.id + "/activar"
        GestorAuth.request("PATCH", endpoint, {}, function(exito) {
            if (exito) {
                cargarUsuarios()
            }
        })
    }
}
