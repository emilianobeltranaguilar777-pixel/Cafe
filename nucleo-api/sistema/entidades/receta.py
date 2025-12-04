from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field

class Receta(SQLModel, table=True):
    __tablename__ = "receta"
    id: Optional[int] = Field(default=None, primary_key=True)
    nombre: str = Field(max_length=100, index=True, unique=True)
    descripcion: Optional[str] = Field(default=None, max_length=500)
    # Margen sin restricciones para permitir edición libre desde UI
    margen: Optional[float] = Field(default=None)
    creado_en: datetime = Field(default_factory=datetime.utcnow)

class RecetaItem(SQLModel, table=True):
    __tablename__ = "receta_item"
    id: Optional[int] = Field(default=None, primary_key=True)
    receta_id: int = Field(foreign_key="receta.id", index=True)
    ingrediente_id: int = Field(foreign_key="ingrediente.id", index=True)
    cantidad: float = Field(ge=0)
    merma: Optional[float] = Field(default=0.0, ge=0, le=1)
