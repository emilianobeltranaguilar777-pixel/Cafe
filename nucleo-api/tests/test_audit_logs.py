"""
🧪 TESTS PARA SISTEMA DE AUDITORÍA - ELCAFESIN
Tests para el nuevo sistema de audit_log (independiente de log_sesion y movimiento)
"""
import pytest
from sqlmodel import Session, create_engine, SQLModel, select
from sqlalchemy.pool import StaticPool
from datetime import datetime, timedelta

# Importar TODOS los modelos
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
    # Import modules to register tables
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


# ==================== TESTS DE CREACIÓN DE AUDIT LOGS ====================

def test_create_audit_log(session: Session, admin_user: Usuario):
    """Test: Crear audit log manualmente"""
    audit = log_event(
        session=session,
        event_type="login_success",
        usuario_id=admin_user.id,
        username=admin_user.username,
        ip_address="192.168.1.1",
        user_agent="Test Browser",
        detalles={"rol": "ADMIN"}
    )

    assert audit.id is not None
    assert audit.event_type == "login_success"
    assert audit.usuario_id == admin_user.id
    assert audit.username == admin_user.username
    assert audit.ip_address == "192.168.1.1"
    assert audit.detalles["rol"] == "ADMIN"


def test_create_audit_log_without_user(session: Session):
    """Test: Crear audit log sin usuario (evento del sistema)"""
    audit = log_event(
        session=session,
        event_type="system_event",
        detalles={"tipo": "backup", "status": "success"}
    )

    assert audit.id is not None
    assert audit.event_type == "system_event"
    assert audit.usuario_id is None
    assert audit.username is None


def test_audit_log_has_timestamp(session: Session):
    """Test: Audit log tiene timestamp automático"""
    audit = log_event(
        session=session,
        event_type="test_event"
    )

    assert audit.creado_en is not None
    assert isinstance(audit.creado_en, datetime)


# ==================== TESTS DE FILTROS ====================

def test_filter_by_event_type(session: Session, admin_user: Usuario):
    """Test: Filtrar audit logs por event_type"""
    # Crear diferentes tipos de eventos
    log_event(session, "login_success", usuario_id=admin_user.id, username="admin")
    log_event(session, "login_success", usuario_id=admin_user.id, username="admin")
    log_event(session, "login_failed", usuario_id=admin_user.id, username="admin")
    log_event(session, "logout", usuario_id=admin_user.id, username="admin")

    # Filtrar por login_success
    logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "login_success")
    ).all()

    assert len(logs) == 2
    for log in logs:
        assert log.event_type == "login_success"


def test_filter_by_username(session: Session):
    """Test: Filtrar audit logs por username"""
    # Crear usuarios
    user1 = Usuario(username="user1", nombre="User 1", password_hash=hash_password("pass1"), rol=Rol.ADMIN, activo=True)
    user2 = Usuario(username="user2", nombre="User 2", password_hash=hash_password("pass2"), rol=Rol.VENDEDOR, activo=True)
    session.add(user1)
    session.add(user2)
    session.commit()

    # Crear logs
    log_event(session, "login_success", usuario_id=user1.id, username="user1")
    log_event(session, "login_success", usuario_id=user1.id, username="user1")
    log_event(session, "login_success", usuario_id=user2.id, username="user2")

    # Filtrar por user1
    logs = session.exec(
        select(AuditLog).where(AuditLog.username == "user1")
    ).all()

    assert len(logs) == 2
    for log in logs:
        assert log.username == "user1"


def test_filter_by_date_range(session: Session, admin_user: Usuario):
    """Test: Filtrar audit logs por rango de fechas"""
    # Crear log con fecha pasada (simulando)
    log_viejo = AuditLog(
        event_type="old_event",
        usuario_id=admin_user.id,
        username=admin_user.username
    )
    # Simular fecha antigua modificando el creado_en
    session.add(log_viejo)
    session.commit()

    # Crear log nuevo
    log_event(session, "new_event", usuario_id=admin_user.id, username=admin_user.username)

    # Filtrar logs de hoy
    hoy = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    logs_hoy = session.exec(
        select(AuditLog).where(AuditLog.creado_en >= hoy)
    ).all()

    # Debería haber al menos 1 log (el nuevo)
    assert len(logs_hoy) >= 1


