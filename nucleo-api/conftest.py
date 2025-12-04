"""
🧪 CONFTEST - FIXTURES DE PRUEBA
Configuración global para pytest con base de datos in-memory
"""
import pytest
from sqlmodel import SQLModel, Session, create_engine
from sqlalchemy.pool import StaticPool
from fastapi.testclient import TestClient

from sistema.motor_principal import app
from sistema.configuracion import obtener_sesion, hash_password
from sistema.entidades import (
    Usuario, Rol, PermisoRol, Accion,
    Ingrediente, Receta, RecetaItem, Cliente
)


@pytest.fixture(name="test_engine")
def test_engine_fixture():
    """
    Crea un motor de SQLite en memoria con StaticPool.
    Esto garantiza que todos los hilos/conexiones vean la misma BD in-memory.
    """
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture(name="test_session")
def test_session_fixture(test_engine):
    """
    Crea una sesión de prueba para cada test.
    Al finalizar, hace rollback para mantener aislamiento entre tests.
    """
    with Session(test_engine) as session:
        yield session
        session.rollback()


@pytest.fixture(name="client")
def client_fixture(test_engine, test_session):
    """
    Cliente HTTP de prueba con override de la sesión de BD.
    """
    def override_get_session():
        with Session(test_engine) as session:
            yield session

    app.dependency_overrides[obtener_sesion] = override_get_session
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()


@pytest.fixture(name="admin_user")
def admin_user_fixture(test_session):
    """
    Crea y retorna un usuario ADMIN de prueba.
    """
    admin = Usuario(
        username="admin_test",
        nombre="Administrador Test",
        password_hash=hash_password("admin123"),
        rol=Rol.ADMIN,
        activo=True
    )
    test_session.add(admin)
    test_session.commit()
    test_session.refresh(admin)
    return admin


@pytest.fixture(name="vendedor_user")
def vendedor_user_fixture(test_session):
    """
    Crea y retorna un usuario VENDEDOR de prueba.
    """
    vendedor = Usuario(
        username="vendedor_test",
        nombre="Vendedor Test",
        password_hash=hash_password("vendedor123"),
        rol=Rol.VENDEDOR,
        activo=True
    )
    test_session.add(vendedor)
    test_session.commit()
    test_session.refresh(vendedor)
    return vendedor


@pytest.fixture(name="seed_permisos")
def seed_permisos_fixture(test_session):
    """
    Siembra permisos base por rol (igual que seed_inicial.py).
    """
    permisos_base = [
        # ADMIN
        ("ADMIN", "usuarios", Accion.VER),
        ("ADMIN", "usuarios", Accion.CREAR),
        ("ADMIN", "usuarios", Accion.EDITAR),
        ("ADMIN", "inventario", Accion.VER),
        ("ADMIN", "inventario", Accion.CREAR),
        ("ADMIN", "inventario", Accion.EDITAR),
        ("ADMIN", "ventas", Accion.CREAR),
        ("ADMIN", "ventas", Accion.VER),
        ("ADMIN", "reportes", Accion.VER),

        # VENDEDOR
        ("VENDEDOR", "ventas", Accion.VER),
        ("VENDEDOR", "ventas", Accion.CREAR),
        ("VENDEDOR", "clientes", Accion.VER),
        ("VENDEDOR", "inventario", Accion.VER),
    ]

    for rol, recurso, accion in permisos_base:
        permiso = PermisoRol(rol=rol, recurso=recurso, accion=accion)
        test_session.add(permiso)

    test_session.commit()


@pytest.fixture(name="auth_headers")
def auth_headers_fixture(client, admin_user, seed_permisos):
    """
    Retorna headers de autenticación para el usuario admin.
    """
    response = client.post(
        "/auth/login",
        data={"username": "admin_test", "password": "admin123"}
    )
    assert response.status_code == 200
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture(name="vendedor_auth_headers")
def vendedor_auth_headers_fixture(client, vendedor_user, seed_permisos):
    """
    Retorna headers de autenticación para el usuario vendedor.
    """
    response = client.post(
        "/auth/login",
        data={"username": "vendedor_test", "password": "vendedor123"}
    )
    assert response.status_code == 200
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture(name="sample_ingrediente")
def sample_ingrediente_fixture(test_session):
    """
    Crea un ingrediente de prueba con stock.
    """
    ingrediente = Ingrediente(
        nombre="Café Molido",
        unidad="kg",
        costo_por_unidad=150.0,
        stock=10.0,
        min_stock=2.0
    )
    test_session.add(ingrediente)
    test_session.commit()
    test_session.refresh(ingrediente)
    return ingrediente


@pytest.fixture(name="sample_receta")
def sample_receta_fixture(test_session, sample_ingrediente):
    """
    Crea una receta de prueba con items.
    """
    receta = Receta(
        nombre="Café Americano",
        descripcion="Café clásico",
        margen=0.5
    )
    test_session.add(receta)
    test_session.commit()
    test_session.refresh(receta)

    # Agregar item
    item = RecetaItem(
        receta_id=receta.id,
        ingrediente_id=sample_ingrediente.id,
        cantidad=0.02,  # 20g
        merma=0.05
    )
    test_session.add(item)
    test_session.commit()

    return receta


@pytest.fixture(name="sample_cliente")
def sample_cliente_fixture(test_session):
    """
    Crea un cliente de prueba.
    """
    cliente = Cliente(
        nombre="Juan Pérez",
        correo="juan@example.com",
        telefono="555-1234"
    )
    test_session.add(cliente)
    test_session.commit()
    test_session.refresh(cliente)
    return cliente
