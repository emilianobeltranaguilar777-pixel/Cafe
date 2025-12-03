"""
📊 RUTAS DE REPORTES - ELCAFESIN
Estadísticas y análisis de ventas
"""
from fastapi import APIRouter, Depends, Query
from sqlmodel import Session, select, func
from datetime import datetime, timedelta
from typing import Optional

from sistema.configuracion import obtener_sesion, requiere_permiso
from sistema.entidades import Venta, VentaItem, Receta, Ingrediente, Usuario

router = APIRouter(prefix="/reportes", tags=["📊 Reportes"])


@router.get("/dashboard")
def obtener_dashboard(
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("reportes", "ver"))
):
    """
    📈 Dashboard con estadísticas generales
    """
    # Total de ventas hoy
    hoy = datetime.utcnow().date()
    ventas_hoy = session.exec(
        select(func.sum(Venta.total)).where(
            func.date(Venta.creado_en) == hoy
        )
    ).first() or 0.0
    
    # Total de ventas este mes
    inicio_mes = datetime.utcnow().replace(day=1, hour=0, minute=0, second=0)
    ventas_mes = session.exec(
        select(func.sum(Venta.total)).where(
            Venta.creado_en >= inicio_mes
        )
    ).first() or 0.0
    
    # Número de ventas hoy
    num_ventas_hoy = session.exec(
        select(func.count(Venta.id)).where(
            func.date(Venta.creado_en) == hoy
        )
    ).first() or 0
    
    # Ingredientes con stock bajo
    ingredientes_bajo_stock = session.exec(
        select(Ingrediente).where(
            Ingrediente.min_stock.isnot(None),
            Ingrediente.stock <= Ingrediente.min_stock
        )
    ).all()
    
    return {
        "ventas_hoy": round(ventas_hoy, 2),
        "ventas_mes": round(ventas_mes, 2),
        "num_ventas_hoy": num_ventas_hoy,
        "alertas_stock": len(ingredientes_bajo_stock),
        "ingredientes_bajo_stock": [
            {
                "id": ing.id,
                "nombre": ing.nombre,
                "stock": ing.stock,
                "min_stock": ing.min_stock
            }
            for ing in ingredientes_bajo_stock
        ]
    }


@router.get("/ventas_periodo")
def reporte_ventas_periodo(
    fecha_desde: datetime,
    fecha_hasta: datetime,
    sucursal: Optional[str] = None,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("reportes", "ver"))
):
    """
    📊 Reporte de ventas por período
    """
    query = select(Venta).where(
        Venta.creado_en >= fecha_desde,
        Venta.creado_en <= fecha_hasta
    )
    
    if sucursal:
        query = query.where(Venta.sucursal == sucursal)
    
    ventas = session.exec(query).all()
    
    # Calcular estadísticas
    total_ventas = sum(v.total for v in ventas)
    num_ventas = len(ventas)
    ticket_promedio = total_ventas / num_ventas if num_ventas > 0 else 0.0
    
    return {
        "fecha_desde": fecha_desde,
        "fecha_hasta": fecha_hasta,
        "sucursal": sucursal,
        "total_ventas": round(total_ventas, 2),
        "num_ventas": num_ventas,
        "ticket_promedio": round(ticket_promedio, 2)
    }


@router.get("/top_recetas")
def top_recetas_vendidas(
    limit: int = Query(10, le=50),
    fecha_desde: Optional[datetime] = None,
    fecha_hasta: Optional[datetime] = None,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("reportes", "ver"))
):
    """
    🏆 Top recetas más vendidas
    """
    query = select(
        VentaItem.receta_id,
        func.sum(VentaItem.cantidad).label("total_vendido"),
        func.sum(VentaItem.subtotal).label("total_monto")
    ).join(Venta)
    
    if fecha_desde:
        query = query.where(Venta.creado_en >= fecha_desde)
    
    if fecha_hasta:
        query = query.where(Venta.creado_en <= fecha_hasta)
    
    query = query.group_by(VentaItem.receta_id).order_by(
        func.sum(VentaItem.subtotal).desc()
    ).limit(limit)
    
    resultados = session.exec(query).all()
    
    top_recetas = []
    for receta_id, total_vendido, total_monto in resultados:
        receta = session.get(Receta, receta_id)
        if receta:
            top_recetas.append({
                "receta_id": receta_id,
                "receta_nombre": receta.nombre,
                "cantidad_vendida": float(total_vendido),
                "monto_total": round(float(total_monto), 2)
            })
    
    return {"top_recetas": top_recetas}


@router.get("/movimientos_inventario")
def movimientos_inventario(
    ingrediente_id: Optional[int] = None,
    fecha_desde: Optional[datetime] = None,
    fecha_hasta: Optional[datetime] = None,
    limit: int = Query(100, le=500),
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_permiso("inventario", "ver"))
):
    """
    📦 Historial de movimientos de inventario (Kardex)
    """
    from sistema.entidades import Movimiento
    
    query = select(Movimiento)
    
    if ingrediente_id:
        query = query.where(Movimiento.ingrediente_id == ingrediente_id)
    
    if fecha_desde:
        query = query.where(Movimiento.creado_en >= fecha_desde)
    
    if fecha_hasta:
        query = query.where(Movimiento.creado_en <= fecha_hasta)
    
    query = query.order_by(Movimiento.creado_en.desc()).limit(limit)
    movimientos = session.exec(query).all()
    
    movimientos_detalle = []
    for mov in movimientos:
        ingrediente = session.get(Ingrediente, mov.ingrediente_id)
        movimientos_detalle.append({
            "id": mov.id,
            "ingrediente_id": mov.ingrediente_id,
            "ingrediente_nombre": ingrediente.nombre if ingrediente else "N/A",
            "tipo": mov.tipo,
            "cantidad": mov.cantidad,
            "referencia": mov.referencia,
            "fecha": mov.creado_en
        })
    
    return {"movimientos": movimientos_detalle}
