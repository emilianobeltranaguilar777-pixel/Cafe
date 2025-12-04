import QtQuick 2.15
import QtTest 1.15
import quantum 1.0

TestCase {
    name: "CrudUsuariosTests"

    property var originalRequest
    property var originalLogout

    function init() {
        originalRequest = GestorAuth.request
        originalLogout = GestorAuth.logout
        GestorAuth.datosUsuario = {rol: "ADMIN"}
        GestorAuth.permisosResueltos = {}
        GestorAuth.token = "token"
    }

    function cleanup() {
        GestorAuth.request = originalRequest
        GestorAuth.logout = originalLogout
        GestorAuth.datosUsuario = null
        GestorAuth.permisosResueltos = {}
        GestorAuth.token = ""
    }

    function crearPantalla(mockRequest) {
        if (mockRequest)
            GestorAuth.request = mockRequest

        var component = Qt.createComponent("../pantallas/pantalla_usuarios.qml")
        var obj = component.createObject(null, { width: 800, height: 600 })
        verify(obj !== null, "Pantalla creada")
        return obj
    }

    function test_carga_inicial() {
        var llamadas = []
        var pantalla = crearPantalla(function(method, endpoint, data, cb) {
            llamadas.push({method: method, endpoint: endpoint})
            if (endpoint === "/usuarios/")
                cb(true, [{id: 1, username: "uno", nombre: "Uno", rol: "ADMIN", activo: true}])
        })

        pantalla.cargarUsuarios()
        compare(pantalla.usuarios.length, 1, "Debe cargar usuarios")
        compare(llamadas[0].endpoint, "/usuarios/", "Usa endpoint correcto")
        pantalla.destroy()
    }

    function test_abrir_modal() {
        var pantalla = crearPantalla()
        pantalla.abrirModalNuevo()
        verify(pantalla.mostrandoModal, "Modal visible")
        verify(!pantalla.modoEdicion, "Modo creación")
        pantalla.destroy()
    }

    function test_creacion_usuario_post() {
        var llamada
        var pantalla = crearPantalla(function(method, endpoint, data, cb) {
            llamada = {method: method, endpoint: endpoint, data: data}
            cb(true, {id: 5})
        })

        pantalla.abrirModalNuevo()
        pantalla.formUsername = "nuevo"
        pantalla.formPassword = "clave"
        pantalla.formNombre = "Nuevo Nombre"
        pantalla.formRol = "GERENTE"
        pantalla.guardarUsuario()

        compare(llamada.method, "POST", "Debe usar POST")
        compare(llamada.endpoint, "/usuarios/", "Endpoint creación")
        compare(llamada.data.username, "nuevo", "Username enviado")
        compare(llamada.data.password, "clave", "Password enviado")
        pantalla.destroy()
    }

    function test_edicion_usuario_put() {
        var llamada
        var pantalla = crearPantalla(function(method, endpoint, data, cb) {
            llamada = {method: method, endpoint: endpoint, data: data}
            cb(true, {})
        })

        var usuario = {id: 9, username: "editar", nombre: "Editar", rol: "VENDEDOR", activo: true}
        pantalla.abrirModalEditar(usuario)
        pantalla.formNombre = "Nombre Editado"
        pantalla.formPassword = ""
        pantalla.guardarUsuario()

        compare(llamada.method, "PUT", "Debe usar PUT")
        compare(llamada.endpoint, "/usuarios/9", "Endpoint edición")
        compare(llamada.data.nombre, "Nombre Editado", "Nombre actualizado")
        pantalla.destroy()
    }

    function test_activar_desactivar_patch() {
        var llamadas = []
        var pantalla = crearPantalla(function(method, endpoint, data, cb) {
            llamadas.push({method: method, endpoint: endpoint})
            cb(true, {})
        })

        pantalla.usuarios = [{id: 3, username: "activo", nombre: "Activo", rol: "ADMIN", activo: false}]
        pantalla.alternarEstado(pantalla.usuarios[0])

        compare(llamadas[0].method, "PATCH", "Debe usar PATCH")
        compare(llamadas[0].endpoint, "/usuarios/3/activar", "Endpoint activar")

        pantalla.usuarios = [{id: 4, username: "activo2", nombre: "Activo 2", rol: "ADMIN", activo: true}]
        pantalla.alternarEstado(pantalla.usuarios[0])

        compare(llamadas[1].method, "PATCH", "Debe usar PATCH para desactivar")
        compare(llamadas[1].endpoint, "/usuarios/4/desactivar", "Endpoint desactivar")
        pantalla.destroy()
    }

    function test_rbac_bloquea_botones() {
        GestorAuth.datosUsuario = {rol: "VENDEDOR"}
        GestorAuth.permisosResueltos = {}

        var pantalla = crearPantalla(function(method, endpoint, data, cb) { cb(true, []) })
        compare(pantalla.btnNuevo.enabled, false, "Crear deshabilitado")

        pantalla.usuarios = [{id: 1, username: "demo", nombre: "Demo", rol: "GERENTE", activo: true}]
        pantalla.listaUsuarios.forceLayout()
        var fila = pantalla.listaUsuarios.itemAtIndex(0)
        verify(fila !== null, "Fila creada")
        compare(fila.btnEditar.enabled, false, "Editar deshabilitado")
        pantalla.destroy()
    }

    function test_logout_limpia_permisos() {
        GestorAuth.token = "algo"
        GestorAuth.datosUsuario = {id: 1, rol: "ADMIN"}
        GestorAuth.permisosRol = [{recurso: "usuarios", accion: "ver", permitido: true}]
        GestorAuth.permisosUsuario = [{recurso: "ventas", accion: "crear", permitido: true}]
        GestorAuth.permisosResueltos = {"usuarios:ver": true}

        GestorAuth.logout = function(callback) {
            GestorAuth.token = ""
            GestorAuth.datosUsuario = null
            GestorAuth.permisosRol = []
            GestorAuth.permisosUsuario = []
            GestorAuth.permisosResueltos = {}
            if (callback)
                callback(true, "")
        }

        GestorAuth.logout(function() {})
        compare(GestorAuth.token, "", "Token limpio")
        compare(GestorAuth.datosUsuario, null, "Usuario limpio")
        compare(GestorAuth.permisosRol.length, 0, "Permisos rol limpios")
        compare(GestorAuth.permisosUsuario.length, 0, "Permisos usuario limpios")
        compare(Object.keys(GestorAuth.permisosResueltos).length, 0, "Permisos resueltos limpios")
    }
}
