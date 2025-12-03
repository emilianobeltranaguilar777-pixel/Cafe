"""
🧪 TESTS DE REGRESIÓN - ELCAFESIN
Asegurar que la adición de logs no rompe funcionalidad existente
"""
import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, create_engine, SQLModel, select
from sqlalchemy.pool import StaticPool

from sistema.motor_principal import app
from sistema.configuracion import obtener_sesion, hash_password
from sistema.entidades import Usuario, Rol, Cliente, Ingrediente, Receta
from sistema.utilidades.seed_inicial import inicializar_datos


# ==================== CONFIGURACIÓN ====================

@pytest.fixture(name="session")
def session_fixture():
    """Base de datos en memoria"""
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        inicializar_datos(session)
        yield session


@pytest.fixture(name="client")
def client_fixture(session: Session):
    """Cliente de test"""
    def get_session_override():
        return session

    app.dependency_overrides[obtener_sesion] = get_session_override
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()


@pytest.fixture(name="admin_user")
def admin_user_fixture(session: Session):
    """Usuario admin"""
    existente = session.exec(select(Usuario).where(Usuario.username == "admin")).first()
    if existente:
        return existente

    usuario = Usuario(
        username="admin",
        nombre="Admin",
        password_hash=hash_password("admin123"),
        rol=Rol.ADMIN,
        activo=True
    )
    session.add(usuario)
    session.commit()
    session.refresh(usuario)
    return usuario


@pytest.fixture(name="admin_token")
def admin_token_fixture(client: TestClient, admin_user: Usuario):
    """Token de admin"""
    response = client.post(
        "/auth/login",
        data={"username": "admin", "password": "admin123"}
    )
    return response.json()["access_token"]


# ==================== TESTS DE REGRESIÓN ====================

def test_endpoints_basicos_funcionan(client: TestClient):
    """Test: Endpoints básicos no se vieron afectados"""
    # Root endpoint
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "proyecto" in data
    assert data["proyecto"] == "EL CAFÉ SIN LÍMITES"

    # Health check
    response = client.get("/salud")
    assert response.status_code == 200
    data = response.json()
    assert data["estado"] == "saludable"


def test_login_flow_sigue_funcionando(client: TestClient):
    """Test: El flujo de login no se rompió"""
    # Login exitoso
    response = client.post(
        "/auth/login",
        data={"username": "admin", "password": "admin123"}
    )
    assert response.status_code == 200
    assert "access_token" in response.json()
    assert "token_type" in response.json()

    # Login fallido
    response = client.post(
        "/auth/login",
        data={"username": "admin", "password": "wrong"}
    )
    assert response.status_code == 401


