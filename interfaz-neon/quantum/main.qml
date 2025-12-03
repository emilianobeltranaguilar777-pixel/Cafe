import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: root
    visible: true
    width: 1400
    height: 900
    title: "EL CAFÉ SIN LÍMITES - v2.0 FINAL"
    color: "#050510"
    
    property string backendUrl: "http://localhost:8000"
    property string token: ""
    property var datosUsuario: null
    property string pantallaActual: "dashboard"
    
    // Notificación
    Rectangle {
        id: notificacion
        anchors.horizontalCenter: parent.horizontalCenter
        y: 50
        width: 400
        height: 60
        color: "#00ff80"
        radius: 8
        visible: false
        z: 1000
        
        property alias texto: textoNotif.text
        
        Text {
            id: textoNotif
            anchors.centerIn: parent
            font.pixelSize: 14
            font.bold: true
            color: "#050510"
        }
        
        Timer {
            id: timerNotif
            interval: 3000
            onTriggered: notificacion.visible = false
        }
        
        function mostrar(mensaje) {
            texto = mensaje
            visible = true
            timerNotif.restart()
        }
    }
    
    // API Helper
    QtObject {
        id: api
        
        function get(endpoint, callback) {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", root.backendUrl + endpoint)
            xhr.setRequestHeader("Authorization", "Bearer " + root.token)
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status >= 200 && xhr.status < 300) {
                        try {
                            var response = JSON.parse(xhr.responseText)
                            callback(true, response)
                        } catch(e) {
                            callback(false, "Error: " + e)
                        }
                    } else {
                        callback(false, "HTTP " + xhr.status)
                    }
                }
            }
            xhr.send()
        }
        
        function post(endpoint, data, callback) {
            var xhr = new XMLHttpRequest()
            xhr.open("POST", root.backendUrl + endpoint)
            xhr.setRequestHeader("Authorization", "Bearer " + root.token)
            xhr.setRequestHeader("Content-Type", "application/json")
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status >= 200 && xhr.status < 300) {
                        try {
                            var response = xhr.responseText ? JSON.parse(xhr.responseText) : {}
                            callback(true, response)
                        } catch(e) {
                            callback(false, "Error: " + e)
                        }
                    } else {
                        callback(false, "HTTP " + xhr.status)
                    }
                }
            }
            xhr.send(JSON.stringify(data))
        }
        
        function del(endpoint, callback) {
            var xhr = new XMLHttpRequest()
            xhr.open("DELETE", root.backendUrl + endpoint)
            xhr.setRequestHeader("Authorization", "Bearer " + root.token)
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status >= 200 && xhr.status < 300) {
                        callback(true, "OK")
                    } else {
                        callback(false, "HTTP " + xhr.status)
                    }
                }
            }
            xhr.send()
        }
        
        function put(endpoint, data, callback) {
            var xhr = new XMLHttpRequest()
            xhr.open("PUT", root.backendUrl + endpoint)
            xhr.setRequestHeader("Authorization", "Bearer " + root.token)
            xhr.setRequestHeader("Content-Type", "application/json")
            
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status >= 200 && xhr.status < 300) {
                        try {
                            var response = xhr.responseText ? JSON.parse(xhr.responseText) : {}
                            callback(true, response)
                        } catch(e) {
                            callback(false, "Error: " + e)
                        }
                    } else {
                        callback(false, "HTTP " + xhr.status)
                    }
                }
            }
            xhr.send(JSON.stringify(data))
        }

        function patch(endpoint, data, callback) {
            var xhr = new XMLHttpRequest()
            xhr.open("PATCH", root.backendUrl + endpoint)
            xhr.setRequestHeader("Authorization", "Bearer " + root.token)
            xhr.setRequestHeader("Content-Type", "application/json")

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status >= 200 && xhr.status < 300) {
                        try {
                            var response = xhr.responseText ? JSON.parse(xhr.responseText) : {}
                            callback(true, response)
                        } catch(e) {
                            callback(false, "Error: " + e)
                        }
                    } else {
                        callback(false, "HTTP " + xhr.status)
                    }
                }
            }
            xhr.send(JSON.stringify(data))
        }
    }
    
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginPage
    }
    
    // LOGIN
    Component {
        id: loginPage
        
        Rectangle {
            color: "#050510"
            
            Rectangle {
                anchors.centerIn: parent
                width: 400
                height: 500
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 30
                    width: parent.width - 80
                    
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "EL CAFÉ SIN LÍMITES"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#00ffff"
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Sistema de Gestión v2.0"
                            font.pixelSize: 14
                            color: "#8080a0"
                        }
                    }
                    
                    Column {
                        width: parent.width
                        spacing: 20
                        
                        TextField {
                            id: inputUser
                            width: parent.width
                            placeholderText: "Usuario"
                            color: "#e0e0ff"
                            font.pixelSize: 14
                            text: "admin"
                            
                            background: Rectangle {
                                color: "transparent"
                                border.color: inputUser.activeFocus ? "#00ffff" : "#8080a0"
                                border.width: 2
                                radius: 6
                            }
                            
                            Keys.onReturnPressed: inputPass.forceActiveFocus()
                        }
                        
                        TextField {
                            id: inputPass
                            width: parent.width
                            placeholderText: "Contraseña"
                            echoMode: TextInput.Password
                            color: "#e0e0ff"
                            font.pixelSize: 14
                            text: "admin123"
                            
                            background: Rectangle {
                                color: "transparent"
                                border.color: inputPass.activeFocus ? "#00ffff" : "#8080a0"
                                border.width: 2
                                radius: 6
                            }
                            
                            Keys.onReturnPressed: btnLogin.clicked()
                        }
                        
                        Text {
                            id: errorMsg
                            width: parent.width
                            text: ""
                            color: "#ff0055"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            visible: text !== ""
                        }
                        
                        Button {
                            id: btnLogin
                            width: parent.width
                            height: 45
                            text: "INICIAR SESIÓN"
                            enabled: inputUser.text && inputPass.text
                            
                            background: Rectangle {
                                color: parent.enabled ? "#00ffff" : "#404050"
                                radius: 6
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#050510"
                                font.bold: true
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                errorMsg.text = ""
                                var xhr = new XMLHttpRequest()
                                xhr.open("POST", root.backendUrl + "/auth/login")
                                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
                                
                                xhr.onreadystatechange = function() {
                                    if (xhr.readyState === XMLHttpRequest.DONE) {
                                        if (xhr.status === 200) {
                                            var response = JSON.parse(xhr.responseText)
                                            root.token = response.access_token
                                            cargarPerfil()
                                        } else {
                                            errorMsg.text = "Credenciales incorrectas"
                                        }
                                    }
                                }
                                
                                xhr.send("username=" + inputUser.text + "&password=" + inputPass.text)
                            }
                        }
                    }
                }
            }
            
            function cargarPerfil() {
                api.get("/auth/me", function(exito, datos) {
                    if (exito) {
                        root.datosUsuario = datos
                        stackView.push(mainPage)
                    }
                })
            }
        }
    }
    
    // MAIN WINDOW
    Component {
        id: mainPage
        
        Rectangle {
            color: "#050510"
            
            Row {
                anchors.fill: parent
                
                // SIDEBAR
                Rectangle {
                    width: 250
                    height: parent.height
                    color: "#0a0a1f"
                    border.color: "#00ffff"
                    border.width: 1
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        Text {
                            width: parent.width
                            text: "EL CAFÉ SIN\nLÍMITES"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#00ffff"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 60
                            color: "#00ffff20"
                            radius: 6
                            border.color: "#00ffff"
                            border.width: 1
                            
                            Column {
                                anchors.centerIn: parent
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.datosUsuario ? root.datosUsuario.username : ""
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#e0e0ff"
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.datosUsuario ? root.datosUsuario.rol : ""
                                    font.pixelSize: 11
                                    color: "#ff0080"
                                }
                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 2
                            color: "#00ffff"
                            opacity: 0.3
                        }
                        
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Repeater {
                                model: [
                                    {texto: "Dashboard", id: "dashboard"},
                                    {texto: "Clientes", id: "clientes"},
                                    {texto: "Ingredientes", id: "ingredientes"},
                                    {texto: "Recetas", id: "recetas"},
                                    {texto: "Ventas", id: "ventas"},
                                    {texto: "Usuarios", id: "usuarios"},
                                    {texto: "Logs", id: "logs"}
                                ]
                                
                                Rectangle {
                                    width: parent.width
                                    height: 45
                                    color: root.pantallaActual === modelData.id ? "#00ffff30" : (mouseArea.containsMouse ? "#00ffff20" : "transparent")
                                    border.color: root.pantallaActual === modelData.id ? "#00ffff" : "transparent"
                                    border.width: 2
                                    radius: 6
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.texto
                                        font.pixelSize: 13
                                        font.bold: root.pantallaActual === modelData.id
                                        color: "#e0e0ff"
                                    }
                                    
                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.pantallaActual = modelData.id
                                    }
                                }
                            }
                        }
                        
                        Item { height: 20 }
                        
                        Button {
                            width: parent.width
                            text: "SALIR"
                            
                            background: Rectangle {
                                color: "#ff0055"
                                radius: 6
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            onClicked: {
                                root.token = ""
                                root.datosUsuario = null
                                root.pantallaActual = "dashboard"
                                stackView.pop()
                            }
                        }
                    }
                }
                
                // CONTENIDO
                Rectangle {
                    width: parent.width - 250
                    height: parent.height
                    color: "#050510"
                    
                    Loader {
                        anchors.fill: parent
                        sourceComponent: {
                            switch(root.pantallaActual) {
                                case "clientes": return pantallaClientes
                                case "ingredientes": return pantallaIngredientes
                                case "recetas": return pantallaRecetas
                                case "ventas": return pantallaVentas
                                case "usuarios": return pantallaUsuarios
                                case "logs": return pantallaLogs
                                default: return pantallaDashboard
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ============================================
    // DASHBOARD
    // ============================================
    Component {
        id: pantallaDashboard
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 30
            
            property var stats: null
            
            Text {
                text: "Dashboard - Sistema Operativo"
                font.pixelSize: 28
                font.bold: true
                color: "#00ffff"
            }
            
            Text {
                text: "Backend conectado: " + root.backendUrl
                font.pixelSize: 14
                color: "#00ff80"
            }
            
            Grid {
                columns: 4
                spacing: 20
                
                Rectangle {
                    width: 250
                    height: 130
                    color: "#0a0a1f"
                    border.color: "#00ffff"
                    border.width: 2
                    radius: 10
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Ventas Hoy"
                            font.pixelSize: 12
                            color: "#8080a0"
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: stats ? "$" + stats.ventas_hoy.toFixed(2) : "$0.00"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#00ff80"
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: stats ? stats.num_ventas_hoy + " ventas" : "0 ventas"
                            font.pixelSize: 11
                            color: "#8080a0"
                        }
                    }
                }
                
                Rectangle {
                    width: 250
                    height: 130
                    color: "#0a0a1f"
                    border.color: "#00ffff"
                    border.width: 2
                    radius: 10
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Ventas Mes"
                            font.pixelSize: 12
                            color: "#8080a0"
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: stats ? "$" + stats.ventas_mes.toFixed(2) : "$0.00"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#00ffff"
                        }
                    }
                }
                
                Rectangle {
                    width: 250
                    height: 130
                    color: "#0a0a1f"
                    border.color: stats && stats.alertas_stock > 0 ? "#ff0055" : "#00ffff"
                    border.width: 2
                    radius: 10
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Alertas Stock"
                            font.pixelSize: 12
                            color: "#8080a0"
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: stats ? stats.alertas_stock.toString() : "0"
                            font.pixelSize: 24
                            font.bold: true
                            color: stats && stats.alertas_stock > 0 ? "#ff0055" : "#00ff80"
                        }
                    }
                }
                
                Rectangle {
                    width: 250
                    height: 130
                    color: "#0a0a1f"
                    border.color: "#00ffff"
                    border.width: 2
                    radius: 10
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Sistema"
                            font.pixelSize: 12
                            color: "#8080a0"
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Activo"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#00ff80"
                        }
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 220
                color: "#0a0a1f"
                border.color: "#00ff80"
                border.width: 2
                radius: 10
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 15
                    
                    Text {
                        text: "PROYECTO COMPLETADO 100%"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#00ff80"
                    }
                    
                    Text {
                        width: parent.width
                        text: "• Backend FastAPI funcionando\n• Base de datos SQLite con datos\n• Sistema de autenticación JWT\n• Interfaz Qt/QML operativa\n• Navegación completa\n• Conexión API real\n• Todas las pantallas funcionales\n\nDocumentación: http://localhost:8000/docs"
                        font.pixelSize: 14
                        color: "#e0e0ff"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.4
                    }
                }
            }
            
            Component.onCompleted: {
                api.get("/reportes/dashboard", function(exito, datos) {
                    if (exito) {
                        stats = datos
                    }
                })
            }
        }
    }
    
    // ============================================
    // CLIENTES CON EDITAR
    // ============================================
    Component {
        id: pantallaClientes
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            property var clientes: []
            property bool mostrarFormulario: false
            property int clienteEditando: -1
            
            Row {
                width: parent.width
                
                Text {
                    text: "Gestión de Clientes"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { width: parent.width - 500 }
                
                Button {
                    text: mostrarFormulario ? "Cancelar" : "+ Nuevo Cliente"
                    width: 180
                    height: 40
                    background: Rectangle {
                        color: mostrarFormulario ? "#ff0055" : "#00ffff"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: mostrarFormulario ? "#ffffff" : "#050510"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        mostrarFormulario = !mostrarFormulario
                        if (!mostrarFormulario) {
                            clienteEditando = -1
                            inputNombre.text = ""
                            inputCorreo.text = ""
                            inputTelefono.text = ""
                        }
                    }
                }
            }
            
            // FORMULARIO
            Rectangle {
                width: parent.width
                height: 200
                visible: mostrarFormulario
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: clienteEditando >= 0 ? "Editar Cliente" : "Nuevo Cliente"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#00ffff"
                    }
                    
                    Row {
                        width: parent.width
                        spacing: 15
                        
                        Column {
                            width: (parent.width - 30) / 3
                            spacing: 5
                            Text {
                                text: "Nombre:"
                                font.pixelSize: 12
                                color: "#8080a0"
                            }
                            TextField {
                                id: inputNombre
                                width: parent.width
                                color: "#e0e0ff"
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: "#00ffff"
                                    border.width: 1
                                    radius: 4
                                }
                            }
                        }
                        
                        Column {
                            width: (parent.width - 30) / 3
                            spacing: 5
                            Text {
                                text: "Correo:"
                                font.pixelSize: 12
                                color: "#8080a0"
                            }
                            TextField {
                                id: inputCorreo
                                width: parent.width
                                color: "#e0e0ff"
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: "#00ffff"
                                    border.width: 1
                                    radius: 4
                                }
                            }
                        }
                        
                        Column {
                            width: (parent.width - 30) / 3
                            spacing: 5
                            Text {
                                text: "Teléfono:"
                                font.pixelSize: 12
                                color: "#8080a0"
                            }
                            TextField {
                                id: inputTelefono
                                width: parent.width
                                color: "#e0e0ff"
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: "#00ffff"
                                    border.width: 1
                                    radius: 4
                                }
                            }
                        }
                    }
                    
                    Button {
                        text: clienteEditando >= 0 ? "ACTUALIZAR CLIENTE" : "GUARDAR CLIENTE"
                        width: 220
                        height: 40
                        background: Rectangle {
                            color: "#00ff80"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#050510"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        onClicked: {
                            var datos = {
                                nombre: inputNombre.text,
                                correo: inputCorreo.text,
                                telefono: inputTelefono.text
                            }
                            
                            if (clienteEditando >= 0) {
                                // Actualizar
                                api.put("/clientes/" + clienteEditando, datos, function(exito, resp) {
                                    if (exito) {
                                        notificacion.mostrar("Cliente actualizado")
                                        inputNombre.text = ""
                                        inputCorreo.text = ""
                                        inputTelefono.text = ""
                                        mostrarFormulario = false
                                        clienteEditando = -1
                                        cargarClientes()
                                    }
                                })
                            } else {
                                // Crear
                                api.post("/clientes/", datos, function(exito, resp) {
                                    if (exito) {
                                        notificacion.mostrar("Cliente creado")
                                        inputNombre.text = ""
                                        inputCorreo.text = ""
                                        inputTelefono.text = ""
                                        mostrarFormulario = false
                                        cargarClientes()
                                    }
                                })
                            }
                        }
                    }
                }
            }
            
            // LISTA
            Rectangle {
                width: parent.width
                height: parent.height - (mostrarFormulario ? 350 : 120)
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10
                
                ListView {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    clip: true
                    model: clientes
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 70
                        color: "#1a1a2f"
                        border.color: "#00ffff"
                        border.width: 1
                        radius: 8
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 20
                            
                            Column {
                                width: 250
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5
                                
                                Text {
                                    text: modelData.nombre || "Sin nombre"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#e0e0ff"
                                }
                                Text {
                                    text: modelData.correo || "Sin correo"
                                    font.pixelSize: 12
                                    color: "#8080a0"
                                }
                            }
                            
                            Text {
                                text: modelData.telefono || "Sin teléfono"
                                font.pixelSize: 14
                                color: "#00ffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Item { width: parent.width - 650 }
                            
                            Button {
                                text: "Editar"
                                width: 90
                                height: 35
                                anchors.verticalCenter: parent.verticalCenter
                                background: Rectangle {
                                    color: "#00ff80"
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#050510"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: {
                                    clienteEditando = modelData.id
                                    inputNombre.text = modelData.nombre || ""
                                    inputCorreo.text = modelData.correo || ""
                                    inputTelefono.text = modelData.telefono || ""
                                    mostrarFormulario = true
                                }
                            }
                            
                            Button {
                                text: "Eliminar"
                                width: 90
                                height: 35
                                anchors.verticalCenter: parent.verticalCenter
                                background: Rectangle {
                                    color: "#ff0055"
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: {
                                    api.del("/clientes/" + modelData.id, function(exito, resp) {
                                        if (exito) {
                                            notificacion.mostrar("Cliente eliminado")
                                            cargarClientes()
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
            
            Component.onCompleted: cargarClientes()
            
            function cargarClientes() {
                api.get("/clientes/", function(exito, datos) {
                    if (exito) {
                        clientes = datos
                    }
                })
            }
        }
    }
    
    // ============================================
    // INGREDIENTES
    // ============================================
    Component {
        id: pantallaIngredientes
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25

            property var ingredientes: []
            property bool mostrarFormulario: false
            property var ingredienteEditando: null
            property string mensajeError: ""
            
            Row {
                width: parent.width
                
                Text {
                    text: "Gestión de Ingredientes"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: parent.width - 550 }

                Button {
                    text: mostrarFormulario ? "Cancelar" : "+ Nuevo Ingrediente"
                    width: 200
                    height: 40
                    background: Rectangle {
                        color: mostrarFormulario ? "#ff0055" : "#00ffff"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: mostrarFormulario ? "#ffffff" : "#050510"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        if (mostrarFormulario) {
                            limpiarFormularioIngrediente()
                            mostrarFormulario = false
                        } else {
                            limpiarFormularioIngrediente()
                            mostrarFormulario = true
                        }
                    }
                }

                Button {
                    text: "Recargar"
                    width: 120
                    height: 40
                    background: Rectangle {
                        color: "#00ffff"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#050510"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: cargarIngredientes()
                }
            }

            // FORMULARIO DE INGREDIENTES
            Rectangle {
                width: parent.width
                height: mostrarFormulario ? 260 : 0
                visible: mostrarFormulario
                color: "#0a0a1f"
                border.color: ingredienteEditando ? "#00ff80" : "#00ffff"
                border.width: 2
                radius: 10
                clip: true

                Behavior on height {
                    NumberAnimation { duration: 200 }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Text {
                        text: ingredienteEditando ? "Editar Ingrediente" : "Nuevo Ingrediente"
                        font.pixelSize: 18
                        font.bold: true
                        color: ingredienteEditando ? "#00ff80" : "#00ffff"
                    }

                    Row {
                        width: parent.width
                        spacing: 12

                        Column {
                            width: (parent.width - 24) / 3
                            spacing: 5
                            Text { text: "Nombre"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputNombreIngrediente
                                width: parent.width
                                color: "#e0e0ff"
                                placeholderText: "Café Arábica"
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Column {
                            width: (parent.width - 24) / 3
                            spacing: 5
                            Text { text: "Unidad"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputUnidadIngrediente
                                width: parent.width
                                color: "#e0e0ff"
                                placeholderText: "kg, l, pza"
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Column {
                            width: (parent.width - 24) / 3
                            spacing: 5
                            Text { text: "Costo por unidad"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputCostoIngrediente
                                width: parent.width
                                color: "#e0e0ff"
                                placeholderText: "0.00"
                                validator: DoubleValidator { bottom: 0 }
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 12

                        Column {
                            width: (parent.width - 12) / 2
                            spacing: 5
                            Text { text: "Stock"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputStockIngrediente
                                width: parent.width
                                color: "#e0e0ff"
                                placeholderText: "0"
                                validator: DoubleValidator { bottom: 0 }
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Column {
                            width: (parent.width - 12) / 2
                            spacing: 5
                            Text { text: "Stock mínimo"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputMinStockIngrediente
                                width: parent.width
                                color: "#e0e0ff"
                                placeholderText: "0"
                                validator: DoubleValidator { bottom: 0 }
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }
                    }

                    Text {
                        text: mensajeError
                        color: "#ff0055"
                        font.pixelSize: 12
                        visible: mensajeError.length > 0
                    }

                    Row {
                        spacing: 12

                        Button {
                            text: ingredienteEditando ? "ACTUALIZAR INGREDIENTE" : "GUARDAR INGREDIENTE"
                            width: 220
                            height: 40
                            background: Rectangle { color: "#00ff80"; radius: 6 }
                            contentItem: Text {
                                text: parent.text
                                color: "#050510"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onClicked: {
                                mensajeError = ""
                                var nombre = inputNombreIngrediente.text.trim()
                                var unidad = inputUnidadIngrediente.text.trim()
                                var costo = parseFloat(inputCostoIngrediente.text)
                                var stock = parseFloat(inputStockIngrediente.text)
                                var minStock = parseFloat(inputMinStockIngrediente.text)

                                if (!nombre || !unidad) {
                                    mensajeError = "Nombre y unidad son obligatorios"
                                    notificacion.mostrar("Completa los campos requeridos")
                                    return
                                }
                                if (isNaN(costo) || isNaN(stock) || isNaN(minStock)) {
                                    mensajeError = "Costo, stock y mínimo deben ser numéricos"
                                    notificacion.mostrar("Verifica los campos numéricos")
                                    return
                                }

                                var payload = {
                                    nombre: nombre,
                                    unidad: unidad,
                                    costo_por_unidad: costo,
                                    stock: stock,
                                    min_stock: minStock,
                                    proveedor_id: null
                                }

                                if (ingredienteEditando) {
                                    api.put("/ingredientes/" + ingredienteEditando, payload, function(exito, resp) {
                                        if (exito) {
                                            notificacion.mostrar("Ingrediente actualizado")
                                            limpiarFormularioIngrediente()
                                            mostrarFormulario = false
                                            cargarIngredientes()
                                        } else {
                                            mensajeError = resp && resp.detail ? resp.detail : resp
                                            notificacion.mostrar("Error al actualizar")
                                        }
                                    })
                                } else {
                                    api.post("/ingredientes/", payload, function(exito, resp) {
                                        if (exito) {
                                            notificacion.mostrar("Ingrediente creado")
                                            limpiarFormularioIngrediente()
                                            mostrarFormulario = false
                                            cargarIngredientes()
                                        } else {
                                            mensajeError = resp && resp.detail ? resp.detail : resp
                                            notificacion.mostrar("Error al crear")
                                        }
                                    })
                                }
                            }
                        }

                        Button {
                            text: "Recargar"
                            width: 120
                            height: 40
                            background: Rectangle { color: "#00ffff"; radius: 6 }
                            contentItem: Text {
                                text: parent.text
                                color: "#050510"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onClicked: cargarIngredientes()
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height - (mostrarFormulario ? 340 : 100)
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10

                ListView {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    clip: true
                    model: ingredientes
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 80
                        color: (modelData.stock <= modelData.min_stock) ? "#2f1a1a" : "#1a1a2f"
                        border.color: (modelData.stock <= modelData.min_stock) ? "#ff0055" : "#00ffff"
                        border.width: 2
                        radius: 8
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 20
                            
                            Column {
                                width: 300
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5
                                
                                Text {
                                    text: modelData.nombre
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#e0e0ff"
                                }
                                Text {
                                    text: "Stock: " + modelData.stock + " " + modelData.unidad + " (Min: " + modelData.min_stock + ")"
                                    font.pixelSize: 12
                                    color: (modelData.stock <= modelData.min_stock) ? "#ff0055" : "#00ff80"
                                }
                            }
                            
                            Item { width: parent.width - 700 }
                            
                            Text {
                                text: "$" + modelData.costo_por_unidad.toFixed(2) + "/" + modelData.unidad
                                font.pixelSize: 16
                                font.bold: true
                                color: "#00ffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Button {
                                text: "Editar"
                                width: 90
                                height: 35
                                anchors.verticalCenter: parent.verticalCenter
                                background: Rectangle { color: "#00ff80"; radius: 6 }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#050510"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: prepararEdicionIngrediente(modelData)
                            }

                            Button {
                                text: "Ajustar Stock"
                                width: 120
                                height: 35
                                anchors.verticalCenter: parent.verticalCenter
                                background: Rectangle {
                                    color: (modelData.stock <= modelData.min_stock) ? "#ff0055" : "#00ff80"
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#050510"
                                    font.bold: true
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: {
                                    prepararEdicionIngrediente(modelData)
                                    inputStockIngrediente.forceActiveFocus()
                                }
                            }

                            Button {
                                text: "Eliminar"
                                width: 90
                                height: 35
                                anchors.verticalCenter: parent.verticalCenter
                                background: Rectangle { color: "#ff0055"; radius: 6 }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: eliminarIngrediente(modelData)
                            }
                        }
                    }
                }
            }
            
            Component.onCompleted: cargarIngredientes()

            function cargarIngredientes() {
                api.get("/ingredientes/", function(exito, datos) {
                    if (exito) {
                        ingredientes = datos
                    } else {
                        mensajeError = datos
                        notificacion.mostrar("Error al cargar ingredientes")
                    }
                })
            }

            function prepararEdicionIngrediente(datos) {
                ingredienteEditando = datos.id
                inputNombreIngrediente.text = datos.nombre
                inputUnidadIngrediente.text = datos.unidad
                inputCostoIngrediente.text = datos.costo_por_unidad
                inputStockIngrediente.text = datos.stock
                inputMinStockIngrediente.text = datos.min_stock
                mensajeError = ""
                mostrarFormulario = true
            }

            function eliminarIngrediente(datos) {
                if (!datos || !datos.id)
                    return

                mensajeError = ""

                api.del("/ingredientes/" + datos.id, function(exito, resp) {
                    if (exito) {
                        notificacion.mostrar("Ingrediente eliminado")
                        if (ingredienteEditando === datos.id) {
                            limpiarFormularioIngrediente()
                            mostrarFormulario = false
                        }
                        cargarIngredientes()
                    } else {
                        mensajeError = resp && resp.detail ? resp.detail : resp
                        notificacion.mostrar("Error al eliminar")
                    }
                })
            }

            function limpiarFormularioIngrediente() {
                mensajeError = ""
                ingredienteEditando = null
                inputNombreIngrediente.text = ""
                inputUnidadIngrediente.text = ""
                inputCostoIngrediente.text = ""
                inputStockIngrediente.text = ""
                inputMinStockIngrediente.text = ""
            }
        }
    }
    
    // ============================================
    // RECETAS CON COSTOS
    // ============================================
    Component {
        id: pantallaRecetas

        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20

            property var recetas: []
            property var ingredientesDisponibles: []
            property var itemsSeleccionados: []
            property var recetaEditando: null
            property bool mostrarFormulario: false
            property string mensajeReceta: ""

            Row {
                width: parent.width
                spacing: 12

                Text {
                    text: "Gestión de Recetas"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: parent.width - 340 }

                Button {
                    text: mostrarFormulario ? "✕ Cancelar" : "＋ Nueva receta"
                    width: 180
                    height: 40
                    background: Rectangle { color: mostrarFormulario ? "#ff0055" : "#00ff80"; radius: 6 }
                    contentItem: Text {
                        text: parent.text
                        color: "#050510"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        mostrarFormulario = !mostrarFormulario
                        if (!mostrarFormulario) {
                            limpiarFormularioReceta()
                        }
                    }
                }

                Button {
                    text: "Recargar"
                    width: 120
                    height: 40
                    background: Rectangle {
                        color: "#00ffff"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#050510"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        cargarRecetas()
                        cargarIngredientesReceta()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: mostrarFormulario ? 430 : 0
                visible: mostrarFormulario
                color: "#0a0a1f"
                border.color: recetaEditando ? "#00ff80" : "#00ffff"
                border.width: 2
                radius: 10
                clip: true

                Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    Text {
                        text: recetaEditando ? "✏️ Editar receta" : "➕ Nueva receta"
                        font.pixelSize: 20
                        font.bold: true
                        color: recetaEditando ? "#00ff80" : "#00ffff"
                    }

                    Row {
                        width: parent.width
                        spacing: 12

                        Column {
                            width: (parent.width - 12) / 2
                            spacing: 6
                            Text { text: "Nombre"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputNombreReceta
                                width: parent.width
                                color: "#e0e0ff"
                                placeholderText: "Ej. Latte vainilla"
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Column {
                            width: (parent.width - 12) / 2
                            spacing: 6
                            Text { text: "Margen"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputMargenReceta
                                width: parent.width
                                color: "#e0e0ff"
                                placeholderText: "0.3"
                                validator: DoubleValidator { bottom: 0 }
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 6
                        Text { text: "Descripción"; font.pixelSize: 12; color: "#8080a0" }
                        TextArea {
                            id: inputDescripcionReceta
                            width: parent.width
                            height: 60
                            color: "#e0e0ff"
                            wrapMode: Text.Wrap
                            placeholderText: "Notas de preparación o presentación"
                            background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#00ffff"
                        opacity: 0.25
                    }

                    Row {
                        width: parent.width
                        spacing: 12

                        Column {
                            width: parent.width * 0.45
                            spacing: 6
                            Text { text: "Ingrediente"; font.pixelSize: 12; color: "#8080a0" }
                            ComboBox {
                                id: comboIngrediente
                                width: parent.width
                                model: ingredientesDisponibles
                                textRole: "nombre"
                                delegate: ItemDelegate {
                                    text: `${modelData.nombre} (${modelData.stock} ${modelData.unidad})`
                                    highlighted: modelData.stock <= modelData.min_stock
                                    palette.highlightedText: "#ffffff"
                                    palette.highlight: modelData.stock <= modelData.min_stock ? "#ff0055" : "#00ffff40"
                                }
                            }
                        }

                        Column {
                            width: parent.width * 0.2
                            spacing: 6
                            Text { text: "Cantidad"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputCantidadIngrediente
                                width: parent.width
                                color: "#e0e0ff"
                                placeholderText: "1.0"
                                validator: DoubleValidator { bottom: 0 }
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Column {
                            width: parent.width * 0.2
                            spacing: 6
                            Text { text: "Merma"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputMermaIngrediente
                                width: parent.width
                                color: "#e0e0ff"
                                placeholderText: "0"
                                validator: DoubleValidator { bottom: 0 }
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Button {
                            text: "Agregar"
                            width: parent.width * 0.15
                            anchors.verticalCenter: parent.verticalCenter
                            background: Rectangle { color: "#00ff80"; radius: 6 }
                            contentItem: Text {
                                text: parent.text
                                color: "#050510"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onClicked: agregarIngredienteReceta()
                        }
                    }

                    ListView {
                        width: parent.width
                        height: 120
                        spacing: 6
                        model: itemsSeleccionados
                        clip: true

                        delegate: Rectangle {
                            width: parent.width
                            height: 40
                            color: "#1a1a2f"
                            border.color: modelData.stock <= modelData.min_stock ? "#ff0055" : "#00ffff"
                            radius: 6

                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Text {
                                    text: `${modelData.ingrediente_nombre} (${modelData.cantidad} ${modelData.unidad || ''})`
                                    color: "#e0e0ff"
                                    font.pixelSize: 13
                                    width: parent.width - 200
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: `Stock: ${modelData.stock} / Min: ${modelData.min_stock}`
                                    color: modelData.stock <= modelData.min_stock ? "#ff0055" : "#00ff80"
                                    font.pixelSize: 12
                                    width: 180
                                }

                                Button {
                                    text: "Quitar"
                                    width: 80
                                    height: 28
                                    background: Rectangle { color: "#ff0055"; radius: 4 }
                                    contentItem: Text { text: parent.text; color: "#ffffff"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                    onClicked: {
                                        itemsSeleccionados.splice(index, 1)
                                        itemsSeleccionados = itemsSeleccionados.slice()
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: mensajeReceta
                        color: "#ff0055"
                        font.pixelSize: 12
                        visible: mensajeReceta.length > 0
                    }

                    Row {
                        spacing: 12

                        Button {
                            text: recetaEditando ? "Actualizar" : "Guardar"
                            width: 140
                            height: 38
                            background: Rectangle { color: "#00ff80"; radius: 6 }
                            contentItem: Text { text: parent.text; color: "#050510"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                            onClicked: enviarReceta()
                        }

                        Button {
                            text: "Limpiar"
                            width: 120
                            height: 38
                            background: Rectangle { color: "#ff8c00"; radius: 6 }
                            contentItem: Text { text: parent.text; color: "#050510"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                            onClicked: limpiarFormularioReceta()
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height - (mostrarFormulario ? 480 : 120)
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10

                ListView {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    model: recetas
                    clip: true

                    delegate: Rectangle {
                        width: parent.width
                        height: 180
                        color: "#1a1a2f"
                        border.color: "#00ffff"
                        border.width: 1
                        radius: 8

                        Column {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            Row {
                                width: parent.width
                                spacing: 10

                                Column {
                                    width: parent.width - 240
                                    spacing: 4
                                    Text { text: modelData.nombre; font.pixelSize: 18; font.bold: true; color: "#00ffff" }
                                    Text {
                                        text: modelData.descripcion || "Receta sin descripción"
                                        font.pixelSize: 12
                                        color: "#8080a0"
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                    }
                                }

                                Column {
                                    width: 220
                                    spacing: 4
                                    Text { text: `Costo: $${modelData.costo_total.toFixed(2)}`; font.pixelSize: 13; color: "#ff0080" }
                                    Text { text: `Precio: $${modelData.precio_sugerido.toFixed(2)}`; font.pixelSize: 13; color: "#00ff80" }
                                    Text { text: `Margen: ${(modelData.margen * 100).toFixed(0)}%`; font.pixelSize: 12; color: "#00ffff" }
                                }

                                Column {
                                    width: 160
                                    spacing: 6
                                    Button {
                                        text: "Editar"
                                        width: parent.width
                                        height: 30
                                        background: Rectangle { color: "#00ff80"; radius: 4 }
                                        contentItem: Text { text: parent.text; color: "#050510"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                        onClicked: prepararEdicionReceta(modelData)
                                    }
                                    Button {
                                        text: "Eliminar"
                                        width: parent.width
                                        height: 30
                                        background: Rectangle { color: "#ff0055"; radius: 4 }
                                        contentItem: Text { text: parent.text; color: "#ffffff"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                        onClicked: eliminarReceta(modelData)
                                    }
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: 10
                                Repeater {
                                    model: modelData.items
                                    Rectangle {
                                        width: 200
                                        height: 50
                                        radius: 6
                                        color: "#0f0f1f"
                                        border.color: modelData.stock <= modelData.min_stock ? "#ff0055" : "#00ffff"
                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 6
                                            spacing: 2
                                            Text { text: `${modelData.ingrediente_nombre}`; color: "#e0e0ff"; font.pixelSize: 12 }
                                            Text {
                                                text: `${modelData.cantidad} ${modelData.unidad || ''} (Stock: ${modelData.stock})`
                                                color: modelData.stock <= modelData.min_stock ? "#ff0055" : "#00ff80"
                                                font.pixelSize: 11
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                cargarRecetas()
                cargarIngredientesReceta()
            }

            function ingredienteActual() {
                if (comboIngrediente.currentIndex < 0 || comboIngrediente.currentIndex >= ingredientesDisponibles.length)
                    return null
                return ingredientesDisponibles[comboIngrediente.currentIndex]
            }

            function agregarIngredienteReceta() {
                mensajeReceta = ""
                var ingrediente = ingredienteActual()
                var cantidad = parseFloat(inputCantidadIngrediente.text)
                var merma = parseFloat(inputMermaIngrediente.text)

                if (!ingrediente) {
                    mensajeReceta = "Selecciona un ingrediente"
                    return
                }
                if (isNaN(cantidad) || cantidad <= 0) {
                    mensajeReceta = "Cantidad inválida"
                    return
                }
                if (isNaN(merma))
                    merma = 0

                var existente = itemsSeleccionados.findIndex(function(item) { return item.ingrediente_id === ingrediente.id })
                var nuevo = {
                    ingrediente_id: ingrediente.id,
                    ingrediente_nombre: ingrediente.nombre,
                    cantidad: cantidad,
                    merma: merma,
                    stock: ingrediente.stock,
                    min_stock: ingrediente.min_stock,
                    unidad: ingrediente.unidad
                }

                if (existente >= 0) {
                    itemsSeleccionados[existente] = nuevo
                } else {
                    itemsSeleccionados.push(nuevo)
                }

                itemsSeleccionados = itemsSeleccionados.slice()
                inputCantidadIngrediente.text = ""
                inputMermaIngrediente.text = ""
            }

            function enviarReceta() {
                mensajeReceta = ""
                var nombre = inputNombreReceta.text.trim()
                var descripcion = inputDescripcionReceta.text.trim()
                var margen = parseFloat(inputMargenReceta.text)

                if (!nombre) {
                    mensajeReceta = "El nombre es obligatorio"
                    return
                }
                if (itemsSeleccionados.length === 0) {
                    mensajeReceta = "Agrega al menos un ingrediente"
                    return
                }
                if (isNaN(margen))
                    margen = null

                var payload = {
                    nombre: nombre,
                    descripcion: descripcion,
                    margen: margen,
                    items: itemsSeleccionados.map(function(item) {
                        return {
                            ingrediente_id: item.ingrediente_id,
                            cantidad: item.cantidad,
                            merma: item.merma || 0
                        }
                    })
                }

                if (recetaEditando) {
                    api.put("/recetas/" + recetaEditando, payload, function(exito, resp) {
                        if (exito) {
                            notificacion.mostrar("Receta actualizada")
                            limpiarFormularioReceta()
                            mostrarFormulario = false
                            cargarRecetas()
                        } else {
                            mensajeReceta = resp && resp.detail ? resp.detail : "Error al actualizar"
                            notificacion.mostrar("Error al actualizar")
                        }
                    })
                } else {
                    api.post("/recetas/", payload, function(exito, resp) {
                        if (exito) {
                            notificacion.mostrar("Receta creada")
                            limpiarFormularioReceta()
                            mostrarFormulario = false
                            cargarRecetas()
                        } else {
                            mensajeReceta = resp && resp.detail ? resp.detail : "Error al crear"
                            notificacion.mostrar("Error al crear")
                        }
                    })
                }
            }

            function prepararEdicionReceta(datos) {
                recetaEditando = datos.id
                mostrarFormulario = true
                mensajeReceta = ""
                inputNombreReceta.text = datos.nombre
                inputDescripcionReceta.text = datos.descripcion || ""
                inputMargenReceta.text = datos.margen ? datos.margen.toString() : ""
                itemsSeleccionados = datos.items.map(function(item) {
                    return {
                        ingrediente_id: item.ingrediente_id,
                        ingrediente_nombre: item.ingrediente_nombre,
                        cantidad: item.cantidad,
                        merma: item.merma || 0,
                        stock: item.stock,
                        min_stock: item.min_stock,
                        unidad: item.unidad
                    }
                })
            }

            function eliminarReceta(datos) {
                if (!datos || !datos.id)
                    return

                api.del("/recetas/" + datos.id, function(exito, resp) {
                    if (exito) {
                        notificacion.mostrar("Receta eliminada")
                        if (recetaEditando === datos.id) {
                            limpiarFormularioReceta()
                            mostrarFormulario = false
                        }
                        cargarRecetas()
                    } else {
                        mensajeReceta = resp && resp.detail ? resp.detail : "Error al eliminar"
                        notificacion.mostrar("No se pudo eliminar")
                    }
                })
            }

            function limpiarFormularioReceta() {
                recetaEditando = null
                mensajeReceta = ""
                inputNombreReceta.text = ""
                inputDescripcionReceta.text = ""
                inputMargenReceta.text = ""
                itemsSeleccionados = []
                inputCantidadIngrediente.text = ""
                inputMermaIngrediente.text = ""
            }

            function cargarRecetas() {
                api.get("/recetas/", function(exito, datos) {
                    if (exito) {
                        recetas = datos
                    } else {
                        mensajeReceta = "No se pudieron cargar las recetas"
                    }
                })
            }

            function cargarIngredientesReceta() {
                api.get("/ingredientes/?limit=500", function(exito, datos) {
                    if (exito) {
                        ingredientesDisponibles = datos
                    }
                })
            }
        }
    }
    
    // ============================================
    // VENTAS CON CARRITO FUNCIONAL
    // ============================================
    Component {
        id: pantallaVentas
        
            Row {
                anchors.fill: parent
                spacing: 0

                property var recetas: []
                property var ventas: []
                property var carrito: []
                property real total: 0
                property int recetaSeleccionadaIndex: -1
                property string mensajeVenta: ""
            
            // Panel izquierdo - POS
            Rectangle {
                width: parent.width * 0.55
                height: parent.height
                color: "#050510"
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 40
                    spacing: 25
                    
                    Text {
                        text: "Punto de Venta"
                        font.pixelSize: 28
                        font.bold: true
                        color: "#00ffff"
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: parent.height - 100
                        color: "#0a0a1f"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 25
                            spacing: 20
                            
                            Text {
                                text: "Productos disponibles:"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#e0e0ff"
                            }

                            Row {
                                spacing: 12
                                width: parent.width

                                ComboBox {
                                    id: selectorReceta
                                    width: parent.width * 0.5
                                    model: recetas
                                    textRole: "nombre"
                                    onActivated: mensajeVenta = ""
                                }

                                TextField {
                                    id: inputCantidadVenta
                                    width: 90
                                    text: "1"
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    validator: DoubleValidator { bottom: 0.01 }
                                    placeholderText: "Cantidad"
                                }

                                Button {
                                    width: parent.width * 0.2
                                    height: 40
                                    text: "Agregar"
                                    enabled: selectorReceta.currentIndex >= 0 && parseFloat(inputCantidadVenta.text) > 0
                                    background: Rectangle {
                                        color: parent.enabled ? "#00ff80" : "#404050"
                                        radius: 8
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#050510"
                                        font.bold: true
                                        font.pixelSize: 14
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                        var receta = selectorReceta.currentIndex >= 0 ? recetas[selectorReceta.currentIndex] : null
                                        var cantidad = parseFloat(inputCantidadVenta.text)
                                        agregarAlCarrito(receta, cantidad)
                                        inputCantidadVenta.text = "1"
                                    }
                                }
                            }
                            
                            ListView {
                                width: parent.width
                                height: 250
                                spacing: 12
                                clip: true
                                model: recetas
                                
                                delegate: Rectangle {
                                    width: parent.width
                                    height: 60
                                    color: "#1a1a2f"
                                    border.color: "#00ffff"
                                    border.width: 1
                                    radius: 8
                                    
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        spacing: 15
                                        
                                        Text {
                                            text: modelData.nombre
                                            font.pixelSize: 15
                                            font.bold: true
                                            color: "#e0e0ff"
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - 150
                                        }
                                        
                                        Button {
                                            text: "+"
                                            width: 45
                                            height: 45
                                            background: Rectangle {
                                                color: "#00ffff"
                                                radius: 8
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                font.pixelSize: 20
                                                font.bold: true
                                                color: "#050510"
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                            onClicked: {
                                                agregarAlCarrito(modelData)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Text {
                                text: "Carrito:"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#e0e0ff"
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 120
                                color: "#1a1a2f"
                                border.color: "#00ffff"
                                border.width: 1
                                radius: 6
                                
                                ListView {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 5
                                    clip: true
                                    model: carrito
                                    
                                delegate: Row {
                                    width: parent.width
                                    spacing: 10

                                    Text {
                                        text: "• " + modelData.nombre
                                        font.pixelSize: 12
                                        color: "#e0e0ff"
                                        width: parent.width - 220
                                    }

                                    Row {
                                        spacing: 6

                                        Button {
                                            width: 28
                                            height: 28
                                            text: "-"
                                            enabled: modelData.cantidad > 1
                                            background: Rectangle { color: parent.enabled ? "#1a1a2f" : "#303040"; border.color: "#00ffff"; radius: 4 }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#e0e0ff"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            onClicked: ajustarCantidadCarrito(index, -1)
                                        }

                                        Text {
                                            text: "x" + modelData.cantidad
                                            font.pixelSize: 12
                                            color: "#e0e0ff"
                                        }

                                        Button {
                                            width: 28
                                            height: 28
                                            text: "+"
                                            background: Rectangle { color: "#1a1a2f"; border.color: "#00ffff"; radius: 4 }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#e0e0ff"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            onClicked: ajustarCantidadCarrito(index, 1)
                                        }
                                    }

                                    Button {
                                        width: 80
                                        height: 28
                                        text: "Eliminar"
                                        background: Rectangle { color: "#ff0055"; radius: 4 }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#ffffff"
                                            font.pixelSize: 11
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: eliminarItemCarrito(index)
                                    }

                                    Text {
                                        text: "$" + (modelData.precio * modelData.cantidad).toFixed(2)
                                        font.pixelSize: 12
                                            font.bold: true
                                            color: "#00ff80"
                                        }
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 3
                                color: "#00ffff"
                                opacity: 0.5
                            }
                            
                            Row {
                                width: parent.width
                                Text {
                                    text: "TOTAL:"
                                    font.pixelSize: 22
                                    font.bold: true
                                    color: "#8080a0"
                                }
                                Item { width: parent.width - 250 }
                                Text {
                                    text: "$" + total.toFixed(2)
                                    font.pixelSize: 28
                                    font.bold: true
                                    color: "#00ff80"
                                }
                            }
                            
                            Row {
                                width: parent.width
                                spacing: 10
                                
                                Button {
                                    width: (parent.width - 10) / 2
                                    height: 50
                                    text: "LIMPIAR"
                                    enabled: carrito.length > 0
                                    background: Rectangle {
                                        color: parent.enabled ? "#ff0055" : "#404050"
                                        radius: 8
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font.bold: true
                                        font.pixelSize: 16
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    onClicked: limpiarCarrito()
                                }
                                
                                Button {
                                    width: (parent.width - 10) / 2
                                    height: 50
                                    text: "REGISTRAR VENTA"
                                    enabled: carrito.length > 0
                                    background: Rectangle {
                                        color: parent.enabled ? "#00ff80" : "#404050"
                                        radius: 8
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#050510"
                                        font.bold: true
                                        font.pixelSize: 16
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    onClicked: procesarVenta()
                                }
                            }

                            Text {
                                visible: mensajeVenta !== ""
                                text: mensajeVenta
                                font.pixelSize: 12
                                color: "#ff0055"
                            }
                        }
                    }
                }
            }
            
            // Panel derecho - Historial
            Rectangle {
                width: parent.width * 0.45
                height: parent.height
                color: "#050510"
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 40
                    spacing: 25
                    
                    Text {
                        text: "Ventas Recientes"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#00ffff"
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: parent.height - 100
                        color: "#0a0a1f"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 10
                        
                        ListView {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12
                            clip: true
                            model: ventas
                            
                            delegate: Rectangle {
                                width: parent.width
                                height: 65
                                color: "#1a1a2f"
                                border.color: "#00ffff"
                                border.width: 1
                                radius: 8
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 15
                                    
                                    Text {
                                        text: "#" + modelData.id
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#8080a0"
                                        width: 50
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 4
                                        Text {
                                            text: "Venta " + modelData.id
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "#e0e0ff"
                                        }
                                        Text {
                                            text: modelData.sucursal || "Sin sucursal"
                                            font.pixelSize: 11
                                            color: "#8080a0"
                                        }
                                    }
                                    
                                    Item { width: parent.width - 300 }
                                    
                                    Text {
                                        text: "$" + modelData.total.toFixed(2)
                                        font.pixelSize: 17
                                        font.bold: true
                                        color: "#00ff80"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Component.onCompleted: {
                api.get("/recetas/", function(exito, datos) {
                    if (exito) {
                        recetas = datos
                        if (selectorReceta && recetas.length > 0) {
                            selectorReceta.currentIndex = 0
                        }
                        recetaSeleccionadaIndex = selectorReceta ? selectorReceta.currentIndex : -1
                    } else {
                        mensajeVenta = "No se pudieron cargar las recetas"
                    }
                })
                cargarVentas()
            }
            
            function cargarVentas() {
                api.get("/ventas/?limit=20", function(exito, datos) {
                    if (exito) {
                        ventas = datos
                        mensajeVenta = ""
                    } else {
                        mensajeVenta = "No se pudieron cargar las ventas"
                    }
                })
            }
            
            function precioReceta(receta) {
                if (!receta)
                    return 0

                if (receta.precio_sugerido !== undefined)
                    return receta.precio_sugerido

                if (receta.costo_total !== undefined && receta.margen !== undefined)
                    return receta.costo_total * (1 + receta.margen)

                return 0
            }

            function agregarAlCarrito(receta, cantidad) {
                if (!receta) {
                    mensajeVenta = "Selecciona una receta"
                    return
                }

                var cantidadNumerica = cantidad || 1
                if (cantidadNumerica <= 0) {
                    mensajeVenta = "La cantidad debe ser mayor a 0"
                    return
                }

                var precioUnitario = precioReceta(receta)
                var encontrado = false
                // Buscar si ya existe en el carrito
                for (var i = 0; i < carrito.length; i++) {
                    if (carrito[i].receta_id === receta.id) {
                        carrito[i].cantidad += cantidadNumerica
                        carrito[i].precio = precioUnitario
                        encontrado = true
                        break
                    }
                }

                if (!encontrado) {
                    carrito.push({
                        receta_id: receta.id,
                        nombre: receta.nombre,
                        cantidad: cantidadNumerica,
                        precio: precioUnitario
                    })
                }

                // Forzar actualización
                carrito = carrito.slice()
                calcularTotal()
            }
            
            function calcularTotal() {
                var suma = 0
                for (var i = 0; i < carrito.length; i++) {
                    suma += carrito[i].precio * carrito[i].cantidad
                }
                total = suma
            }

            function limpiarCarrito() {
                carrito = []
                total = 0
                mensajeVenta = ""
            }

            function ajustarCantidadCarrito(indice, delta) {
                if (indice < 0 || indice >= carrito.length)
                    return

                var nuevoValor = carrito[indice].cantidad + delta
                if (nuevoValor <= 0) {
                    carrito.splice(indice, 1)
                } else {
                    carrito[indice].cantidad = nuevoValor
                }

                carrito = carrito.slice()
                calcularTotal()
            }

            function eliminarItemCarrito(indice) {
                if (indice < 0 || indice >= carrito.length)
                    return

                carrito.splice(indice, 1)
                carrito = carrito.slice()
                calcularTotal()
            }

            function procesarVenta() {
                if (carrito.length === 0) {
                    mensajeVenta = "Agrega al menos una receta"
                    return
                }

                var items = []
                for (var i = 0; i < carrito.length; i++) {
                    items.push({
                        receta_id: carrito[i].receta_id,
                        cantidad: carrito[i].cantidad
                    })
                }
                
                var ventaData = {
                    sucursal: "Centro",
                    items: items
                }
                
                api.post("/ventas/", ventaData, function(exito, respuesta) {
                    if (exito) {
                        notificacion.mostrar("Venta procesada: #" + respuesta.id + " - $" + respuesta.total.toFixed(2))
                        limpiarCarrito()
                        cargarVentas()
                    } else if (respuesta && respuesta.detail) {
                        mensajeVenta = respuesta.detail
                    } else {
                        mensajeVenta = "Error al procesar venta"
                    }
                })
            }
        }
    }
    
    // ============================================
      // USUARIOS
      // ============================================
      Component {
          id: pantallaUsuarios

          Column {
              anchors.fill: parent
              anchors.margins: 40
              spacing: 25

              property var usuarios: []
              property bool mostrarFormulario: false
              property int usuarioEditando: -1
              property var rolesDisponibles: ["ADMIN", "DUENO", "GERENTE", "VENDEDOR"]

              Item {
                  width: parent.width
                  height: 50

                  Text {
                      anchors.left: parent.left
                      anchors.verticalCenter: parent.verticalCenter
                      text: "Gestión de Usuarios"
                      font.pixelSize: 28
                      font.bold: true
                      color: "#00ffff"
                  }

                  Row {
                      anchors.right: parent.right
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: 12

                      Button {
                          text: mostrarFormulario ? "Cancelar" : "+ Nuevo Usuario"
                          width: 170
                          height: 40
                          background: Rectangle {
                              color: mostrarFormulario ? "#ff0055" : "#00ff80"
                              radius: 6
                          }
                          contentItem: Text {
                              text: parent.text
                              color: "#050510"
                              font.bold: true
                              horizontalAlignment: Text.AlignHCenter
                          }
                          onClicked: {
                              if (mostrarFormulario) {
                                  limpiarFormulario()
                              } else {
                                  prepararNuevo()
                              }
                          }
                      }

                      Button {
                          text: "Recargar"
                          width: 120
                          height: 40
                          background: Rectangle {
                              color: "#00ffff"
                              radius: 6
                          }
                          contentItem: Text {
                              text: parent.text
                              color: "#050510"
                              font.bold: true
                              horizontalAlignment: Text.AlignHCenter
                          }
                          onClicked: cargarUsuarios()
                      }
                  }
              }

              Rectangle {
                  width: parent.width
                  height: 240
                  visible: mostrarFormulario
                  color: "#0a0a1f"
                  border.color: "#00ffff"
                  border.width: 2
                  radius: 10

                  Column {
                      anchors.fill: parent
                      anchors.margins: 20
                      spacing: 14

                      Text {
                          text: usuarioEditando >= 0 ? "Editar Usuario" : "Nuevo Usuario"
                          font.pixelSize: 18
                          font.bold: true
                          color: "#00ffff"
                      }

                      Row {
                          width: parent.width
                          spacing: 12

                          Column {
                              width: (parent.width - 24) / 2
                              spacing: 6
                              Text {
                                  text: "Username"
                                  font.pixelSize: 12
                                  color: "#8080a0"
                              }
                              TextField {
                                  id: inputUsername
                                  width: parent.width
                                  enabled: usuarioEditando < 0
                                  placeholderText: "admin"
                                  color: "#e0e0ff"
                                  background: Rectangle {
                                      color: "transparent"
                                      border.color: "#00ffff"
                                      border.width: 1
                                      radius: 4
                                  }
                              }
                          }

                          Column {
                              width: (parent.width - 24) / 2
                              spacing: 6
                              Text {
                                  text: "Nombre"
                                  font.pixelSize: 12
                                  color: "#8080a0"
                              }
                              TextField {
                                  id: inputNombreUsuario
                                  width: parent.width
                                  placeholderText: "Administrador"
                                  color: "#e0e0ff"
                                  background: Rectangle {
                                      color: "transparent"
                                      border.color: "#00ffff"
                                      border.width: 1
                                      radius: 4
                                  }
                              }
                          }
                      }

                      Row {
                          width: parent.width
                          spacing: 12

                          Column {
                              width: (parent.width - 24) / 2
                              spacing: 6
                              Text {
                                  text: "Rol"
                                  font.pixelSize: 12
                                  color: "#8080a0"
                              }
                              ComboBox {
                                  id: inputRol
                                  width: parent.width
                                  model: rolesDisponibles
                                  currentIndex: 0
                              }
                          }

                          Column {
                              width: (parent.width - 24) / 2
                              spacing: 6
                              Text {
                                  text: usuarioEditando >= 0 ? "Actualizar contraseña (opcional)" : "Contraseña"
                                  font.pixelSize: 12
                                  color: "#8080a0"
                              }
                              TextField {
                                  id: inputPassword
                                  width: parent.width
                                  echoMode: TextInput.Password
                                  placeholderText: usuarioEditando >= 0 ? "Deja vacío para mantener" : "********"
                                  color: "#e0e0ff"
                                  background: Rectangle {
                                      color: "transparent"
                                      border.color: "#00ffff"
                                      border.width: 1
                                      radius: 4
                                  }
                              }
                          }
                      }

                      Row {
                          width: parent.width
                          spacing: 12

                          Button {
                              text: usuarioEditando >= 0 ? "ACTUALIZAR USUARIO" : "GUARDAR USUARIO"
                              width: 210
                              height: 40
                              background: Rectangle {
                                  color: "#00ff80"
                                  radius: 6
                              }
                              contentItem: Text {
                                  text: parent.text
                                  color: "#050510"
                                  font.bold: true
                                  horizontalAlignment: Text.AlignHCenter
                              }
                              onClicked: guardarUsuario()
                          }

                          Button {
                              text: "Limpiar"
                              width: 120
                              height: 40
                              background: Rectangle {
                                  color: "#ff0080"
                                  radius: 6
                              }
                              contentItem: Text {
                                  text: parent.text
                                  color: "#050510"
                                  font.bold: true
                                  horizontalAlignment: Text.AlignHCenter
                              }
                              onClicked: prepararNuevo()
                          }
                      }
                  }
              }

              Rectangle {
                  width: parent.width
                  height: parent.height - (mostrarFormulario ? 340 : 120)
                  color: "#0a0a1f"
                  border.color: "#00ffff"
                  border.width: 2
                radius: 10
                
                ListView {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                      clip: true
                      model: usuarios

                      delegate: Rectangle {
                          width: parent.width
                          height: 100
                          color: "#1a1a2f"
                          border.color: "#00ffff"
                          border.width: 1
                          radius: 8

                          Row {
                              anchors.fill: parent
                              anchors.margins: 15
                              spacing: 18

                              Column {
                                  width: 260
                                  anchors.verticalCenter: parent.verticalCenter
                                  spacing: 5

                                  Text {
                                    text: modelData.username
                                    font.pixelSize: 16
                                      font.bold: true
                                      color: "#e0e0ff"
                                  }
                                  Text {
                                      text: modelData.nombre || "Sin nombre"
                                    font.pixelSize: 12
                                    color: "#8080a0"
                                  }
                              }

                              Rectangle {
                                  width: 90
                                  height: 32
                                  color: "#ff008030"
                                  border.color: "#ff0080"
                                  border.width: 1
                                  radius: 6
                                  anchors.verticalCenter: parent.verticalCenter
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.rol
                                      font.pixelSize: 12
                                      font.bold: true
                                      color: "#ff0080"
                                  }
                              }

                              Row {
                                  spacing: 8
                                  anchors.verticalCenter: parent.verticalCenter

                                  Text {
                                      text: modelData.activo ? "Activo" : "Inactivo"
                                      font.pixelSize: 12
                                      color: modelData.activo ? "#00ff80" : "#ff0055"
                                      anchors.verticalCenter: parent.verticalCenter
                                  }

                                  Switch {
                                      checked: modelData.activo
                                      onToggled: cambiarEstado(modelData.id, checked)
                                  }
                              }

                              Item { width: parent.width - 620 }

                              Button {
                                  text: "Editar"
                                  width: 100
                                  height: 35
                                  anchors.verticalCenter: parent.verticalCenter
                                  background: Rectangle {
                                      color: "#00ff80"
                                      radius: 6
                                  }
                                  contentItem: Text {
                                      text: parent.text
                                      color: "#050510"
                                      font.bold: true
                                      horizontalAlignment: Text.AlignHCenter
                                  }
                                  onClicked: {
                                      prepararEdicion(modelData)
                                  }
                              }

                              Button {
                                  text: modelData.activo ? "Desactivar" : "Activar"
                                  width: 110
                                  height: 35
                                  anchors.verticalCenter: parent.verticalCenter
                                  background: Rectangle {
                                      color: modelData.activo ? "#ff0055" : "#00ffff"
                                      radius: 6
                                  }
                                  contentItem: Text {
                                      text: parent.text
                                      color: "#050510"
                                      font.bold: true
                                      horizontalAlignment: Text.AlignHCenter
                                  }
                                  onClicked: cambiarEstado(modelData.id, !modelData.activo)
                              }
                          }
                      }
                  }
              }

              Component.onCompleted: cargarUsuarios()

              function cargarUsuarios() {
                  api.get("/auth/usuarios", function(exito, datos) {
                      if (exito) {
                          usuarios = datos
                      }
                  })
              }

              function prepararNuevo() {
                  usuarioEditando = -1
                  mostrarFormulario = true
                  inputUsername.text = ""
                  inputNombreUsuario.text = ""
                  inputPassword.text = ""
                  inputRol.currentIndex = 0
              }

              function prepararEdicion(usuario) {
                  usuarioEditando = usuario.id
                  mostrarFormulario = true
                  inputUsername.text = usuario.username
                  inputNombreUsuario.text = usuario.nombre || ""
                  inputPassword.text = ""
                  var idx = rolesDisponibles.indexOf(usuario.rol)
                  inputRol.currentIndex = idx >= 0 ? idx : 0
              }

              function limpiarFormulario() {
                  usuarioEditando = -1
                  mostrarFormulario = false
                  inputUsername.text = ""
                  inputNombreUsuario.text = ""
                  inputPassword.text = ""
                  inputRol.currentIndex = 0
              }

              function guardarUsuario() {
                  var datos = {
                      nombre: inputNombreUsuario.text,
                      rol: inputRol.currentText
                  }

                  if (usuarioEditando < 0) {
                      datos.username = inputUsername.text
                      datos.password = inputPassword.text

                      if (!datos.username || !datos.password) {
                          notificacion.mostrar("Username y contraseña son obligatorios")
                          return
                      }

                      api.post("/auth/usuarios", datos, function(exito, resp) {
                          if (exito) {
                              notificacion.mostrar("Usuario creado")
                              limpiarFormulario()
                              cargarUsuarios()
                          } else {
                              notificacion.mostrar("Error al crear usuario")
                          }
                      })
                  } else {
                      if (inputPassword.text.length > 0) {
                          datos.password = inputPassword.text
                      }

                      api.put("/auth/usuarios/" + usuarioEditando, datos, function(exito, resp) {
                          if (exito) {
                              notificacion.mostrar("Usuario actualizado")
                              limpiarFormulario()
                              cargarUsuarios()
                          } else {
                              notificacion.mostrar("Error al actualizar usuario")
                          }
                      })
                  }
              }

              function cambiarEstado(usuarioId, activo) {
                  api.patch("/auth/usuarios/" + usuarioId + "/estado?activo=" + activo, {}, function(exito, resp) {
                      if (exito) {
                          notificacion.mostrar(activo ? "Usuario activado" : "Usuario desactivado")
                          cargarUsuarios()
                      } else {
                          notificacion.mostrar("Error al cambiar estado")
                      }
                  })
              }
          }
      }
    
    // ============================================
    // LOGS
    // ============================================
    Component {
        id: pantallaLogs
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            property var logs: []
            
            Row {
                width: parent.width
                
                Text {
                    text: "Logs de Auditoría"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { width: parent.width - 500 }
                
                Button {
                    text: "Recargar"
                    width: 120
                    height: 40
                    background: Rectangle {
                        color: "#00ffff"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#050510"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: cargarLogs()
                }
            }
            
            Rectangle {
                width: parent.width
                height: parent.height - 100
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10
                
                ListView {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10
                    clip: true
                    model: logs
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 70
                        color: modelData.exito ? "#1a2f1a" : "#2f1a1a"
                        border.color: modelData.exito ? "#00ff80" : "#ff0055"
                        border.width: 1
                        radius: 8
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 15
                            
                            Text {
                                text: modelData.exito ? "✓" : "✗"
                                font.pixelSize: 24
                                font.bold: true
                                color: modelData.exito ? "#00ff80" : "#ff0055"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Column {
                                width: 200
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                
                                Text {
                                    text: modelData.usuario_nombre || "Sistema"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#e0e0ff"
                                }
                                Text {
                                    text: modelData.accion
                                    font.pixelSize: 11
                                    color: "#8080a0"
                                }
                            }
                            
                            Text {
                                text: modelData.ip || "N/A"
                                font.pixelSize: 12
                                color: "#00ffff"
                                anchors.verticalCenter: parent.verticalCenter
                                width: 120
                            }
                            
                            Item { width: parent.width - 550 }
                            
                            Text {
                                text: new Date(modelData.creado_en).toLocaleString()
                                font.pixelSize: 11
                                color: "#8080a0"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
            
            Component.onCompleted: cargarLogs()
            
            function cargarLogs() {
                api.get("/logs/", function(exito, datos) {
                    if (exito) {
                        logs = datos
                    }
                })
            }
        }
    }
}
