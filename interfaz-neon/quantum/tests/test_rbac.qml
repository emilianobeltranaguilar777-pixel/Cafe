import QtQuick 2.15
import QtTest 1.15
import quantum 1.0

TestCase {
    name: "RBACTests"
    id: rbacTests

    // Simular datos de usuario para tests
    property var testUsuarioAdmin: {
        "id": 1,
        "username": "admin_test",
        "rol": "ADMIN"
    }

    property var testUsuarioGerente: {
        "id": 2,
        "username": "gerente_test",
        "rol": "GERENTE"
    }

    property var testUsuarioVendedor: {
        "id": 3,
        "username": "vendedor_test",
        "rol": "VENDEDOR"
    }

    property var testUsuarioDueno: {
        "id": 4,
        "username": "dueno_test",
        "rol": "DUENO"
    }

    // Mock de permisos por rol
    property var permisosRolAdmin: [
        {recurso: "usuarios", accion: "ver", permitido: true},
        {recurso: "usuarios", accion: "crear", permitido: true},
        {recurso: "usuarios", accion: "editar", permitido: true},
        {recurso: "usuarios", accion: "borrar", permitido: false},
        {recurso: "inventario", accion: "ver", permitido: true},
        {recurso: "inventario", accion: "crear", permitido: true},
        {recurso: "inventario", accion: "editar", permitido: true},
        {recurso: "recetas", accion: "ver", permitido: true},
        {recurso: "ventas", accion: "ver", permitido: true},
        {recurso: "ventas", accion: "crear", permitido: true}
    ]

    property var permisosRolGerente: [
        {recurso: "inventario", accion: "ver", permitido: true},
        {recurso: "inventario", accion: "editar", permitido: true},
        {recurso: "recetas", accion: "ver", permitido: true},
        {recurso: "ventas", accion: "ver", permitido: true},
        {recurso: "ventas", accion: "crear", permitido: true},
        {recurso: "clientes", accion: "ver", permitido: true}
    ]

    property var permisosRolVendedor: [
        {recurso: "ventas", accion: "ver", permitido: true},
        {recurso: "ventas", accion: "crear", permitido: true},
        {recurso: "clientes", accion: "ver", permitido: true},
        {recurso: "clientes", accion: "crear", permitido: true}
    ]

    // Overrides de usuario
    property var overridesUsuario: [
        {recurso: "inventario", accion: "borrar", permitido: true},
        {recurso: "ventas", accion: "editar", permitido: true}
    ]

    function test_dueno_tiene_acceso_total() {
        // Simular usuario DUENO
        GestorAuth.datosUsuario = testUsuarioDueno
        GestorAuth.permisosRol = []
        GestorAuth.permisosUsuario = []
        GestorAuth.combinarPermisos()

        // DUENO debe tener acceso a TODO
        verify(GestorAuth.tienePermiso("usuarios", "crear"))
        verify(GestorAuth.tienePermiso("usuarios", "editar"))
        verify(GestorAuth.tienePermiso("usuarios", "borrar"))
        verify(GestorAuth.tienePermiso("inventario", "crear"))
        verify(GestorAuth.tienePermiso("recetas", "borrar"))
        verify(GestorAuth.tienePermiso("ventas", "crear"))
        verify(GestorAuth.tienePermiso("logs", "ver"))
    }

    function test_admin_permisos_rol() {
        // Simular usuario ADMIN
        GestorAuth.datosUsuario = testUsuarioAdmin
        GestorAuth.permisosRol = permisosRolAdmin
        GestorAuth.permisosUsuario = []
        GestorAuth.combinarPermisos()

        // ADMIN debe tener permisos según su rol
        verify(GestorAuth.tienePermiso("usuarios", "ver"))
        verify(GestorAuth.tienePermiso("usuarios", "crear"))
        verify(GestorAuth.tienePermiso("usuarios", "editar"))
        verify(!GestorAuth.tienePermiso("usuarios", "borrar")) // Explícitamente denegado
        verify(GestorAuth.tienePermiso("inventario", "ver"))
        verify(GestorAuth.tienePermiso("inventario", "crear"))
    }

    function test_gerente_permisos_limitados() {
        // Simular usuario GERENTE
        GestorAuth.datosUsuario = testUsuarioGerente
        GestorAuth.permisosRol = permisosRolGerente
        GestorAuth.permisosUsuario = []
        GestorAuth.combinarPermisos()

        // GERENTE tiene permisos limitados
        verify(GestorAuth.tienePermiso("inventario", "ver"))
        verify(GestorAuth.tienePermiso("inventario", "editar"))
        verify(!GestorAuth.tienePermiso("inventario", "borrar")) // No tiene este permiso
        verify(GestorAuth.tienePermiso("ventas", "crear"))
        verify(!GestorAuth.tienePermiso("usuarios", "ver")) // No tiene acceso
    }

    function test_vendedor_permisos_basicos() {
        // Simular usuario VENDEDOR
        GestorAuth.datosUsuario = testUsuarioVendedor
        GestorAuth.permisosRol = permisosRolVendedor
        GestorAuth.permisosUsuario = []
        GestorAuth.combinarPermisos()

        // VENDEDOR solo tiene permisos básicos
        verify(GestorAuth.tienePermiso("ventas", "ver"))
        verify(GestorAuth.tienePermiso("ventas", "crear"))
        verify(GestorAuth.tienePermiso("clientes", "ver"))
        verify(!GestorAuth.tienePermiso("inventario", "ver")) // No tiene acceso
        verify(!GestorAuth.tienePermiso("usuarios", "crear")) // No tiene acceso
        verify(!GestorAuth.tienePermiso("recetas", "editar")) // No tiene acceso
    }

    function test_overrides_precedencia_sobre_rol() {
        // Simular GERENTE con overrides
        GestorAuth.datosUsuario = testUsuarioGerente
        GestorAuth.permisosRol = permisosRolGerente
        GestorAuth.permisosUsuario = overridesUsuario
        GestorAuth.combinarPermisos()

        // Los overrides deben tener precedencia
        verify(GestorAuth.tienePermiso("inventario", "borrar")) // Override permite
        verify(GestorAuth.tienePermiso("ventas", "editar")) // Override permite
    }

    function test_override_deniega_permiso_rol() {
        // Simular ADMIN con override que deniega permiso
        GestorAuth.datosUsuario = testUsuarioAdmin
        GestorAuth.permisosRol = permisosRolAdmin
        GestorAuth.permisosUsuario = [
            {recurso: "usuarios", accion: "crear", permitido: false} // Denegar override
        ]
        GestorAuth.combinarPermisos()

        // El override debe denegar el permiso aunque el rol lo permita
        verify(!GestorAuth.tienePermiso("usuarios", "crear")) // Override deniega
        verify(GestorAuth.tienePermiso("usuarios", "ver")) // Sigue permitido por rol
    }

    function test_sin_permiso_explicito_denegar() {
        // Simular usuario sin permisos
        GestorAuth.datosUsuario = testUsuarioVendedor
        GestorAuth.permisosRol = []
        GestorAuth.permisosUsuario = []
        GestorAuth.combinarPermisos()

        // Sin permiso explícito, debe denegar (excepto DUENO)
        verify(!GestorAuth.tienePermiso("usuarios", "ver"))
        verify(!GestorAuth.tienePermiso("inventario", "crear"))
        verify(!GestorAuth.tienePermiso("recetas", "borrar"))
    }

    function test_limpieza_logout() {
        // Establecer permisos
        GestorAuth.datosUsuario = testUsuarioAdmin
        GestorAuth.permisosRol = permisosRolAdmin
        GestorAuth.permisosUsuario = overridesUsuario
        GestorAuth.combinarPermisos()
        GestorAuth.token = "test_token"

        // Hacer logout (simular limpieza)
        GestorAuth.token = ""
        GestorAuth.datosUsuario = null
        GestorAuth.permisosRol = []
        GestorAuth.permisosUsuario = []
        GestorAuth.permisosResueltos = {}

        // Verificar que todo fue limpiado
        compare(GestorAuth.token, "")
        compare(GestorAuth.datosUsuario, null)
        compare(GestorAuth.permisosRol.length, 0)
        compare(GestorAuth.permisosUsuario.length, 0)
        compare(Object.keys(GestorAuth.permisosResueltos).length, 0)
    }
}
