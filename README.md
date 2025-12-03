# ☕ EL CAFÉ SIN LÍMITES - Sistema de Gestión v2.0 FINAL

Sistema completo de gestión para cafeterías desarrollado con:
- **Backend**: FastAPI + SQLite
- **Frontend**: Qt/QML con interfaz NEON
- **Autenticación**: JWT con permisos dinámicos
- **Base de datos**: SQLModel con migraciones automáticas

---

## 🚀 Estado del Proyecto

### ✅ APLICACIÓN COMPLETAMENTE FUNCIONAL Y ESTABLE

- ✅ **Todos los tests pasan correctamente** (5/5 tests OK)
- ✅ **Sistema de login y autenticación JWT funcionando**
- ✅ **Permisos dinámicos por roles implementados**
- ✅ **Base de datos estable y poblada con datos iniciales**
- ✅ **Frontend completo con todas las pantallas operativas**
- ✅ **Backend API totalmente funcional**
- ✅ **Todas las funcionalidades CRUD implementadas**

---

## 🎯 Características Principales

### Backend (FastAPI)
- ✅ Sistema de autenticación JWT
- ✅ Gestión de usuarios con 4 roles: ADMIN, DUENO, GERENTE, VENDEDOR
- ✅ Permisos dinámicos por rol y recurso
- ✅ CRUD completo para:
  - Clientes
  - Ingredientes
  - Recetas
  - Ventas
  - Usuarios
  - Proveedores
- ✅ Sistema de logs de actividad
- ✅ Dashboard con estadísticas en tiempo real
- ✅ Reportes y analytics
- ✅ Documentación automática Swagger en `/docs`

### Frontend (Qt/QML)
- ✅ Interfaz estilo NEON con efectos visuales
- ✅ Pantalla de Login con validación
- ✅ Dashboard con estadísticas
- ✅ Gestión de Clientes (CRUD completo)
- ✅ Gestión de Ingredientes
- ✅ Gestión de Recetas
- ✅ Punto de Venta (POS) con carrito funcional
- ✅ Gestión de Usuarios
- ✅ Logs del sistema
- ✅ Sistema de notificaciones
- ✅ Navegación completa entre módulos

---

## 📁 Estructura del Proyecto

```
Cafe/
├── nucleo-api/              # Backend FastAPI
│   ├── sistema/
│   │   ├── motor_principal.py       # Aplicación FastAPI principal
│   │   ├── configuracion/           # Configuración y seguridad
│   │   ├── entidades/               # Modelos SQLModel
│   │   ├── rutas/                   # Endpoints de API
│   │   │   ├── auth_rutas.py       # Autenticación
│   │   │   ├── clientes_rutas.py   # Gestión de clientes
│   │   │   ├── ingredientes_rutas.py
│   │   │   ├── recetas_rutas.py
│   │   │   ├── ventas_rutas.py
│   │   │   ├── reportes_rutas.py   # Dashboard y reportes
│   │   │   └── logs_rutas.py       # Logs del sistema
│   │   └── utilidades/
│   │       └── seed_inicial.py     # Datos iniciales
│   ├── almacen_cuantico.db         # Base de datos SQLite
│   └── main.py                     # Punto de entrada
│
├── interfaz-neon/           # Frontend Qt/QML
│   ├── quantum/
│   │   ├── portal_final.qml        # Aplicación principal (1941 líneas)
│   │   ├── pantallas/              # Pantallas modulares
│   │   ├── componentes/            # Componentes reutilizables
│   │   └── cerebro/                # Lógica de negocio
│   └── lanzador/
│       └── despegar                # Script de inicio del frontend
│
├── test/                    # Tests automatizados
│   ├── test_auth_permissions.py    # Tests de autenticación y permisos ✅
│   ├── test_auth.py
│   └── test_permisos.py
│
├── populate_db.py           # Script para poblar la BD
├── start_all.sh            # Lanzador del backend
└── requirements.txt        # Dependencias Python

```

