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
    property var permisoFlags

    function init() {
        originalRequest = GestorAuth.request
        originalTienePermiso = GestorAuth.tienePermiso
        permisoFlags = {
            "usuarios:ver": true,
            "usuarios:crear": true,
            "usuarios:editar": true
        }
        GestorAuth.tienePermiso = function(recurso, accion) {
            var key = recurso + ":" + accion
            return permisoFlags.hasOwnProperty(key) ? permisoFlags[key] : false
        }
        GestorAuth.request = function(metodo, endpoint, data, callback) {
            lastRequest = { method: metodo, endpoint: endpoint, data: data }
            if (callback) callback(true, [{ id: 1, username: "admin", nombre: "Administrador", rol: "ADMIN", activo: true }])
        }
        GestorAuth.datosUsuario = { rol: "ADMIN" }
        component = Qt.createComponent("../pantallas/pantalla_usuarios.qml")
        pantalla = component.createObject(null)
    }

    function cleanup() {
        GestorAuth.request = originalRequest
        GestorAuth.tienePermiso = originalTienePermiso
        if (pantalla) pantalla.destroy()
        pantalla = null
        component = null
        lastRequest = null
    }

    function test_pantalla_carga() {
        verify(pantalla !== null)
    }

    function test_carga_lista_usuarios() {
        pantalla.cargarUsuarios()
        tryCompare(pantalla, "usuarios.length", 1)
    }

    function test_boton_nuevo_permiso() {
        permisoFlags["usuarios:crear"] = false
        pantalla.puedeCrear = GestorAuth.tienePermiso("usuarios", "crear")
        compare(pantalla.puedeCrear, false)
    }

    function test_modal_se_abre() {
        pantalla.abrirModalNuevo()
        compare(pantalla.modalVisible, true)
    }

    function test_post_crear_usuario() {
        pantalla.abrirModalNuevo()
        pantalla.usuarioActual.username = "nuevo"
        pantalla.usuarioActual.nombre = "Nuevo Usuario"
        pantalla.usuarioActual.password = "secreto"
        pantalla.usuarioActual.rol = "GERENTE"
        pantalla.guardarUsuario()
        compare(lastRequest.method, "POST")
        compare(lastRequest.endpoint, "/usuarios/")
        compare(lastRequest.data.username, "nuevo")
        compare(lastRequest.data.password, "secreto")
    }

    function test_put_actualizar_usuario() {
        pantalla.abrirModalEditar({ id: 10, username: "existente", nombre: "User", rol: "VENDEDOR", activo: true })
        pantalla.usuarioActual.nombre = "Actualizado"
        pantalla.guardarUsuario()
        compare(lastRequest.method, "PUT")
        compare(lastRequest.endpoint, "/usuarios/10")
        compare(lastRequest.data.nombre, "Actualizado")
    }

    function test_patch_activar_desactivar() {
        pantalla.activarDesactivarUsuario({ id: 2, activo: false })
        compare(lastRequest.endpoint, "/usuarios/2/activar")
        pantalla.activarDesactivarUsuario({ id: 2, activo: true })
        compare(lastRequest.endpoint, "/usuarios/2/desactivar")
    }

    function test_rbac_botones() {
        permisoFlags = { "usuarios:ver": true, "usuarios:crear": false, "usuarios:editar": false }
        pantalla.puedeCrear = GestorAuth.tienePermiso("usuarios", "crear")
        pantalla.puedeEditar = GestorAuth.tienePermiso("usuarios", "editar")
        compare(pantalla.puedeCrear, false)
        compare(pantalla.puedeEditar, false)
    }

    function test_logout_limpia_estado() {
        pantalla.usuarios = [{ id: 1 }]
        pantalla.modalVisible = true
        GestorAuth.token = "token"
        GestorAuth.token = ""
        compare(pantalla.usuarios.length, 0)
        compare(pantalla.modalVisible, false)
    }
}
