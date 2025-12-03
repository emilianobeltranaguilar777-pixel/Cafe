import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: root
    visible: true
    width: 1400
    height: 900
    title: "LUA's Place"
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
                            text: "LUA's Place"
                            font.pixelSize: 28
                            font.bold: true
                            color: "#00eaff"

                            SequentialAnimation on color {
                                loops: Animation.Infinite
                                ColorAnimation { to: "#00ff95"; duration: 2000; easing.type: Easing.InOutSine }
                                ColorAnimation { to: "#00eaff"; duration: 2000; easing.type: Easing.InOutSine }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Where every cup tastes like stardust."
                            font.pixelSize: 13
                            font.italic: true
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
            spacing: 25

            property var stats: null

            Column {
                width: parent.width
                spacing: 8

                Row {
                    width: parent.width
                    spacing: 20

                    Text {
                        text: "Command Bridge"
                        font.pixelSize: 34
                        font.bold: true
                        font.letterSpacing: 1.5
                        color: "#00eaff"
                        anchors.verticalCenter: parent.verticalCenter

                        SequentialAnimation on color {
                            loops: Animation.Infinite
                            ColorAnimation { to: "#00ff95"; duration: 3000; easing.type: Easing.InOutSine }
                            ColorAnimation { to: "#00eaff"; duration: 3000; easing.type: Easing.InOutSine }
                        }
                    }

                    Item { width: parent.width - 700 }

                // The Lunar Bros Badge with Cyber Neon Pulse
                Rectangle {
                    id: creadorBadge
                    width: 350
                    height: 50
                    color: Qt.rgba(0, 0.92, 1, 0.1)
                    radius: 25
                    border.color: "#00eaff"
                    border.width: 2
                    anchors.verticalCenter: parent.verticalCenter

                    opacity: 1.0
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.7; duration: 1800; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
                    }

                    SequentialAnimation on border.color {
                        loops: Animation.Infinite
                        ColorAnimation { to: "#00ff95"; duration: 2500; easing.type: Easing.InOutSine }
                        ColorAnimation { to: "#00eaff"; duration: 2500; easing.type: Easing.InOutSine }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "🌙"
                            font.pixelSize: 22
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "The Lunar Bros"
                            font.pixelSize: 17
                            font.bold: true
                            font.letterSpacing: 1.5
                            color: "#00eaff"
                            anchors.verticalCenter: parent.verticalCenter

                            SequentialAnimation on color {
                                loops: Animation.Infinite
                                ColorAnimation { to: "#00ff95"; duration: 2500; easing.type: Easing.InOutSine }
                                ColorAnimation { to: "#00eaff"; duration: 2500; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }
                }

                Text {
                    text: "A cosmic overview of sales, activity and performance."
                    font.pixelSize: 14
                    font.italic: true
                    color: "#8080a0"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // First Row: Main Stats
            Grid {
                width: parent.width
                columns: 4
                spacing: 20

                Rectangle {
                    width: 260
                    height: 140
                    color: "#0a0a1f"
                    border.color: "#00ff95"
                    border.width: 2
                    radius: 12

                    SequentialAnimation on border.color {
                        loops: Animation.Infinite
                        ColorAnimation { to: "#00eaff"; duration: 2000; easing.type: Easing.InOutSine }
                        ColorAnimation { to: "#00ff95"; duration: 2000; easing.type: Easing.InOutSine }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Sales Today"
                            font.pixelSize: 13
                            font.letterSpacing: 0.8
                            color: "#8080a0"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: stats ? "$" + stats.ventas_hoy.toFixed(2) : "$0.00"
                            font.pixelSize: 28
                            font.bold: true
                            color: "#00ff95"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: stats ? stats.num_ventas_hoy + " transactions" : "0 transactions"
                            font.pixelSize: 11
                            color: "#8080a0"
                        }
                    }
                }

                Rectangle {
                    width: 260
                    height: 140
                    color: "#0a0a1f"
                    border.color: "#00eaff"
                    border.width: 2
                    radius: 12

                    SequentialAnimation on border.color {
                        loops: Animation.Infinite
                        ColorAnimation { to: "#00ff95"; duration: 2200; easing.type: Easing.InOutSine }
                        ColorAnimation { to: "#00eaff"; duration: 2200; easing.type: Easing.InOutSine }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Weekly Sales"
                            font.pixelSize: 13
                            font.letterSpacing: 0.8
                            color: "#8080a0"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: stats ? "$" + (stats.ventas_mes * 0.25).toFixed(2) : "$0.00"
                            font.pixelSize: 28
                            font.bold: true
                            color: "#00eaff"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Last 7 days"
                            font.pixelSize: 11
                            color: "#8080a0"
                        }
                    }
                }

                Rectangle {
                    width: 260
                    height: 140
                    color: "#0a0a1f"
                    border.color: stats && stats.alertas_stock > 0 ? "#ff0055" : "#00ff95"
                    border.width: 2
                    radius: 12

                    SequentialAnimation on border.color {
                        loops: Animation.Infinite
                        running: !(stats && stats.alertas_stock > 0)
                        ColorAnimation { to: "#00eaff"; duration: 2400; easing.type: Easing.InOutSine }
                        ColorAnimation { to: "#00ff95"; duration: 2400; easing.type: Easing.InOutSine }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Stock Alerts"
                            font.pixelSize: 13
                            font.letterSpacing: 0.8
                            color: "#8080a0"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: stats ? stats.alertas_stock.toString() : "0"
                            font.pixelSize: 28
                            font.bold: true
                            color: stats && stats.alertas_stock > 0 ? "#ff0055" : "#00ff95"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Low inventory"
                            font.pixelSize: 11
                            color: "#8080a0"
                        }
                    }
                }

                Rectangle {
                    width: 260
                    height: 140
                    color: "#0a0a1f"
                    border.color: "#00eaff"
                    border.width: 2
                    radius: 12

                    SequentialAnimation on border.color {
                        loops: Animation.Infinite
                        ColorAnimation { to: "#00ff95"; duration: 1800; easing.type: Easing.InOutSine }
                        ColorAnimation { to: "#00eaff"; duration: 1800; easing.type: Easing.InOutSine }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Active Users"
                            font.pixelSize: 13
                            font.letterSpacing: 0.8
                            color: "#8080a0"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "3"
                            font.pixelSize: 28
                            font.bold: true
                            color: "#00eaff"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "In session"
                            font.pixelSize: 11
                            color: "#8080a0"
                        }
                    }
                }
            }

            // Second Row: Additional Widgets
            Row {
                width: parent.width
                spacing: 20

                // Productos Más Vendidos
                Rectangle {
                    width: (parent.width - 20) / 2
                    height: 280
                    color: "#0a0a1f"
                    border.color: "#00ffff"
                    border.width: 2
                    radius: 12

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Row {
                            width: parent.width
                            spacing: 10

                            Text {
                                text: "🏆 Productos Más Vendidos"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#00ffff"
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#00ffff"
                            opacity: 0.3
                        }

                        Column {
                            width: parent.width
                            spacing: 10

                            Repeater {
                                model: ["Latte Vainilla", "Cappuccino Clásico", "Americano Doble", "Mocha Especial"]
                                Rectangle {
                                    width: parent.width
                                    height: 36
                                    color: "#1a1a2f"
                                    radius: 6
                                    border.color: "#00ffff"
                                    border.width: 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10

                                        Rectangle {
                                            width: 24
                                            height: 24
                                            radius: 12
                                            color: "#00ffff"
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                anchors.centerIn: parent
                                                text: (index + 1).toString()
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: "#050510"
                                            }
                                        }

                                        Text {
                                            text: modelData
                                            font.pixelSize: 13
                                            color: "#e0e0ff"
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - 150
                                        }

                                        Text {
                                            text: (15 - index * 2) + " ventas"
                                            font.pixelSize: 12
                                            color: "#8080a0"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Quick Stats
                Rectangle {
                    width: (parent.width - 20) / 2
                    height: 280
                    color: "#0a0a1f"
                    border.color: "#00ff80"
                    border.width: 2
                    radius: 12

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        Text {
                            text: "📊 Resumen Rápido"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#00ff80"
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#00ff80"
                            opacity: 0.3
                        }

                        Column {
                            width: parent.width
                            spacing: 12

                            Row {
                                width: parent.width
                                spacing: 10

                                Text {
                                    text: "🛒"
                                    font.pixelSize: 24
                                }

                                Column {
                                    Text {
                                        text: "Ventas del Mes"
                                        font.pixelSize: 12
                                        color: "#8080a0"
                                    }
                                    Text {
                                        text: stats ? "$" + stats.ventas_mes.toFixed(2) : "$0.00"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "#00ff80"
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#00ff80"
                                opacity: 0.1
                            }

                            Row {
                                width: parent.width
                                spacing: 10

                                Text {
                                    text: "📦"
                                    font.pixelSize: 24
                                }

                                Column {
                                    Text {
                                        text: "Ingredientes en Stock"
                                        font.pixelSize: 12
                                        color: "#8080a0"
                                    }
                                    Text {
                                        text: "12 disponibles"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#00ffff"
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#00ff80"
                                opacity: 0.1
                            }

                            Row {
                                width: parent.width
                                spacing: 10

                                Text {
                                    text: "🍰"
                                    font.pixelSize: 24
                                }

                                Column {
                                    Text {
                                        text: "Recetas Activas"
                                        font.pixelSize: 12
                                        color: "#8080a0"
                                    }
                                    Text {
                                        text: "8 productos"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#ff0080"
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#00ff80"
                                opacity: 0.1
                            }

                            Row {
                                width: parent.width
                                spacing: 10

                                Text {
                                    text: "✅"
                                    font.pixelSize: 24
                                }

                                Column {
                                    Text {
                                        text: "Estado del Sistema"
                                        font.pixelSize: 12
                                        color: "#8080a0"
                                    }
                                    Text {
                                        text: "Operativo"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#00ff80"
                                    }
                                }
                            }
                        }
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
            spacing: 20

            property var clientes: []
            property var clientesFiltrados: []
            property bool mostrarFormulario: false
            property int clienteEditando: -1
            property string busquedaClientes: ""

            onClientesChanged: aplicarFiltro()
            onBusquedaClientesChanged: {
                timerBusqueda.restart()
            }

            Timer {
                id: timerBusqueda
                interval: 300
                repeat: false
                onTriggered: aplicarFiltro()
            }

            Row {
                width: parent.width
                spacing: 15

                Text {
                    text: "👥 Gestión de Clientes"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: parent.width - 580 }

                Rectangle {
                    width: 50
                    height: 28
                    color: Qt.rgba(0, 1, 1, 0.2)
                    radius: 14
                    border.color: "#00ffff"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: clientesFiltrados.length.toString()
                        font.pixelSize: 14
                        font.bold: true
                        color: "#00ffff"
                    }
                }

                Button {
                    text: mostrarFormulario ? "✕ Cancelar" : "+ Nuevo Cliente"
                    width: 160
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

            // BARRA DE BÚSQUEDA
            Rectangle {
                width: parent.width
                height: 60
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10

                Row {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text {
                        text: "🔍"
                        font.pixelSize: 24
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        width: parent.width - 40
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        Text {
                            text: "Buscar cliente"
                            font.pixelSize: 11
                            color: "#8080a0"
                        }

                        TextField {
                            id: inputBusquedaClientes
                            width: parent.width
                            height: 32
                            placeholderText: "Buscar por nombre, correo o teléfono..."
                            color: "#e0e0ff"
                            font.pixelSize: 14
                            onTextChanged: busquedaClientes = text
                            background: Rectangle {
                                color: "transparent"
                                border.color: inputBusquedaClientes.focus ? "#00ffff" : "#8080a0"
                                border.width: inputBusquedaClientes.focus ? 2 : 1
                                radius: 4

                                Behavior on border.width {
                                    NumberAnimation { duration: 150 }
                                }
                            }
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
                height: parent.height - (mostrarFormulario ? 390 : 180)
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10

                ListView {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    clip: true
                    model: clientesFiltrados
                    
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

            function aplicarFiltro() {
                if (busquedaClientes === "") {
                    clientesFiltrados = clientes
                    return
                }

                var filtrados = []
                var busquedaLower = busquedaClientes.toLowerCase()

                for (var i = 0; i < clientes.length; i++) {
                    var cliente = clientes[i]
                    var nombre = (cliente.nombre || "").toLowerCase()
                    var correo = (cliente.correo || "").toLowerCase()
                    var telefono = (cliente.telefono || "").toLowerCase()

                    if (nombre.indexOf(busquedaLower) !== -1 ||
                        correo.indexOf(busquedaLower) !== -1 ||
                        telefono.indexOf(busquedaLower) !== -1) {
                        filtrados.push(cliente)
                    }
                }

                clientesFiltrados = filtrados
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
                        id: ingredienteCard
                        width: parent.width
                        height: 80
                        color: (modelData.stock <= modelData.min_stock) ? "#2f1a1a" : "#1a1a2f"
                        border.color: (modelData.stock <= modelData.min_stock) ? "#ff0055" : "#00ffff"
                        border.width: 2
                        radius: 8

                        scale: 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true
                            onEntered: ingredienteCard.scale = 1.02
                            onExited: ingredienteCard.scale = 1.0
                            onPressed: mouse.accepted = false
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 20

                            Column {
                                width: 300
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                Text {
                                    text: modelData.nombre
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#e0e0ff"
                                }
                                Text {
                                    text: "Stock: " + modelData.stock + " " + modelData.unidad + " (Min: " + modelData.min_stock + ")"
                                    font.pixelSize: 13
                                    color: (modelData.stock <= modelData.min_stock) ? "#ff0055" : "#00ff80"
                                }
                            }

                            Item { width: parent.width - 700 }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3

                                Text {
                                    text: "$" + modelData.costo_por_unidad.toFixed(2) + "/" + modelData.unidad
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#00ffff"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: "Costo/unidad"
                                    font.pixelSize: 10
                                    color: "#8080a0"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
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
                        id: recetaCard
                        width: parent.width
                        height: recetaContent.height + 28
                        color: "#1a1a2f"
                        border.color: "#00ffff"
                        border.width: 1
                        radius: 8

                        scale: 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }

                        MouseArea {
                            id: recetaHover
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true
                            onEntered: recetaCard.scale = 1.01
                            onExited: recetaCard.scale = 1.0
                            onPressed: mouse.accepted = false
                        }

                        Column {
                            id: recetaContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 10

                            Row {
                                width: parent.width
                                spacing: 15

                                Column {
                                    width: parent.width - 410
                                    spacing: 5
                                    Text {
                                        text: modelData.nombre
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#00ffff"
                                    }
                                    Text {
                                        text: modelData.descripcion || "Receta sin descripción"
                                        font.pixelSize: 12
                                        color: "#8080a0"
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                    }
                                }

                                Rectangle {
                                    width: 220
                                    height: 80
                                    color: Qt.rgba(0, 1, 1, 0.05)
                                    radius: 8
                                    border.color: "#00ffff"
                                    border.width: 1

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 6

                                        Text {
                                            text: `Costo: $${modelData.costo_total.toFixed(2)}`
                                            font.pixelSize: 13
                                            color: "#ff0080"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: `Precio: $${modelData.precio_sugerido.toFixed(2)}`
                                            font.pixelSize: 13
                                            color: "#00ff80"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: `Margen: ${(modelData.margen * 100).toFixed(0)}%`
                                            font.pixelSize: 12
                                            color: "#00ffff"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }

                                Column {
                                    width: 140
                                    spacing: 8
                                    Button {
                                        text: "✏️ Editar"
                                        width: parent.width
                                        height: 32
                                        background: Rectangle { color: "#00ff80"; radius: 6 }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#050510"
                                            font.bold: true
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        onClicked: prepararEdicionReceta(modelData)
                                    }
                                    Button {
                                        text: "🗑️ Eliminar"
                                        width: parent.width
                                        height: 32
                                        background: Rectangle { color: "#ff0055"; radius: 6 }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#ffffff"
                                            font.bold: true
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        onClicked: eliminarReceta(modelData)
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#00ffff"
                                opacity: 0.2
                            }

                            Flow {
                                width: parent.width
                                spacing: 8

                                Repeater {
                                    model: modelData.items
                                    Rectangle {
                                        width: 185
                                        height: 52
                                        radius: 6
                                        color: "#0f0f1f"
                                        border.color: modelData.stock <= modelData.min_stock ? "#ff0055" : "#00ffff"
                                        border.width: 1

                                        scale: 1.0
                                        Behavior on scale {
                                            NumberAnimation { duration: 150 }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onEntered: parent.scale = 1.05
                                            onExited: parent.scale = 1.0
                                        }

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 3

                                            Text {
                                                text: `${modelData.ingrediente_nombre}`
                                                color: "#e0e0ff"
                                                font.pixelSize: 12
                                                font.bold: true
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                            Text {
                                                text: `${modelData.cantidad} ${modelData.unidad || ''}`
                                                color: "#00ffff"
                                                font.pixelSize: 11
                                            }
                                            Text {
                                                text: `Stock: ${modelData.stock}`
                                                color: modelData.stock <= modelData.min_stock ? "#ff0055" : "#00ff80"
                                                font.pixelSize: 10
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
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                Text {
                                    text: "🛒 Carrito:"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#00ffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Rectangle {
                                    visible: carrito.length > 0
                                    width: 30
                                    height: 22
                                    color: Qt.rgba(0, 1, 1, 0.2)
                                    radius: 11
                                    border.color: "#00ffff"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        anchors.centerIn: parent
                                        text: carrito.length.toString()
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#00ffff"
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 140
                                color: "#1a1a2f"
                                border.color: carrito.length > 0 ? "#00ffff" : "#404050"
                                border.width: 2
                                radius: 8

                                Behavior on border.color {
                                    ColorAnimation { duration: 300 }
                                }

                                ListView {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8
                                    clip: true
                                    model: carrito

                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 38
                                        color: "#0f0f1f"
                                        border.color: "#00ffff"
                                        border.width: 1
                                        radius: 6

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10

                                            Text {
                                                text: "• " + modelData.nombre
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: "#e0e0ff"
                                                width: parent.width - 230
                                                elide: Text.ElideRight
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Row {
                                                spacing: 6
                                                anchors.verticalCenter: parent.verticalCenter

                                                Button {
                                                    width: 28
                                                    height: 28
                                                    text: "-"
                                                    enabled: modelData.cantidad > 1
                                                    background: Rectangle { color: parent.enabled ? "#1a1a2f" : "#303040"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                                                    contentItem: Text {
                                                        text: parent.text
                                                        color: "#e0e0ff"
                                                        font.bold: true
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                    }
                                                    onClicked: ajustarCantidadCarrito(index, -1)
                                                }

                                                Text {
                                                    text: "x" + modelData.cantidad
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                    color: "#00ffff"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Button {
                                                    width: 28
                                                    height: 28
                                                    text: "+"
                                                    background: Rectangle { color: "#1a1a2f"; border.color: "#00ffff"; border.width: 1; radius: 4 }
                                                    contentItem: Text {
                                                        text: parent.text
                                                        color: "#e0e0ff"
                                                        font.bold: true
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                    }
                                                    onClicked: ajustarCantidadCarrito(index, 1)
                                                }
                                            }

                                            Button {
                                                width: 75
                                                height: 28
                                                text: "🗑️"
                                                background: Rectangle { color: "#ff0055"; radius: 4 }
                                                contentItem: Text {
                                                    text: parent.text
                                                    font.pixelSize: 14
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                anchors.verticalCenter: parent.verticalCenter
                                                onClicked: eliminarItemCarrito(index)
                                            }

                                            Text {
                                                text: "$" + (modelData.precio * modelData.cantidad).toFixed(2)
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: "#00ff80"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }

                                    Text {
                                        visible: carrito.length === 0
                                        anchors.centerIn: parent
                                        text: "Carrito vacío"
                                        font.pixelSize: 14
                                        color: "#8080a0"
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 70
                                color: Qt.rgba(0, 1, 0.5, 0.1)
                                border.color: "#00ff80"
                                border.width: 2
                                radius: 10

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 20

                                    Text {
                                        text: "TOTAL:"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "#8080a0"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "$" + total.toFixed(2)
                                        font.pixelSize: 32
                                        font.bold: true
                                        color: "#00ff80"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: 12

                                Button {
                                    width: (parent.width - 12) / 2
                                    height: 55
                                    text: "🗑️ LIMPIAR"
                                    enabled: carrito.length > 0
                                    background: Rectangle {
                                        color: parent.enabled ? "#ff0055" : "#404050"
                                        radius: 8
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font.bold: true
                                        font.pixelSize: 17
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: limpiarCarrito()
                                }

                                Button {
                                    id: btnRegistrar
                                    width: (parent.width - 12) / 2
                                    height: 55
                                    text: "✓ REGISTRAR VENTA"
                                    enabled: carrito.length > 0

                                    scale: 1.0
                                    Behavior on scale {
                                        NumberAnimation { duration: 100 }
                                    }

                                    background: Rectangle {
                                        color: parent.enabled ? "#00ff80" : "#404050"
                                        radius: 8
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#050510"
                                        font.bold: true
                                        font.pixelSize: 17
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                        btnRegistrar.scale = 0.95
                                        timerRegistrar.start()
                                        procesarVenta()
                                    }

                                    Timer {
                                        id: timerRegistrar
                                        interval: 100
                                        onTriggered: btnRegistrar.scale = 1.0
                                    }
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
    // LOGS - ENHANCED WITH FAKE DATA & FILTERING
    // ============================================
    Component {
        id: pantallaLogs

        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20

            property var logsData: null
            property string filtroActual: "todos"
            property string busqueda: ""
            property bool cargando: false
            property bool usandoDatosEjemplo: false
            property var logsActuales: []

            onLogsDataChanged: actualizarLogs()
            onFiltroActualChanged: actualizarLogs()
            onBusquedaChanged: actualizarLogs()

            // Título con indicador
            Row {
                width: parent.width
                spacing: 15

                Text {
                    text: "📋"
                    font.pixelSize: 40
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Sistema de Auditoría"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    visible: usandoDatosEjemplo
                    width: 150
                    height: 28
                    color: Qt.rgba(1, 0.65, 0, 0.2)
                    radius: 14
                    border.color: "#ffaa00"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "📊"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Vista Previa"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#ffaa00"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // Controles de filtro
            Rectangle {
                width: parent.width
                height: 80
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10

                Row {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Column {
                        width: parent.width * 0.4
                        spacing: 8

                        Text {
                            text: "Tipo de Log"
                            font.pixelSize: 11
                            color: "#8080a0"
                        }

                        Row {
                            spacing: 10

                            Button {
                                text: "Todos"
                                width: 75
                                height: 32
                                background: Rectangle {
                                    color: filtroActual === "todos" ? "#00ffff" : "transparent"
                                    border.color: "#00ffff"
                                    border.width: 2
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: filtroActual === "todos" ? "#050510" : "#00ffff"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: {
                                    filtroActual = "todos"
                                    cargarLogs()
                                }
                            }

                            Button {
                                text: "Sesiones"
                                width: 85
                                height: 32
                                background: Rectangle {
                                    color: filtroActual === "sesion" ? "#00ffff" : "transparent"
                                    border.color: "#00ffff"
                                    border.width: 2
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: filtroActual === "sesion" ? "#050510" : "#00ffff"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: {
                                    filtroActual = "sesion"
                                    cargarLogs()
                                }
                            }

                            Button {
                                text: "Inventario"
                                width: 95
                                height: 32
                                background: Rectangle {
                                    color: filtroActual === "movimiento" ? "#00ffff" : "transparent"
                                    border.color: "#00ffff"
                                    border.width: 2
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: filtroActual === "movimiento" ? "#050510" : "#00ffff"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: {
                                    filtroActual = "movimiento"
                                    cargarLogs()
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width * 0.5
                        spacing: 8

                        Text {
                            text: "Buscar"
                            font.pixelSize: 11
                            color: "#8080a0"
                        }

                        TextField {
                            id: inputBusqueda
                            width: parent.width
                            height: 32
                            placeholderText: "Buscar por usuario, acción..."
                            color: "#e0e0ff"
                            onTextChanged: busqueda = text
                            background: Rectangle {
                                color: "transparent"
                                border.color: "#00ffff"
                                border.width: 1
                                radius: 4
                            }
                        }
                    }
                }
            }

            // Estadísticas rápidas
            Row {
                width: parent.width
                spacing: 15

                Rectangle {
                    width: (parent.width - 30) / 3
                    height: 60
                    color: Qt.rgba(0, 1, 1, 0.05)
                    radius: 6
                    border.color: "#00ffff"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "📊"
                            font.pixelSize: 24
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: 2
                            Text {
                                text: logsData ? logsData.total.toString() : "0"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#00ffff"
                            }
                            Text {
                                text: "Total Registros"
                                font.pixelSize: 10
                                color: "#8080a0"
                            }
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 30) / 3
                    height: 60
                    color: Qt.rgba(0, 1, 0.5, 0.05)
                    radius: 6
                    border.color: "#00ff80"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "✅"
                            font.pixelSize: 24
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: 2
                            Text {
                                text: contarPorTipo("sesion")
                                font.pixelSize: 18
                                font.bold: true
                                color: "#00ff80"
                            }
                            Text {
                                text: "Sesiones"
                                font.pixelSize: 10
                                color: "#8080a0"
                            }
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 30) / 3
                    height: 60
                    color: Qt.rgba(1, 0.65, 0, 0.05)
                    radius: 6
                    border.color: "#ffaa00"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "📦"
                            font.pixelSize: 24
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: 2
                            Text {
                                text: contarPorTipo("movimiento")
                                font.pixelSize: 18
                                font.bold: true
                                color: "#ffaa00"
                            }
                            Text {
                                text: "Movimientos"
                                font.pixelSize: 10
                                color: "#8080a0"
                            }
                        }
                    }
                }
            }

            // Lista de logs
            Rectangle {
                width: parent.width
                height: parent.height - 260
                color: "#0a0a1f"
                border.color: "#00ffff"
                border.width: 2
                radius: 10

                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Row {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "Registros de Auditoría"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#e0e0ff"
                        }

                        Item { width: parent.width - 270 }

                        Button {
                            text: "📊 Vista Previa"
                            width: 130
                            height: 30
                            background: Rectangle {
                                color: "transparent"
                                border.color: "#ffaa00"
                                border.width: 2
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffaa00"
                                font.bold: true
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onClicked: cargarDatosEjemplo()
                        }

                        Button {
                            text: "🔄 Recargar"
                            width: 110
                            height: 30
                            background: Rectangle {
                                color: "transparent"
                                border.color: "#00ffff"
                                border.width: 2
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#00ffff"
                                font.bold: true
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onClicked: cargarLogs()
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#00ffff"
                        opacity: 0.3
                    }

                    ListView {
                        id: listaLogs
                        width: parent.width
                        height: parent.height - 55
                        clip: true
                        spacing: 8
                        model: logsActuales

                        delegate: Rectangle {
                            width: parent.width
                            height: 70
                            color: Qt.rgba(0, 0, 0, 0.3)
                            radius: 6
                            border.color: modelData.tipo === "sesion" ? "#0088ff" : "#ffaa00"
                            border.width: 1

                            Rectangle {
                                anchors.left: parent.left
                                width: 4
                                height: parent.height
                                radius: 2
                                color: modelData.tipo === "sesion" ? "#0088ff" : "#ffaa00"
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 15

                                Text {
                                    text: modelData.tipo === "sesion" ? "🔐" : "📦"
                                    font.pixelSize: 28
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width * 0.3
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: modelData.usuario
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#e0e0ff"
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Text {
                                        text: modelData.accion
                                        font.pixelSize: 11
                                        color: "#ff0080"
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                Column {
                                    width: parent.width * 0.35
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: obtenerDetallesPrincipales(modelData)
                                        font.pixelSize: 11
                                        color: "#8080a0"
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Text {
                                        text: obtenerDetallesSecundarios(modelData)
                                        font.pixelSize: 10
                                        color: "#8080a0"
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                Column {
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: formatearFecha(modelData.fecha)
                                        font.pixelSize: 11
                                        color: "#00ffff"
                                    }

                                    Text {
                                        text: formatearHora(modelData.fecha)
                                        font.pixelSize: 10
                                        color: "#8080a0"
                                    }
                                }
                            }
                        }

                        Column {
                            visible: listaLogs.count === 0
                            anchors.centerIn: parent
                            spacing: 15

                            Text {
                                text: "📋"
                                font.pixelSize: 60
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 0.5
                            }

                            Text {
                                text: "No hay registros para mostrar"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#e0e0ff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Prueba cargando la vista previa con datos de ejemplo"
                                font.pixelSize: 13
                                color: "#8080a0"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Button {
                                text: "📊 Cargar Vista Previa"
                                width: 200
                                height: 40
                                anchors.horizontalCenter: parent.horizontalCenter
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
                                onClicked: cargarDatosEjemplo()
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 10
                            contentItem: Rectangle {
                                implicitWidth: 6
                                radius: 3
                                color: "#00ffff"
                                opacity: parent.active ? 0.8 : 0.4
                                Behavior on opacity {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                cargarLogs()
                timer.start()
            }

            Timer {
                id: timer
                interval: 2000
                running: false
                repeat: false
                onTriggered: {
                    if (!logsData || !logsData.logs || logsData.logs.length === 0) {
                        cargarDatosEjemplo()
                    }
                }
            }

            function cargarLogs() {
                cargando = true
                usandoDatosEjemplo = false

                var endpoint = "/logs?tipo=" + filtroActual + "&limit=100"

                api.get(endpoint, function(exito, datos) {
                    cargando = false
                    if (exito) {
                        logsData = datos
                        usandoDatosEjemplo = false
                    } else {
                        cargarDatosEjemplo()
                    }
                })
            }

            function cargarDatosEjemplo() {
                cargando = false
                usandoDatosEjemplo = true

                var ahora = new Date()
                var ejemplos = []

                // Logs de sesión
                for (var i = 0; i < 15; i++) {
                    var fecha = new Date(ahora.getTime() - (i * 3600000 * Math.random() * 48))
                    var usuarios = ["admin", "gerente", "vendedor1", "supervisor"]
                    var acciones = ["LOGIN", "LOGOUT", "PASSWORD_CHANGE", "PROFILE_UPDATE"]
                    var ips = ["192.168.1.100", "192.168.1.101", "192.168.1.102", "10.0.0.50"]

                    if (filtroActual === "todos" || filtroActual === "sesion") {
                        ejemplos.push({
                            "id": "sesion_" + i,
                            "tipo": "sesion",
                            "usuario": usuarios[Math.floor(Math.random() * usuarios.length)],
                            "accion": acciones[Math.floor(Math.random() * acciones.length)],
                            "detalles": {
                                "ip": ips[Math.floor(Math.random() * ips.length)],
                                "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
                                "exito": Math.random() > 0.2
                            },
                            "fecha": fecha.toISOString()
                        })
                    }
                }

                // Logs de movimientos
                var ingredientes = ["Café Arábica", "Leche Entera", "Azúcar", "Chocolate", "Vainilla", "Canela"]
                var tipos_mov = ["ENTRADA", "SALIDA", "AJUSTE"]
                var referencias = [
                    "Proveedor: Café Premium SA",
                    "Staff: María García",
                    "Venta #1234",
                    "Sistema automático",
                    "Staff: Juan Pérez"
                ]

                for (var j = 0; j < 20; j++) {
                    var fecha2 = new Date(ahora.getTime() - (j * 3600000 * Math.random() * 72))

                    if (filtroActual === "todos" || filtroActual === "movimiento") {
                        ejemplos.push({
                            "id": "movimiento_" + j,
                            "tipo": "movimiento",
                            "usuario": referencias[Math.floor(Math.random() * referencias.length)],
                            "accion": tipos_mov[Math.floor(Math.random() * tipos_mov.length)],
                            "detalles": {
                                "ingrediente": ingredientes[Math.floor(Math.random() * ingredientes.length)],
                                "cantidad": (Math.random() * 50 + 5).toFixed(2),
                                "tipo_movimiento": tipos_mov[Math.floor(Math.random() * tipos_mov.length)],
                                "referencia": referencias[Math.floor(Math.random() * referencias.length)]
                            },
                            "fecha": fecha2.toISOString()
                        })
                    }
                }

                ejemplos.sort(function(a, b) {
                    return new Date(b.fecha) - new Date(a.fecha)
                })

                logsData = {
                    "total": ejemplos.length,
                    "logs": ejemplos
                }
            }

            function actualizarLogs() {
                if (!logsData || !logsData.logs) {
                    logsActuales = []
                    return
                }

                var logs = logsData.logs

                if (busqueda !== "") {
                    var filtrados = []
                    var busquedaLower = busqueda.toLowerCase()

                    for (var i = 0; i < logs.length; i++) {
                        var log = logs[i]
                        if (log.usuario.toLowerCase().indexOf(busquedaLower) !== -1 ||
                            log.accion.toLowerCase().indexOf(busquedaLower) !== -1) {
                            filtrados.push(log)
                        }
                    }
                    logsActuales = filtrados
                } else {
                    logsActuales = logs
                }
            }

            function contarPorTipo(tipo) {
                if (!logsData || !logsData.logs) return "0"

                var count = 0
                for (var i = 0; i < logsData.logs.length; i++) {
                    if (logsData.logs[i].tipo === tipo) {
                        count++
                    }
                }
                return count.toString()
            }

            function obtenerDetallesPrincipales(log) {
                if (log.tipo === "sesion") {
                    var exito = log.detalles.exito ? "✅ Exitoso" : "❌ Fallido"
                    return exito + " • IP: " + (log.detalles.ip || "N/A")
                } else {
                    return "📦 " + log.detalles.ingrediente + " • Cantidad: " + log.detalles.cantidad
                }
            }

            function obtenerDetallesSecundarios(log) {
                if (log.tipo === "sesion") {
                    return "User Agent: " + (log.detalles.user_agent || "N/A")
                } else {
                    return "Referencia: " + (log.detalles.referencia || "Sistema automático")
                }
            }

            function formatearFecha(fechaISO) {
                var fecha = new Date(fechaISO)
                var dia = fecha.getDate().toString().length === 1 ? "0" + fecha.getDate() : fecha.getDate()
                var mes = (fecha.getMonth() + 1).toString().length === 1 ? "0" + (fecha.getMonth() + 1) : (fecha.getMonth() + 1)
                var año = fecha.getFullYear()
                return dia + "/" + mes + "/" + año
            }

            function formatearHora(fechaISO) {
                var fecha = new Date(fechaISO)
                var horas = fecha.getHours().toString().length === 1 ? "0" + fecha.getHours() : fecha.getHours()
                var minutos = fecha.getMinutes().toString().length === 1 ? "0" + fecha.getMinutes() : fecha.getMinutes()
                var segundos = fecha.getSeconds().toString().length === 1 ? "0" + fecha.getSeconds() : fecha.getSeconds()
                return horas + ":" + minutos + ":" + segundos
            }
        }
    }
}
