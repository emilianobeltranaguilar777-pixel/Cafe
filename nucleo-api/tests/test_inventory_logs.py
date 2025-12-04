"""
🧪 TESTS FOR INVENTORY LOGGING - ELCAFESIN
Tests that inventory operations log to AuditLog
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


@pytest.fixture(name="ingrediente")
def ingrediente_fixture(session: Session):
    """Ingrediente de prueba"""
    ingrediente = Ingrediente(
        nombre="Café Premium",
        stock=10.0,
        min_stock=5.0,
        unidad="kg",
        costo_por_unidad=50.0
    )
    session.add(ingrediente)
    session.commit()
    session.refresh(ingrediente)
    return ingrediente


# ==================== TESTS ====================

def test_log_stock_restock(session: Session, admin_user: Usuario, ingrediente: Ingrediente):
    """Test: Log stock restock event"""
    stock_anterior = ingrediente.stock
    cantidad_restock = 50.0
    stock_nuevo = stock_anterior + cantidad_restock

    log_event(
        session=session,
        event_type="stock_restock",
        usuario_id=admin_user.id,
        username=admin_user.username,
        detalles={
            "ingrediente_id": ingrediente.id,
            "ingrediente_nombre": ingrediente.nombre,
            "cantidad": cantidad_restock,
            "stock_anterior": stock_anterior,
            "stock_nuevo": stock_nuevo
        }
    )

    logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "stock_restock")
    ).all()

    assert len(logs) == 1
    assert logs[0].detalles["ingrediente_nombre"] == "Café Premium"
    assert logs[0].detalles["cantidad"] == 50.0
    assert logs[0].detalles["stock_anterior"] == 10.0


def test_multiple_restock_events(session: Session, admin_user: Usuario, ingrediente: Ingrediente):
    """Test: Multiple restock events are logged"""
    for i in range(3):
        log_event(
            session=session,
            event_type="stock_restock",
            usuario_id=admin_user.id,
            username=admin_user.username,
            detalles={
                "ingrediente_id": ingrediente.id,
                "ingrediente_nombre": ingrediente.nombre,
                "cantidad": 10.0 * (i + 1)
            }
        )

    logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "stock_restock")
    ).all()

    assert len(logs) == 3


def test_restock_log_includes_user_info(session: Session, admin_user: Usuario, ingrediente: Ingrediente):
    """Test: Restock log includes user information"""
    log_event(
        session=session,
        event_type="stock_restock",
        usuario_id=admin_user.id,
        username=admin_user.username,
        ip_address="192.168.1.50",
        detalles={
            "ingrediente_id": ingrediente.id,
            "ingrediente_nombre": ingrediente.nombre,
            "cantidad": 25.0
        }
    )

    log = session.exec(select(AuditLog)).first()
    assert log.usuario_id == admin_user.id
    assert log.username == "admin"
    assert log.ip_address == "192.168.1.50"


def test_restock_different_ingredients(session: Session, admin_user: Usuario):
    """Test: Restock logs for different ingredients"""
    ingredientes_data = [
        ("Café", 10.0),
        ("Leche", 20.0),
        ("Azúcar", 15.0)
    ]

    for nombre, cantidad in ingredientes_data:
        log_event(
            session=session,
            event_type="stock_restock",
            usuario_id=admin_user.id,
            username=admin_user.username,
            detalles={
                "ingrediente_nombre": nombre,
                "cantidad": cantidad
            }
        )

    logs = session.exec(
        select(AuditLog).where(AuditLog.event_type == "stock_restock")
    ).all()

    assert len(logs) == 3
    nombres = [log.detalles["ingrediente_nombre"] for log in logs]
    assert "Café" in nombres
    assert "Leche" in nombres
    assert "Azúcar" in nombres


def test_filter_restock_by_ingrediente(session: Session, admin_user: Usuario):
    """Test: Filter restock logs by ingredient"""
    # Log restocks for different ingredients
    for i in range(5):
        log_event(
            session=session,
            event_type="stock_restock",
            usuario_id=admin_user.id,
            username=admin_user.username,
            detalles={
                "ingrediente_id": 1 if i < 3 else 2,
                "ingrediente_nombre": "Café" if i < 3 else "Leche",
                "cantidad": 10.0
            }
        )

    # Count total logs
    all_logs = session.exec(select(AuditLog)).all()
    assert len(all_logs) == 5

    # Filter logs manually by ingrediente_id in detalles
    # (In real implementation, this would be done in the endpoint logic)
    cafe_logs = [log for log in all_logs if log.detalles.get("ingrediente_id") == 1]
    assert len(cafe_logs) == 3


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
