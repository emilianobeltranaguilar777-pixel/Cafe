"""
🛒 RUTAS DE VENTAS - ELCAFESIN
Sistema de ventas con descuento automático de stock y kardex
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select
from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel

from sistema.configuracion import obtener_sesion, requiere_permiso
from sistema.entidades import (
    Venta, VentaItem, Receta, RecetaItem, Ingrediente,
    Movimiento, TipoMovimiento, Usuario
)

router = APIRouter(prefix="/ventas", tags=["🛒 Ventas"])


class ItemVentaCreate(BaseModel):
    """Item de venta a crear"""
    receta_id: int
    cantidad: float = 1.0


class VentaCreate(BaseModel):
    """Datos para crear venta"""
    cliente_id: Optional[int] = None
    sucursal: Optional[str] = None
    items: List[ItemVentaCreate]


@router.post("/", response_model=Venta)
def crear_venta(
    datos: VentaCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("ventas", "crear"))
):
    """
    ➕ Crear nueva venta
    
    Proceso:
    1. Validar stock de todos los ingredientes
    2. Crear venta y items
    3. Descontar stock de ingredientes
    4. Registrar movimientos en kardex
    """
    if not datos.items:
        raise HTTPException(status_code=400, detail="La venta debe tener al menos un item")
    
    # FASE 1: Validar stock suficiente
    ingredientes_a_descontar = {}  # {ingrediente_id: cantidad_total}
    
    for item_data in datos.items:
        receta = session.get(Receta, item_data.receta_id)
        if not receta:
            raise HTTPException(
                status_code=404,
                detail=f"Receta {item_data.receta_id} no encontrada"
            )
        
        # Obtener ingredientes de la receta
        receta_items = session.exec(
            select(RecetaItem).where(RecetaItem.receta_id == receta.id)
        ).all()
        
        for receta_item in receta_items:
            cantidad_necesaria = receta_item.cantidad * (1 + receta_item.merma) * item_data.cantidad
            
            if receta_item.ingrediente_id in ingredientes_a_descontar:
                ingredientes_a_descontar[receta_item.ingrediente_id] += cantidad_necesaria
            else:
                ingredientes_a_descontar[receta_item.ingrediente_id] = cantidad_necesaria
    
    # Verificar stock
    for ingrediente_id, cantidad_necesaria in ingredientes_a_descontar.items():
        ingrediente = session.get(Ingrediente, ingrediente_id)
        if not ingrediente:
            continue
        
        if ingrediente.stock < cantidad_necesaria:
            raise HTTPException(
                status_code=400,
                detail=f"Stock insuficiente de {ingrediente.nombre}. "
                       f"Disponible: {ingrediente.stock}, Necesario: {cantidad_necesaria:.2f}"
            )
    
    # FASE 2: Crear venta
    venta = Venta(
        cliente_id=datos.cliente_id,
        sucursal=datos.sucursal,
        total=0.0
    )
    session.add(venta)
    session.commit()
    session.refresh(venta)
    
    # FASE 3: Agregar items y calcular total
    total_venta = 0.0
    
    for item_data in datos.items:
        receta = session.get(Receta, item_data.receta_id)
        
        # Calcular precio de la receta
        receta_items = session.exec(
            select(RecetaItem).where(RecetaItem.receta_id == receta.id)
        ).all()
        
        costo_receta = 0.0
        for receta_item in receta_items:
            ingrediente = session.get(Ingrediente, receta_item.ingrediente_id)
            if ingrediente:
                costo_receta += receta_item.cantidad * (1 + receta_item.merma) * ingrediente.costo_por_unidad
        
        # Aplicar margen
        from sistema.configuracion import obtener_ajustes
        ajustes = obtener_ajustes()
        margen = receta.margen if receta.margen is not None else ajustes.MARGIN_DEFAULT
        precio_unitario = costo_receta * (1 + margen)
        subtotal = precio_unitario * item_data.cantidad
        
        # Crear item de venta
        venta_item = VentaItem(
            venta_id=venta.id,
            receta_id=receta.id,
            cantidad=item_data.cantidad,
            precio_unitario=precio_unitario,
            subtotal=subtotal
        )
        session.add(venta_item)
        
        total_venta += subtotal
    
    # Actualizar total de venta
    venta.total = total_venta
    session.add(venta)
    
    # FASE 4: Descontar stock y registrar movimientos
    for ingrediente_id, cantidad_descontar in ingredientes_a_descontar.items():
        ingrediente = session.get(Ingrediente, ingrediente_id)
        if ingrediente:
            # Descontar stock
            ingrediente.stock -= cantidad_descontar
            session.add(ingrediente)
            
            # Registrar movimiento en kardex
            movimiento = Movimiento(
                ingrediente_id=ingrediente_id,
                tipo=TipoMovimiento.VENTA,
                cantidad=-cantidad_descontar,
                referencia=f"Venta #{venta.id}"
            )
            session.add(movimiento)
    
    session.commit()
    session.refresh(venta)
    
    return venta


@router.get("/", response_model=List[Venta])
def listar_ventas(
    sucursal: Optional[str] = None,
    fecha_desde: Optional[datetime] = None,
    fecha_hasta: Optional[datetime] = None,
    limit: int = Query(100, le=500),
    offset: int = 0,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("ventas", "ver"))
):
    """📋 Listar ventas con filtros"""
    query = select(Venta)
    
    if sucursal:
        query = query.where(Venta.sucursal == sucursal)
    
    if fecha_desde:
        query = query.where(Venta.creado_en >= fecha_desde)
    
    if fecha_hasta:
        query = query.where(Venta.creado_en <= fecha_hasta)
    
    query = query.order_by(Venta.creado_en.desc()).offset(offset).limit(limit)
    ventas = session.exec(query).all()
    
    return ventas


@router.get("/{venta_id}")
def obtener_venta_detallada(
    venta_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("ventas", "ver"))
):
    """🔍 Obtener venta con items detallados"""
    venta = session.get(Venta, venta_id)
    
    if not venta:
        raise HTTPException(status_code=404, detail="Venta no encontrada")
    
    # Obtener items
    items = session.exec(
        select(VentaItem).where(VentaItem.venta_id == venta_id)
    ).all()
    
    items_detalle = []
    for item in items:
        receta = session.get(Receta, item.receta_id)
        items_detalle.append({
            "receta_id": item.receta_id,
            "receta_nombre": receta.nombre if receta else "N/A",
            "cantidad": item.cantidad,
            "precio_unitario": item.precio_unitario,
            "subtotal": item.subtotal
        })
    
    return {
        "id": venta.id,
        "cliente_id": venta.cliente_id,
        "sucursal": venta.sucursal,
        "total": venta.total,
        "creado_en": venta.creado_en,
        "items": items_detalle
    }
