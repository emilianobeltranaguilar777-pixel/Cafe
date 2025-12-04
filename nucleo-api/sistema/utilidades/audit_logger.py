"""
📋 AUDIT LOGGER - ELCAFESIN
Utility for logging audit events
"""
from sqlmodel import Session
from typing import Optional, Dict, Any
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
    Log an audit event to the database

    Args:
        session: Database session
        event_type: Type of event (login_success, login_failed, logout, stock_restock)
        usuario_id: ID of the user (optional)
        username: Username (optional)
        ip_address: IP address of the client (optional)
        user_agent: User agent string (optional)
        detalles: Additional event details as dict (optional)

    Returns:
        AuditLog: The created audit log entry
    """
    audit_log = AuditLog(
        event_type=event_type,
        usuario_id=usuario_id,
        username=username,
        ip_address=ip_address,
        user_agent=user_agent,
        detalles=detalles or {}
    )

    session.add(audit_log)
    session.commit()
    session.refresh(audit_log)

    return audit_log
