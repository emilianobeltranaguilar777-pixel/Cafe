# ✅ Checklist de Verificación Manual - RBAC QML

## 🎯 OBJETIVO
Verificar que el sistema RBAC funciona correctamente después de las correcciones.

---

## 📋 CHECKLIST DE COMPILACIÓN

### 1. Compilar sin errores
```bash
cd /home/user/Cafe
export QML2_IMPORT_PATH=./interfaz-neon
qmlscene interfaz-neon/quantum/main.qml
```

**Resultado esperado:**
- [ ] Sin errores "Glow is not a type"
- [ ] Sin errores "module quantum is not installed"
- [ ] Sin errores "Component elements may not contain properties"
- [ ] Sin errores de sintaxis en pantalla_permisos.qml (línea 776 corregida)
- [ ] Ventana de login aparece correctamente

---

## 🧪 CHECKLIST DE TESTS AUTOMÁTICOS

### 2. Ejecutar tests de imports
```bash
export QML2_IMPORT_PATH=./interfaz-neon
qmltestrunner -input interfaz-neon/quantum/tests/test_imports.qml
```

**Resultado esperado:**
- [ ] 11 tests pasan
- [ ] 0 tests fallan

### 3. Ejecutar tests de RBAC
```bash
export QML2_IMPORT_PATH=./interfaz-neon
qmltestrunner -input interfaz-neon/quantum/tests/test_rbac_final.qml
```

**Resultado esperado:**
- [ ] test_admin_tiene_acceso_total: PASS
- [ ] test_dueno_tiene_acceso_total: PASS
- [ ] test_gerente_permisos_limitados: PASS
- [ ] test_vendedor_permisos_minimos: PASS
- [ ] test_override_usuario_permite_accion_denegada: PASS
- [ ] test_override_usuario_deniega_accion_permitida: PASS
- [ ] test_sin_login_sin_permisos: PASS
- [ ] test_permiso_inexistente_deniega: PASS
- [ ] test_limpieza_logout: PASS
- [ ] test_combinacion_permisos_precedencia_usuario: PASS
- [ ] test_estado_inicial_correcto: PASS

**Total esperado:** 11 PASS, 0 FAIL

---

## 🖥️ CHECKLIST DE FUNCIONALIDAD UI

### 4. Login y Dashboard

**Pasos:**
1. Iniciar aplicación
2. Ingresar credenciales (usuario ADMIN recomendado)
3. Click en "INGRESAR"

**Verificar:**
- [ ] Login exitoso sin errores en consola
- [ ] Aparece el dashboard
- [ ] Sidebar visible con todos los items
- [ ] Nombre de usuario y rol visible en sidebar

---

### 5. Menú Lateral (Sidebar) - CRÍTICO

**Para usuario ADMIN:**

**Verificar que TODOS los items están habilitados y responden:**
- [ ] Click en "Dashboard" → cambia a dashboard ✅
- [ ] Click en "Clientes" → cambia a clientes ✅
- [ ] Click en "Ingredientes" → cambia a ingredientes ✅
- [ ] Click en "Recetas" → cambia a recetas ✅
- [ ] Click en "Ventas" → cambia a ventas ✅
- [ ] Click en "Usuarios" → cambia a usuarios ✅
- [ ] Click en "Logs" → cambia a logs ✅
- [ ] Click en "Permisos" → cambia a permisos ✅

**Verificar estilos:**
- [ ] Items habilitados: color #e0e0ff (azul claro)
- [ ] Hover funciona en items habilitados
- [ ] Item activo: borde #00ffff (cyan) visible
- [ ] Cursor: pointer en items habilitados

---

### 6. Pantalla de Permisos - CRÍTICO

**Pasos:**
1. Click en "Permisos" en sidebar
2. Verificar que la pantalla carga

**Verificar:**
- [ ] Pantalla de permisos carga sin errores
- [ ] Tabs "Por Usuario" y "Por Rol" visibles
- [ ] ComboBox de usuarios/roles funciona
- [ ] Botón "Cargar" funciona
- [ ] Tabla de permisos se muestra correctamente
- [ ] Botones "Guardar" / "Eliminar" visibles
- [ ] Modal de agregar permiso funciona
- [ ] Sin errores en consola relacionados con línea 776

---

### 7. Botones CRUD con RBAC - Usuario ADMIN

**En Pantalla Usuarios:**
- [ ] Botón "+ Nuevo Usuario" → HABILITADO ✅
- [ ] Botón "Editar" en lista → HABILITADO ✅
- [ ] Switch "Activo/Inactivo" → HABILITADO ✅
- [ ] Botón "Activar/Desactivar" → HABILITADO ✅
- [ ] Todos los botones responden al click

**En Pantalla Ingredientes:**
- [ ] Botón "+ Nuevo Ingrediente" → HABILITADO ✅
- [ ] Botón "Editar" → HABILITADO ✅
- [ ] Botón "Ajustar Stock" → HABILITADO ✅
- [ ] Botón "Eliminar" → HABILITADO ✅

**En Pantalla Recetas:**
- [ ] Botón "+ Nueva Receta" → HABILITADO ✅
- [ ] Botón "Editar" → HABILITADO ✅
- [ ] Botón "Eliminar" → HABILITADO ✅

**En Pantalla Ventas:**
- [ ] Botón "Registrar Venta" → HABILITADO ✅ (cuando carrito > 0)

**En Pantalla Clientes:**
- [ ] Botón "+ Nuevo Cliente" → HABILITADO ✅
- [ ] Botón "Editar" → HABILITADO ✅
- [ ] Botón "Eliminar" → HABILITADO ✅

