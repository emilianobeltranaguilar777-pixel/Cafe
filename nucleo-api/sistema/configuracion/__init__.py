"""
📦 Módulo de configuración - ELCAFESIN
Exporta funciones y clases principales
"""
from .ajustes import Ajustes, obtener_ajustes
from .base_datos import engine, crear_tablas, obtener_sesion
from .seguridad import (
    hash_password,
    verificar_password,
    crear_token,
    obtener_usuario_actual,
    requiere_roles,
    requiere_permiso
)

__all__ = [
    # Ajustes
    "Ajustes",
    "obtener_ajustes",
    
    # Base de datos
    "engine",
    "crear_tablas",
    "obtener_sesion",
    
    # Seguridad
    "hash_password",
    "verificar_password",
    "crear_token",
    "obtener_usuario_actual",
    "requiere_roles",
    "requiere_permiso",
]
