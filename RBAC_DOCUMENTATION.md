# 📋 Documentación del Módulo RBAC Dinámico - Sistema Neon-Quantum

## 🎯 Resumen Ejecutivo

Este documento describe la implementación completa del sistema RBAC (Role-Based Access Control) dinámico para la aplicación Neon-Quantum Café.

### Características Implementadas

✅ **Carga dinámica de permisos** desde el backend
✅ **Combinación de permisos** rol + usuario con precedencia correcta
✅ **Función `tienePermiso(recurso, accion)`** centralizada
✅ **Integración en todas las pantallas CRUD**
✅ **Sidebar con items desactivados** (nunca ocultos)
✅ **Tests automáticos** para validar funcionamiento
✅ **Compatibilidad total** con backend FastAPI existente

---

## 🔑 Recursos y Acciones Detectados

### 1. **clientes** - Gestión de Clientes

| Acción    | Descripción                     | Botón/Acción UI                        |
|-----------|---------------------------------|----------------------------------------|
| `ver`     | Visualizar lista de clientes    | Acceso a pantalla                      |
| `crear`   | Crear nuevo cliente             | Botón "+ Nuevo Cliente"                |
| `editar`  | Modificar cliente existente     | Botón "Editar", Botón "Actualizar"     |
| `borrar`  | Eliminar cliente                | Botón "Eliminar"                       |

### 2. **inventario** - Gestión de Ingredientes

| Acción    | Descripción                       | Botón/Acción UI                          |
|-----------|-----------------------------------|------------------------------------------|
| `ver`     | Visualizar inventario             | Acceso a pantalla                        |
| `crear`   | Agregar nuevo ingrediente         | Botón "+ Nuevo Ingrediente"              |
| `editar`  | Modificar ingrediente/stock       | Botón "Editar", "Ajustar Stock"          |
| `borrar`  | Eliminar ingrediente              | Botón "Eliminar"                         |

### 3. **recetas** - Gestión de Recetas

| Acción    | Descripción                       | Botón/Acción UI                          |
|-----------|-----------------------------------|------------------------------------------|
| `ver`     | Visualizar recetas                | Acceso a pantalla                        |
| `crear`   | Crear nueva receta                | Botón "+ Nueva Receta"                   |
| `editar`  | Modificar receta existente        | Botón "Editar", Botón "Actualizar"       |
| `borrar`  | Eliminar receta                   | Botón "Eliminar"                         |

### 4. **ventas** - Punto de Venta

| Acción    | Descripción                       | Botón/Acción UI                          |
|-----------|-----------------------------------|------------------------------------------|
| `ver`     | Visualizar historial ventas       | Acceso a pantalla, panel de ventas       |
| `crear`   | Registrar nueva venta             | Botón "Registrar Venta"                  |
| `editar`  | Modificar venta (no implementado) | -                                        |
| `borrar`  | Anular venta (no implementado)    | -                                        |

### 5. **usuarios** - Gestión de Usuarios

| Acción    | Descripción                       | Botón/Acción UI                              |
|-----------|-----------------------------------|----------------------------------------------|
| `ver`     | Visualizar usuarios               | Acceso a pantalla                            |
| `crear`   | Crear nuevo usuario               | Botón "+ Nuevo Usuario"                      |
| `editar`  | Modificar usuario/activar         | Botón "Editar", Switch Activo, Botón Estado  |
| `borrar`  | Eliminar usuario (no implementado)| -                                            |

### 6. **logs** - Auditoría del Sistema

| Acción    | Descripción                       | Botón/Acción UI                          |
|-----------|-----------------------------------|------------------------------------------|
| `ver`     | Visualizar logs de auditoría      | Acceso a pantalla completa               |

---

## 🏗️ Arquitectura de Implementación

### Componentes Modificados

1. **`GestorAuth.qml`** - Gestor central de autenticación y permisos
   - Propiedades: `permisosRol`, `permisosUsuario`, `permisosResueltos`
   - Funciones: `cargarPermisosRol()`, `cargarPermisosUsuario()`, `combinarPermisos()`, `tienePermiso()`

