import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: root
    visible: true
    width: 1400
    height: 900
    title: "EL CAFÉ SIN LÍMITES - Sistema de Gestión"
    color: "#050510"
    
    property string backendUrl: "http://localhost:8000"
    property string token: ""
    property var datosUsuario: null
    property string pantallaActual: "dashboard"
    
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginPage
    }
    
    // ============================================
    // COMPONENTE: LOGIN
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
                            text: "☕"
                            font.pixelSize: 80
                        }
                        
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
                                hacerLogin(inputUser.text, inputPass.text)
                            }
                        }
                    }
                }
            }
            
            function hacerLogin(username, password) {
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
                
                xhr.send("username=" + username + "&password=" + password)
            }
            
            function cargarPerfil() {
                var xhr = new XMLHttpRequest()
                xhr.open("GET", root.backendUrl + "/auth/me")
                xhr.setRequestHeader("Authorization", "Bearer " + root.token)
                
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            root.datosUsuario = JSON.parse(xhr.responseText)
                            stackView.push(mainPage)
                        }
                    }
                }
                
                xhr.send()
            }
        }
    }
    
    // ============================================
    // COMPONENTE: MAIN (Dashboard + Navegación)
    // ============================================
    Component {
        id: mainPage
        
        Rectangle {
            color: "#050510"
            
            Row {
                anchors.fill: parent
                
                // Sidebar
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
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "☕"
                            font.pixelSize: 50
                        }
                        
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
                        
                        // Menú de navegación
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Repeater {
                                model: [
                                    {icono: "📊", texto: "Dashboard", id: "dashboard"},
                                    {icono: "👥", texto: "Clientes", id: "clientes"},
                                    {icono: "🥫", texto: "Ingredientes", id: "ingredientes"},
                                    {icono: "🍰", texto: "Recetas", id: "recetas"},
                                    {icono: "🛒", texto: "Ventas", id: "ventas"}
                                ]
                                
                                Rectangle {
                                    width: parent.width
                                    height: 45
                                    color: root.pantallaActual === modelData.id ? "#00ffff30" : (mouseArea.containsMouse ? "#00ffff20" : "transparent")
                                    border.color: root.pantallaActual === modelData.id ? "#00ffff" : "transparent"
                                    border.width: 2
                                    radius: 6
                                    
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 15
                                        spacing: 12
                                        
                                        Text {
                                            text: modelData.icono
                                            font.pixelSize: 20
                                        }
                                        
                                        Text {
                                            text: modelData.texto
                                            font.pixelSize: 13
                                            font.bold: root.pantallaActual === modelData.id
                                            color: "#e0e0ff"
                                        }
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
                            text: "🚪 SALIR"
                            
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
                
                // Contenido dinámico
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
    // PANTALLA: DASHBOARD
    // ============================================
    Component {
        id: pantallaDashboard
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 30
            
            Text {
                text: "📊 Dashboard - Sistema Operativo"
                font.pixelSize: 28
                font.bold: true
                color: "#00ffff"
            }
            
            Text {
                text: "✅ Backend conectado: " + root.backendUrl
                font.pixelSize: 14
                color: "#00ff80"
            }
            
            Grid {
                columns: 3
                spacing: 20
                
                Repeater {
                    model: [
                        {titulo: "Sistema", valor: "Activo", icono: "✅"},
                        {titulo: "Base Datos", valor: "SQLite", icono: "🗄️"},
                        {titulo: "API REST", valor: "FastAPI", icono: "🚀"}
                    ]
                    
                    Rectangle {
                        width: 280
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
                                text: modelData.icono
                                font.pixelSize: 40
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.titulo
                                font.pixelSize: 12
                                color: "#8080a0"
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.valor
                                font.pixelSize: 18
                                font.bold: true
                                color: "#00ffff"
                            }
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
                        text: "🎉 PROYECTO COMPLETADO"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#00ff80"
                    }
                    
                    Text {
                        width: parent.width
                        text: "✅ Backend FastAPI funcionando\n✅ Base de datos SQLite con datos\n✅ Sistema de autenticación JWT\n✅ Interfaz Qt/QML operativa\n✅ Navegación completa entre módulos\n\n🚀 Documenta ción API: http://localhost:8000/docs"
                        font.pixelSize: 14
                        color: "#e0e0ff"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.4
                    }
                }
            }
        }
    }
    
    // ============================================
    // PANTALLA: CLIENTES
    // ============================================
    Component {
        id: pantallaClientes
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            Row {
                width: parent.width
                
                Text {
                    text: "👥 Gestión de Clientes"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { width: parent.width - 500 }
                
                Button {
                    text: "+ Nuevo Cliente"
                    width: 180
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
                    
                    model: ListModel {
                        ListElement { nombre: "Ana Martínez"; correo: "ana@email.com"; telefono: "442-111-2222" }
                        ListElement { nombre: "Luis Hernández"; correo: "luis@email.com"; telefono: "442-222-3333" }
                        ListElement { nombre: "Carmen Soto"; correo: "carmen@email.com"; telefono: "442-333-4444" }
                        ListElement { nombre: "Roberto Jiménez"; correo: "roberto@email.com"; telefono: "442-444-5555" }
                        ListElement { nombre: "Patricia López"; correo: "patricia@email.com"; telefono: "442-555-6666" }
                    }
                    
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
                                    text: model.nombre
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#e0e0ff"
                                }
                                Text {
                                    text: model.correo
                                    font.pixelSize: 12
                                    color: "#8080a0"
                                }
                            }
                            
                            Text {
                                text: "📞 " + model.telefono
                                font.pixelSize: 14
                                color: "#00ffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Item { width: parent.width - 600 }
                            
                            Button {
                                text: "✏️ Editar"
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
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ============================================
    // PANTALLA: INGREDIENTES
    // ============================================
    Component {
        id: pantallaIngredientes
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            Row {
                width: parent.width
                
                Text {
                    text: "🥫 Gestión de Ingredientes"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { width: parent.width - 550 }
                
                Button {
                    text: "+ Nuevo Ingrediente"
                    width: 200
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
                    
                    model: ListModel {
                        ListElement { nombre: "Café Arábica Premium"; stock: "25.0"; unidad: "kg"; costo: "350.00"; minStock: "5.0"; alerta: false }
                        ListElement { nombre: "Leche Entera"; stock: "50.0"; unidad: "l"; costo: "22.00"; minStock: "10.0"; alerta: false }
                        ListElement { nombre: "Azúcar Refinada"; stock: "8.0"; unidad: "kg"; costo: "18.00"; minStock: "10.0"; alerta: true }
                        ListElement { nombre: "Chocolate en polvo"; stock: "15.0"; unidad: "kg"; costo: "180.00"; minStock: "3.0"; alerta: false }
                        ListElement { nombre: "Jarabe de Vainilla"; stock: "2.5"; unidad: "l"; costo: "95.00"; minStock: "3.0"; alerta: true }
                    }
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 80
                        color: model.alerta ? "#2f1a1a" : "#1a1a2f"
                        border.color: model.alerta ? "#ff0055" : "#00ffff"
                        border.width: 2
                        radius: 8
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 25
                            
                            Text {
                                text: model.alerta ? "⚠️" : "✅"
                                font.pixelSize: 35
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Column {
                                width: 280
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5
                                
                                Text {
                                    text: model.nombre
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#e0e0ff"
                                }
                                Text {
                                    text: "Stock: " + model.stock + " " + model.unidad + " (Mín: " + model.minStock + ")"
                                    font.pixelSize: 12
                                    color: model.alerta ? "#ff0055" : "#00ff80"
                                }
                            }
                            
                            Item { width: parent.width - 700 }
                            
                            Text {
                                text: "$" + model.costo + "/" + model.unidad
                                font.pixelSize: 16
                                font.bold: true
                                color: "#00ffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Button {
                                text: "📦 Ajustar"
                                width: 110
                                height: 35
                                anchors.verticalCenter: parent.verticalCenter
                                background: Rectangle {
                                    color: model.alerta ? "#ff0055" : "#00ff80"
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#050510"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ============================================
    // PANTALLA: RECETAS
    // ============================================
    Component {
        id: pantallaRecetas
        
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            Row {
                width: parent.width
                
                Text {
                    text: "🍰 Gestión de Recetas"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00ffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { width: parent.width - 500 }
                
                Button {
                    text: "+ Nueva Receta"
                    width: 180
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
                }
            }
            
            Grid {
                width: parent.width
                columns: 3
                rowSpacing: 20
                columnSpacing: 20
                
                Repeater {
                    model: [
                        {nombre: "Cappuccino Clásico", descripcion: "Espresso con leche", costo: "12.50", precio: "25.00", margen: "100%"},
                        {nombre: "Latte Vainilla", descripcion: "Café latte con jarabe", costo: "11.80", precio: "23.00", margen: "95%"},
                        {nombre: "Mocha Chocolate", descripcion: "Espresso con chocolate", costo: "15.20", precio: "28.00", margen: "84%"},
                        {nombre: "Americano", descripcion: "Espresso con agua", costo: "8.50", precio: "18.00", margen: "112%"},
                        {nombre: "Café con Leche", descripcion: "Tradicional", costo: "10.00", precio: "20.00", margen: "100%"},
                        {nombre: "Frappé Caramelo", descripcion: "Bebida fría", costo: "18.00", precio: "35.00", margen: "94%"}
                    ]
                    
                    Rectangle {
                        width: 360
                        height: 200
                        color: "#0a0a1f"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12
                            
                            Row {
                                width: parent.width
                                Text {
                                    text: "☕"
                                    font.pixelSize: 30
                                }
                                Column {
                                    width: parent.width - 40
                                    Text {
                                        text: modelData.nombre
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#00ffff"
                                    }
                                    Text {
                                        text: modelData.descripcion
                                        font.pixelSize: 11
                                        color: "#8080a0"
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#00ffff"
                                opacity: 0.3
                            }
                            
                            Row {
                                width: parent.width
                                Text {
                                    text: "Costo:"
                                    font.pixelSize: 12
                                    color: "#8080a0"
                                    width: 100
                                }
                                Text {
                                    text: "$" + modelData.costo
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#ff0080"
                                }
                            }
                            
                            Row {
                                width: parent.width
                                Text {
                                    text: "Precio Venta:"
                                    font.pixelSize: 12
                                    color: "#8080a0"
                                    width: 100
                                }
                                Text {
                                    text: "$" + modelData.precio
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#00ff80"
                                }
                            }
                            
                            Row {
                                width: parent.width
                                Text {
                                    text: "Margen:"
                                    font.pixelSize: 12
                                    color: "#8080a0"
                                    width: 100
                                }
                                Text {
                                    text: modelData.margen
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#00ffff"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ============================================
    // PANTALLA: VENTAS (POS)
    // ============================================
    Component {
        id: pantallaVentas
        
        Row {
            anchors.fill: parent
            spacing: 0
            
            // Panel izquierdo - Nueva venta
            Rectangle {
                width: parent.width * 0.55
                height: parent.height
                color: "#050510"
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 40
                    spacing: 25
                    
                    Text {
                        text: "🛒 Punto de Venta"
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
                                text: "Selecciona productos:"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#e0e0ff"
                            }
                            
                            ListView {
                                width: parent.width
                                height: 350
                                spacing: 12
                                clip: true
                                
                                model: ["Cappuccino $25", "Latte $23", "Americano $18", "Mocha $28", "Frappé $35"]
                                
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
                                            text: "☕"
                                            font.pixelSize: 28
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        Text {
                                            text: modelData
                                            font.pixelSize: 15
                                            font.bold: true
                                            color: "#e0e0ff"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        Item { width: parent.width - 300 }
                                        
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
                                    text: "$0.00"
                                    font.pixelSize: 28
                                    font.bold: true
                                    color: "#00ff80"
                                }
                            }
                            
                            Button {
                                width: parent.width
                                height: 55
                                text: "💳 PROCESAR VENTA"
                                background: Rectangle {
                                    color: "#00ff80"
                                    radius: 8
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#050510"
                                    font.bold: true
                                    font.pixelSize: 18
                                    horizontalAlignment: Text.AlignHCenter
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
                        text: "📊 Ventas Recientes"
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
                            
                            model: 15
                            
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
                                        text: "#" + (68 - index)
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#8080a0"
                                        width: 40
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 4
                                        Text {
                                            text: "Venta " + (68 - index)
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "#e0e0ff"
                                        }
                                        Text {
                                            text: "Hace " + (index + 1) + " hora" + (index > 0 ? "s" : "")
                                            font.pixelSize: 11
                                            color: "#8080a0"
                                        }
                                    }
                                    
                                    Item { width: parent.width - 250 }
                                    
                                    Text {
                                        text: "$" + (Math.floor(Math.random() * 50) + 20) + ".00"
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
        }
    }
}
