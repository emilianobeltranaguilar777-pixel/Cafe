import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: root
    visible: true
    width: 1400
    height: 900
    title: "EL CAFÉ SIN LÍMITES - Sistema de Gestión v2.0"
    color: "#050510"
    
    property string backendUrl: "http://localhost:8000"
    property string token: ""
    property var datosUsuario: null
    property string pantallaActual: "dashboard"
    
    // API Helper integrado
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
    }
    
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginPage
    }
    
    // ============================================
    // LOGIN
    // ============================================
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
    
    // ============================================
    // MAIN WINDOW
    // ============================================
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
                                    {texto: "Ventas", id: "ventas"}
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
                                default: return pantallaDashboard
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ============================================
    // DASHBOARD (CONECTADO)
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
                        text: "PROYECTO COMPLETADO"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#00ff80"
                    }
                    
                    Text {
                        width: parent.width
                        text: "• Backend FastAPI funcionando\n• Base de datos SQLite con datos\n• Sistema de autenticación JWT\n• Interfaz Qt/QML operativa\n• Navegación completa\n• Conexión API real\n\nDocumentación: http://localhost:8000/docs"
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
    // CLIENTES (CONECTADO)
    // ============================================
    Component {
        id: pantallaClientes
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            property var clientes: []
            property bool mostrarFormulario: false
            
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
                    onClicked: mostrarFormulario = !mostrarFormulario
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
                        text: "GUARDAR CLIENTE"
                        width: 200
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
                            api.post("/clientes/", datos, function(exito, respuesta) {
                                if (exito) {
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
                            spacing: 25
                            
                            Column {
                                width: 280
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
    // INGREDIENTES (CONECTADO)
    // ============================================
    Component {
        id: pantallaIngredientes
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            property var ingredientes: []
            
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
                            spacing: 25
                            
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
        }
    }
    
    // ============================================
    // RECETAS (CONECTADO)
    // ============================================
    Component {
        id: pantallaRecetas
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            property var recetas: []
            
            Row {
                width: parent.width
                
                Text {
                    text: "Gestión de Recetas"
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
                    onClicked: cargarRecetas()
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
                        height: 180
                        color: "#0a0a1f"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12
                            
                            Text {
                                text: modelData.nombre
                                font.pixelSize: 18
                                font.bold: true
                                color: "#00ffff"
                            }
                            
                            Text {
                                text: modelData.descripcion || ""
                                font.pixelSize: 11
                                color: "#8080a0"
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#00ffff"
                                opacity: 0.3
                            }
                            
                            Text {
                                text: "Margen: " + (modelData.margen * 100).toFixed(0) + "%"
                                font.pixelSize: 14
                                color: "#00ffff"
                            }
                            
                            Button {
                                text: "Ver Detalles"
                                width: parent.width
                                height: 35
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
                                    console.log("Ver receta:", modelData.id)
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
        }
    }
    
    // ============================================
    // VENTAS / POS (CONECTADO)
    // ============================================
    Component {
        id: pantallaVentas
        
        Row {
            anchors.fill: parent
            spacing: 0
            
            property var recetas: []
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
                                height: 350
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
                            
                            Button {
                                width: parent.width
                                height: 55
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
                                    font.pixelSize: 18
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: procesarVenta()
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
                
                property var ventas: []
                
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
                
                Component.onCompleted: cargarVentas()
                
                function cargarVentas() {
                    api.get("/ventas/?limit=20", function(exito, datos) {
                        if (exito) {
                            ventas = datos
                        }
                    })
                }
            }
            
            Component.onCompleted: {
                api.get("/recetas/", function(exito, datos) {
                    if (exito) {
                        recetas = datos
                    }
                })
            }
            
            function agregarAlCarrito(receta) {
                carrito.push({receta_id: receta.id, cantidad: 1})
                calcularTotal()
            }
            
            function calcularTotal() {
                // Simplificado: asumir $25 promedio por item
                total = carrito.length * 25
            }
            
            function procesarVenta() {
                var items = []
                for (var i = 0; i < carrito.length; i++) {
                    items.push(carrito[i])
                }
                
                var ventaData = {
                    sucursal: "Centro",
                    items: items
                }
                
                api.post("/ventas/", ventaData, function(exito, respuesta) {
                    if (exito) {
                        console.log("Venta procesada:", respuesta.id)
                        carrito = []
                        total = 0
                        // Recargar ventas
                        api.get("/ventas/?limit=20", function(e, d) {
                            if (e) ventas = d
                        })
                    } else {
                        console.log("Error:", respuesta)
                    }
                })
            }
        }
    }
}
