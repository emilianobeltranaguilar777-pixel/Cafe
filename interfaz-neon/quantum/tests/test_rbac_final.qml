import QtQuick 2.15
import QtTest 1.15
import quantum 1.0

TestCase {
    name: "RBACFinalTests"
    id: rbacFinalTests

    // Mock de datos de usuario
    property var mockUsuarioAdmin: {
        "id": 1,
        "username": "admin_test",
        "nombre": "Administrador Test",
        "rol": "ADMIN",
        "activo": true
    }

    property var mockUsuarioDueno: {
        "id": 2,
        "username": "dueno_test",
        "nombre": "Dueño Test",
        "rol": "DUENO",
        "activo": true
    }

    property var mockUsuarioGerente: {
        "id": 3,
        "username": "gerente_test",
        "nombre": "Gerente Test",
        "rol": "GERENTE",
        "activo": true
    }

    property var mockUsuarioVendedor: {
        "id": 4,
        "username": "vendedor_test",
        "nombre": "Vendedor Test",
        "rol": "VENDEDOR",
        "activo": true
    }

    // Mock de permisos del backend REAL
    property var permisosGerente: [
        {recurso: "inventario", accion: "ver", permitido: true},
        {recurso: "inventario", accion: "crear", permitido: false},
        {recurso: "inventario", accion: "editar", permitido: true},
        {recurso: "ventas", accion: "ver", permitido: true},
        {recurso: "ventas", accion: "crear", permitido: true},
        {recurso: "clientes", accion: "ver", permitido: true}
    ]

    property var permisosVendedor: [
        {recurso: "ventas", accion: "ver", permitido: true},
        {recurso: "ventas", accion: "crear", permitido: true},
        {recurso: "clientes", accion: "ver", permitido: true}
    ]

    function init() {
        // Limpiar estado antes de cada test
        GestorAuth.token = ""
        GestorAuth.datosUsuario = null
        GestorAuth.permisosRol = []
        GestorAuth.permisosUsuario = []
        GestorAuth.permisosResueltos = {}
        GestorAuth.cargandoPermisos = false
    }

    // ========================================
    // TESTS DE ACCESO TOTAL: ADMIN
    // ========================================

    function test_admin_tiene_acceso_total() {
        // Simular login como ADMIN
        GestorAuth.datosUsuario = mockUsuarioAdmin
        GestorAuth.token = "mock_token_admin"

        // ADMIN debe tener acceso a TODO sin necesidad de permisos
        verify(GestorAuth.tienePermiso("usuarios", "ver"), "ADMIN puede ver usuarios")
        verify(GestorAuth.tienePermiso("usuarios", "crear"), "ADMIN puede crear usuarios")
        verify(GestorAuth.tienePermiso("usuarios", "editar"), "ADMIN puede editar usuarios")
        verify(GestorAuth.tienePermiso("inventario", "ver"), "ADMIN puede ver inventario")
        verify(GestorAuth.tienePermiso("inventario", "crear"), "ADMIN puede crear inventario")
        verify(GestorAuth.tienePermiso("inventario", "editar"), "ADMIN puede editar inventario")
        verify(GestorAuth.tienePermiso("ventas", "ver"), "ADMIN puede ver ventas")
        verify(GestorAuth.tienePermiso("ventas", "crear"), "ADMIN puede crear ventas")
        verify(GestorAuth.tienePermiso("clientes", "ver"), "ADMIN puede ver clientes")
        verify(GestorAuth.tienePermiso("reportes", "ver"), "ADMIN puede ver reportes")

        // Incluso recursos que no existen
        verify(GestorAuth.tienePermiso("cualquier_cosa", "cualquier_accion"), "ADMIN tiene acceso a todo")
    }

    function test_dueno_tiene_acceso_total() {
        // Simular login como DUENO
        GestorAuth.datosUsuario = mockUsuarioDueno
        GestorAuth.token = "mock_token_dueno"

        // DUENO debe tener acceso a TODO
        verify(GestorAuth.tienePermiso("usuarios", "ver"), "DUENO puede ver usuarios")
        verify(GestorAuth.tienePermiso("usuarios", "crear"), "DUENO puede crear usuarios")
        verify(GestorAuth.tienePermiso("inventario", "editar"), "DUENO puede editar inventario")
        verify(GestorAuth.tienePermiso("ventas", "crear"), "DUENO puede crear ventas")
        verify(GestorAuth.tienePermiso("cualquier_recurso", "cualquier_accion"), "DUENO tiene acceso total")
    }

    // ========================================
    // TESTS DE PERMISOS LIMITADOS
    // ========================================

    function test_gerente_permisos_limitados() {
        // Simular login como GERENTE
        GestorAuth.datosUsuario = mockUsuarioGerente
        GestorAuth.token = "mock_token_gerente"
        GestorAuth.permisosRol = permisosGerente
        GestorAuth.permisosUsuario = []
        GestorAuth.combinarPermisos()

        // Verificar permisos permitidos
        verify(GestorAuth.tienePermiso("inventario", "ver"), "GERENTE puede ver inventario")
        verify(GestorAuth.tienePermiso("inventario", "editar"), "GERENTE puede editar inventario")
        verify(GestorAuth.tienePermiso("ventas", "ver"), "GERENTE puede ver ventas")
        verify(GestorAuth.tienePermiso("ventas", "crear"), "GERENTE puede crear ventas")
        verify(GestorAuth.tienePermiso("clientes", "ver"), "GERENTE puede ver clientes")

        // Verificar permisos denegados
        verify(!GestorAuth.tienePermiso("inventario", "crear"), "GERENTE NO puede crear inventario")
        verify(!GestorAuth.tienePermiso("usuarios", "ver"), "GERENTE NO puede ver usuarios")
        verify(!GestorAuth.tienePermiso("usuarios", "crear"), "GERENTE NO puede crear usuarios")
    }

    function test_vendedor_permisos_minimos() {
        // Simular login como VENDEDOR
        GestorAuth.datosUsuario = mockUsuarioVendedor
        GestorAuth.token = "mock_token_vendedor"
        GestorAuth.permisosRol = permisosVendedor
        GestorAuth.permisosUsuario = []
        GestorAuth.combinarPermisos()

        // Verificar permisos permitidos (solo ventas y clientes)
        verify(GestorAuth.tienePermiso("ventas", "ver"), "VENDEDOR puede ver ventas")
        verify(GestorAuth.tienePermiso("ventas", "crear"), "VENDEDOR puede crear ventas")
        verify(GestorAuth.tienePermiso("clientes", "ver"), "VENDEDOR puede ver clientes")

        // Verificar permisos denegados (todo lo demás)
        verify(!GestorAuth.tienePermiso("inventario", "ver"), "VENDEDOR NO puede ver inventario")
        verify(!GestorAuth.tienePermiso("inventario", "crear"), "VENDEDOR NO puede crear inventario")
        verify(!GestorAuth.tienePermiso("usuarios", "ver"), "VENDEDOR NO puede ver usuarios")
        verify(!GestorAuth.tienePermiso("reportes", "ver"), "VENDEDOR NO puede ver reportes")
    }

    // ========================================
    // TESTS DE OVERRIDES (PERMISOS INDIVIDUALES)
    // ========================================

    function test_override_usuario_permite_accion_denegada() {
        // GERENTE normalmente NO puede crear inventario
        GestorAuth.datosUsuario = mockUsuarioGerente
        GestorAuth.token = "mock_token_gerente"
        GestorAuth.permisosRol = permisosGerente

        // Pero este usuario tiene un override que lo permite
        GestorAuth.permisosUsuario = [
            {recurso: "inventario", accion: "crear", permitido: true}
        ]
        GestorAuth.combinarPermisos()

        // Ahora SÍ puede crear inventario
        verify(GestorAuth.tienePermiso("inventario", "crear"), "Override permite crear inventario")

        // Los otros permisos siguen igual
        verify(GestorAuth.tienePermiso("inventario", "ver"), "Sigue pudiendo ver inventario")
        verify(GestorAuth.tienePermiso("ventas", "crear"), "Sigue pudiendo crear ventas")
    }

    function test_override_usuario_deniega_accion_permitida() {
        // GERENTE normalmente SÍ puede ver ventas
        GestorAuth.datosUsuario = mockUsuarioGerente
        GestorAuth.token = "mock_token_gerente"
        GestorAuth.permisosRol = permisosGerente

        // Pero este usuario tiene un override que lo deniega
        GestorAuth.permisosUsuario = [
            {recurso: "ventas", accion: "ver", permitido: false}
        ]
        GestorAuth.combinarPermisos()

        // Ahora NO puede ver ventas
        verify(!GestorAuth.tienePermiso("ventas", "ver"), "Override deniega ver ventas")

        // Pero sigue pudiendo crear ventas (no se sobrescribió)
        verify(GestorAuth.tienePermiso("ventas", "crear"), "Sigue pudiendo crear ventas")
    }

    // ========================================
    // TESTS DE CASOS EDGE
    // ========================================

    function test_sin_login_sin_permisos() {
        // Sin login, no debe tener permisos
        GestorAuth.datosUsuario = null
        GestorAuth.token = ""

        verify(!GestorAuth.tienePermiso("usuarios", "ver"), "Sin login no puede ver usuarios")
        verify(!GestorAuth.tienePermiso("ventas", "crear"), "Sin login no puede crear ventas")
        verify(!GestorAuth.tienePermiso("cualquier_cosa", "cualquier_accion"), "Sin login sin acceso")
    }

    function test_permiso_inexistente_deniega() {
        // Usuario con permisos limitados
        GestorAuth.datosUsuario = mockUsuarioVendedor
        GestorAuth.token = "mock_token_vendedor"
        GestorAuth.permisosRol = permisosVendedor
        GestorAuth.permisosUsuario = []
        GestorAuth.combinarPermisos()

        // Si no existe el permiso, debe denegar
        verify(!GestorAuth.tienePermiso("recurso_no_existente", "accion_no_existente"), "Permiso inexistente se deniega")
    }

    function test_limpieza_logout() {
        // Establecer estado con permisos
        GestorAuth.datosUsuario = mockUsuarioAdmin
        GestorAuth.token = "mock_token_admin"
        GestorAuth.permisosRol = permisosGerente
        GestorAuth.permisosUsuario = [{recurso: "test", accion: "test", permitido: true}]
        GestorAuth.combinarPermisos()

        // Simular logout manual
        GestorAuth.token = ""
        GestorAuth.datosUsuario = null
        GestorAuth.permisosRol = []
        GestorAuth.permisosUsuario = []
        GestorAuth.permisosResueltos = {}
        GestorAuth.cargandoPermisos = false

        // Verificar que todo se limpió
        compare(GestorAuth.token, "", "Token limpiado")
        compare(GestorAuth.datosUsuario, null, "datosUsuario limpiado")
        compare(GestorAuth.permisosRol.length, 0, "permisosRol limpiado")
        compare(GestorAuth.permisosUsuario.length, 0, "permisosUsuario limpiado")
        compare(Object.keys(GestorAuth.permisosResueltos).length, 0, "permisosResueltos limpiado")
        verify(!GestorAuth.tienePermiso("usuarios", "ver"), "Sin permisos después de logout")
    }

    // ========================================
    // TESTS DE COMBINACIÓN DE PERMISOS
    // ========================================

    function test_combinacion_permisos_precedencia_usuario() {
        GestorAuth.datosUsuario = mockUsuarioGerente
        GestorAuth.token = "mock_token"

        // Permisos del rol
        GestorAuth.permisosRol = [
            {recurso: "ventas", accion: "ver", permitido: true},
            {recurso: "ventas", accion: "crear", permitido: true}
        ]

        // Permisos del usuario (override)
        GestorAuth.permisosUsuario = [
            {recurso: "ventas", accion: "ver", permitido: false}  // Sobrescribe a TRUE del rol
        ]

        GestorAuth.combinarPermisos()

        // El permiso del usuario debe tener precedencia
        verify(!GestorAuth.tienePermiso("ventas", "ver"), "Override usuario deniega (precedencia sobre rol)")
        verify(GestorAuth.tienePermiso("ventas", "crear"), "Permiso rol sigue válido si no hay override")
    }

    // ========================================
    // TEST DE ESTADO INICIAL
    // ========================================

    function test_estado_inicial_correcto() {
        // Verificar estado inicial de GestorAuth
        compare(GestorAuth.token, "", "Token inicial vacío")
        compare(GestorAuth.datosUsuario, null, "datosUsuario inicial null")
        compare(GestorAuth.estaAutenticado, false, "No autenticado inicialmente")
        verify(Array.isArray(GestorAuth.permisosRol), "permisosRol es array")
        verify(Array.isArray(GestorAuth.permisosUsuario), "permisosUsuario es array")
        compare(GestorAuth.cargandoPermisos, false, "No cargando inicialmente")
    }
}
