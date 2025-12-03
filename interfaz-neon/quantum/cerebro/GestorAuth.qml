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
                    if (callback) callback(true, "Login exitoso")
                } else {
                    if (callback) callback(false, "Error al cargar perfil")
                }
            }
        }
        
        xhr.send()
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
    
    // 🔍 Verificar permiso
    function tienePermiso(recurso, accion) {
        if (!datosUsuario) return false
        
        var rol = datosUsuario.rol
        
        // DUENO tiene acceso a todo
        if (rol === "DUENO") return true
        
        // Permisos por rol (simplificado)
        var permisos = {
            "ADMIN": ["usuarios", "inventario", "reportes", "ventas"],
            "GERENTE": ["inventario", "reportes", "ventas", "clientes"],
            "VENDEDOR": ["ventas", "clientes"]
        }
        
        return permisos[rol] && permisos[rol].indexOf(recurso) !== -1
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