2. **`main.qml`** - Integración UI
   - Sidebar: items desactivados según permisos
   - Pantallas CRUD: botones restringidos dinámicamente

3. **`test_rbac.qml`** - Suite de tests automáticos
   - Tests de carga de permisos
   - Tests de resolución y precedencia
   - Tests de integración UI

---

## 🔄 Flujo de Funcionamiento

### 1. Login y Carga de Permisos

```
Usuario ingresa credenciales
    ↓
POST /auth/login → token
    ↓
GET /auth/me → datosUsuario (incluye rol)
    ↓
GET /permisos/rol/{rol} → permisosRol[]
    ↓
GET /permisos/usuario/{id} → permisosUsuario[]
    ↓
combinarPermisos() → permisosResueltos{}
    ↓
UI actualizada según permisos
```

### 2. Resolución de Permisos

```javascript
function tienePermiso(recurso, accion) {
    // 1. DUENO tiene acceso total
    if (usuario.rol === "DUENO") return true

    // 2. Buscar en permisos resueltos
    var clave = recurso + ":" + accion
    if (permisosResueltos[clave]) {
        return permisosResueltos[clave]
    }

    // 3. Sin permiso explícito → denegar
    return false
}
```

### 3. Combinación de Permisos (Precedencia)

```javascript
function combinarPermisos() {
    var resueltos = {}

    // Primero: permisos del ROL
    for (var permisoRol of permisosRol) {
        resueltos[permisoRol.recurso + ":" + permisoRol.accion] = permisoRol.permitido
    }

    // Segundo: permisos del USUARIO (sobrescriben)
    for (var permisoUsuario of permisosUsuario) {
        resueltos[permisoUsuario.recurso + ":" + permisoUsuario.accion] = permisoUsuario.permitido
    }

    permisosResueltos = resueltos
}
```

---

## 🧪 Tests Automáticos

### Casos de Prueba Implementados

#### A) Tests de Carga de Permisos
- ✅ `test_dueno_tiene_acceso_total()` - DUENO puede TODO
- ✅ `test_admin_permisos_rol()` - ADMIN según permisos configurados
- ✅ `test_gerente_permisos_limitados()` - GERENTE acceso parcial
- ✅ `test_vendedor_permisos_basicos()` - VENDEDOR solo ventas/clientes

#### B) Tests de Resolución
- ✅ `test_overrides_precedencia_sobre_rol()` - Usuario > Rol
- ✅ `test_override_deniega_permiso_rol()` - Override puede denegar
- ✅ `test_sin_permiso_explicito_denegar()` - Sin permiso → denegar

#### C) Tests de Integración
- ✅ `test_limpieza_logout()` - Logout limpia todo

### Ejecución de Tests

```bash
# Ejecutar tests desde Qt Creator o línea de comandos
qmlscene interfaz-neon/quantum/tests/test_rbac.qml
```

---

## 📊 Matriz de Permisos por Rol (Ejemplo)

| Recurso       | Acción   | DUENO | ADMIN | GERENTE | VENDEDOR |
|---------------|----------|-------|-------|---------|----------|
| clientes:ver  | -        | ✅    | ✅    | ✅      | ✅       |
| clientes:crear| -        | ✅    | ✅    | ❌      | ✅       |
| clientes:editar| -       | ✅    | ✅    | ❌      | ❌       |
| clientes:borrar| -       | ✅    | ❌    | ❌      | ❌       |
| inventario:ver| -        | ✅    | ✅    | ✅      | ❌       |
| inventario:crear| -      | ✅    | ✅    | ❌      | ❌       |
| inventario:editar| -     | ✅    | ✅    | ✅      | ❌       |
| inventario:borrar| -     | ✅    | ❌    | ❌      | ❌       |
| recetas:ver   | -        | ✅    | ✅    | ✅      | ❌       |
| recetas:crear | -        | ✅    | ✅    | ❌      | ❌       |
| recetas:editar| -        | ✅    | ✅    | ❌      | ❌       |
| recetas:borrar| -        | ✅    | ❌    | ❌      | ❌       |
| ventas:ver    | -        | ✅    | ✅    | ✅      | ✅       |
| ventas:crear  | -        | ✅    | ✅    | ✅      | ✅       |
| usuarios:ver  | -        | ✅    | ✅    | ❌      | ❌       |
| usuarios:crear| -        | ✅    | ✅    | ❌      | ❌       |
| usuarios:editar| -       | ✅    | ✅    | ❌      | ❌       |
| logs:ver      | -        | ✅    | ✅    | ❌      | ❌       |

