from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field

class Venta(SQLModel, table=True):
    __tablename__ = "venta"
    id: Optional[int] = Field(default=None, primary_key=True)
    cliente_id: Optional[int] = Field(default=None, foreign_key="cliente.id")
    sucursal: Optional[str] = Field(default=None, max_length=50)
    total: float = Field(default=0.0, ge=0)
    creado_en: datetime = Field(default_factory=datetime.utcnow)

class VentaItem(SQLModel, table=True):
    __tablename__ = "venta_item"
    id: Optional[int] = Field(default=None, primary_key=True)
    venta_id: int = Field(foreign_key="venta.id", index=True)
    receta_id: int = Field(foreign_key="receta.id", index=True)
    cantidad: float = Field(default=1.0, ge=0)
    precio_unitario: float = Field(default=0.0, ge=0)
    subtotal: float = Field(default=0.0, ge=0)
