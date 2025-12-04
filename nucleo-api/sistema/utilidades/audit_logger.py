from typing import Optional, Dict
from sqlmodel import Session
from sistema.entidades import AuditLog


def log_event(
    session: Session,
    action: str,
    user_id: Optional[int] = None,
    entity: Optional[str] = None,
    entity_id: Optional[int] = None,
    ip: Optional[str] = None,
    user_agent: Optional[str] = None,
    success: bool = True,
    details: Optional[Dict] = None,
) -> None:
    log = AuditLog(
        action=action,
        user_id=user_id,
        entity=entity,
        entity_id=entity_id,
        ip=ip,
        user_agent=user_agent,
        success=success
    )

    if details is not None:
        log.set_details(details)

    session.add(log)
    session.commit()
