# 🎨 FRONTEND - Guía de Interfaz QML

## 📄 Archivo Principal

**El único archivo que necesitas es:**

```
interfaz-neon/quantum/main.qml
```

Este archivo contiene:
- ✅ 1941 líneas de código completo
- ✅ Todas las pantallas implementadas
- ✅ Login funcional
- ✅ Dashboard con estadísticas
- ✅ CRUD completo de clientes
- ✅ Gestión de ingredientes
- ✅ Gestión de recetas
- ✅ Punto de venta (POS) con carrito
- ✅ Gestión de usuarios
- ✅ Logs del sistema
- ✅ Sistema de notificaciones
- ✅ Navegación completa
- ✅ Todas las llamadas API conectadas

---

## 🚀 Cómo Ejecutar el Frontend

### Opción 1: Script de Lanzamiento (Recomendado)

```bash
cd interfaz-neon/lanzador
./despegar
```

Este script:
- Configura las rutas correctamente
- Establece las variables de entorno
- Lanza `main.qml` con qmlscene

### Opción 2: Directo con qmlscene

```bash
cd interfaz-neon/quantum
qmlscene main.qml
```

### Requisitos

```bash
# Instalar Qt5 y herramientas QML
sudo apt install qtdeclarative5-dev-tools qml-module-qtquick2 qml-module-qtquick-controls2
```

---

## 📁 Estructura del Frontend

```
interfaz-neon/
├── quantum/
│   ├── main.qml              ⭐ ARCHIVO PRINCIPAL (úsalo)
│   ├── ApiHelper.qml         📡 Helper para llamadas HTTP
│   ├── README.md             📚 Documentación del módulo
│   ├── qmldir                🔧 Configuración Qt
│   ├── cerebro/              🧠 Lógica de negocio
│   │   ├── GestorAuth.qml   🔐 Gestión de autenticación
│   │   └── PaletaNeon.qml   🎨 Colores del tema NEON
│   ├── componentes/          🧩 Componentes reutilizables
│   │   └── BotonNeon.qml    🔘 Botón estilo NEON
│   └── pantallas/            📺 Pantallas modulares (legacy)
│       ├── pantalla_login.qml
│       └── pantalla_dashboard.qml
│
└── lanzador/
    └── despegar              🚀 Script de inicio
```

**IMPORTANTE:** Las pantallas están todas integradas en `main.qml`. Los archivos en `pantallas/` son código legacy para referencia.

---

## 🔧 Configuración del Backend

El frontend se conecta al backend en:

```javascript
backendUrl: "http://localhost:8000"
```

Esto está configurado en la línea 13 de `main.qml`:

```qml
property string backendUrl: "http://localhost:8000"
```

Para cambiar la URL del backend, edita esa línea.

---

## 🔐 Credenciales en el Frontend

En la pantalla de login, usa:

```
Usuario: admin
Contraseña: admin123
```

---

## 📱 Pantallas Disponibles en main.qml

El archivo `main.qml` incluye todas estas pantallas:

### 1. **Login** (Línea 150)
- Autenticación con usuario/contraseña
- Validación de credenciales
- Obtención de token JWT
- Redirección automática al dashboard

### 2. **Dashboard** (Línea 459)
- Estadísticas de ventas del día
- Ventas del mes
- Alertas de inventario
- Resumen del sistema
- Llamada API: `GET /reportes/dashboard`

### 3. **Clientes** (Línea 657)
- Listar todos los clientes
- Crear nuevo cliente
- Editar cliente existente
- Eliminar cliente
- Búsqueda y filtros
- Llamadas API:
  - `GET /clientes/`
  - `POST /clientes/`
  - `PUT /clientes/{id}`
  - `DELETE /clientes/{id}`

### 4. **Ingredientes** (Línea 974)
- Gestión de inventario
- Ver stock actual
- Alertas de stock mínimo
- Editar ingredientes
- Llamadas API:
  - `GET /ingredientes/`
  - `PUT /ingredientes/{id}`

### 5. **Recetas** (Línea 1111)
- Ver todas las recetas
- Ingredientes por receta
- Costos calculados
- Precios de venta
- Llamadas API:
  - `GET /recetas/`
  - `GET /recetas/{id}`

