"""
🧪 TESTS FOR LOGS ENDPOINTS - ELCAFESIN
Tests for the /logs endpoint that queries AuditLog
"""
import pytest
from sqlmodel import Session, create_engine, SQLModel, select
from sqlalchemy.pool import StaticPool
from datetime import datetime

from sistema.entidades.usuario import Usuario, Rol
from sistema.entidades.permiso import PermisoRol, UsuarioPermiso, Accion
from sistema.entidades.cliente import Cliente
from sistema.entidades.proveedor import Proveedor
from sistema.entidades.ingrediente import Ingrediente
from sistema.entidades.receta import Receta, RecetaItem
from sistema.entidades.venta import Venta, VentaItem
from sistema.entidades.movimiento import Movimiento, TipoMovimiento
from sistema.entidades.log_sesion import LogSesion
from sistema.entidades.audit_log import AuditLog
from sistema.configuracion import hash_password


# ==================== FIXTURES ====================

@pytest.fixture(name="engine")
def engine_fixture():
    """Motor de base de datos en memoria"""
    import sistema.entidades.usuario as _u
    import sistema.entidades.permiso as _p
    import sistema.entidades.cliente as _c
    import sistema.entidades.proveedor as _pr
    import sistema.entidades.ingrediente as _i
    import sistema.entidades.receta as _r
    import sistema.entidades.venta as _v
    import sistema.entidades.movimiento as _m
    import sistema.entidades.log_sesion as _l
    import sistema.entidades.audit_log as _a

    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture(name="session")
def session_fixture(engine):
    """Sesión de base de datos"""
    with Session(engine) as session:
        yield session


@pytest.fixture(name="admin_user")
def admin_user_fixture(session: Session):
    """Usuario administrador"""
    usuario = Usuario(
        username="admin",
        nombre="Admin Test",
        password_hash=hash_password("admin123"),
        rol=Rol.ADMIN,
        activo=True
    )
    session.add(usuario)
    session.commit()
    session.refresh(usuario)
    return usuario


# ==================== TESTS ====================

def test_audit_log_creation(session: Session, admin_user: Usuario):
    """Test: Create audit log entry"""
    log = AuditLog(
        event_type="login_success",
        usuario_id=admin_user.id,
        username=admin_user.username,
        ip_address="192.168.1.1",
        user_agent="Test Browser",
        detalles={"method": "password"}
    )
    session.add(log)
    session.commit()

    logs = session.exec(select(AuditLog)).all()
    assert len(logs) == 1
    assert logs[0].event_type == "login_success"
    assert logs[0].username == "admin"


def test_audit_log_filter_by_event_type(session: Session, admin_user: Usuario):
    """Test: Filter audit logs by event type"""
    # Create different event types
    events = [
        AuditLog(event_type="login_success", usuario_id=admin_user.id, username="admin"),
        AuditLog(event_type="login_failed", username="hacker"),
        AuditLog(event_type="logout", usuario_id=admin_user.id, username="admin"),
        AuditLog(event_type="stock_restock", usuario_id=admin_user.id, username="admin"),
    ]

    for event in events:
        session.add(event)
    session.commit()

    # Filter by login_success
    login_logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "login_success")
    ).all()
    assert len(login_logs) == 1

    # Filter by logout
    logout_logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "logout")
    ).all()
    assert len(logout_logs) == 1


def test_audit_log_filter_by_username(session: Session, admin_user: Usuario):
    """Test: Filter audit logs by username"""
    # Create logs for different users
    logs_data = [
        ("admin", "login_success"),
        ("admin", "logout"),
        ("vendedor", "login_success"),
        ("vendedor", "logout"),
    ]

    for username, event_type in logs_data:
        log = AuditLog(
            event_type=event_type,
            username=username
        )
        session.add(log)
    session.commit()

    # Filter by admin username
    admin_logs = session.exec(
        select(AuditLog).where(AuditLog.username == "admin")
    ).all()
    assert len(admin_logs) == 2


def test_audit_log_ordering_by_date(session: Session, admin_user: Usuario):
    """Test: Audit logs can be ordered by creation date"""
    # Create multiple logs
    for i in range(5):
        log = AuditLog(
            event_type="login_success",
            usuario_id=admin_user.id,
            username="admin"
        )
        session.add(log)
    session.commit()

    # Query ordered by date desc
    logs = session.exec(
        select(AuditLog).order_by(AuditLog.creado_en.desc())
    ).all()

    assert len(logs) == 5
    # Verify ordering (newest first)
    for i in range(len(logs) - 1):
        assert logs[i].creado_en >= logs[i + 1].creado_en


def test_audit_log_with_detalles(session: Session, admin_user: Usuario):
    """Test: Audit log stores detalles as JSON"""
    log = AuditLog(
        event_type="stock_restock",
        usuario_id=admin_user.id,
        username="admin",
        detalles={
            "ingrediente_id": 5,
            "ingrediente_nombre": "Café Premium",
            "cantidad": 50.0,
            "stock_anterior": 10.0,
            "stock_nuevo": 60.0
        }
    )
    session.add(log)
    session.commit()

    retrieved_log = session.exec(select(AuditLog)).first()
    assert retrieved_log.detalles["ingrediente_nombre"] == "Café Premium"
    assert retrieved_log.detalles["cantidad"] == 50.0


def test_audit_log_pagination(session: Session, admin_user: Usuario):
    """Test: Audit logs support pagination"""
    # Create 20 logs
    for i in range(20):
        log = AuditLog(
            event_type="login_success",
            usuario_id=admin_user.id,
            username="admin"
        )
        session.add(log)
    session.commit()

    # Test pagination
    page_1 = session.exec(
        select(AuditLog).order_by(AuditLog.creado_en.desc()).limit(10).offset(0)
    ).all()
    page_2 = session.exec(
        select(AuditLog).order_by(AuditLog.creado_en.desc()).limit(10).offset(10)
    ).all()

    assert len(page_1) == 10
    assert len(page_2) == 10
    assert page_1[0].id != page_2[0].id


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
