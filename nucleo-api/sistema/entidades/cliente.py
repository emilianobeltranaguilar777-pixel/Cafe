from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field

class Cliente(SQLModel, table=True):
    __tablename__ = "cliente"
    id: Optional[int] = Field(default=None, primary_key=True)
    nombre: str = Field(max_length=100, index=True)
    correo: Optional[str] = Field(default=None, max_length=100)
    telefono: Optional[str] = Field(default=None, max_length=20)
    direccion: Optional[str] = Field(default=None, max_length=200)
    alergias: Optional[str] = Field(default=None, max_length=500)
    creado_en: datetime = Field(default_factory=datetime.utcnow)