**Nota:** DUENO (✅ ALL) tiene acceso completo a todo sin restricciones.

---

## 🔒 Reglas de Seguridad

1. **Precedencia Usuario > Rol**: Los overrides del usuario siempre tienen prioridad.
2. **Sin Permiso Explícito = Denegar**: Si no existe permiso, se deniega acceso.
3. **DUENO Sin Restricciones**: El rol DUENO bypassa todas las verificaciones.
4. **Logout Limpia Todo**: Al cerrar sesión, todos los permisos se borran de memoria.
5. **Items Desactivados, No Ocultos**: UI sigue visible pero no interactiva.

---

## 🎨 Experiencia de Usuario (UX)

### Elementos Desactivados

Los botones y elementos desactivados muestran:
- **Color gris** (`#404050` background, `#808080` texto)
- **Opacidad reducida** (50%)
- **Cursor prohibido** (`Qt.ForbiddenCursor`)
- **Sin efectos hover** (glow desactivado)

### Elementos Habilitados

- **Colores neon completos**
- **Efectos de glow** en hover
- **Cursor pointer** (`Qt.PointingHandCursor`)
- **Feedback visual** en interacciones

---

## 📝 Notas de Implementación

### ✅ Cumplimiento de Requisitos

- ✅ NO se modificó `pantalla_permisos.qml`
- ✅ NO se modificó el login
- ✅ NO se duplicaron requests de permisos
- ✅ NO se agregaron fugas de estado global
- ✅ NO se cambió el estilo neon ni colores
- ✅ NO se ocultaron botones (solo `enabled: false`)
- ✅ NO se hardcodearon permisos en QML
- ✅ NO se cambió navegación ni Sidebar layout
- ✅ NO se tocó ApiHelper ni funciones de red existentes

### 🔧 Archivos Modificados

1. `/interfaz-neon/quantum/cerebro/GestorAuth.qml` - **CORE RBAC**
2. `/interfaz-neon/quantum/main.qml` - **Integración UI**

### 📦 Archivos Creados

1. `/interfaz-neon/quantum/tests/test_rbac.qml` - **Tests automáticos**
2. `/RBAC_DOCUMENTATION.md` - **Esta documentación**

---

## 🚀 Checklist Final

### Implementación
- [x] GestorAuth.tienePermiso(recurso, accion) implementado
- [x] Carga de permisos rol desde /permisos/rol/{rol}
- [x] Carga de permisos usuario desde /permisos/usuario/{id}
- [x] Combinación con precedencia usuario > rol
- [x] Expone permisosResueltos en memoria

### Integración UI
- [x] pantallaClientes - botones restringidos
- [x] pantallaIngredientes - botones restringidos
- [x] pantallaRecetas - botones restringidos
- [x] pantallaVentas - botón registrar restringido
- [x] pantallaUsuarios - botones y switches restringidos
- [x] pantallaLogs - solo visualización
- [x] Sidebar - items desactivados (nunca ocultos)

### Tests
- [x] Tests de roles (DUENO, ADMIN, GERENTE, VENDEDOR)
- [x] Tests de precedencia (overrides)
- [x] Tests de resolución (permitir/denegar)
- [x] Tests de limpieza (logout)

---

## 📞 Soporte

Para más información o modificaciones al sistema RBAC, consultar:
- Backend: `/permisos/rol/{rol}` y `/permisos/usuario/{id}`
- Frontend: `GestorAuth.qml` líneas 19-226
- Tests: `tests/test_rbac.qml`

---

**Implementado por:** Claude (Anthropic)
**Fecha:** 2025-12-04
**Versión del Módulo:** 1.0.0
**Compatible con:** Neon-Quantum Backend FastAPI v2.0
