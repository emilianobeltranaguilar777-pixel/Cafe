"""
📋 RUTAS DE LOGS - ELCAFESIN
Sistema de auditoría
"""
from fastapi import APIRouter, Depends, Query
from sqlmodel import Session, select
from typing import List, Optional
from datetime import datetime

from sistema.configuracion import obtener_sesion, requiere_roles
from sistema.entidades import LogSesion, Usuario, Rol, Movimiento, Ingrediente, TipoMovimiento

router = APIRouter(prefix="/logs", tags=["📋 Logs"])


@router.get("/")
def listar_logs(
    tipo: Optional[str] = Query(None, description="Tipo de log: sesion, movimiento, todos"),
    limit: int = Query(100, le=500),
    offset: int = 0,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles([Rol.ADMIN, Rol.DUENO]))
):
    """
    📋 Listar logs del sistema (sesiones y movimientos de inventario)

    Tipos de logs:
    - sesion: Solo logs de login/logout
    - movimiento: Solo movimientos de inventario (reabastecimientos, etc)
    - todos: Ambos tipos combinados (default)
    """
    if not isinstance(tipo, str):
        tipo = None
    logs_combinados = []

    # Obtener logs de sesión
    if tipo in [None, "todos", "sesion"]:
        query_sesion = select(LogSesion).order_by(LogSesion.creado_en.desc())
        logs_sesion = session.exec(query_sesion).all()

        for log in logs_sesion:
            usuario = session.get(Usuario, log.usuario_id) if log.usuario_id else None
            logs_combinados.append({
                "id": f"sesion_{log.id}",
                "tipo": "sesion",
                "usuario": usuario.username if usuario else "Sistema",
                "accion": log.accion,
                "detalles": {
                    "ip": log.ip,
                    "user_agent": log.user_agent,
                    "exito": log.exito
                },
                "fecha": log.creado_en.isoformat(),
                "creado_en": log.creado_en
            })

    # Obtener logs de movimientos (reabastecimientos)
    if tipo in [None, "todos", "movimiento"]:
        query_movimiento = select(Movimiento).order_by(Movimiento.creado_en.desc())
        movimientos = session.exec(query_movimiento).all()

        for mov in movimientos:
            ingrediente = session.get(Ingrediente, mov.ingrediente_id)
            logs_combinados.append({
                "id": f"movimiento_{mov.id}",
                "tipo": "movimiento",
                "usuario": mov.referencia if mov.referencia else "Sistema",
                "accion": f"{mov.tipo.value.upper()}",
                "detalles": {
                    "ingrediente": ingrediente.nombre if ingrediente else "Desconocido",
                    "cantidad": mov.cantidad,
                    "tipo_movimiento": mov.tipo.value,
                    "referencia": mov.referencia
                },
                "fecha": mov.creado_en.isoformat(),
                "creado_en": mov.creado_en
            })

    # Ordenar por fecha descendente
    logs_combinados.sort(key=lambda x: x["creado_en"], reverse=True)

    # Aplicar paginación
    logs_paginados = logs_combinados[offset:offset + limit]

    # Remover campo creado_en temporal usado para ordenar
    for log in logs_paginados:
        del log["creado_en"]

    return {
        "total": len(logs_combinados),
        "logs": logs_paginados
    }
