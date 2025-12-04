"""
📋 RUTAS DE LOGS - ELCAFESIN
Sistema de auditoría
"""
from fastapi import APIRouter, Depends, Query
from sqlmodel import Session, select
from typing import List, Optional
from datetime import datetime

from sistema.configuracion import obtener_sesion, requiere_roles
from sistema.entidades import Usuario, Rol, AuditLog

router = APIRouter(prefix="/logs", tags=["📋 Logs"])


@router.get("/")
def listar_logs(
    event_type: Optional[str] = Query(None, description="Filter by event type"),
    username: Optional[str] = Query(None, description="Filter by username"),
    limit: int = Query(100, le=500),
    offset: int = 0,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles([Rol.ADMIN, Rol.DUENO]))
):
    """
    📋 List audit logs from the system

    Filters:
    - event_type: Filter by event type (login_success, login_failed, logout, stock_restock)
    - username: Filter by username
    - limit: Maximum number of results (default 100, max 500)
    - offset: Number of results to skip for pagination
    """
    query = select(AuditLog)

    if event_type:
        query = query.where(AuditLog.event_type == event_type)

    if username:
        query = query.where(AuditLog.username == username)

    query = query.order_by(AuditLog.creado_en.desc()).offset(offset).limit(limit)

    logs = session.exec(query).all()

    # Transform to response format
    logs_response = []
    for log in logs:
        logs_response.append({
            "id": log.id,
            "event_type": log.event_type,
            "usuario_id": log.usuario_id,
            "username": log.username,
            "ip_address": log.ip_address,
            "user_agent": log.user_agent,
            "detalles": log.detalles,
            "creado_en": log.creado_en.isoformat()
        })

    return {
        "total": len(logs_response),
        "logs": logs_response
    }
