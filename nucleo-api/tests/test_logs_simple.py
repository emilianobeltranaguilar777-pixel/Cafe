"""
🧪 TESTS SIMPLES PARA LOGS - ELCAFESIN
Tests directos sin TestClient para evitar problemas de sesión
"""
import pytest
from sqlmodel import Session, create_engine, SQLModel, select
from datetime import datetime

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

from sistema.configuracion import hash_password


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

    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False}
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


# ==================== TESTS DE LOGS DE SESIÓN ====================

def test_log_sesion_creation(session: Session, admin_user: Usuario):
    """Test: Crear log de sesión manualmente"""
    log = LogSesion(
        usuario_id=admin_user.id,
        accion="LOGIN",
        ip="192.168.1.1",
        user_agent="Test Browser",
        exito=True
    )
    session.add(log)
    session.commit()

    # Verificar que se creó
    logs = session.exec(select(LogSesion)).all()
    assert len(logs) == 1
    assert logs[0].accion == "LOGIN"
    assert logs[0].usuario_id == admin_user.id
    assert logs[0].exito is True


def test_log_sesion_failed_login(session: Session, admin_user: Usuario):
    """Test: Log de login fallido"""
    log = LogSesion(
        usuario_id=admin_user.id,
        accion="LOGIN_FAILED",
        ip="192.168.1.1",
        user_agent="Test Browser",
        exito=False
    )
    session.add(log)
    session.commit()

    logs = session.exec(select(LogSesion).where(LogSesion.exito == False)).all()
    assert len(logs) == 1
    assert logs[0].accion == "LOGIN_FAILED"


def test_log_sesion_includes_metadata(session: Session, admin_user: Usuario):
    """Test: Log incluye metadata (IP, user agent)"""
    log = LogSesion(
        usuario_id=admin_user.id,
        accion="LOGIN",
        ip="10.0.0.5",
        user_agent="Mozilla/5.0 Test",
        exito=True
    )
    session.add(log)
    session.commit()

    retrieved_log = session.exec(select(LogSesion)).first()
    assert retrieved_log.ip == "10.0.0.5"
    assert retrieved_log.user_agent == "Mozilla/5.0 Test"


def test_multiple_login_logs(session: Session, admin_user: Usuario):
    """Test: Múltiples logs de login"""
    for i in range(5):
        log = LogSesion(
            usuario_id=admin_user.id,
            accion="LOGIN",
            ip=f"192.168.1.{i}",
            exito=True
        )
        session.add(log)
    session.commit()

    logs = session.exec(select(LogSesion)).all()
    assert len(logs) == 5


# ==================== TESTS DE MOVIMIENTOS ====================