def test_filter_by_usuario_id(session: Session):
    """Test: Filtrar audit logs por usuario_id"""
    # Crear usuarios
    user1 = Usuario(username="user1", nombre="User 1", password_hash=hash_password("pass1"), rol=Rol.ADMIN, activo=True)
    user2 = Usuario(username="user2", nombre="User 2", password_hash=hash_password("pass2"), rol=Rol.VENDEDOR, activo=True)
    session.add(user1)
    session.add(user2)
    session.commit()

    # Crear logs
    log_event(session, "action1", usuario_id=user1.id, username="user1")
    log_event(session, "action2", usuario_id=user1.id, username="user1")
    log_event(session, "action3", usuario_id=user2.id, username="user2")

    # Filtrar por user1.id
    logs = session.exec(
        select(AuditLog).where(AuditLog.usuario_id == user1.id)
    ).all()

    assert len(logs) == 2


# ==================== TESTS DE PAGINACIÓN ====================

def test_pagination(session: Session, admin_user: Usuario):
    """Test: Paginación de audit logs"""
    # Crear 15 logs
    for i in range(15):
        log_event(session, "test_event", usuario_id=admin_user.id, username=admin_user.username)

    # Página 1: primeros 10
    query = select(AuditLog).order_by(AuditLog.creado_en.desc()).offset(0).limit(10)
    page1 = session.exec(query).all()
    assert len(page1) == 10

    # Página 2: siguientes 5
    query = select(AuditLog).order_by(AuditLog.creado_en.desc()).offset(10).limit(10)
    page2 = session.exec(query).all()
    assert len(page2) == 5


# ==================== TESTS DE EVENTOS ESPECÍFICOS ====================

def test_login_success_event(session: Session, admin_user: Usuario):
    """Test: Registrar evento login_success"""
    audit = log_event(
        session=session,
        event_type="login_success",
        usuario_id=admin_user.id,
        username=admin_user.username,
        ip_address="10.0.0.1",
        user_agent="Mozilla/5.0",
        detalles={"rol": "ADMIN"}
    )

    assert audit.event_type == "login_success"
    assert audit.detalles["rol"] == "ADMIN"


def test_login_failed_event(session: Session, admin_user: Usuario):
    """Test: Registrar evento login_failed"""
    audit = log_event(
        session=session,
        event_type="login_failed",
        usuario_id=admin_user.id,
        username=admin_user.username,
        ip_address="10.0.0.1",
        user_agent="Mozilla/5.0",
        detalles={"razon": "credenciales_incorrectas"}
    )

    assert audit.event_type == "login_failed"
    assert audit.detalles["razon"] == "credenciales_incorrectas"


def test_logout_event(session: Session, admin_user: Usuario):
    """Test: Registrar evento logout"""
    audit = log_event(
        session=session,
        event_type="logout",
        usuario_id=admin_user.id,
        username=admin_user.username,
        ip_address="10.0.0.1",
        user_agent="Mozilla/5.0"
    )

    assert audit.event_type == "logout"
    assert audit.usuario_id == admin_user.id


def test_stock_restock_event(session: Session, admin_user: Usuario):
    """Test: Registrar evento stock_restock"""
    audit = log_event(
        session=session,
        event_type="stock_restock",
        usuario_id=admin_user.id,
        username=admin_user.username,
        detalles={
            "ingrediente_id": 1,
            "ingrediente_nombre": "Café Premium",
            "stock_anterior": 100.0,
            "stock_nuevo": 150.0,
            "diferencia": 50.0
        }
    )

    assert audit.event_type == "stock_restock"
    assert audit.detalles["ingrediente_nombre"] == "Café Premium"
    assert audit.detalles["diferencia"] == 50.0


# ==================== TESTS DE INDEPENDENCIA ====================

