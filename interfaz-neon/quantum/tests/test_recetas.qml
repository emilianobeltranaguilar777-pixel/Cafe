import QtQuick 2.15
import QtTest 1.15
import quantum 1.0

TestCase {
    name: "PantallaRecetasTests"

    property var window
    property var originalPermiso

    function init() {
        originalPermiso = GestorAuth.tienePermiso
        GestorAuth.datosUsuario = {rol: "ADMIN"}
        GestorAuth.permisosResueltos = {}
        GestorAuth.tienePermiso = function(recurso, accion) { return true }
    }

    function cleanup() {
        GestorAuth.tienePermiso = originalPermiso
        GestorAuth.datosUsuario = null
        GestorAuth.permisosResueltos = {}
        if (window)
            window.destroy()
        window = null
    }

    function crearPantalla(mockApi) {
        var component = Qt.createComponent("../main.qml")
        window = component.createObject(null, {width: 1200, height: 800, visible: false})
        window.pantallaActual = "recetas"

        if (mockApi) {
            if (mockApi.get)
                window.api.get = mockApi.get
            if (mockApi.post)
                window.api.post = mockApi.post
            if (mockApi.put)
                window.api.put = mockApi.put
        }

        wait(50)
        return window.loaderPantallas.item
    }

    function test_carga_recetas_e_ingredientes() {
        var llamadas = []
        var pantalla = crearPantalla({
            get: function(endpoint, cb) {
                llamadas.push(endpoint)
                if (endpoint.indexOf("/recetas/") === 0)
                    cb(true, [{id: 1, nombre: "Latte", margen: 0.3, items: []}])
                else if (endpoint.indexOf("/ingredientes/") === 0)
                    cb(true, [{id: 1, nombre: "Leche", stock: 5, min_stock: 1}])
            }
        })

        pantalla.cargarRecetas()
        pantalla.cargarIngredientesReceta()
        compare(pantalla.recetas.length, 1, "Debe cargar recetas")
        compare(pantalla.ingredientesDisponibles.length, 1, "Debe cargar ingredientes")
        verify(llamadasIncluye(llamadas, "/recetas/"))
        verify(llamadasIncluye(llamadas, "/ingredientes/"))
        pantalla.destroy()
    }

    function llamadasIncluye(arr, texto) {
        for (var i=0; i<arr.length; i++) {
            if (arr[i].indexOf(texto) === 0)
                return true
        }
        return false
    }

    function test_agregar_ingrediente_actualiza_modelo() {
        var pantalla = crearPantalla({ get: function(endpoint, cb) { cb(true, []) } })
        pantalla.ingredientesDisponibles = [
            {id: 1, nombre: "Leche", stock: 10, min_stock: 1, unidad: "ml"}
        ]
        pantalla.comboIngrediente.currentIndex = 0
        pantalla.inputCantidadIngrediente.text = "50"
        pantalla.agregarIngredienteReceta()

        compare(pantalla.itemsSeleccionados.length, 1)
        compare(pantalla.itemsSeleccionados[0].cantidad, 50)
        pantalla.destroy()
    }

    function test_crear_receta_post() {
        var payload
        var pantalla = crearPantalla({
            get: function(endpoint, cb) { cb(true, []) },
            post: function(endpoint, data, cb) { payload = {endpoint: endpoint, data: data}; cb(true, {id: 9}) }
        })

        pantalla.itemsSeleccionados = [{ingrediente_id: 1, cantidad: 20, merma: 0}]
        pantalla.inputNombreReceta.text = "Nueva"
        pantalla.inputMargenReceta.text = "0.5"
        pantalla.enviarReceta()

        compare(payload.endpoint, "/recetas/")
        compare(payload.data.items.length, 1)
        compare(payload.data.margen, 0.5)
        pantalla.destroy()
    }

    function test_editar_receta_put_envia_lista_completa() {
        var payload
        var pantalla = crearPantalla({
            get: function(endpoint, cb) { cb(true, {id: 7, nombre: "Edit", margen: 0.2, items: []}) },
            put: function(endpoint, data, cb) { payload = {endpoint: endpoint, data: data}; cb(true, {id: 7}) }
        })

        pantalla.recetaEditando = 7
        pantalla.itemsSeleccionados = [
            {ingrediente_id: 1, cantidad: 30, merma: 0.1},
            {ingrediente_id: 2, cantidad: 10, merma: 0}
        ]
        pantalla.inputNombreReceta.text = "Editada"
        pantalla.inputMargenReceta.text = "0.4"
        pantalla.enviarReceta()

        compare(payload.endpoint, "/recetas/7")
        compare(payload.data.items.length, 2)
        compare(payload.data.nombre, "Editada")
        pantalla.destroy()
    }

    function test_rbac_admin_vs_vendedor() {
        // Admin puede crear
        var pantalla = crearPantalla({ get: function(endpoint, cb) { cb(true, []) } })
        compare(pantalla.btnNuevaReceta.enabled, true)
        pantalla.destroy()

        // Vendedor bloqueado
        GestorAuth.datosUsuario = {rol: "VENDEDOR"}
        GestorAuth.permisosResueltos = {}
        GestorAuth.tienePermiso = originalPermiso

        pantalla = crearPantalla({ get: function(endpoint, cb) { cb(true, []) } })
        compare(pantalla.btnNuevaReceta.enabled, false)
        pantalla.destroy()
    }
}
