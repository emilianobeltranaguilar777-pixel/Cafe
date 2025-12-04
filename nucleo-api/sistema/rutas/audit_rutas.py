"""
🔍 RUTAS DE AUDITORÍA - ELCAFESIN
Sistema de auditoría unificado (adicional al sistema de logs existente)
"""
from fastapi import APIRouter, Depends, Query
from sqlmodel import Session, select
from typing import Optional
from datetime import datetime

from sistema.configuracion import obtener_sesion, requiere_roles
from sistema.entidades import Usuario, Rol
from sistema.entidades.audit_log import AuditLog

router = APIRouter(prefix="/audit", tags=["🔍 Auditoría"])


@router.get("/")
def listar_audit_logs(
    event_type: Optional[str] = Query(None, description="Filtrar por tipo de evento"),
    username: Optional[str] = Query(None, description="Filtrar por nombre de usuario"),
    fecha_desde: Optional[datetime] = Query(None, description="Filtrar desde fecha (ISO 8601)"),
    fecha_hasta: Optional[datetime] = Query(None, description="Filtrar hasta fecha (ISO 8601)"),
    limit: int = Query(100, le=500),
    offset: int = 0,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles([Rol.ADMIN, Rol.DUENO]))
):
    """
    📋 Listar logs de auditoría con filtros opcionales

    Sistema independiente que no interfiere con /logs (log_sesion + movimiento)

    Filtros disponibles:
    - event_type: login_success, login_failed, logout, stock_restock, etc
    - username: Nombre de usuario
    - fecha_desde: Fecha inicial (ISO 8601)
    - fecha_hasta: Fecha final (ISO 8601)
    - limit: Cantidad de registros (max 500)
    - offset: Desplazamiento para paginación
    """
    # Construir query base
    query = select(AuditLog)

    # Aplicar filtros
    if event_type:
        query = query.where(AuditLog.event_type == event_type)

    if username:
        query = query.where(AuditLog.username == username)

    if fecha_desde:
        query = query.where(AuditLog.creado_en >= fecha_desde)

    if fecha_hasta:
        query = query.where(AuditLog.creado_en <= fecha_hasta)

    # Contar total (antes de paginación)
    total_query = query
    total = len(session.exec(total_query).all())

    # Ordenar y paginar
    query = query.order_by(AuditLog.creado_en.desc()).offset(offset).limit(limit)
    logs = session.exec(query).all()

    # Formatear respuesta
    logs_formateados = [
        {
            "id": log.id,
            "event_type": log.event_type,
            "usuario_id": log.usuario_id,
            "username": log.username,
            "ip_address": log.ip_address,
            "user_agent": log.user_agent,
            "detalles": log.detalles,
            "creado_en": log.creado_en.isoformat()
        }
        for log in logs
    ]

    return {
        "total": total,
        "logs": logs_formateados
    }
