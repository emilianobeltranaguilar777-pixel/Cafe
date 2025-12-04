"""
📝 AUDIT LOGGER - Servicio de registro de eventos de auditoría
"""
from typing import Optional, Dict, Any
from sqlmodel import Session
from sistema.entidades.audit_log import AuditLog


def log_event(
    session: Session,
    event_type: str,
    usuario_id: Optional[int] = None,
    username: Optional[str] = None,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
    detalles: Optional[Dict[str, Any]] = None
) -> AuditLog:
    """
    Registra un evento de auditoría en la base de datos.

    Args:
        session: Sesión de base de datos
        event_type: Tipo de evento (login_success, login_failed, logout, stock_restock, etc)
        usuario_id: ID del usuario (opcional)
        username: Nombre de usuario (opcional)
        ip_address: Dirección IP (opcional)
        user_agent: User agent del navegador/cliente (opcional)
        detalles: Detalles adicionales en formato JSON (opcional)

    Returns:
        AuditLog: El registro de auditoría creado
    """
    audit_log = AuditLog(
        event_type=event_type,
        usuario_id=usuario_id,
        username=username,
        ip_address=ip_address,
        user_agent=user_agent,
        detalles=detalles
    )

    session.add(audit_log)
    session.commit()
    session.refresh(audit_log)

    return audit_log
