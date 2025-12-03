"""
📋 CONTRATOS DE AUTENTICACIÓN - ELCAFESIN
Schemas Pydantic para auth
"""
from pydantic import BaseModel, Field
from typing import Optional
from sistema.entidades import Rol


class TokenOut(BaseModel):
    """Token de acceso JWT"""
    access_token: str
    token_type: str = "bearer"


class UsuarioCreate(BaseModel):
    """Datos para crear usuario"""
    username: str = Field(min_length=3, max_length=50)
    nombre: Optional[str] = None
    password: str = Field(min_length=6)
    rol: Rol = Rol.VENDEDOR


class UsuarioUpdate(BaseModel):
    """Datos para actualizar usuario"""
    nombre: Optional[str] = None
    rol: Optional[Rol] = None
    password: Optional[str] = Field(None, min_length=6)


class UsuarioOut(BaseModel):
    """Usuario para respuestas (sin password)"""
    id: int
    username: str
    nombre: Optional[str]
    rol: str
    activo: bool
    
    model_config = {"from_attributes": True}