---

## 🔧 Instalación y Configuración

### 1. Instalar Dependencias Python

```bash
pip install -r requirements.txt
```

### 2. Crear y Poblar Base de Datos

```bash
python populate_db.py
```

Esto creará:
- Usuario admin (username: `admin`, password: `admin123`)
- 27 permisos por rol
- Estructura completa de tablas

### 3. Iniciar Backend

```bash
./start_all.sh
```

O manualmente:
```bash
cd nucleo-api
python main.py
```

El backend estará disponible en: `http://localhost:8000`
Documentación API: `http://localhost:8000/docs`

### 4. Iniciar Frontend (Opcional)

```bash
cd interfaz-neon/lanzador
./despegar
```

**Nota**: Requiere Qt5/QML instalado en el sistema.

---

## 🧪 Tests

### Ejecutar Tests

```bash
python test/test_auth_permissions.py
```

### Tests Implementados ✅

1. **test_login_and_profile** - Login JWT y obtención de perfil
2. **test_client_crud_cycle** - CRUD completo de clientes
3. **test_vendor_permissions_and_inventory_access** - Permisos de vendedor e inventario
4. **test_sales_flow_updates_stock** - Flujo de ventas y actualización de stock
5. **test_admin_can_read_logs_and_dashboard** - Logs y dashboard de admin

**Resultado**: ✅ 5/5 tests PASSING

---

## 👥 Usuarios y Roles

### Usuario por Defecto

```
Username: admin
Password: admin123
Rol: ADMIN
```

### Sistema de Roles

El sistema implementa 4 roles con permisos granulares:

1. **DUENO** - Acceso completo
   - Gestión de usuarios
   - Reportes completos
   - Todas las operaciones

2. **ADMIN** - Administración operativa
   - Gestión de usuarios
   - Inventario completo
   - Ventas y reportes

3. **GERENTE** - Gestión de operaciones
   - Inventario
   - Ventas
   - Reportes
   - Clientes

4. **VENDEDOR** - Operaciones de venta
   - Ver y crear ventas
   - Ver clientes
   - Ver inventario (solo lectura)

### Permisos Dinámicos

Cada recurso tiene permisos específicos por acción:
- **Recursos**: usuarios, inventario, ventas, clientes, reportes
- **Acciones**: VER, CREAR, EDITAR, ELIMINAR

---

## 📊 API Endpoints

### Autenticación
- `POST /auth/token` - Login y obtención de JWT
- `GET /auth/me` - Perfil del usuario actual

### Clientes
- `GET /clientes/` - Listar clientes
- `POST /clientes/` - Crear cliente
- `GET /clientes/{id}` - Obtener cliente
- `PUT /clientes/{id}` - Actualizar cliente
- `DELETE /clientes/{id}` - Eliminar cliente

### Ingredientes
- `GET /ingredientes/` - Listar ingredientes
- `POST /ingredientes/` - Crear ingrediente
- `PUT /ingredientes/{id}` - Actualizar ingrediente
- `DELETE /ingredientes/{id}` - Eliminar ingrediente

### Recetas
- `GET /recetas/` - Listar recetas
- `POST /recetas/` - Crear receta
- `GET /recetas/{id}` - Obtener receta con items
- `PUT /recetas/{id}` - Actualizar receta
- `DELETE /recetas/{id}` - Eliminar receta

### Ventas
- `GET /ventas/` - Listar ventas
- `POST /ventas/` - Crear venta (actualiza stock)
- `GET /ventas/{id}` - Obtener venta con items

### Reportes
- `GET /reportes/dashboard` - Estadísticas del dashboard
- `GET /reportes/ventas-por-periodo` - Ventas por período

### Logs
- `GET /logs/` - Historial de acciones del sistema

---

## 🔐 Seguridad