def test_audit_log_independent_from_log_sesion(session: Session, admin_user: Usuario):
    """Test: audit_log es independiente de log_sesion"""
    # Crear log de sesión
    log_sesion = LogSesion(
        usuario_id=admin_user.id,
        accion="LOGIN",
        ip="192.168.1.1",
        exito=True
    )
    session.add(log_sesion)
    session.commit()

    # Crear audit log
    log_event(session, "login_success", usuario_id=admin_user.id, username=admin_user.username)

    # Verificar que ambos existen independientemente
    logs_sesion = session.exec(select(LogSesion)).all()
    audit_logs = session.exec(select(AuditLog)).all()

    assert len(logs_sesion) == 1
    assert len(audit_logs) == 1


def test_audit_log_independent_from_movimiento(session: Session, admin_user: Usuario):
    """Test: audit_log es independiente de movimiento"""
    # Crear ingrediente
    ingrediente = Ingrediente(
        nombre="Café",
        stock=100.0,
        min_stock=20.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    # Crear movimiento
    movimiento = Movimiento(
        ingrediente_id=ingrediente.id,
        tipo=TipoMovimiento.ENTRADA,
        cantidad=50.0,
        referencia="Reabastecimiento"
    )
    session.add(movimiento)
    session.commit()

    # Crear audit log de restock
    log_event(
        session,
        "stock_restock",
        usuario_id=admin_user.id,
        username=admin_user.username,
        detalles={"ingrediente_id": ingrediente.id}
    )

    # Verificar que ambos existen independientemente
    movimientos = session.exec(select(Movimiento)).all()
    audit_logs = session.exec(select(AuditLog)).all()

    assert len(movimientos) == 1
    assert len(audit_logs) == 1


# ==================== TESTS DE MÚLTIPLES EVENTOS ====================

def test_multiple_event_types(session: Session, admin_user: Usuario):
    """Test: Crear múltiples tipos de eventos"""
    eventos = [
        ("login_success", {"rol": "ADMIN"}),
        ("login_failed", {"razon": "password_incorrecto"}),
        ("logout", {}),
        ("stock_restock", {"ingrediente": "Café"}),
        ("user_created", {"nuevo_usuario": "vendedor1"}),
    ]

    for event_type, detalles in eventos:
        log_event(
            session,
            event_type,
            usuario_id=admin_user.id,
            username=admin_user.username,
            detalles=detalles
        )

    # Verificar que todos se crearon
    logs = session.exec(select(AuditLog)).all()
    assert len(logs) == 5

    # Verificar variedad de tipos
    event_types = {log.event_type for log in logs}
    assert len(event_types) == 5


def test_ordering_by_date_desc(session: Session, admin_user: Usuario):
    """Test: Ordenar audit logs por fecha descendente"""
    # Crear logs en orden
    log_event(session, "event1", usuario_id=admin_user.id, username=admin_user.username)
    log_event(session, "event2", usuario_id=admin_user.id, username=admin_user.username)
    log_event(session, "event3", usuario_id=admin_user.id, username=admin_user.username)

    # Obtener logs ordenados
    logs = session.exec(
        select(AuditLog).order_by(AuditLog.creado_en.desc())
    ).all()

    # El más reciente debería ser event3
    assert logs[0].event_type == "event3"
    assert logs[1].event_type == "event2"
    assert logs[2].event_type == "event1"


# ==================== TESTS DE DATOS JSON ====================

def test_detalles_json_complex(session: Session, admin_user: Usuario):
    """Test: Detalles JSON con estructura compleja"""
    detalles_complejos = {
        "accion": "update_user",
        "cambios": {
            "rol_anterior": "VENDEDOR",
            "rol_nuevo": "GERENTE"
        },
        "metadata": {
            "ip": "10.0.0.1",
            "timestamp": "2025-12-04T10:00:00"
        }
    }

    audit = log_event(
        session,
        "user_role_changed",
        usuario_id=admin_user.id,
        username=admin_user.username,
        detalles=detalles_complejos
    )

    # Verificar que se guardó correctamente
    retrieved = session.get(AuditLog, audit.id)
    assert retrieved.detalles["accion"] == "update_user"
    assert retrieved.detalles["cambios"]["rol_nuevo"] == "GERENTE"
    assert retrieved.detalles["metadata"]["ip"] == "10.0.0.1"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
