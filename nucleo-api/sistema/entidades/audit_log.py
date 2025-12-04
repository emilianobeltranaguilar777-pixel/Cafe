"""
📋 AUDIT LOG - Sistema de auditoría unificado
"""
from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field, Column, JSON


class AuditLog(SQLModel, table=True):
    """
    Sistema de auditoría adicional para eventos del sistema.
    Convive con log_sesion y movimiento sin reemplazarlos.
    """
    __tablename__ = "audit_log"

    id: Optional[int] = Field(default=None, primary_key=True)
    event_type: str = Field(max_length=50, index=True)  # login_success, login_failed, logout, stock_restock, etc
    usuario_id: Optional[int] = Field(default=None, foreign_key="usuario.id", index=True)
    username: Optional[str] = Field(default=None, max_length=50, index=True)
    ip_address: Optional[str] = Field(default=None, max_length=45)
    user_agent: Optional[str] = Field(default=None, max_length=200)
    detalles: Optional[dict] = Field(default=None, sa_column=Column(JSON))
    creado_en: datetime = Field(default_factory=datetime.utcnow, index=True)
