import QtQuick 2.15
import QtTest 1.15
import quantum 1.0

TestCase {
    name: "PantallaUsuariosExtraTests"

    property var originalRequest
    property var window

    function init() {
        originalRequest = GestorAuth.request
        GestorAuth.datosUsuario = {rol: "ADMIN"}
        GestorAuth.permisosResueltos = {}
    }

    function cleanup() {
        GestorAuth.request = originalRequest
        GestorAuth.datosUsuario = null
        GestorAuth.permisosResueltos = {}
        if (window)
            window.destroy()
        window = null
    }

    function crearPantalla(mockRequest) {
        if (mockRequest)
            GestorAuth.request = mockRequest

        var component = Qt.createComponent("../pantallas/pantalla_usuarios.qml")
        window = component.createObject(null, {width: 900, height: 700})
        return window
    }

    function test_carga_lista_completa() {
        var llamada
        var pantalla = crearPantalla(function(method, endpoint, data, cb) {
            llamada = {method: method, endpoint: endpoint}
            cb(true, [
                {id: 1, username: "uno", nombre: "Uno", rol: "ADMIN", activo: true},
                {id: 2, username: "dos", nombre: "Dos", rol: "VENDEDOR", activo: false}
            ])
        })

        pantalla.cargarUsuarios()
        compare(llamada.endpoint, "/usuarios/")
        compare(pantalla.usuarios.length, 2)
        pantalla.destroy()
    }

    function test_get_usuario_rellena_modal() {
        var llamada
        var pantalla = crearPantalla(function(method, endpoint, data, cb) {
            llamada = {method: method, endpoint: endpoint}
            if (endpoint === "/usuarios/5")
                cb(true, {id: 5, username: "cinco", nombre: "Cinco", rol: "GERENTE", activo: true})
            else
                cb(true, [])
        })

        pantalla.abrirModalEditar({id: 5, username: "", nombre: "", rol: ""})
        compare(llamada.endpoint, "/usuarios/5")
        compare(pantalla.formUsername, "cinco")
        compare(pantalla.formRol, "GERENTE")
        pantalla.destroy()
    }

    function test_put_usuario_envia_campos() {
        var llamada
        var pantalla = crearPantalla(function(method, endpoint, data, cb) {
            llamada = {method: method, endpoint: endpoint, data: data}
            cb(true, {})
        })

        pantalla.abrirModalEditar({id: 7, username: "viejo", nombre: "Viejo", rol: "VENDEDOR", activo: true})
        pantalla.formNombre = "Nuevo Nombre"
        pantalla.formUsername = "nuevo" // se puede editar
        pantalla.formRol = "ADMIN"
        pantalla.guardarUsuario()

        compare(llamada.method, "PUT")
        compare(llamada.endpoint, "/usuarios/7")
        compare(llamada.data.username, "nuevo")
        compare(llamada.data.nombre, "Nuevo Nombre")
        pantalla.destroy()
    }

    function test_parches_estado() {
        var llamadas = []
        var pantalla = crearPantalla(function(method, endpoint, data, cb) {
            llamadas.push({method: method, endpoint: endpoint})
            cb(true, {})
        })

        pantalla.alternarEstado({id: 3, activo: false})
        pantalla.alternarEstado({id: 4, activo: true})

        compare(llamadas[0].endpoint, "/usuarios/3/activar")
        compare(llamadas[1].endpoint, "/usuarios/4/desactivar")
        pantalla.destroy()
    }

    function test_rbac_admin_vs_vendedor() {
        var pantalla = crearPantalla(function(method, endpoint, data, cb) { cb(true, []) })
        compare(pantalla.btnNuevo.enabled, true)
        pantalla.destroy()

        GestorAuth.datosUsuario = {rol: "VENDEDOR"}
        GestorAuth.permisosResueltos = {}
        pantalla = crearPantalla(function(method, endpoint, data, cb) { cb(true, []) })
        pantalla.listaUsuarios.model = [{id: 1, username: "demo", nombre: "Demo", rol: "VENDEDOR", activo: true}]
        pantalla.listaUsuarios.forceLayout()
        var fila = pantalla.listaUsuarios.itemAtIndex(0)
        compare(fila.btnEditar.enabled, false)
        pantalla.destroy()
    }
}