def test_movimiento_creation(session: Session):
    """Test: Crear movimiento de inventario"""
    ingrediente = Ingrediente(
        nombre="Café Test",
        stock=100.0,
        min_stock=20.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    movimiento = Movimiento(
        ingrediente_id=ingrediente.id,
        tipo=TipoMovimiento.ENTRADA,
        cantidad=50.0,
        referencia="Proveedor: Test SA"
    )
    session.add(movimiento)
    session.commit()

    movimientos = session.exec(select(Movimiento)).all()
    assert len(movimientos) == 1
    assert movimientos[0].tipo == TipoMovimiento.ENTRADA
    assert movimientos[0].cantidad == 50.0


def test_movimiento_different_types(session: Session):
    """Test: Diferentes tipos de movimientos"""
    ingrediente = Ingrediente(
        nombre="Leche",
        stock=100.0,
        min_stock=20.0,
        unidad="litros"
    )
    session.add(ingrediente)
    session.commit()

    tipos = [
        (TipoMovimiento.ENTRADA, 50.0, "Compra"),
        (TipoMovimiento.SALIDA, 25.0, "Venta"),
        (TipoMovimiento.AJUSTE, 5.0, "Corrección"),
        (TipoMovimiento.MERMA, 3.0, "Vencimiento")
    ]

    for tipo, cantidad, ref in tipos:
        mov = Movimiento(
            ingrediente_id=ingrediente.id,
            tipo=tipo,
            cantidad=cantidad,
            referencia=ref
        )
        session.add(mov)
    session.commit()

    movimientos = session.exec(select(Movimiento)).all()
    assert len(movimientos) == 4


def test_movimiento_with_provider_info(session: Session):
    """Test: Movimiento con información de proveedor"""
    ingrediente = Ingrediente(
        nombre="Azúcar",
        stock=100.0,
        min_stock=20.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    movimiento = Movimiento(
        ingrediente_id=ingrediente.id,
        tipo=TipoMovimiento.ENTRADA,
        cantidad=100.0,
        referencia="Proveedor: Azucarera Premium - Juan Pérez"
    )
    session.add(movimiento)
    session.commit()

    mov = session.exec(select(Movimiento)).first()
    assert "Proveedor" in mov.referencia
    assert "Juan Pérez" in mov.referencia


def test_movimiento_with_staff_info(session: Session):
    """Test: Movimiento realizado por staff"""
    ingrediente = Ingrediente(
        nombre="Café",
        stock=100.0,
        min_stock=20.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    movimiento = Movimiento(
        ingrediente_id=ingrediente.id,
        tipo=TipoMovimiento.AJUSTE,
        cantidad=10.0,
        referencia="Staff: María García - Supervisora"
    )
    session.add(movimiento)
    session.commit()

    mov = session.exec(select(Movimiento)).first()
    assert "Staff" in mov.referencia
    assert "María García" in mov.referencia


# ==================== TESTS DE FECHAS ====================

def test_log_sesion_has_timestamp(session: Session, admin_user: Usuario):
    """Test: Log de sesión tiene timestamp"""
    log = LogSesion(
        usuario_id=admin_user.id,
        accion="LOGIN",
        ip="192.168.1.1",
        exito=True
    )
    session.add(log)
    session.commit()

    retrieved_log = session.exec(select(LogSesion)).first()
    assert retrieved_log.creado_en is not None
    assert isinstance(retrieved_log.creado_en, datetime)


def test_movimiento_has_timestamp(session: Session):
    """Test: Movimiento tiene timestamp"""
    ingrediente = Ingrediente(
        nombre="Test",
        stock=100.0,
        min_stock=20.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    movimiento = Movimiento(
        ingrediente_id=ingrediente.id,
        tipo=TipoMovimiento.ENTRADA,
        cantidad=50.0,
        referencia="Test"
    )
    session.add(movimiento)
    session.commit()

    mov = session.exec(select(Movimiento)).first()
    assert mov.creado_en is not None
    assert isinstance(mov.creado_en, datetime)


# ==================== TESTS DE QUERIES ====================

def test_filter_logs_by_user(session: Session):
    """Test: Filtrar logs por usuario"""
    # Crear dos usuarios
    user1 = Usuario(
        username="user1",
        nombre="User 1",
        password_hash=hash_password("pass1"),
        rol=Rol.ADMIN,
        activo=True
    )
    user2 = Usuario(
        username="user2",
        nombre="User 2",
        password_hash=hash_password("pass2"),
        rol=Rol.VENDEDOR,
        activo=True
    )
    session.add(user1)
    session.add(user2)
    session.commit()

    # Crear logs para cada usuario
    for i in range(3):
        log1 = LogSesion(usuario_id=user1.id, accion="LOGIN", exito=True)
        log2 = LogSesion(usuario_id=user2.id, accion="LOGIN", exito=True)
        session.add(log1)
        session.add(log2)
    session.commit()

    # Filtrar por user1
    user1_logs = session.exec(
        select(LogSesion).where(LogSesion.usuario_id == user1.id)
    ).all()
    assert len(user1_logs) == 3


def test_filter_movements_by_type(session: Session):
    """Test: Filtrar movimientos por tipo"""
    ingrediente = Ingrediente(
        nombre="Test",
        stock=100.0,
        min_stock=20.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    # Crear diferentes tipos de movimientos
    for _ in range(3):
        mov_entrada = Movimiento(
            ingrediente_id=ingrediente.id,
            tipo=TipoMovimiento.ENTRADA,
            cantidad=10.0,
            referencia="Entrada"
        )
        mov_salida = Movimiento(
            ingrediente_id=ingrediente.id,
            tipo=TipoMovimiento.SALIDA,
            cantidad=5.0,
            referencia="Salida"
        )
        session.add(mov_entrada)
        session.add(mov_salida)
    session.commit()

    # Filtrar por ENTRADA
    entradas = session.exec(
        select(Movimiento).where(Movimiento.tipo == TipoMovimiento.ENTRADA)
    ).all()
    assert len(entradas) == 3


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
