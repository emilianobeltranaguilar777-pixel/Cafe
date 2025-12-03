from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field

class LogSesion(SQLModel, table=True):
    __tablename__ = "log_sesion"
    id: Optional[int] = Field(default=None, primary_key=True)
    usuario_id: int = Field(foreign_key="usuario.id", index=True)
    accion: str = Field(max_length=50, index=True)
    ip: Optional[str] = Field(default=None, max_length=45)
    user_agent: Optional[str] = Field(default=None, max_length=200)
    exito: bool = Field(default=True)
    creado_en: datetime = Field(default_factory=datetime.utcnow)
