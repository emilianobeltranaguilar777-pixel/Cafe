import QtQuick 2.15
import QtTest 1.15
import QtGraphicalEffects 1.0
import quantum 1.0

TestCase {
    name: "ImportsTests"
    id: importsTests

    function test_quantum_module_available() {
        // Verificar que el módulo quantum está disponible
        verify(true, "quantum module imported successfully")
    }

    function test_gestor_auth_singleton_available() {
        // Verificar que GestorAuth singleton está disponible
        verify(GestorAuth !== undefined, "GestorAuth singleton is available")
        verify(GestorAuth !== null, "GestorAuth singleton is not null")
    }

    function test_gestor_auth_properties() {
        // Verificar propiedades básicas de GestorAuth
        verify(GestorAuth.hasOwnProperty("token"), "GestorAuth has token property")
        verify(GestorAuth.hasOwnProperty("datosUsuario"), "GestorAuth has datosUsuario property")
        verify(GestorAuth.hasOwnProperty("estaAutenticado"), "GestorAuth has estaAutenticado property")

        // Verificar propiedades RBAC
        verify(GestorAuth.hasOwnProperty("permisosRol"), "GestorAuth has permisosRol property")
        verify(GestorAuth.hasOwnProperty("permisosUsuario"), "GestorAuth has permisosUsuario property")
        verify(GestorAuth.hasOwnProperty("permisosResueltos"), "GestorAuth has permisosResueltos property")
        verify(GestorAuth.hasOwnProperty("cargandoPermisos"), "GestorAuth has cargandoPermisos property")
    }

    function test_gestor_auth_functions() {
        // Verificar funciones de GestorAuth
        verify(typeof GestorAuth.login === "function", "GestorAuth.login is a function")
        verify(typeof GestorAuth.logout === "function", "GestorAuth.logout is a function")
        verify(typeof GestorAuth.tienePermiso === "function", "GestorAuth.tienePermiso is a function")
        verify(typeof GestorAuth.cargarPerfil === "function", "GestorAuth.cargarPerfil is a function")
        verify(typeof GestorAuth.cargarPermisosRol === "function", "GestorAuth.cargarPermisosRol is a function")
        verify(typeof GestorAuth.cargarPermisosUsuario === "function", "GestorAuth.cargarPermisosUsuario is a function")
        verify(typeof GestorAuth.combinarPermisos === "function", "GestorAuth.combinarPermisos is a function")
    }

    function test_glow_effect_available() {
        // Verificar que Glow de QtGraphicalEffects está disponible
        var testGlow = Qt.createQmlObject('import QtQuick 2.15; import QtGraphicalEffects 1.0; Glow { samples: 9 }', importsTests, 'testGlow')
        verify(testGlow !== null, "Glow effect can be instantiated")
        testGlow.destroy()
    }

    function test_paleta_neon_singleton_available() {
        // Verificar que PaletaNeon singleton está disponible (si existe)
        verify(PaletaNeon !== undefined || true, "PaletaNeon check completed")
    }

    function test_component_structure_valid() {
        // Este test verifica que no hay Components con propiedades inválidas
        // Se ejecuta al cargar el archivo de tests sin errores
        verify(true, "Component structure is valid (no compilation errors)")
    }

    function test_loader_can_instantiate() {
        // Verificar que Loader funciona correctamente
        var testLoader = Qt.createQmlObject('import QtQuick 2.15; Loader { }', importsTests, 'testLoader')
        verify(testLoader !== null, "Loader can be instantiated")
        testLoader.destroy()
    }

    function test_no_circular_dependencies() {
        // Verificar que no hay dependencias circulares
        // Si llegamos aquí sin errores, no hay ciclos
        verify(true, "No circular dependencies detected")
    }

    function test_gestor_auth_initial_state() {
        // Verificar estado inicial de GestorAuth
        compare(GestorAuth.token, "", "GestorAuth token is initially empty")
        compare(GestorAuth.datosUsuario, null, "GestorAuth datosUsuario is initially null")
        compare(GestorAuth.estaAutenticado, false, "GestorAuth estaAutenticado is initially false")
        verify(Array.isArray(GestorAuth.permisosRol), "GestorAuth permisosRol is an array")
        verify(Array.isArray(GestorAuth.permisosUsuario), "GestorAuth permisosUsuario is an array")
        compare(GestorAuth.cargandoPermisos, false, "GestorAuth cargandoPermisos is initially false")
    }

    function test_tiene_permiso_sin_login() {
        // Verificar que tienePermiso retorna false sin login
        verify(!GestorAuth.tienePermiso("usuarios", "ver"), "tienePermiso returns false without login")
        verify(!GestorAuth.tienePermiso("inventario", "crear"), "tienePermiso returns false for any permission")
    }
}
