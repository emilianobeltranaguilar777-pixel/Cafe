pragma Singleton
import QtQuick 2.15

QtObject {
    // 🎨 Colores principales
    readonly property color primario: "#00ffff"      // Cyan neón
    readonly property color secundario: "#ff0080"    // Magenta neón
    readonly property color acento: "#00ff80"        // Verde neón
    readonly property color fondo: "#050510"         // Casi negro
    readonly property color tarjeta: "#0a0a1f"       // Azul muy oscuro
    readonly property color texto: "#e0e0ff"         // Blanco azulado
    readonly property color textoSecundario: "#8080a0"
    
    // 🎨 Estados
    readonly property color exito: "#00ff88"
    readonly property color advertencia: "#ffaa00"
    readonly property color error: "#ff0055"
    readonly property color info: "#0088ff"
    
    // 📏 Dimensiones
    readonly property int radioGlow: 12
    readonly property int duracionAnimacion: 300
    readonly property int radioBorde: 6
    
    // 🔤 Tipografía
    readonly property string fuentePrincipal: "Monospace"
    readonly property int tamañoFuentePequeña: 11
    readonly property int tamañoFuenteNormal: 14
    readonly property int tamañoFuenteGrande: 18
    readonly property int tamañoFuenteTitulo: 24
    
    // ✨ Función para crear efecto glow
    function crearGlow(color, intensidad) {
        return {
            "color": color,
            "radius": radioGlow * (intensidad || 1),
            "samples": 17,
            "spread": 0.5
        }
    }
}
