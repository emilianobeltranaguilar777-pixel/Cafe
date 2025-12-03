"""
📦 Módulo de rutas (routers) - ELCAFESIN
"""
from .auth_rutas import router as auth_router
from .clientes_rutas import router as clientes_router
from .ingredientes_rutas import router as ingredientes_router
from .proveedores_rutas import router as proveedores_router
from .recetas_rutas import router as recetas_router
from .ventas_rutas import router as ventas_router
from .reportes_rutas import router as reportes_router

__all__ = [
    "auth_router",
    "clientes_router",
    "ingredientes_router",
    "proveedores_router",
    "recetas_router",
    "ventas_router",
    "reportes_router",
]