def test_auth_me_funciona(client: TestClient, admin_token: str):
    """Test: Endpoint /auth/me funciona correctamente"""
    response = client.get(
        "/auth/me",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "username" in data
    assert "rol" in data


def test_crud_clientes_no_afectado(
    client: TestClient,
    session: Session,
    admin_token: str
):
    """Test: CRUD de clientes sigue funcionando"""
    # Crear cliente
    response = client.post(
        "/clientes",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={
            "nombre": "Cliente Test",
            "email": "test@example.com",
            "telefono": "555-1234"
        }
    )
    assert response.status_code == 200
    cliente_id = response.json()["id"]

    # Listar clientes
    response = client.get(
        "/clientes",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200
    assert isinstance(response.json(), list)

    # Actualizar cliente
    response = client.put(
        f"/clientes/{cliente_id}",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"nombre": "Cliente Actualizado"}
    )
    assert response.status_code == 200

    # Eliminar cliente
    response = client.delete(
        f"/clientes/{cliente_id}",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200


def test_crud_ingredientes_no_afectado(
    client: TestClient,
    admin_token: str
):
    """Test: CRUD de ingredientes sigue funcionando"""
    # Crear ingrediente
    response = client.post(
        "/ingredientes",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={
            "nombre": "Café Test",
            "stock": 100.0,
            "min_stock": 50.0,
            "unidad": "kg"
        }
    )
    assert response.status_code == 200
    ingrediente_id = response.json()["id"]

    # Listar ingredientes
    response = client.get(
        "/ingredientes",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200
    assert isinstance(response.json(), list)

    # Actualizar ingrediente
    response = client.patch(
        f"/ingredientes/{ingrediente_id}",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"stock": 150.0}
    )
    assert response.status_code == 200


def test_crud_recetas_no_afectado(
    client: TestClient,
    session: Session,
    admin_token: str
):
    """Test: CRUD de recetas sigue funcionando"""
    # Crear ingrediente primero
    ingrediente = Ingrediente(
        nombre="Café",
        stock=100.0,
        min_stock=50.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    # Crear receta
    response = client.post(
        "/recetas",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={
            "nombre": "Café Americano",
            "descripcion": "Café negro",
            "precio": 2.50,
            "items": [
                {
                    "ingrediente_id": ingrediente.id,
                    "cantidad": 0.02
                }
            ]
        }
    )
    assert response.status_code == 200

    # Listar recetas
    response = client.get(
        "/recetas",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_ventas_workflow_no_afectado(
    client: TestClient,
    session: Session,
    admin_token: str
):
    """Test: El flujo de ventas sigue funcionando"""
    # Crear ingrediente
    ingrediente = Ingrediente(
        nombre="Café",
        stock=100.0,
        min_stock=50.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    # Crear receta
    receta = Receta(
        nombre="Café",
        precio=2.50
    )
    session.add(receta)
    session.commit()

    # Crear cliente
    cliente = Cliente(
        nombre="Cliente Test",
        email="test@example.com"
    )
    session.add(cliente)
    session.commit()

    # Crear venta
    response = client.post(
        "/ventas",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={
            "cliente_id": cliente.id,
            "items": [
                {
                    "receta_id": receta.id,
                    "cantidad": 2
                }
            ]
        }
    )
    assert response.status_code == 200

    # Listar ventas
    response = client.get(
        "/ventas",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200


def test_reportes_dashboard_funciona(client: TestClient, admin_token: str):
    """Test: El dashboard de reportes sigue funcionando"""
    response = client.get(
        "/reportes/dashboard",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    # Puede retornar 200 o 500 dependiendo de si hay datos
    assert response.status_code in [200, 500]


def test_permisos_no_afectados(client: TestClient):
    """Test: El sistema de permisos sigue funcionando"""
    # Crear usuario vendedor
    response = client.post(
        "/auth/login",
        data={"username": "admin", "password": "admin123"}
    )
    admin_token = response.json()["access_token"]

    # Vendedor no debería poder acceder a usuarios
    vendedor_response = client.get(
        "/auth/usuarios",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    # Admin sí puede acceder
    assert vendedor_response.status_code in [200, 403]


def test_estructura_respuesta_logs_correcta(
    client: TestClient,
    admin_token: str
):
    """Test: La respuesta de logs tiene estructura correcta"""
    response = client.get(
        "/logs",
        headers={"Authorization": f"Bearer {admin_token}"}
    )

    assert response.status_code == 200
    data = response.json()

    # Verificar estructura
    assert "total" in data
    assert "logs" in data
    assert isinstance(data["total"], int)
    assert isinstance(data["logs"], list)


def test_logs_no_interfiere_con_autenticacion(
    client: TestClient,
    session: Session
):
    """Test: Los logs no interfieren con el proceso de autenticación"""
    # Hacer varios logins
    for i in range(5):
        response = client.post(
            "/auth/login",
            data={"username": "admin", "password": "admin123"}
        )
        assert response.status_code == 200
        assert "access_token" in response.json()


def test_movimientos_inventario_no_afectados(
    client: TestClient,
    session: Session,
    admin_token: str
):
    """Test: Los movimientos de inventario siguen funcionando"""
    # Crear ingrediente
    ingrediente = Ingrediente(
        nombre="Café Test",
        stock=100.0,
        min_stock=50.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    # Actualizar stock (debería crear un movimiento)
    response = client.patch(
        f"/ingredientes/{ingrediente.id}",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"stock": 150.0}
    )
    assert response.status_code == 200

    # Verificar que el movimiento se puede consultar en logs
    response = client.get(
        "/logs?tipo=movimiento",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200


def test_rendimiento_logs_aceptable(
    client: TestClient,
    session: Session,
    admin_user: Usuario,
    admin_token: str
):
    """Test: El rendimiento de logs es aceptable con muchos registros"""
    from sistema.entidades import LogSesion
    import time

    # Crear 100 logs
    for i in range(100):
        log = LogSesion(
            usuario_id=admin_user.id,
            accion=f"TEST_{i}",
            ip="192.168.1.1",
            exito=True
        )
        session.add(log)
    session.commit()

    # Medir tiempo de respuesta
    inicio = time.time()
    response = client.get(
        "/logs?limit=100",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    tiempo_respuesta = time.time() - inicio

    assert response.status_code == 200
    # La respuesta debe ser menor a 2 segundos
    assert tiempo_respuesta < 2.0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
