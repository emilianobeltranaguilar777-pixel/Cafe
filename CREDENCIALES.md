# 🔐 CREDENCIALES DEL SISTEMA

## Usuario Administrador por Defecto

Las credenciales del sistema son las siguientes:

```
Username: admin
Password: admin123
```

**IMPORTANTE:**
- El campo para login es `username`, NO `email`
- El sistema NO usa correo electrónico para autenticación
- Estos datos se crean automáticamente al ejecutar `populate_db.py`

---

## Cómo Hacer Login

### 1. Desde la API (HTTP)

**Endpoint:** `POST http://localhost:8000/auth/login`

**Content-Type:** `application/x-www-form-urlencoded`

**Parámetros:**
```
username: admin
password: admin123
```

**Ejemplo con curl:**
```bash
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"
```

**Respuesta esperada:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### 2. Desde la Documentación Swagger

1. Abrir: http://localhost:8000/docs
2. Click en "Authorize" (botón con candado)
3. Ingresar:
   - Username: `admin`
   - Password: `admin123`
4. Click en "Authorize"
5. Click en "Close"

Ahora puedes probar todos los endpoints.

### 3. Desde el Frontend QML

En la pantalla de login:
- **Usuario:** `admin`
- **Contraseña:** `admin123`

---

## Verificar las Credenciales

Ejecuta este script para verificar que el login funciona:

```bash
python verificar_login.py
```

Si todo está bien, verás:
```
✅ Login exitoso
Token recibido: eyJhbGciOiJIUzI1NiIs...
Usuario: admin
Rol: ADMIN
```

---

## Otros Usuarios de Prueba

Si necesitas crear más usuarios, usa el endpoint:

**POST** `/auth/usuarios`

**Headers:**
```
Authorization: Bearer <tu_token>
```

**Body:**
```json
{
  "username": "vendedor1",
  "nombre": "Juan Vendedor",
  "password": "venta123",
  "rol": "VENDEDOR"
}
```

---

## Roles Disponibles

El sistema tiene 4 roles con diferentes permisos:

1. **DUENO** - Acceso completo a todo el sistema
2. **ADMIN** - Administración de usuarios, inventario, ventas y reportes
3. **GERENTE** - Gestión de inventario, ventas, reportes y clientes
4. **VENDEDOR** - Solo ventas y consulta de clientes

---

## Estructura de Usuario en Base de Datos

Los usuarios en la base de datos tienen esta estructura:

```python
{
  "id": 1,
  "username": "admin",          # ← Campo usado para login
  "nombre": "Administrador",
  "password_hash": "...",        # ← Hash bcrypt
  "rol": "ADMIN",
  "activo": true,
  "creado_en": "2025-12-03T..."
}
```

**NO hay campo `email`** - El sistema usa `username` para autenticación.

---

## Solución de Problemas

### ❌ Error: "Credenciales incorrectas"

**Posibles causas:**
1. Username incorrecto (debe ser `admin`, no un email)
2. Password incorrecto (debe ser `admin123`)
3. Usuario no existe en la base de datos
4. Base de datos no ha sido inicializada

**Solución:**
```bash
# Recrear base de datos con usuario admin
python populate_db.py
```

### ❌ Error: "Usuario inactivo"

El usuario existe pero está desactivado.

**Solución:**
Activar usuario con endpoint PATCH o directamente en BD.

### ❌ Error: "Token inválido"

El token JWT ha expirado o es incorrecto.

**Solución:**
Hacer login nuevamente para obtener un nuevo token.

---

## Cambiar Contraseña del Admin

Para cambiar la contraseña del admin:

**PUT** `/auth/usuarios/1`

**Headers:**
```
Authorization: Bearer <tu_token>
```

**Body:**
```json
{
  "password": "nueva_contraseña_segura"
}
```

---

## Tokens JWT

Los tokens tienen:
- **Expiración:** 60 minutos (configurable en `.env`)
- **Algoritmo:** HS256
- **Contenido:** username y rol del usuario

Para ver el contenido de un token:
https://jwt.io/

---

## Variables de Entorno

Puedes configurar la seguridad en `.env`:

```env
SECRET_KEY=tu_clave_secreta_super_segura_cambiar_en_produccion
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

**IMPORTANTE:** Cambia `SECRET_KEY` en producción.

---

## Resumen Rápido

```
✅ Username: admin
✅ Password: admin123
✅ Endpoint: POST /auth/login
✅ Formato: application/x-www-form-urlencoded
✅ Respuesta: { "access_token": "...", "token_type": "bearer" }
```

**NO usar:**
- ❌ Email para login
- ❌ JSON para login (usar form-urlencoded)
- ❌ Otros campos además de username/password
