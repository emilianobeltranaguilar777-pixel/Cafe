"""
📋 CONTRATOS DE PERMISOS POR USUARIO - ELCAFESIN
Schemas Pydantic para manejar overrides individuales
"""
from datetime import datetime
from sistema.entidades.permiso import PermisoRolBase


class PermisoUsuarioBase(PermisoRolBase):
    """Datos base de un permiso override de usuario"""
    permitido: bool = True


class PermisoUsuarioCreate(PermisoUsuarioBase):
    """Payload para crear o eliminar permisos individuales"""
    pass


class PermisoUsuarioResponse(PermisoUsuarioBase):
    """Respuesta detallada de un permiso override"""
    id: int
    usuario_id: int
    creado_en: datetime

    class Config:
        orm_mode = True
