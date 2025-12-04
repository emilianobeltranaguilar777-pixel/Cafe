"""
🔐 CONTRATOS DE PERMISOS - ELCAFESIN
Schemas Pydantic para gestión de permisos
"""
from pydantic import BaseModel, Field
from typing import Optional
from sistema.entidades import Accion


class PermisoRolCreate(BaseModel):
    """Datos para crear permiso de rol"""
    recurso: str = Field(min_length=1, max_length=50)
    accion: Accion


class PermisoRolOut(BaseModel):
    """Permiso de rol para respuestas"""
    id: int
    rol: str
    recurso: str
    accion: str

    model_config = {"from_attributes": True}


class PermisoUsuarioCreate(BaseModel):
    """Datos para crear permiso de usuario"""
    recurso: str = Field(min_length=1, max_length=50)
    accion: Accion
    permitido: bool = True


class PermisoUsuarioOut(BaseModel):
    """Permiso de usuario para respuestas"""
    id: int
    usuario_id: int
    recurso: str
    accion: str
    permitido: bool

    model_config = {"from_attributes": True}
