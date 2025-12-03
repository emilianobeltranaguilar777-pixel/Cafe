"""
🚀 MOTOR PRINCIPAL - ELCAFESIN
FastAPI application con todas las rutas
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from sistema.configuracion import crear_tablas, obtener_ajustes
from sistema.utilidades.seed_inicial import inicializar_datos

# Importar todos los routers
from sistema.rutas import (
    auth_router,
    clientes_router,
    ingredientes_router,
    proveedores_router,
    recetas_router,
    ventas_router,
    reportes_router
)
from sistema.rutas.logs_rutas import router as logs_router

# Obtener configuración
ajustes = obtener_ajustes()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Eventos de inicio y cierre"""
    # 🚀 STARTUP
    print("=" * 60)
    print(f"🚀 {ajustes.PROJECT_NAME} v{ajustes.PROJECT_VERSION}")
    print("=" * 60)
    
    crear_tablas()
    
    from sistema.configuracion.base_datos import obtener_sesion
    for session in obtener_sesion():
        inicializar_datos(session)
        break
    
    print("✅ Sistema listo")
    print("=" * 60)
    
    yield
    
    # 🛑 SHUTDOWN
    print("🛑 Cerrando sistema...")


# Crear aplicación FastAPI
app = FastAPI(
    title=ajustes.PROJECT_NAME,
    version=ajustes.PROJECT_VERSION,
    description="Sistema ERP para gestión de cafeterías con diseño neón",
    lifespan=lifespan
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== RUTAS PRINCIPALES ====================

@app.get("/")
def raiz():
    """Ruta raíz - Info del sistema"""
    return {
        "proyecto": ajustes.PROJECT_NAME,
        "version": ajustes.PROJECT_VERSION,
        "estado": "operativo",
        "mensaje": "☕ Bienvenido al Almacén Cuántico"
    }


@app.get("/salud")
def verificar_salud():
    """Health check"""
    return {
        "estado": "saludable",
        "base_datos": "sqlite",
        "timestamp": "ok"
    }


# ==================== INCLUIR TODOS LOS ROUTERS ====================

app.include_router(auth_router)
app.include_router(clientes_router)
app.include_router(ingredientes_router)
app.include_router(proveedores_router)
app.include_router(recetas_router)
app.include_router(ventas_router)
app.include_router(reportes_router)
app.include_router(logs_router)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "sistema.motor_principal:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