---

### 8. Botones CRUD con RBAC - Usuario VENDEDOR

**Crear usuario VENDEDOR en backend primero**

**Verificar restricciones (botones DESACTIVADOS):**

**Pantalla Usuarios:**
- [ ] NO puede acceder (sidebar item desactivado o pantalla vacía)

**Pantalla Ingredientes:**
- [ ] NO puede acceder (sidebar item desactivado)

**Pantalla Recetas:**
- [ ] NO puede acceder (sidebar item desactivado)

**Pantalla Ventas:**
- [ ] SÍ puede acceder ✅
- [ ] Botón "Registrar Venta" → HABILITADO ✅

**Pantalla Clientes:**
- [ ] SÍ puede acceder ✅
- [ ] Botones en SOLO LECTURA (sin editar/eliminar)

---

### 9. Estilos de Botones Desactivados

**Cuando un botón está desactivado por falta de permisos:**

**Verificar:**
- [ ] Background color: #404050 (gris oscuro) ✅
- [ ] Text color: #808080 (gris medio) ✅
- [ ] Opacity: normal (no transparente) ✅
- [ ] No responde a hover ✅
- [ ] No responde a click ✅
- [ ] Cursor: ForbiddenCursor (🚫) ✅

---

### 10. Funcionalidad CRUD Real

**Crear un cliente (como ADMIN):**
1. Ir a "Clientes"
2. Click "+ Nuevo Cliente"
3. Llenar nombre, correo, teléfono
4. Click "Guardar Cliente"

**Verificar:**
- [ ] Cliente se crea exitosamente
- [ ] Aparece en la lista
- [ ] Notificación de éxito visible

**Editar un ingrediente (como ADMIN):**
1. Ir a "Ingredientes"
2. Click "Editar" en un item
3. Modificar stock
4. Click "Actualizar"

**Verificar:**
- [ ] Ingrediente se actualiza
- [ ] Stock refleja cambio
- [ ] Notificación de éxito

---

### 11. Permisos Backend

**Verificar endpoints funcionando:**

```bash
# Login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"

# Obtener token y usarlo:
export TOKEN="<token_obtenido>"

# Permisos por rol
curl http://localhost:8000/permisos/rol/GERENTE \
  -H "Authorization: Bearer $TOKEN"

# Permisos por usuario
curl http://localhost:8000/permisos/usuario/1 \
  -H "Authorization: Bearer $TOKEN"
```

**Verificar:**
- [ ] GET /permisos/rol/{rol} retorna array de permisos
- [ ] GET /permisos/usuario/{id} retorna array de overrides
- [ ] Formato correcto: `{recurso, accion, permitido}`

---

## 🐛 CHECKLIST DE ERRORES CORREGIDOS

### 12. Errores Específicos Reparados

- [ ] **Línea 776 pantalla_permisos.qml**: Llave extra eliminada ✅
- [ ] **Import QtGraphicalEffects**: Agregado en main.qml línea 4 ✅
- [ ] **Component pantalla_permisos**: Envuelto en Loader ✅
- [ ] **GestorAuth.tienePermiso()**: ADMIN tiene acceso total ✅

---

## 📊 RESUMEN DE PRUEBAS

| Categoría | Tests | Descripción |
|-----------|-------|-------------|
| Compilación | 5 checks | Sin errores de sintaxis |
| Tests Auto | 22 tests | Imports + RBAC |
| UI Login | 4 checks | Login funcional |
| Sidebar | 8 checks | Navegación correcta |
| Permisos | 8 checks | Pantalla funcional |
| CRUD ADMIN | 13 checks | Todos los botones habilitados |
| CRUD VENDEDOR | 7 checks | Restricciones aplicadas |
| Estilos | 6 checks | Botones desactivados correctos |
| CRUD Real | 5 checks | Operaciones exitosas |
| Backend | 3 checks | Endpoints funcionando |
| Fixes | 4 checks | Errores corregidos |

**TOTAL:** 85 verificaciones

---

## ✅ CRITERIO DE ÉXITO

**La implementación está correcta si:**

1. ✅ Todos los tests automáticos pasan (22/22)
2. ✅ La aplicación compila sin errores
3. ✅ Usuario ADMIN puede hacer TODO
4. ✅ Usuario VENDEDOR tiene restricciones
5. ✅ Sidebar responde a clicks en todos los items
6. ✅ Pantalla de permisos carga sin errores
7. ✅ Botones CRUD respetan RBAC
8. ✅ Estilos neon se mantienen intactos
9. ✅ No hay errores en consola durante navegación
10. ✅ CRUD real funciona (crear, editar, eliminar)

---

## 🚀 COMANDOS RÁPIDOS

### Compilar y ejecutar
```bash
cd /home/user/Cafe
export QML2_IMPORT_PATH=./interfaz-neon
qmlscene interfaz-neon/quantum/main.qml
```

### Ejecutar todos los tests
```bash
export QML2_IMPORT_PATH=./interfaz-neon
qmltestrunner -input interfaz-neon/quantum/tests/
```

### Ver logs en tiempo real
```bash
qmlscene interfaz-neon/quantum/main.qml 2>&1 | tee qml_output.log
```

### Verificar sintaxis QML
```bash
qmllint interfaz-neon/quantum/main.qml
qmllint interfaz-neon/quantum/pantallas/pantalla_permisos.qml
qmllint interfaz-neon/quantum/cerebro/GestorAuth.qml
```

---

**Checklist completado por:** _______________
**Fecha:** _______________
**Resultado:** [ ] PASS [ ] FAIL
**Notas:** _______________________________________________
