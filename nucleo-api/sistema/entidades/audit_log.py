"""
📋 AUDIT LOG MODEL - ELCAFESIN
Unified audit log for all system events
"""
from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field, JSON, Column
from sqlalchemy import Text


class AuditLog(SQLModel, table=True):
    """
    Unified audit log table for all system events

    Events tracked:
    - login_success: Successful user login
    - login_failed: Failed login attempt
    - logout: User logout
    - stock_restock: Inventory restocking event
    """
    __tablename__ = "audit_log"

    id: Optional[int] = Field(default=None, primary_key=True)
    event_type: str = Field(max_length=50, index=True)  # login_success, login_failed, logout, stock_restock
    usuario_id: Optional[int] = Field(default=None, foreign_key="usuario.id", index=True)
    username: Optional[str] = Field(default=None, max_length=50, index=True)
    ip_address: Optional[str] = Field(default=None, max_length=45)
    user_agent: Optional[str] = Field(default=None, sa_column=Column(Text))
    detalles: Optional[dict] = Field(default=None, sa_column=Column(JSON))
    creado_en: datetime = Field(default_factory=datetime.utcnow, index=True)