### 6. **Ventas / POS** (Línea 1263)
- Carrito de compras funcional
- Selección de recetas
- Cálculo de totales
- Registro de ventas
- Historial de ventas
- Llamadas API:
  - `GET /recetas/` (para cargar productos)
  - `POST /ventas/` (para crear venta)
  - `GET /ventas/` (para historial)

### 7. **Usuarios** (Línea 1541)
- Listar usuarios del sistema
- Ver roles y permisos
- Gestión de usuarios
- Llamadas API:
  - `GET /auth/usuarios`

### 8. **Logs** (Línea 1688)
- Historial de actividad
- Acciones de usuarios
- Auditoría del sistema
- Llamadas API:
  - `GET /logs/`

---

## 🎨 Sistema de Notificaciones

El frontend incluye un sistema de notificaciones (Línea 19):

```qml
notificacion.mostrar("Mensaje aquí")
```

Se muestra automáticamente por 3 segundos en la parte superior de la pantalla.

---

## 📡 API Helper

El archivo `ApiHelper.qml` proporciona funciones para hacer llamadas HTTP:

```qml
// GET request
api.get("/endpoint", function(exito, datos) {
    if (exito) {
        // Procesar datos
    }
})

// POST request
api.post("/endpoint", {datos: "valor"}, function(exito, respuesta) {
    if (exito) {
        // Procesar respuesta
    }
})

// PUT request
api.put("/endpoint/1", {datos: "valor"}, function(exito, respuesta) {
    // ...
})

// DELETE request
api.del("/endpoint/1", function(exito, respuesta) {
    // ...
})
```

Todas las peticiones incluyen automáticamente el header `Authorization: Bearer {token}`.

---

## 🎨 Tema Visual NEON

El frontend usa un tema visual estilo "neon" con estos colores principales:

```qml
- Fondo principal: #050510 (negro azulado oscuro)
- Fondo secundario: #0a0a1f (negro azulado)
- Color neón principal: #00ffff (cyan)
- Color neón secundario: #00ff80 (verde neón)
- Texto: #e0e0ff (blanco azulado)
- Texto secundario: #8080a0 (gris azulado)
```

---

## 🔄 Navegación

La navegación se maneja con una propiedad reactiva:

```qml
property string pantallaActual: "dashboard"
```

Los botones del menú lateral cambian esta propiedad:
- `dashboard`
- `clientes`
- `ingredientes`
- `recetas`
- `ventas`
- `usuarios`
- `logs`

---

## 🐛 Solución de Problemas

### Frontend no inicia

**Error:** `qmlscene: command not found`

**Solución:**
```bash
sudo apt install qtdeclarative5-dev-tools
```

### Backend no responde

**Síntoma:** Las pantallas están vacías o no cargan datos.

**Solución:**
1. Verifica que el backend esté corriendo: `http://localhost:8000`
2. Abre la consola de QML para ver errores de red
3. Verifica que el token JWT sea válido (puede expirar)

### Error: "Failed to connect to localhost:8000"

**Causa:** El backend no está corriendo.

**Solución:**
```bash
# En otra terminal
cd nucleo-api
python main.py
```

### Error de autenticación

**Síntoma:** Login falla o retorna 401.

**Solución:**
1. Verifica las credenciales: `admin` / `admin123`
2. Ejecuta: `python verificar_login.py`
3. Reinicializa la BD si es necesario: `python populate_db.py`

---

## 📝 Modificar el Frontend

### Cambiar colores del tema

Edita las propiedades de color en `main.qml` (alrededor de la línea 155):

```qml
color: "#050510"  // Fondo
border.color: "#00ffff"  // Bordes neón
```

### Agregar una nueva pantalla

1. Crea un nuevo Component en `main.qml`
2. Agrégalo al switch de navegación (línea ~442)
3. Agrega un botón en el menú lateral (línea ~369)

### Cambiar URL del backend

Edita la línea 13 de `main.qml`:

```qml
property string backendUrl: "http://tu-servidor:puerto"
```

---

## ✅ Resumen

**Archivo a usar:** `interfaz-neon/quantum/main.qml`

**Cómo ejecutar:**
```bash
cd interfaz-neon/lanzador
./despegar
```

**Credenciales:**
- Usuario: `admin`
- Password: `admin123`

**Backend requerido:** `http://localhost:8000`

**Todo está listo para usar. ¡Disfruta!** ☕
