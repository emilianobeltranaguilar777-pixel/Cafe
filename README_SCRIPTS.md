# 🚀 Scripts de Gestión del Backend

Este directorio contiene scripts para facilitar el inicio y detención del backend de "El Café Sin Límites".

## 📜 Scripts Disponibles

### 1. `iniciar_backend.sh`
Script para iniciar el servidor backend de FastAPI.

**Uso:**
```bash
./iniciar_backend.sh
```

**¿Qué hace?**
- ✅ Verifica que exista el entorno virtual
- ✅ Activa el entorno virtual automáticamente
- ✅ Verifica que las dependencias estén instaladas
- ✅ Instala dependencias faltantes si es necesario
- ✅ Verifica si el puerto 8000 está ocupado
- ✅ Inicia el servidor en http://localhost:8000

---

### 2. `detener_backend.sh`
Script para detener el servidor backend.

**Uso:**
```bash
./detener_backend.sh
```

**¿Qué hace?**
- ✅ Busca el proceso corriendo en el puerto 8000
- ✅ Detiene el proceso de forma segura
- ✅ Si no responde, fuerza el cierre

---

## 🔐 Credenciales de Login

Una vez que el backend esté corriendo, puedes acceder con:

- **Usuario:** `admin`
- **Contraseña:** `admin123`

---

## 🌐 URLs del Backend

- **API Principal:** http://localhost:8000
- **Documentación Interactiva (Swagger):** http://localhost:8000/docs
- **Documentación Alternativa (ReDoc):** http://localhost:8000/redoc
- **Health Check:** http://localhost:8000/salud

---

## 📝 Notas

- El backend debe estar corriendo para que la interfaz QML pueda autenticar usuarios
- Si encuentras errores, revisa que todas las dependencias estén instaladas
- Los logs del servidor aparecerán en la terminal donde ejecutaste el script

---

## 🐛 Solución de Problemas

### El puerto 8000 está ocupado
```bash
# Detén el proceso existente
./detener_backend.sh

# O encuentra y mata el proceso manualmente
lsof -ti :8000 | xargs kill -9
```

### Dependencias faltantes
```bash
cd nucleo-api
source cafeina-env/bin/activate
pip install -r dependencias-python.txt
pip install cffi  # Si es necesario
```

### El entorno virtual no existe
```bash
cd nucleo-api
python3 -m venv cafeina-env
source cafeina-env/bin/activate
pip install -r dependencias-python.txt
```
