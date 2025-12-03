"""
📋 RUTAS DE LOGS - ELCAFESIN
Sistema de auditoría
"""
from fastapi import APIRouter, Depends, Query
from sqlmodel import Session, select
from typing import List
from datetime import datetime

from sistema.configuracion import obtener_sesion, requiere_roles
from sistema.entidades import LogSesion, Usuario, Rol

router = APIRouter(prefix="/logs", tags=["📋 Logs"])


@router.get("/")
def listar_logs(
    limit: int = Query(100, le=500),
    offset: int = 0,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles([Rol.ADMIN, Rol.DUENO]))
):
    """📋 Listar logs de sesión"""
    query = select(LogSesion).order_by(LogSesion.creado_en.desc()).offset(offset).limit(limit)
    logs = session.exec(query).all()
    
    logs_detalle = []
    for log in logs:
        usuario = session.get(Usuario, log.usuario_id) if log.usuario_id else None
        logs_detalle.append({
            "id": log.id,
            "usuario_id": log.usuario_id,
            "usuario_nombre": usuario.username if usuario else "Sistema",
            "accion": log.accion,
            "ip": log.ip,
            "user_agent": log.user_agent,
            "exito": log.exito,
            "creado_en": log.creado_en
        })
    
    return logs_detalle
