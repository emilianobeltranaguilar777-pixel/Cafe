from datetime import datetime
from enum import Enum
from typing import Optional
from sqlmodel import SQLModel, Field

class TipoMovimiento(str, Enum):
    ENTRADA = "entrada"
    SALIDA = "salida"
    AJUSTE = "ajuste"
    VENTA = "venta"
    MERMA = "merma"

class Movimiento(SQLModel, table=True):
    __tablename__ = "movimiento"
    id: Optional[int] = Field(default=None, primary_key=True)
    ingrediente_id: int = Field(foreign_key="ingrediente.id", index=True)
    tipo: TipoMovimiento = Field(default=TipoMovimiento.AJUSTE)
    cantidad: float
    referencia: str = Field(default="", max_length=200)
    creado_en: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        use_enum_values = True
