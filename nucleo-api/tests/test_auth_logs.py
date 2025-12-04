"""
🧪 TESTS FOR AUTH LOGGING - ELCAFESIN
Tests that auth endpoints properly log to AuditLog
"""
import pytest
from sqlmodel import Session, create_engine, SQLModel, select
from sqlalchemy.pool import StaticPool

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
from sistema.utilidades.audit_logger import log_event


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

def test_log_event_login_success(session: Session, admin_user: Usuario):
    """Test: log_event creates login_success entry"""
    log_event(
        session=session,
        event_type="login_success",
        usuario_id=admin_user.id,
        username=admin_user.username,
        ip_address="192.168.1.100",
        user_agent="Mozilla/5.0"
    )

    logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "login_success")
    ).all()

    assert len(logs) == 1
    assert logs[0].usuario_id == admin_user.id
    assert logs[0].username == "admin"
    assert logs[0].ip_address == "192.168.1.100"


def test_log_event_login_failed(session: Session):
    """Test: log_event creates login_failed entry without user_id"""
    log_event(
        session=session,
        event_type="login_failed",
        username="hacker",
        ip_address="10.0.0.5",
        user_agent="curl/7.0"
    )

    logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "login_failed")
    ).all()

    assert len(logs) == 1
    assert logs[0].usuario_id is None
    assert logs[0].username == "hacker"
    assert logs[0].ip_address == "10.0.0.5"


def test_log_event_logout(session: Session, admin_user: Usuario):
    """Test: log_event creates logout entry"""
    log_event(
        session=session,
        event_type="logout",
        usuario_id=admin_user.id,
        username=admin_user.username,
        ip_address="192.168.1.100"
    )

    logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "logout")
    ).all()

    assert len(logs) == 1
    assert logs[0].usuario_id == admin_user.id
    assert logs[0].username == "admin"


def test_log_event_with_detalles(session: Session, admin_user: Usuario):
    """Test: log_event stores additional detalles"""
    log_event(
        session=session,
        event_type="login_success",
        usuario_id=admin_user.id,
        username=admin_user.username,
        detalles={"method": "oauth", "provider": "google"}
    )

    log = session.exec(select(AuditLog)).first()
    assert log.detalles["method"] == "oauth"
    assert log.detalles["provider"] == "google"


def test_multiple_auth_events(session: Session, admin_user: Usuario):
    """Test: Multiple auth events are logged correctly"""
    # Simulate login flow
    log_event(session, "login_success", admin_user.id, "admin", "192.168.1.1")
    log_event(session, "logout", admin_user.id, "admin", "192.168.1.1")
    log_event(session, "login_success", admin_user.id, "admin", "192.168.1.1")

    all_logs = session.exec(select(AuditLog)).all()
    assert len(all_logs) == 3

    login_logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "login_success")
    ).all()
    assert len(login_logs) == 2


def test_failed_login_attempts_tracking(session: Session):
    """Test: Track multiple failed login attempts"""
    ips = ["10.0.0.1", "10.0.0.2", "10.0.0.3"]

    for ip in ips:
        log_event(
            session=session,
            event_type="login_failed",
            username="attacker",
            ip_address=ip
        )

    failed_logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "login_failed")
    ).all()

    assert len(failed_logs) == 3
    assert all(log.username == "attacker" for log in failed_logs)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
