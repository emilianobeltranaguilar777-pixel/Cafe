from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field

class Proveedor(SQLModel, table=True):
    __tablename__ = "proveedor"
    id: Optional[int] = Field(default=None, primary_key=True)
    nombre: str = Field(max_length=100, index=True)
    empresa: Optional[str] = Field(default=None, max_length=100)
    correo: Optional[str] = Field(default=None, max_length=100)
    telefono: Optional[str] = Field(default=None, max_length=20)
    direccion: Optional[str] = Field(default=None, max_length=200)
    notas: Optional[str] = Field(default=None, max_length=500)
    creado_en: datetime = Field(default_factory=datetime.utcnow)
