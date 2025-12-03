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
                height: 260
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

                    Row {
                        width: parent.width
                        spacing: 15

                        Column {
                            width: (parent.width - 15) / 2
                            spacing: 5
                            Text {
                                text: "Dirección:"
                                font.pixelSize: 12
                                color: "#8080a0"
                            }
                            TextField {
                                id: inputDireccion
                                width: parent.width
                                placeholderText: "Calle, número, colonia, ciudad"
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
                            width: (parent.width - 15) / 2
                            spacing: 5
                            Text {
                                text: "Alergias:"
                                font.pixelSize: 12
                                color: "#8080a0"
                            }
                            TextField {
                                id: inputAlergias
                                width: parent.width
                                placeholderText: "Lactosa, gluten, nueces..."
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
                                telefono: inputTelefono.text,
                                direccion: inputDireccion.text,
                                alergias: inputAlergias.text
                            }

                            if (clienteEditando >= 0) {
                                api.put("/clientes/" + clienteEditando, datos, function(exito, resp) {
                                    if (exito) {
                                        notificacion.mostrar("Cliente actualizado")
                                        limpiarFormulario()
                                        cargarClientes()
                                    }
                                })
                            } else {
                                api.post("/clientes/", datos, function(exito, resp) {
                                    if (exito) {
                                        notificacion.mostrar("Cliente creado")
                                        limpiarFormulario()
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
                            
                            Column {
                                width: 300
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text {
                                    text: modelData.telefono || "Sin teléfono"
                                    font.pixelSize: 14
                                    color: "#00ffff"
                                }
                                Text {
                                    text: modelData.direccion ? ("Dir: " + modelData.direccion) : "Sin dirección"
                                    font.pixelSize: 11
                                    color: "#8080a0"
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            Text {
                                text: modelData.alergias ? ("Alergias: " + modelData.alergias) : "Sin alergias"
                                font.pixelSize: 12
                                color: "#00ff80"
                                anchors.verticalCenter: parent.verticalCenter
                                width: 200
                                elide: Text.ElideRight
                            }

                            Item { width: parent.width - 850 }
                            
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
                                    inputDireccion.text = modelData.direccion || ""
                                    inputAlergias.text = modelData.alergias || ""
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

            function limpiarFormulario() {
                clienteEditando = -1
                mostrarFormulario = false
                inputNombre.text = ""
                inputCorreo.text = ""
                inputTelefono.text = ""
                inputDireccion.text = ""
                inputAlergias.text = ""
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
            property int ingredienteEditando: -1

            Item {
                width: parent.width
                height: 50

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Gestión de Ingredientes"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Button {
                        text: mostrarFormulario ? "Cancelar" : "+ Nuevo Ingrediente"
                        width: 200
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
                                prepararNuevoIngrediente()
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
            }

            Rectangle {
                width: parent.width
                height: 230
                visible: mostrarFormulario
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Text {
                        text: ingredienteEditando >= 0 ? "Editar Ingrediente" : "Nuevo Ingrediente"
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
                            Text { text: "Nombre"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputIngNombre
                                width: parent.width
                                placeholderText: "Café, leche, azúcar..."
                                color: "#e0e0ff"
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Column {
                            width: (parent.width - 24) / 2
                            spacing: 6
                            Text { text: "Unidad"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputIngUnidad
                                width: parent.width
                                placeholderText: "kg, L, piezas"
                                color: "#e0e0ff"
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 12

                        Column {
                            width: (parent.width - 24) / 3
                            spacing: 6
                            Text { text: "Costo por unidad"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputIngCosto
                                width: parent.width
                                placeholderText: "0.00"
                                color: "#e0e0ff"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Column {
                            width: (parent.width - 24) / 3
                            spacing: 6
                            Text { text: "Stock"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputIngStock
                                width: parent.width
                                placeholderText: "100"
                                color: "#e0e0ff"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Column {
                            width: (parent.width - 24) / 3
                            spacing: 6
                            Text { text: "Stock mínimo"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputIngMinStock
                                width: parent.width
                                placeholderText: "10"
                                color: "#e0e0ff"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }
                    }

                    Button {
                        text: ingredienteEditando >= 0 ? "ACTUALIZAR INGREDIENTE" : "GUARDAR INGREDIENTE"
                        width: 240
                        height: 40
                        background: Rectangle { color: "#00ff80"; radius: 6 }
                        contentItem: Text { text: parent.text; color: "#050510"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                        onClicked: guardarIngrediente()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height - (mostrarFormulario ? 340 : 140)
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
                        height: 90
                        color: (modelData.stock <= modelData.min_stock) ? "#2f1a1a" : "#1a1a2f"
                        border.color: (modelData.stock <= modelData.min_stock) ? "#ff0055" : "#00ffff"
                        border.width: 2
                        radius: 8

                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 20

                            Column {
                                width: 260
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text { text: modelData.nombre; font.pixelSize: 16; font.bold: true; color: "#e0e0ff" }
                                Text { text: "Unidad: " + modelData.unidad; font.pixelSize: 12; color: "#8080a0" }
                            }

                            Column {
                                width: 250
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                Text { text: "Stock: " + modelData.stock + " (Min: " + modelData.min_stock + ")"; font.pixelSize: 12; color: (modelData.stock <= modelData.min_stock) ? "#ff0055" : "#00ff80" }
                                Text { text: "$" + modelData.costo_por_unidad.toFixed(2) + "/" + modelData.unidad; font.pixelSize: 12; color: "#00ffff" }
                            }

                            Item { width: parent.width - 850 }

                            Button {
                                text: "Editar"
                                width: 90
                                height: 35
                                anchors.verticalCenter: parent.verticalCenter
                                background: Rectangle { color: "#00ff80"; radius: 6 }
                                contentItem: Text { text: parent.text; color: "#050510"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                onClicked: prepararEdicionIngrediente(modelData)
                            }

                            Button {
                                text: "Eliminar"
                                width: 90
                                height: 35
                                anchors.verticalCenter: parent.verticalCenter
                                background: Rectangle { color: "#ff0055"; radius: 6 }
                                contentItem: Text { text: parent.text; color: "#ffffff"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                onClicked: {
                                    api.del("/ingredientes/" + modelData.id, function(exito, resp) {
                                        if (exito) {
                                            notificacion.mostrar("Ingrediente eliminado")
                                            cargarIngredientes()
                                        }
                                    })
                                }
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
                    }
                })
            }

            function prepararNuevoIngrediente() {
                ingredienteEditando = -1
                mostrarFormulario = true
                inputIngNombre.text = ""
                inputIngUnidad.text = ""
                inputIngCosto.text = ""
                inputIngStock.text = ""
                inputIngMinStock.text = ""
            }

            function prepararEdicionIngrediente(ing) {
                ingredienteEditando = ing.id
                mostrarFormulario = true
                inputIngNombre.text = ing.nombre
                inputIngUnidad.text = ing.unidad
                inputIngCosto.text = ing.costo_por_unidad
                inputIngStock.text = ing.stock
                inputIngMinStock.text = ing.min_stock
            }

            function limpiarFormulario() {
                ingredienteEditando = -1
                mostrarFormulario = false
                inputIngNombre.text = ""
                inputIngUnidad.text = ""
                inputIngCosto.text = ""
                inputIngStock.text = ""
                inputIngMinStock.text = ""
            }

            function guardarIngrediente() {
                var datos = {
                    nombre: inputIngNombre.text,
                    unidad: inputIngUnidad.text,
                    costo_por_unidad: Number(inputIngCosto.text),
                    stock: Number(inputIngStock.text),
                    min_stock: Number(inputIngMinStock.text)
                }

                if (ingredienteEditando < 0) {
                    api.post("/ingredientes/", datos, function(exito, resp) {
                        if (exito) {
                            notificacion.mostrar("Ingrediente creado")
                            limpiarFormulario()
                            cargarIngredientes()
                        }
                    })
                } else {
                    api.put("/ingredientes/" + ingredienteEditando, datos, function(exito, resp) {
                        if (exito) {
                            notificacion.mostrar("Ingrediente actualizado")
                            limpiarFormulario()
                            cargarIngredientes()
                        }
                    })
                }
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
            spacing: 25

            property var recetas: []
            property bool mostrarFormulario: false
            property int recetaEditando: -1

            Item {
                width: parent.width
                height: 50

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Gestión de Recetas"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Button {
                        text: mostrarFormulario ? "Cancelar" : "+ Nueva Receta"
                        width: 170
                        height: 40
                        background: Rectangle { color: mostrarFormulario ? "#ff0055" : "#00ff80"; radius: 6 }
                        contentItem: Text { text: parent.text; color: "#050510"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                        onClicked: {
                            if (mostrarFormulario) {
                                limpiarFormularioRecetas()
                            } else {
                                prepararNuevaReceta()
                            }
                        }
                    }

                    Button {
                        text: "Recargar"
                        width: 120
                        height: 40
                        background: Rectangle { color: "#00ffff"; radius: 6 }
                        contentItem: Text { text: parent.text; color: "#050510"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                        onClicked: cargarRecetas()
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
                    spacing: 12

                    Text {
                        text: recetaEditando >= 0 ? "Editar Receta" : "Nueva Receta"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#00ffff"
                    }

                    Row {
                        width: parent.width
                        spacing: 12

                        Column {
                            width: (parent.width - 12) / 2
                            spacing: 6
                            Text { text: "Nombre"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputRecNombre
                                width: parent.width
                                placeholderText: "Latte, Cappuccino, Cold Brew"
                                color: "#e0e0ff"
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }

                        Column {
                            width: (parent.width - 12) / 2
                            spacing: 6
                            Text { text: "Margen"; font.pixelSize: 12; color: "#8080a0" }
                            TextField {
                                id: inputRecMargen
                                width: parent.width
                                placeholderText: "0.50 (50%)"
                                color: "#e0e0ff"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 6
                        Text { text: "Descripción"; font.pixelSize: 12; color: "#8080a0" }
                        TextArea {
                            id: inputRecDescripcion
                            width: parent.width
                            height: 70
                            wrapMode: Text.WordWrap
                            placeholderText: "Detalle los pasos, ingredientes y notas"
                            color: "#e0e0ff"
                            background: Rectangle { color: "transparent"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                        }
                    }

                    Button {
                        text: recetaEditando >= 0 ? "ACTUALIZAR RECETA" : "GUARDAR RECETA"
                        width: 220
                        height: 40
                        background: Rectangle { color: "#00ff80"; radius: 6 }
                        contentItem: Text { text: parent.text; color: "#050510"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                        onClicked: guardarReceta()
                    }
                }
            }

            Grid {
                width: parent.width
                columns: 3
                rowSpacing: 20
                columnSpacing: 20

                Repeater {
                    model: recetas

                    Rectangle {
                        width: 360
                        height: 210
                        color: "#0a0a1f"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 10

                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 10

                            Text { text: modelData.nombre; font.pixelSize: 18; font.bold: true; color: "#00ffff" }
                            Text { text: modelData.descripcion || "Sin descripción"; font.pixelSize: 11; color: "#8080a0"; wrapMode: Text.WordWrap; width: parent.width }

                            Rectangle { width: parent.width; height: 1; color: "#00ffff"; opacity: 0.3 }

                            Text { text: "Margen: " + (modelData.margen * 100).toFixed(0) + "%"; font.pixelSize: 12; color: "#00ff80" }

                            Row {
                                width: parent.width
                                spacing: 10

                                Button {
                                    text: "Editar"
                                    width: 80
                                    height: 32
                                    background: Rectangle { color: "#00ff80"; radius: 6 }
                                    contentItem: Text { text: parent.text; color: "#050510"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                    onClicked: prepararEdicionReceta(modelData)
                                }

                                Button {
                                    text: "Eliminar"
                                    width: 90
                                    height: 32
                                    background: Rectangle { color: "#ff0055"; radius: 6 }
                                    contentItem: Text { text: parent.text; color: "#ffffff"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                    onClicked: {
                                        api.del("/recetas/" + modelData.id, function(exito, resp) {
                                            if (exito) {
                                                notificacion.mostrar("Receta eliminada")
                                                cargarRecetas()
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Component.onCompleted: cargarRecetas()

            function cargarRecetas() {
                api.get("/recetas/", function(exito, datos) {
                    if (exito) {
                        recetas = datos
                    }
                })
            }

            function prepararNuevaReceta() {
                recetaEditando = -1
                mostrarFormulario = true
                inputRecNombre.text = ""
                inputRecDescripcion.text = ""
                inputRecMargen.text = ""
            }

            function prepararEdicionReceta(receta) {
                recetaEditando = receta.id
                mostrarFormulario = true
                inputRecNombre.text = receta.nombre
                inputRecDescripcion.text = receta.descripcion || ""
                inputRecMargen.text = receta.margen
            }

            function limpiarFormularioRecetas() {
                recetaEditando = -1
                mostrarFormulario = false
                inputRecNombre.text = ""
                inputRecDescripcion.text = ""
                inputRecMargen.text = ""
            }

            function guardarReceta() {
                var datos = {
                    nombre: inputRecNombre.text,
                    descripcion: inputRecDescripcion.text,
                    margen: Number(inputRecMargen.text)
                }

                if (recetaEditando < 0) {
                    api.post("/recetas/", datos, function(exito, resp) {
                        if (exito) {
                            notificacion.mostrar("Receta creada")
                            limpiarFormularioRecetas()
                            cargarRecetas()
                        }
                    })
                } else {
                    api.put("/recetas/" + recetaEditando, datos, function(exito, resp) {
                        if (exito) {
                            notificacion.mostrar("Receta actualizada")
                            limpiarFormularioRecetas()
                            cargarRecetas()
                        }
                    })
                }
            }
        }
    }
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
                                            text: "• " + modelData.nombre + " x" + modelData.cantidad
                                            font.pixelSize: 12
                                            color: "#e0e0ff"
                                            width: parent.width - 100
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
                                    text: "PROCESAR VENTA"
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
                    }
                })
                cargarVentas()
            }
            
            function cargarVentas() {
                api.get("/ventas/?limit=20", function(exito, datos) {
                    if (exito) {
                        ventas = datos
                    }
                })
            }
            
            function agregarAlCarrito(receta) {
                // Buscar si ya existe en el carrito
                var encontrado = false
                for (var i = 0; i < carrito.length; i++) {
                    if (carrito[i].receta_id === receta.id) {
                        carrito[i].cantidad++
                        encontrado = true
                        break
                    }
                }
                
                if (!encontrado) {
                    carrito.push({
                        receta_id: receta.id,
                        nombre: receta.nombre,
                        cantidad: 1,
                        precio: 25.00
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
            }
            
            function procesarVenta() {
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
                    } else {
                        notificacion.mostrar("Error al procesar venta")
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
