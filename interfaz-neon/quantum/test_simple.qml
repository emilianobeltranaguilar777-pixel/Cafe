import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    visible: true
    width: 800
    height: 600
    title: "Test - EL CAFÉ SIN LÍMITES"
    color: "#050510"
    
    Rectangle {
        anchors.centerIn: parent
        width: 400
        height: 300
        color: "#0a0a1f"
        border.color: "#00ffff"
        border.width: 2
        radius: 10
        
        Column {
            anchors.centerIn: parent
            spacing: 20
            
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
                text: "Sistema Operativo"
                font.pixelSize: 14
                color: "#8080a0"
            }
            
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "✅ Qt Funciona"
                
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
    }
}
