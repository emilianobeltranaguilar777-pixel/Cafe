# ⚠️ IMPORTANTE - LEER ANTES DE USAR

## 🔴 EL BACKEND DEBE ESTAR CORRIENDO

Para que la aplicación frontend funcione correctamente (guardar clientes, ingredientes, etc.), **EL BACKEND DEBE ESTAR CORRIENDO**.

### ¿Cómo iniciar el backend?

```bash
# Opción 1: Script rápido
./start_all.sh

# Opción 2: Manual
cd nucleo-api
python main.py
```

### ¿Cómo saber si el backend está corriendo?

Abre en tu navegador: http://localhost:8000

Deberías ver:
```json
{
  "proyecto": "EL CAFÉ SIN LÍMITES",
  "version": "2.0",
  "estado": "operativo",
  "mensaje": "☕ Bienvenido al Almacén Cuántico"
}
```

### Si el backend NO está corriendo:

❌ **Los datos NO se guardarán**
❌ Verás errores como: "Error al crear cliente"
❌ Las listas aparecerán vacías
❌ Los formularios darán error

### Si el backend SÍ está corriendo:

✅ Los datos se guardan correctamente
✅ Las listas se cargan con información
✅ Todo funciona perfectamente

---

## 🚀 Inicio Completo del Sistema

### Paso 1: Iniciar Backend

```bash
# Terminal 1
./start_all.sh

# Deberías ver:
# 🚀 EL CAFÉ SIN LÍMITES API v2.0
# 🌐 URL: http://localhost:8000
# ✅ Sistema listo
```

### Paso 2: Iniciar Frontend (opcional)

```bash
# Terminal 2
cd interfaz-neon/lanzador
./despegar

# Deberías ver:
# 🚀 Iniciando EL CAFÉ SIN LÍMITES v2.0 FINAL...
# ✅ Arrancando con Qt5...
```

### Paso 3: Hacer Login

**Credenciales:**
- Usuario: `admin`
- Contraseña: `admin123`

---

## 📋 Verificar que Todo Funciona

### Test 1: Backend
```bash
curl http://localhost:8000/salud
# Debe retornar: {"estado":"saludable",...}
```

### Test 2: Login
```bash
python verificar_login.py
# Debe mostrar: ✅ Login exitoso
```

### Test 3: Crear Cliente (con backend corriendo)
```bash
# 1. Obtener token
TOKEN=$(curl -s -X POST http://localhost:8000/auth/login \
  -d 'username=admin&password=admin123' | \
  python3 -c 'import sys, json; print(json.load(sys.stdin)["access_token"])')

# 2. Crear cliente
curl -X POST "http://localhost:8000/clientes/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Juan Pérez","correo":"juan@test.com","telefono":"555-1234","direccion":"Calle 123","alergias":"Lactosa"}'

# Debe retornar el cliente creado con su ID
```

---

## 🐛 Troubleshooting

### Error: "Failed to connect to localhost port 8000"

**Causa:** El backend no está corriendo

**Solución:**
```bash
./start_all.sh
```

### Error: "HTTP 401: Unauthorized"

**Causa:** Token inválido o expirado

**Solución:** Hacer logout y login nuevamente en el frontend

### Error: "HTTP 422: Validation Error"

**Causa:** Datos mal formateados o campos faltantes

**Solución:** Verifica que el formulario tenga todos los datos necesarios

---

## 📝 Logs y Debug

El frontend muestra logs en la consola de QML. Para verlos:

```bash
# Al ejecutar el frontend, verás logs como:
POST http://localhost:8000/clientes/ {"nombre":"...","correo":"..."}
✅ Cliente creado
```

Si hay un error, verás:
```bash
POST Error: HTTP 0 - Backend no está corriendo
```

---

## ✅ Resumen

1. **SIEMPRE** inicia el backend primero con `./start_all.sh`
2. Verifica que esté corriendo: `http://localhost:8000`
3. Luego inicia el frontend: `cd interfaz-neon/lanzador && ./despegar`
4. Usa credenciales: `admin` / `admin123`
5. ¡Disfruta de la aplicación!

---

**¿Dudas?** Lee `README.md`, `CREDENCIALES.md` y `FRONTEND.md`
