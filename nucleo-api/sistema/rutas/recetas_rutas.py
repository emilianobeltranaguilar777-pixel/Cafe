"""
🍰 RUTAS DE RECETAS - ELCAFESIN
Gestión de recetas y cálculo de costos
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List, Optional
from pydantic import BaseModel, Field

from sistema.configuracion import obtener_sesion, requiere_permiso, obtener_ajustes
from sistema.entidades import Receta, RecetaItem, Ingrediente, Usuario

router = APIRouter(prefix="/recetas", tags=["🍰 Recetas"])

ajustes = obtener_ajustes()

# RBAC alineado con recurso "recetas" que consume la UI
permiso_crear_receta = requiere_permiso("recetas", "crear")
permiso_ver_recetas = requiere_permiso("recetas", "ver")
permiso_editar_receta = requiere_permiso("recetas", "editar")
permiso_eliminar_receta = requiere_permiso("recetas", "borrar")


class RecetaItemPayload(BaseModel):
    """Item de receta enviado desde el frontend."""

    ingrediente_id: int
    cantidad: float = Field(gt=0)
    merma: float = Field(default=0.0, ge=0, le=1)


class RecetaCreate(BaseModel):
    """Datos para crear receta"""
    nombre: str
    descripcion: Optional[str] = None
    margen: Optional[float] = Field(default=None)
    # Aceptamos tanto "items" como "ingredientes" para compatibilidad UI
    items: List[RecetaItemPayload] = Field(default_factory=list)
    ingredientes: List[RecetaItemPayload] = Field(default_factory=list)

    model_config = {"populate_by_name": True}


class RecetaUpdate(RecetaCreate):
    """Datos para actualizar una receta"""
    pass


class RecetaConCosto(BaseModel):
    """Receta con costo calculado"""
    id: int
    nombre: str
    descripcion: Optional[str] = None
    margen: float
    costo_total: float
    precio_sugerido: float
    items: List["RecetaItemDetalle"] = Field(default_factory=list)

    model_config = {"from_attributes": True}


class RecetaItemDetalle(BaseModel):
    """Detalle de item con información de stock y costos."""

    ingrediente_id: int
    ingrediente_nombre: str
    cantidad: float
    merma: float
    costo_unitario: float
    stock: float
    min_stock: float
    unidad: Optional[str] = None

    model_config = {"from_attributes": True}


RecetaConCosto.model_rebuild()


def _calcular_detalle_receta(receta: Receta, session: Session) -> RecetaConCosto:
    """Construye el detalle completo de una receta con costos e items."""

    items = session.exec(
        select(RecetaItem).where(RecetaItem.receta_id == receta.id)
    ).all()

    costo_total = 0.0
    items_detalle: List[RecetaItemDetalle] = []

    for item in items:
        ingrediente = session.get(Ingrediente, item.ingrediente_id)
        if not ingrediente:
            # Saltamos ingredientes inexistentes para no romper la respuesta
            continue

        costo_item = item.cantidad * (1 + item.merma) * ingrediente.costo_por_unidad
        costo_total += costo_item

        items_detalle.append(
            RecetaItemDetalle(
                ingrediente_id=ingrediente.id,
                ingrediente_nombre=ingrediente.nombre,
                cantidad=item.cantidad,
                merma=item.merma,
                costo_unitario=ingrediente.costo_por_unidad,
                stock=ingrediente.stock,
                min_stock=ingrediente.min_stock,
                unidad=ingrediente.unidad,
            )
        )

    margen = receta.margen or ajustes.MARGIN_DEFAULT
    precio_sugerido = costo_total * (1 + margen)

    return RecetaConCosto(
        id=receta.id,
        nombre=receta.nombre,
        descripcion=receta.descripcion,
        margen=margen,
        costo_total=round(costo_total, 2),
        precio_sugerido=round(precio_sugerido, 2),
        items=items_detalle,
    )


def _items_desde_payload(datos: RecetaCreate) -> List[RecetaItemPayload]:
    """Normaliza items recibidos desde UI."""

    items = datos.items or datos.ingredientes
    if not items:
        raise HTTPException(status_code=422, detail="Agrega al menos un ingrediente")

    return items


def _guardar_items(receta: Receta, items: List[RecetaItemPayload], session: Session) -> None:
    """Guarda o reemplaza los items de una receta."""

    # Limpiar items previos
    for existente in session.exec(
        select(RecetaItem).where(RecetaItem.receta_id == receta.id)
    ):
        session.delete(existente)

    for item_data in items:
        ingrediente = session.get(Ingrediente, item_data.ingrediente_id)
        if not ingrediente:
            raise HTTPException(status_code=404, detail="Ingrediente no encontrado")

        item = RecetaItem(
            receta_id=receta.id,
            ingrediente_id=ingrediente.id,
            cantidad=item_data.cantidad,
            merma=item_data.merma,
        )
        session.add(item)


@router.post("/", response_model=RecetaConCosto)
def crear_receta(
    datos: RecetaCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_crear_receta)
):
    """➕ Crear nueva receta con ingredientes"""
    items = _items_desde_payload(datos)

    # Crear receta
    receta = Receta(
        nombre=datos.nombre,
        descripcion=datos.descripcion,
        margen=ajustes.MARGIN_DEFAULT if datos.margen is None else datos.margen,
    )

    session.add(receta)
    session.commit()
    session.refresh(receta)

    _guardar_items(receta, items, session)

    session.commit()

    return _calcular_detalle_receta(receta, session)


@router.get("/", response_model=List[RecetaConCosto])
def listar_recetas(
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_ver_recetas)
):
    """📋 Listar todas las recetas"""
    recetas = session.exec(select(Receta)).all()
    return [_calcular_detalle_receta(receta, session) for receta in recetas]


@router.get("/{receta_id}", response_model=RecetaConCosto)
def obtener_receta_con_costo(
    receta_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_ver_recetas)
):
    """🔍 Obtener receta con costo calculado"""
    receta = session.get(Receta, receta_id)
    
    if not receta:
        raise HTTPException(status_code=404, detail="Receta no encontrada")
    
    return _calcular_detalle_receta(receta, session)


@router.put("/{receta_id}", response_model=RecetaConCosto)
def actualizar_receta(
    receta_id: int,
    datos: RecetaUpdate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_editar_receta)
):
    """✏️ Actualizar receta y sus ingredientes"""
    receta = session.get(Receta, receta_id)

    if not receta:
        raise HTTPException(status_code=404, detail="Receta no encontrada")

    items = _items_desde_payload(datos)

    receta.nombre = datos.nombre
    receta.descripcion = datos.descripcion
    receta.margen = ajustes.MARGIN_DEFAULT if datos.margen is None else datos.margen

    session.add(receta)
    session.commit()
    session.refresh(receta)

    _guardar_items(receta, items, session)
    session.commit()

    return _calcular_detalle_receta(receta, session)


@router.delete("/{receta_id}")
def eliminar_receta(
    receta_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_eliminar_receta)
):
    """🗑️ Eliminar receta e items"""
    receta = session.get(Receta, receta_id)
    
    if not receta:
        raise HTTPException(status_code=404, detail="Receta no encontrada")
    
    # Eliminar items primero
    items = session.exec(
        select(RecetaItem).where(RecetaItem.receta_id == receta_id)
    ).all()
    
    for item in items:
        session.delete(item)
    
    # Eliminar receta
    session.delete(receta)
    session.commit()
    
    return {"mensaje": "Receta eliminada"}
