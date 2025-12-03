"""
👤 MODELO DE USUARIO - ELCAFESIN
Define la tabla de usuarios y roles del sistema
"""
from datetime import datetime
from enum import Enum
from typing import Optional
from sqlmodel import SQLModel, Field


class Rol(str, Enum):
    """Roles disponibles en el sistema"""
    DUENO = "DUENO"
    ADMIN = "ADMIN"
    GERENTE = "GERENTE"
    VENDEDOR = "VENDEDOR"


class Usuario(SQLModel, table=True):
    """
    Tabla de usuarios del sistema
    
    Campos:
        - id: ID único
        - username: Nombre de usuario (único)
        - nombre: Nombre completo (opcional)
        - password_hash: Contraseña hasheada
        - rol: Rol del usuario (define permisos base)
        - activo: Si el usuario puede iniciar sesión
        - creado_en: Fecha de creación
    """
    __tablename__ = "usuario"
    
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(index=True, unique=True, max_length=50)
    nombre: Optional[str] = Field(default=None, max_length=100)
    password_hash: str = Field(max_length=255)
    rol: Rol = Field(default=Rol.VENDEDOR)
    activo: bool = Field(default=True)
    creado_en: datetime = Field(default_factory=datetime.utcnow, index=True)
    
    class Config:
        use_enum_values = True  # Guarda el valor del enum, no el objeto
