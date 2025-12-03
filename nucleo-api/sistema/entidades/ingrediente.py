from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field

class Ingrediente(SQLModel, table=True):
    __tablename__ = "ingrediente"
    id: Optional[int] = Field(default=None, primary_key=True)
    nombre: str = Field(max_length=100, index=True)
    unidad: str = Field(default="pza", max_length=20)
    costo_por_unidad: float = Field(default=0.0, ge=0)
    stock: float = Field(default=0.0, ge=0)
    min_stock: Optional[float] = Field(default=None, ge=0)
    proveedor_id: Optional[int] = Field(default=None, foreign_key="proveedor.id")
    creado_en: datetime = Field(default_factory=datetime.utcnow)
