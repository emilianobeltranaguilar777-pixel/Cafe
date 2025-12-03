"""
🔐 MODELOS DE PERMISOS - ELCAFESIN
Sistema híbrido: permisos por rol + excepciones por usuario
"""
from datetime import datetime
from enum import Enum
from typing import Optional
from sqlmodel import SQLModel, Field


class Accion(str, Enum):
    """Acciones disponibles en el sistema"""
    VER = "ver"
    CREAR = "crear"
    EDITAR = "editar"
    ELIMINAR = "eliminar"


class PermisoRol(SQLModel, table=True):
    """
    Permisos BASE por rol
    
    Ejemplo:
        - Rol VENDEDOR puede "crear" en recurso "ventas"
        - Rol ADMIN puede "editar" en recurso "usuarios"
    """
    __tablename__ = "permiso_rol"
    
    id: Optional[int] = Field(default=None, primary_key=True)
    rol: str = Field(index=True, max_length=20)  # "ADMIN", "VENDEDOR", etc.
    recurso: str = Field(index=True, max_length=50)  # "ventas", "inventario", etc.
    accion: Accion = Field(default=Accion.VER)
    creado_en: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        use_enum_values = True


class UsuarioPermiso(SQLModel, table=True):
    """
    EXCEPCIONES de permisos por usuario individual
    
    Casos de uso:
        - Dar permiso extra a un vendedor específico
        - Quitar un permiso a un admin específico
    
    Prioridad: UsuarioPermiso > PermisoRol
    """
    __tablename__ = "usuario_permiso"
    
    id: Optional[int] = Field(default=None, primary_key=True)
    usuario_id: int = Field(foreign_key="usuario.id", index=True)
    recurso: str = Field(index=True, max_length=50)
    accion: Accion = Field(default=Accion.VER)
    permitido: bool = Field(default=True)  # True = permitir, False = denegar
    creado_en: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        use_enum_values = True
