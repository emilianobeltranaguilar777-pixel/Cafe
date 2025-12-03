"""
🍰 RUTAS DE RECETAS - ELCAFESIN
Gestión de recetas y cálculo de costos
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from pydantic import BaseModel

from sistema.configuracion import obtener_sesion, requiere_permiso, obtener_ajustes
from sistema.entidades import Receta, RecetaItem, Ingrediente, Usuario

router = APIRouter(prefix="/recetas", tags=["🍰 Recetas"])

ajustes = obtener_ajustes()


class RecetaCreate(BaseModel):
    """Datos para crear receta"""
    nombre: str
    descripcion: str = None
    margen: float = None
    items: List[dict] = []  # [{ingrediente_id, cantidad, merma}]


class RecetaConCosto(BaseModel):
    """Receta con costo calculado"""
    id: int
    nombre: str
    descripcion: str = None
    margen: float
    costo_total: float
    precio_sugerido: float
    items: List[dict] = []
    
    model_config = {"from_attributes": True}


@router.post("/", response_model=Receta)
def crear_receta(
    datos: RecetaCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("inventario", "crear"))
):
    """➕ Crear nueva receta con ingredientes"""
    # Crear receta
    receta = Receta(
        nombre=datos.nombre,
        descripcion=datos.descripcion,
        margen=datos.margen or ajustes.MARGIN_DEFAULT
    )
    
    session.add(receta)
    session.commit()
    session.refresh(receta)
    
    # Agregar items
    for item_data in datos.items:
        item = RecetaItem(
            receta_id=receta.id,
            ingrediente_id=item_data["ingrediente_id"],
            cantidad=item_data["cantidad"],
            merma=item_data.get("merma", 0.0)
        )
        session.add(item)
    
    session.commit()
    
    return receta


@router.get("/", response_model=List[Receta])
def listar_recetas(
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("inventario", "ver"))
):
    """📋 Listar todas las recetas"""
    recetas = session.exec(select(Receta)).all()
    return recetas


@router.get("/{receta_id}", response_model=RecetaConCosto)
def obtener_receta_con_costo(
    receta_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("inventario", "ver"))
):
    """🔍 Obtener receta con costo calculado"""
    receta = session.get(Receta, receta_id)
    
    if not receta:
        raise HTTPException(status_code=404, detail="Receta no encontrada")
    
    # Obtener items
    items = session.exec(
        select(RecetaItem).where(RecetaItem.receta_id == receta_id)
    ).all()
    
    # Calcular costo
    costo_total = 0.0
    items_detalle = []
    
    for item in items:
        ingrediente = session.get(Ingrediente, item.ingrediente_id)
        if ingrediente:
            costo_item = item.cantidad * (1 + item.merma) * ingrediente.costo_por_unidad
            costo_total += costo_item
            
            items_detalle.append({
                "ingrediente_id": ingrediente.id,
                "ingrediente_nombre": ingrediente.nombre,
                "cantidad": item.cantidad,
                "merma": item.merma,
                "costo_unitario": ingrediente.costo_por_unidad,
                "costo_item": round(costo_item, 2)
            })
    
    # Calcular precio
    margen = receta.margen or ajustes.MARGIN_DEFAULT
    precio_sugerido = costo_total * (1 + margen)
    
    return RecetaConCosto(
        id=receta.id,
        nombre=receta.nombre,
        descripcion=receta.descripcion,
        margen=margen,
        costo_total=round(costo_total, 2),
        precio_sugerido=round(precio_sugerido, 2),
        items=items_detalle
    )


@router.delete("/{receta_id}")
def eliminar_receta(
    receta_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("inventario", "eliminar"))
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
