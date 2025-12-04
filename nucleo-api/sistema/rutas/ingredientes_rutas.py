"""
🥫 RUTAS DE INGREDIENTES - ELCAFESIN
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Body
from sqlmodel import Session, select, or_
from typing import List, Optional

from sistema.configuracion import obtener_sesion, requiere_permiso
from sistema.entidades import Ingrediente, Usuario
from sistema.utilidades.audit_logger import log_event

router = APIRouter(prefix="/ingredientes", tags=["🥫 Ingredientes"])

permiso_crear_ingrediente = requiere_permiso("inventario", "crear")
permiso_ver_ingredientes = requiere_permiso("inventario", "ver")
permiso_editar_ingrediente = requiere_permiso("inventario", "editar")
permiso_eliminar_ingrediente = requiere_permiso("inventario", "eliminar")


@router.post("/", response_model=Ingrediente)
def crear_ingrediente(
    ingrediente: Ingrediente,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_crear_ingrediente)
):
    """➕ Crear nuevo ingrediente"""
    session.add(ingrediente)
    session.commit()
    session.refresh(ingrediente)
    return ingrediente


@router.get("/", response_model=List[Ingrediente])
def listar_ingredientes(
    q: Optional[str] = None,
    unidad: Optional[str] = None,
    stock_min: Optional[float] = None,
    limit: int = Query(100, le=500),
    offset: int = 0,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_ver_ingredientes)
):
    """
    📋 Listar ingredientes con filtros
    - q: Buscar por nombre
    - unidad: Filtrar por unidad (kg, l, pza, etc)
    - stock_min: Mostrar solo items con stock <= stock_min
    """
    query = select(Ingrediente)
    
    if q:
        query = query.where(Ingrediente.nombre.contains(q))
    
    if unidad:
        query = query.where(Ingrediente.unidad == unidad)
    
    if stock_min is not None:
        query = query.where(Ingrediente.stock <= stock_min)
    
    query = query.offset(offset).limit(limit)
    ingredientes = session.exec(query).all()
    
    return ingredientes


@router.get("/{ingrediente_id}", response_model=Ingrediente)
def obtener_ingrediente(
    ingrediente_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_ver_ingredientes)
):
    """🔍 Obtener ingrediente por ID"""
    ingrediente = session.get(Ingrediente, ingrediente_id)
    
    if not ingrediente:
        raise HTTPException(status_code=404, detail="Ingrediente no encontrado")
    
    return ingrediente


@router.put("/{ingrediente_id}", response_model=Ingrediente)
def actualizar_ingrediente(
    ingrediente_id: int,
    datos: Ingrediente,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_editar_ingrediente)
):
    """✏️ Actualizar ingrediente"""
    ingrediente = session.get(Ingrediente, ingrediente_id)
    
    if not ingrediente:
        raise HTTPException(status_code=404, detail="Ingrediente no encontrado")
    
    ingrediente.nombre = datos.nombre
    ingrediente.unidad = datos.unidad
    ingrediente.costo_por_unidad = datos.costo_por_unidad
    ingrediente.stock = datos.stock
    ingrediente.min_stock = datos.min_stock
    ingrediente.proveedor_id = datos.proveedor_id
    
    session.add(ingrediente)
    session.commit()
    session.refresh(ingrediente)
    
    return ingrediente


@router.delete("/{ingrediente_id}")
def eliminar_ingrediente(
    ingrediente_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_eliminar_ingrediente)
):
    """🗑️ Eliminar ingrediente"""
    ingrediente = session.get(Ingrediente, ingrediente_id)
    
    if not ingrediente:
        raise HTTPException(status_code=404, detail="Ingrediente no encontrado")
    
    session.delete(ingrediente)
    session.commit()

    return {"mensaje": "Ingrediente eliminado"}


@router.patch("/{ingrediente_id}", response_model=Ingrediente)
def actualizar_parcial_ingrediente(
    ingrediente_id: int,
    datos: dict = Body(...),
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_editar_ingrediente),
):
    """✏️ Actualización parcial del ingrediente"""
    ingrediente = session.get(Ingrediente, ingrediente_id)

    if not ingrediente:
        raise HTTPException(status_code=404, detail="Ingrediente no encontrado")

    # Capturar stock anterior si se está modificando
    stock_anterior = ingrediente.stock if "stock" in datos else None

    for campo, valor in datos.items():
        if hasattr(ingrediente, campo) and valor is not None:
            setattr(ingrediente, campo, valor)

    session.add(ingrediente)
    session.commit()
    session.refresh(ingrediente)

    # Log restock si el stock cambió
    if stock_anterior is not None and ingrediente.stock != stock_anterior:
        cantidad_agregada = ingrediente.stock - stock_anterior
        log_event(
            session=session,
            action="stock_restock",
            user_id=usuario_actual.id,
            entity="ingrediente",
            entity_id=ingrediente.id,
            success=True,
            details={
                "ingrediente_nombre": ingrediente.nombre,
                "cantidad_anterior": stock_anterior,
                "cantidad_nueva": ingrediente.stock,
                "cantidad_agregada": cantidad_agregada
            }
        )

    return ingrediente
