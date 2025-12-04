from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field
import json


class AuditLog(SQLModel, table=True):
    __tablename__ = "audit_logs"

    id: Optional[int] = Field(default=None, primary_key=True)
    timestamp: datetime = Field(default_factory=datetime.utcnow, index=True)
    user_id: Optional[int] = Field(default=None, foreign_key="usuario.id", index=True)
    action: str = Field(max_length=100, index=True)
    entity: Optional[str] = Field(default=None, max_length=50, index=True)
    entity_id: Optional[int] = Field(default=None, index=True)
    ip: Optional[str] = Field(default=None, max_length=45)
    user_agent: Optional[str] = Field(default=None, max_length=500)
    success: bool = Field(default=True)
    details: Optional[str] = Field(default=None)

    def set_details(self, data: dict):
        self.details = json.dumps(data, ensure_ascii=False)

    def get_details(self) -> dict:
        if self.details:
            try:
                return json.loads(self.details)
            except Exception:
                return {}
        return {}
