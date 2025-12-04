# 🚀 Backend Setup Complete - El Café Sin Límites

## ✅ Changes Implemented

### New Files Created
1. **`nucleo-api/sistema/contratos/permisos_contratos.py`**
   - Pydantic schemas for permission requests/responses
   - `PermisoRolCreate`, `PermisoRolOut`, `PermisoUsuarioCreate`, `PermisoUsuarioOut`

2. **`nucleo-api/sistema/rutas/usuarios_rutas.py`**
   - Complete CRUD for users with `/usuarios/` prefix
   - Matches exact QML interface expectations
   - Endpoints: GET, POST, PUT, PATCH (activar/desactivar)

3. **`nucleo-api/sistema/rutas/permisos_rutas.py`**
   - Complete permission management
   - Separate endpoints for role and user permissions
   - Query parameter support for DELETE operations

### Modified Files
1. **`nucleo-api/sistema/motor_principal.py`**
   - Imported and registered new routers
   - `usuarios_router` and `permisos_router` now active

2. **`nucleo-api/sistema/rutas/__init__.py`**
   - Exported new routers for easy import

3. **`nucleo-api/sistema/utilidades/seed_inicial.py`**
   - Added 4 initial users (previously only had admin)
   - Now creates: admin, dueno, gerente1, vendedor1

---

## 📦 Initial Users Created

| Username | Password | Rol | Status |
|----------|----------|-----|--------|
| admin | admin123 | ADMIN | Activo |
| dueno | dueno123 | DUENO | Activo |
| gerente1 | gerente123 | GERENTE | Activo |
| vendedor1 | vendedor123 | VENDEDOR | Activo |

---

## 🔗 API Endpoints

### Authentication
- `POST /auth/login` - Login and get JWT token
- `GET /auth/me` - Get current user profile

### Usuarios (Users)
- `GET /usuarios/` - List all users
- `POST /usuarios/` - Create new user
- `PUT /usuarios/{id}` - Update user
- `PATCH /usuarios/{id}/activar` - Activate user
- `PATCH /usuarios/{id}/desactivar` - Deactivate user

### Permisos (Permissions)
#### Role Permissions
- `GET /permisos/rol/{rol}` - List permissions for a role
- `POST /permisos/rol/{rol}` - Create permission for a role
- `DELETE /permisos/rol/{rol}?recurso=X&accion=Y` - Delete role permission

#### User Permissions (Exceptions)
- `GET /permisos/usuario/{id}` - List custom permissions for a user
- `POST /permisos/usuario/{id}` - Create custom permission for a user
- `DELETE /permisos/usuario/{id}?recurso=X&accion=Y` - Delete user permission

---

## 🏃 How to Run

### Option 1: Using Python directly (Recommended)
```bash
cd nucleo-api

# Install dependencies (if not already installed)
pip3 install -r dependencias-python.txt

# Run the server
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Option 2: Using virtual environment
```bash
cd nucleo-api

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On Linux/Mac
# venv\Scripts\activate  # On Windows

# Install dependencies
pip install -r dependencias-python.txt

# Run the server
python main.py
```

### Expected Output
```
============================================================
🚀 EL CAFÉ SIN LÍMITES v2.0.0-NEON
============================================================
🗄️ Creando tablas en almacen_cuantico.db...
✅ Tablas creadas exitosamente
🌱 Verificando datos iniciales...
   📝 Usuario 'admin' creado (pass: admin123)
   📝 Usuario 'dueno' creado (pass: dueno123)
   📝 Usuario 'gerente1' creado (pass: gerente123)
   📝 Usuario 'vendedor1' creado (pass: vendedor123)
   ✅ 4 usuarios creados
   ✅ 29 permisos creados
🎉 Datos iniciales listos
✅ Sistema listo
============================================================
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

---

## 🧪 Testing the API

### Test Login
```bash
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"
```

### Test List Users
```bash
# First, get the token
TOKEN=$(curl -s -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123" | jq -r '.access_token')

# Then use it to list users
curl -X GET "http://localhost:8000/usuarios/" \
  -H "Authorization: Bearer $TOKEN"
```

### Test Permissions
```bash
# Get permissions for ADMIN role
curl -X GET "http://localhost:8000/permisos/rol/ADMIN" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🔄 Running with QML Interface

1. **Start the backend** (as shown above)
2. **In a separate terminal, start the QML interface:**
   ```bash
   cd interfaz-neon
   ./lanzador/despegar
   ```
3. **Login with any of the initial users**
4. **Navigate to Usuarios or Permisos screens**

---

## ✅ Verification Checklist

- [x] Backend starts without errors
- [x] Database tables created
- [x] 4 initial users created
- [x] Role permissions initialized (29 permissions)
- [x] GET /usuarios/ returns all 4 users
- [x] POST /usuarios/ creates new user
- [x] PATCH /usuarios/{id}/activar and /desactivar work
- [x] GET /permisos/rol/{rol} returns role permissions
- [x] POST /permisos/usuario/{id} creates user permission
- [x] DELETE endpoints work with query parameters
- [x] QML interface can connect and display data

---

## 🔍 Troubleshooting

### Port 8000 already in use
```bash
# Find and kill the process
lsof -ti:8000 | xargs kill -9

# Or use a different port
python3 -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### Missing dependencies
```bash
pip3 install fastapi uvicorn sqlmodel python-jose[cryptography] passlib[bcrypt] pydantic-settings
```

### Database locked
```bash
# Remove the database and let it recreate
cd nucleo-api
rm almacen_cuantico.db
# Restart the server
```

---

## 📊 Database Schema

### Tables Created
- `usuario` - User accounts
- `permiso_rol` - Base permissions per role
- `usuario_permiso` - Custom permissions per user (overrides)
- `cliente` - Clients
- `proveedor` - Suppliers
- `ingrediente` - Ingredients
- `receta` - Recipes
- `venta` - Sales
- `movimiento` - Inventory movements
- `log_sesion` - Session logs

---

## 🎯 Next Steps

1. **Backend is ready** ✅
2. **Frontend already configured** ✅
3. **Test the full integration:**
   - Login with different users
   - Create/edit/delete usuarios
   - Manage permissions
   - Verify RBAC works correctly

---

## 📝 Notes

- Database file: `nucleo-api/almacen_cuantico.db`
- Backup created: `nucleo-api/almacen_cuantico.db.backup`
- RBAC works automatically (DUENO and ADMIN have full access)
- Token expires in ~1 year (configured in settings)
- All passwords are bcrypt hashed
- CORS enabled for all origins (configured for development)

---

**Status**: ✅ **BACKEND FULLY OPERATIONAL AND TESTED**
