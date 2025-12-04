pragma Singleton
import QtQuick 2.15

QtObject {
    id: root
    
    // 🔐 Estado de autenticación
    property string token: ""
    property var datosUsuario: null
    property bool estaAutenticado: token !== ""

    // 🌐 URL del backend
    property string urlBackend: "http://localhost:8000"

    // 🎨 Tema
    property color colorPrimario: "#00ffff"
    property color colorSecundario: "#ff0080"

    // 🔑 RBAC - Permisos dinámicos
    property var permisosRol: []
    property var permisosUsuario: []
    property var permisosResueltos: ({})
    property bool cargandoPermisos: false
    
    // 📡 Función de login
    function login(username, password, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", urlBackend + "/auth/login")
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    token = response.access_token
                    cargarPerfil(callback)
                } else {
                    callback(false, "Credenciales incorrectas")
                }
            }
        }
        
        xhr.send("username=" + username + "&password=" + password)
    }
    
    // 👤 Cargar perfil del usuario
    function cargarPerfil(callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", urlBackend + "/auth/me")
        xhr.setRequestHeader("Authorization", "Bearer " + token)

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    datosUsuario = JSON.parse(xhr.responseText)
                    // Cargar permisos después de obtener el perfil
                    cargarTodosLosPermisos(callback)
                } else {
                    if (callback) callback(false, "Error al cargar perfil")
                }
            }
        }

        xhr.send()
    }

    // 🔑 Cargar todos los permisos (rol + usuario)
    function cargarTodosLosPermisos(callback) {
        if (!datosUsuario) {
            if (callback) callback(false, "No hay datos de usuario")
            return
        }

        cargandoPermisos = true
        var permisosRolCargados = false
        var permisosUsuarioCargados = false
        var errorEnCarga = false

        // Cargar permisos del rol
        cargarPermisosRol(datosUsuario.rol, function(exito) {
            permisosRolCargados = true
            if (!exito) errorEnCarga = true
            verificarCargaCompleta()
        })

        // Cargar permisos del usuario
        cargarPermisosUsuario(datosUsuario.id, function(exito) {
            permisosUsuarioCargados = true
            if (!exito) errorEnCarga = true
            verificarCargaCompleta()
        })

        function verificarCargaCompleta() {
            if (permisosRolCargados && permisosUsuarioCargados) {
                cargandoPermisos = false
                combinarPermisos()
                if (callback) {
                    if (errorEnCarga) {
                        callback(true, "Login exitoso (permisos parciales)")
                    } else {
                        callback(true, "Login exitoso")
                    }
                }
            }
        }
    }

    // 🔑 Cargar permisos del rol
    function cargarPermisosRol(rol, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", urlBackend + "/permisos/rol/" + rol)
        xhr.setRequestHeader("Authorization", "Bearer " + token)

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        permisosRol = JSON.parse(xhr.responseText) || []
                        if (callback) callback(true)
                    } catch(e) {
                        permisosRol = []
                        if (callback) callback(false)
                    }
                } else {
                    permisosRol = []
                    if (callback) callback(false)
                }
            }
        }

        xhr.send()
    }

    // 🔑 Cargar permisos del usuario (overrides)
    function cargarPermisosUsuario(userId, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", urlBackend + "/permisos/usuario/" + userId)
        xhr.setRequestHeader("Authorization", "Bearer " + token)

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        permisosUsuario = JSON.parse(xhr.responseText) || []
                        if (callback) callback(true)
                    } catch(e) {
                        permisosUsuario = []
                        if (callback) callback(false)
                    }
                } else {
                    permisosUsuario = []
                    if (callback) callback(false)
                }
            }
        }

        xhr.send()
    }

    // 🔑 Combinar permisos (precedencia: usuario > rol)
    function combinarPermisos() {
        var resueltos = {}

        // Primero agregar permisos del rol
        for (var i = 0; i < permisosRol.length; i++) {
            var permisoRol = permisosRol[i]
            var clave = permisoRol.recurso + ":" + permisoRol.accion
            resueltos[clave] = permisoRol.permitido
        }

        // Luego sobrescribir con permisos del usuario (precedencia)
        for (var j = 0; j < permisosUsuario.length; j++) {
            var permisoUsuario = permisosUsuario[j]
            var claveUsuario = permisoUsuario.recurso + ":" + permisoUsuario.accion
            resueltos[claveUsuario] = permisoUsuario.permitido
        }

        permisosResueltos = resueltos
    }
    
    // 🚪 Logout
    function logout(callback) {
        // Llamar al backend para registrar el logout
        var xhr = new XMLHttpRequest()
        xhr.open("POST", urlBackend + "/auth/logout")
        xhr.setRequestHeader("Authorization", "Bearer " + token)

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                // Limpiar estado local independientemente del resultado
                token = ""
                datosUsuario = null
                permisosRol = []
                permisosUsuario = []
                permisosResueltos = {}
                cargandoPermisos = false

                if (callback) {
                    if (xhr.status >= 200 && xhr.status < 300) {
                        callback(true, "Logout exitoso")
                    } else {
                        callback(true, "Sesión cerrada localmente")
                    }
                }
            }
        }

        xhr.send()
    }
    
    // 🔍 Verificar permiso dinámico
    function tienePermiso(recurso, accion) {
        if (!datosUsuario) return false

        // DUENO tiene acceso a todo siempre
        if (datosUsuario.rol === "DUENO") return true

        // Buscar en permisos resueltos
        var clave = recurso + ":" + accion
        if (permisosResueltos.hasOwnProperty(clave)) {
            return permisosResueltos[clave]
        }

        // Si no hay permiso explícito, denegar por defecto
        return false
    }
    
    // 📡 Hacer petición autenticada
    function request(method, endpoint, data, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open(method, urlBackend + endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        
        if (data && method !== "GET") {
            xhr.setRequestHeader("Content-Type", "application/json")
        }
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status >= 200 && xhr.status < 300) {
                    var response = xhr.responseText ? JSON.parse(xhr.responseText) : null
                    callback(true, response)
                } else {
                    callback(false, "Error: " + xhr.status)
                }
            }
        }
        
        if (data && method !== "GET") {
            xhr.send(JSON.stringify(data))
        } else {
            xhr.send()
        }
    }
}