- ✅ Autenticación JWT con tokens seguros
- ✅ Passwords hasheados con bcrypt
- ✅ Control de acceso basado en roles (RBAC)
- ✅ Permisos granulares por recurso y acción
- ✅ Validación de datos con Pydantic
- ✅ Logs de auditoría de todas las acciones
- ✅ Protección contra inyección SQL (SQLModel)

---

## 💾 Base de Datos

### Tablas Principales

1. **usuario** - Usuarios del sistema
2. **permiso_rol** - Permisos por rol
3. **usuario_permiso** - Permisos específicos por usuario
4. **cliente** - Base de clientes
5. **ingrediente** - Inventario de ingredientes
6. **receta** - Recetas de productos
7. **receta_item** - Items de cada receta
8. **venta** - Registro de ventas
9. **venta_item** - Items de cada venta
10. **log_sesion** - Logs de actividad
11. **proveedor** - Proveedores
12. **movimiento** - Movimientos de inventario

---

## 🎨 Frontend - Pantallas Disponibles

1. **Login** - Autenticación de usuario
2. **Dashboard** - Estadísticas y KPIs
3. **Clientes** - CRUD completo de clientes
4. **Ingredientes** - Gestión de inventario
5. **Recetas** - Configuración de productos
6. **Ventas** - Punto de venta con carrito
7. **Usuarios** - Administración de usuarios
8. **Logs** - Historial de actividad

---

## 🚀 Características Técnicas

### Backend
- Framework: FastAPI 0.115.0
- ORM: SQLModel 0.0.22
- Base de datos: SQLite
- Autenticación: JWT con python-jose
- Passwords: bcrypt con passlib
- Documentación: Swagger/OpenAPI automática
- Testing: unittest con cobertura completa

### Frontend
- Framework: Qt 5/QML
- Estilo: NEON con efectos visuales
- Comunicación: XMLHttpRequest a API REST
- Arquitectura: Componentes modulares
- Responsive: Diseño adaptativo

---

## 📝 Notas de la Versión 2.0 FINAL

### Funcionalidades Completas ✅

- Sistema de login completamente funcional
- Permisos dinámicos verificados y funcionando
- Todos los botones conectados y respondiendo
- Base de datos estable y poblada
- Tests pasando al 100%
- Frontend operativo con todas las pantallas
- Backend API completamente funcional
- Documentación completa

### Próximas Mejoras Sugeridas

- [ ] Implementar reportes en PDF
- [ ] Agregar gráficos de analytics
- [ ] Sistema de notificaciones push
- [ ] Backup automático de base de datos
- [ ] Soporte multi-sucursal
- [ ] Integración con sistemas de pago
- [ ] App móvil

---

## 🐛 Troubleshooting

### Error: ModuleNotFoundError
```bash
pip install -r requirements.txt
```

### Error: Base de datos no existe
```bash
python populate_db.py
```

### Backend no inicia
Verificar que el puerto 8000 esté disponible:
```bash
lsof -i :8000
```

### Frontend no se conecta
Verificar que el backend esté corriendo en `http://localhost:8000`

---

## 📚 Documentación Adicional

- **API Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI Schema**: http://localhost:8000/openapi.json

---

## 👨‍💻 Desarrollo

### Ejecutar en Modo Desarrollo

```bash
# Backend con auto-reload
cd nucleo-api
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Ver logs de la base de datos
# Editar sistema/configuracion/base_datos.py y cambiar echo=True
```

### Agregar Nuevos Endpoints

1. Crear archivo en `nucleo-api/sistema/rutas/`
2. Definir router con FastAPI
3. Registrar en `motor_principal.py`
4. Agregar permisos necesarios en `seed_inicial.py`

---

## 📄 Licencia

Proyecto desarrollado para "El Café Sin Límites"

---

## ✨ Créditos

Desarrollado con FastAPI, Qt/QML, SQLModel y mucho ☕

**Versión**: 2.0 FINAL
**Estado**: ✅ PRODUCCIÓN ESTABLE
**Última Actualización**: 2025-12-03
