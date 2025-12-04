"""
📋 RUTAS DE LOGS - ELCAFESIN
Sistema de auditoría
"""
from fastapi import APIRouter, Depends, Query
from sqlmodel import Session, select, and_
from typing import List, Optional
from datetime import datetime

from sistema.configuracion import obtener_sesion, requiere_roles
from sistema.entidades import AuditLog, Usuario, Rol

router = APIRouter(prefix="/logs", tags=["📋 Logs"])


@router.get("/")
def listar_logs(
    action: Optional[str] = None,
    entity: Optional[str] = None,
    user_id: Optional[int] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    q: Optional[str] = None,
    limit: int = Query(100, le=500),
    offset: int = 0,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles([Rol.ADMIN, Rol.DUENO]))
):
    """
    📋 Listar logs de auditoría con filtros y paginación

    Filtros:
    - action: Filtrar por acción específica
    - entity: Filtrar por tipo de entidad
    - user_id: Filtrar por usuario
    - date_from: Fecha desde (ISO datetime)
    - date_to: Fecha hasta (ISO datetime)
    - q: Búsqueda de texto en action y details
    """
    # Construir filtros
    filters = []

    if action:
        filters.append(AuditLog.action == action)

    if entity:
        filters.append(AuditLog.entity == entity)

    if user_id is not None:
        filters.append(AuditLog.user_id == user_id)

    if date_from:
        try:
            dt_from = datetime.fromisoformat(date_from)
            filters.append(AuditLog.timestamp >= dt_from)
        except ValueError:
            pass

    if date_to:
        try:
            dt_to = datetime.fromisoformat(date_to)
            filters.append(AuditLog.timestamp <= dt_to)
        except ValueError:
            pass

    if q:
        filters.append(AuditLog.action.contains(q))

    # Query base con filtros
    query = select(AuditLog)
    if filters:
        query = query.where(and_(*filters))

    # Calcular total ANTES de paginación
    total_query = query
    total = len(session.exec(total_query).all())

    # Aplicar orden y paginación
    query = query.order_by(AuditLog.timestamp.desc())
    query = query.offset(offset).limit(limit)

    # Ejecutar query paginada
    logs = session.exec(query).all()

    # Formatear respuesta
    logs_formatted = []
    for log in logs:
        # Resolver usuario
        user = "Sistema"
        if log.user_id is not None:
            usuario = session.get(Usuario, log.user_id)
            if usuario:
                user = usuario.username

        logs_formatted.append({
            "id": log.id,
            "timestamp": log.timestamp.isoformat(),
            "user": user,
            "user_id": log.user_id,
            "action": log.action,
            "entity": log.entity,
            "entity_id": log.entity_id,
            "ip": log.ip,
            "user_agent": log.user_agent,
            "success": log.success,
            "details": log.get_details()
        })

    return {
        "total": total,
        "logs": logs_formatted
    }
