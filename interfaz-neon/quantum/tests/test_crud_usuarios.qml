import QtQuick 2.15
import QtTest 1.15
import quantum 1.0

TestCase {
    name: "CrudUsuariosTest"

    property var component
    property var pantalla
    property var originalRequest
    property var originalTienePermiso
    property var lastRequest
    property var requestLog
    property var permisoFlags
    property var stubResponses

    function init() {
        originalRequest = GestorAuth.request
        originalTienePermiso = GestorAuth.tienePermiso
        permisoFlags = {
            "usuarios:ver": true,
            "usuarios:crear": true,
            "usuarios:editar": true
        }
        stubResponses = []
        requestLog = []
        lastRequest = null

        GestorAuth.tienePermiso = function(recurso, accion) {
            var key = recurso + ":" + accion
            return permisoFlags.hasOwnProperty(key) ? permisoFlags[key] : false
        }

        GestorAuth.request = function(metodo, endpoint, data, callback) {
            lastRequest = { method: metodo, endpoint: endpoint, data: data }
            requestLog.push(lastRequest)

            var respuesta = stubResponses.length ? stubResponses.shift() : { success: true, data: null }
            if (callback)
                callback(respuesta.success, respuesta.data)
        }

        GestorAuth.datosUsuario = GestorAuth.datosUsuario || { rol: "ADMIN" }
        GestorAuth.token = GestorAuth.token || ""

        component = Qt.createComponent("../pantallas/pantalla_usuarios.qml")
        pantalla = component.createObject(null)
    }

    function cleanup() {
        GestorAuth.request = originalRequest
        GestorAuth.tienePermiso = originalTienePermiso
        if (pantalla)
            pantalla.destroy()
        pantalla = null
        component = null
        lastRequest = null
        requestLog = []
        stubResponses = []
    }

    function findObjectWithText(obj, text, visited) {
        if (!obj)
            return null
        visited = visited || []
        if (visited.indexOf(obj) !== -1)
            return null
        visited.push(obj)

        if (obj.text === text)
            return obj

        var candidates = []
        if (obj.children)
            candidates = candidates.concat(obj.children)
        if (obj.contentItem)
            candidates.push(obj.contentItem)
        if (obj.background)
            candidates.push(obj.background)

        for (var i = 0; i < candidates.length; ++i) {
            var found = findObjectWithText(candidates[i], text, visited)
            if (found)
                return found
        }
        return null
    }

    function findListViewForModel(obj, model, visited) {
        if (!obj)
            return null
        visited = visited || []
        if (visited.indexOf(obj) !== -1)
            return null
        visited.push(obj)

        if (obj.model === model && obj.hasOwnProperty("count"))
            return obj

        var children = []
        if (obj.children)
            children = children.concat(obj.children)
        if (obj.contentItem)
            children.push(obj.contentItem)
        if (obj.background)
            children.push(obj.background)

        for (var i = 0; i < children.length; ++i) {
            var child = children[i]
            var match = findListViewForModel(child, model, visited)
            if (match)
                return match
        }
        return null
    }

    function prepareListView() {
        var listView = findListViewForModel(pantalla, pantalla.usuarios)
        if (!listView)
            return null
        if (listView.forceLayout)
            listView.forceLayout()
        wait(0)
        return listView
    }

    function test_pantalla_carga() {
        verify(pantalla !== null)
    }

    function test_lista_usuarios_muestra_filas() {
        pantalla.usuarios = [
            { id: 1, username: "uno", nombre: "Primero", rol: "ADMIN", activo: true },
            { id: 2, username: "dos", nombre: "Segundo", rol: "GERENTE", activo: false }
        ]

        var listView = prepareListView()
        verify(listView !== null)
        tryCompare(listView, "count", pantalla.usuarios.length)
    }

    function test_modal_nuevo_usuario_limpiar() {
        var botonNuevo = findObjectWithText(pantalla, "Nuevo Usuario")
        verify(botonNuevo !== null)
        botonNuevo.clicked()

        compare(pantalla.modalVisible, true)
        compare(pantalla.usuarioActual.username, "")
        compare(pantalla.usuarioActual.nombre, "")
        compare(pantalla.usuarioActual.password, "")
        compare(pantalla.usuarioActual.rol, "DUENO")
        compare(pantalla.usuarioActual.activo, true)
    }

    function test_crearUsuario_enviaPayloadCorrecto() {
        stubResponses = [
            { success: true, data: null },
            { success: true, data: [
                { id: 1, username: "admin", nombre: "Administrador", rol: "ADMIN", activo: true },
                { id: 2, username: "nuevo", nombre: "Nuevo Usuario", rol: "GERENTE", activo: true }
            ] }
        ]

        pantalla.abrirModalNuevo()
        pantalla.usuarioActual.username = "nuevo"
        pantalla.usuarioActual.nombre = "Nuevo Usuario"
        pantalla.usuarioActual.password = "secreto"
        pantalla.usuarioActual.rol = "GERENTE"
        pantalla.usuarioActual.activo = true

        pantalla.guardarUsuario()

        compare(requestLog.length >= 1, true)
        compare(requestLog[0].method, "POST")
        compare(requestLog[0].endpoint, "/usuarios/")
        compare(requestLog[0].data.username, "nuevo")
        compare(requestLog[0].data.nombre, "Nuevo Usuario")
        compare(requestLog[0].data.password, "secreto")
        compare(requestLog[0].data.rol, "GERENTE")
        compare(requestLog[0].data.activo, true)

        compare(pantalla.modalVisible, false)
        tryCompare(pantalla, "usuarios.length", 2)
    }

    function test_editarUsuario_actualizaModelo() {
        pantalla.usuarios = [{ id: 10, username: "existente", nombre: "User", rol: "VENDEDOR", activo: true }]
        stubResponses = [
            { success: true, data: null },
            { success: true, data: [{ id: 10, username: "existente", nombre: "Actualizado", rol: "ADMIN", activo: true }] }
        ]

        pantalla.abrirModalEditar(pantalla.usuarios[0])
        pantalla.usuarioActual.nombre = "Actualizado"
        pantalla.usuarioActual.rol = "ADMIN"
        pantalla.guardarUsuario()

        compare(requestLog[0].method, "PUT")
        compare(requestLog[0].endpoint, "/usuarios/10")
        compare(requestLog[0].data.nombre, "Actualizado")
        compare(requestLog[0].data.rol, "ADMIN")
        compare(requestLog[0].data.hasOwnProperty("password"), false)

        tryCompare(pantalla, "usuarios[0].nombre", "Actualizado")
        compare(pantalla.usuarios[0].rol, "ADMIN")
    }

    function test_toggleUsuario_actualizaActivo() {
        pantalla.usuarios = [{ id: 3, username: "des", nombre: "Desactivado", rol: "GERENTE", activo: false }]
        stubResponses = [
            { success: true, data: null },
            { success: true, data: [{ id: 3, username: "des", nombre: "Desactivado", rol: "GERENTE", activo: true }] }
        ]

        pantalla.activarDesactivarUsuario(pantalla.usuarios[0])
        compare(requestLog[0].method, "PATCH")
        compare(requestLog[0].endpoint, "/usuarios/3/activar")
        tryCompare(pantalla, "usuarios[0].activo", true)

        requestLog = []
        stubResponses = [
            { success: true, data: null },
            { success: true, data: [{ id: 3, username: "des", nombre: "Desactivado", rol: "GERENTE", activo: false }] }
        ]

        pantalla.activarDesactivarUsuario({ id: 3, username: "des", nombre: "Desactivado", rol: "GERENTE", activo: true })
        compare(requestLog[0].endpoint, "/usuarios/3/desactivar")
        tryCompare(pantalla, "usuarios[0].activo", false)
    }

    function test_rbac_botones() {
        permisoFlags = { "usuarios:ver": true, "usuarios:crear": false, "usuarios:editar": false }
        pantalla.puedeCrear = GestorAuth.tienePermiso("usuarios", "crear")
        pantalla.puedeEditar = GestorAuth.tienePermiso("usuarios", "editar")

        var botonNuevo = findObjectWithText(pantalla, "Nuevo Usuario")
        verify(botonNuevo !== null)
        compare(botonNuevo.enabled, false)

        pantalla.usuarios = [{ id: 1, username: "uno", nombre: "Primero", rol: "ADMIN", activo: true }]
        var listView = prepareListView()
        verify(listView !== null)
        var delegate = listView.itemAtIndex(0)
        verify(delegate !== null)
        var botonEditar = findObjectWithText(delegate, "Editar")
        var botonToggle = findObjectWithText(delegate, "Desactivar")
        compare(botonEditar.enabled, false)
        compare(botonToggle.enabled, false)

        permisoFlags = { "usuarios:ver": true, "usuarios:crear": true, "usuarios:editar": true }
        pantalla.puedeCrear = GestorAuth.tienePermiso("usuarios", "crear")
        pantalla.puedeEditar = GestorAuth.tienePermiso("usuarios", "editar")
        compare(botonNuevo.enabled, true)
        compare(botonEditar.enabled, true)
        compare(botonToggle.enabled, true)
    }

    function test_logout_limpia_estado() {
        pantalla.usuarios = [{ id: 1, username: "u", nombre: "U", rol: "ADMIN", activo: true }]
        pantalla.modalVisible = true
        GestorAuth.token = "token"
        GestorAuth.token = ""

        tryCompare(pantalla, "usuarios.length", 0)
        compare(pantalla.modalVisible, false)
        compare(pantalla.usuarioActual.id, null)
        compare(pantalla.usuarioActual.username, "")
    }
}
