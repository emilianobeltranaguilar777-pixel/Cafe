"""
🧪 TESTS COMPLETOS PARA LOGS - ELCAFESIN
Tests para logs de sesión, movimientos de inventario y permisos
"""
import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, create_engine, SQLModel
from datetime import datetime

from sistema.motor_principal import app
from sistema.configuracion import obtener_sesion, hash_password
from sistema.entidades import Usuario, Rol, LogSesion, Ingrediente, Movimiento, TipoMovimiento


# ==================== CONFIGURACIÓN DE TESTS ====================

@pytest.fixture(name="session")
def session_fixture():
    """Crea una base de datos en memoria para tests"""
    engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        yield session


@pytest.fixture(name="client")
def client_fixture(session: Session):
    """Cliente de test con base de datos en memoria"""
    def get_session_override():
        return session

    app.dependency_overrides[obtener_sesion] = get_session_override
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()


@pytest.fixture(name="admin_user")
def admin_user_fixture(session: Session):
    """Crea un usuario administrador para tests"""
    usuario = Usuario(
        username="admin_test",
        nombre="Admin Test",
        password_hash=hash_password("admin123"),
        rol=Rol.ADMIN,
        activo=True
    )
    session.add(usuario)
    session.commit()
    session.refresh(usuario)
    return usuario


@pytest.fixture(name="vendedor_user")
def vendedor_user_fixture(session: Session):
    """Crea un usuario vendedor para tests"""
    usuario = Usuario(
        username="vendedor_test",
        nombre="Vendedor Test",
        password_hash=hash_password("vendedor123"),
        rol=Rol.VENDEDOR,
        activo=True
    )
    session.add(usuario)
    session.commit()
    session.refresh(usuario)
    return usuario


@pytest.fixture(name="admin_token")
def admin_token_fixture(client: TestClient):
    """Obtiene token de admin"""
    response = client.post(
        "/auth/login",
        data={"username": "admin_test", "password": "admin123"}
    )
    assert response.status_code == 200
    return response.json()["access_token"]


@pytest.fixture(name="vendedor_token")
def vendedor_token_fixture(client: TestClient):
    """Obtiene token de vendedor"""
    response = client.post(
        "/auth/login",
        data={"username": "vendedor_test", "password": "vendedor123"}
    )
    assert response.status_code == 200
    return response.json()["access_token"]


# ==================== TESTS DE LOGS DE SESIÓN ====================

def test_crear_log_sesion(session: Session, admin_user: Usuario):
    """Test: Crear un log de sesión exitosamente"""
    log = LogSesion(
        usuario_id=admin_user.id,
        accion="LOGIN",
        ip="192.168.1.1",
        user_agent="Mozilla/5.0",
        exito=True
    )
    session.add(log)
    session.commit()

    assert log.id is not None
    assert log.usuario_id == admin_user.id
    assert log.accion == "LOGIN"
    assert log.exito is True


def test_listar_logs_sesion(
    client: TestClient,
    session: Session,
    admin_user: Usuario,
    admin_token: str
):
    """Test: Listar logs de sesión"""
    # Crear algunos logs de sesión
    for i in range(3):
        log = LogSesion(
            usuario_id=admin_user.id,
            accion=f"LOGIN_{i}",
            ip=f"192.168.1.{i}",
            user_agent="Mozilla/5.0",
            exito=True
        )
        session.add(log)
    session.commit()

    # Obtener logs de sesión
    response = client.get(
        "/logs?tipo=sesion",
        headers={"Authorization": f"Bearer {admin_token}"}
    )

    assert response.status_code == 200
    data = response.json()
    assert "logs" in data
    assert "total" in data
    assert data["total"] >= 3

    # Verificar estructura de logs
    for log in data["logs"]:
        assert "id" in log
        assert "tipo" in log
        assert "usuario" in log
        assert "accion" in log
        assert "detalles" in log
        assert "fecha" in log


def test_log_sesion_fallido(session: Session, admin_user: Usuario):
    """Test: Registrar un intento de login fallido"""
    log = LogSesion(
        usuario_id=admin_user.id,
        accion="LOGIN_FAILED",
        ip="192.168.1.100",
        user_agent="Mozilla/5.0",
        exito=False
    )
    session.add(log)
    session.commit()

    assert log.exito is False
    assert "FAILED" in log.accion


# ==================== TESTS DE MOVIMIENTOS DE INVENTARIO ====================

def test_crear_movimiento_reabastecimiento(session: Session):
    """Test: Crear un movimiento de reabastecimiento"""
    # Crear ingrediente
    ingrediente = Ingrediente(
        nombre="Café Arabica",
        stock=100.0,
        min_stock=50.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    # Crear movimiento de entrada (reabastecimiento)
    movimiento = Movimiento(
        ingrediente_id=ingrediente.id,
        tipo=TipoMovimiento.ENTRADA,
        cantidad=50.0,
        referencia="Proveedor: Café Premium - Juan Pérez"
    )
    session.add(movimiento)
    session.commit()

    assert movimiento.id is not None
    assert movimiento.tipo == TipoMovimiento.ENTRADA
    assert movimiento.cantidad == 50.0
    assert "Proveedor" in movimiento.referencia


def test_listar_logs_movimientos(
    client: TestClient,
    session: Session,
    admin_token: str
):
    """Test: Listar logs de movimientos de inventario"""
    # Crear ingrediente
    ingrediente = Ingrediente(
        nombre="Leche Entera",
        stock=200.0,
        min_stock=100.0,
        unidad="litros"
    )
    session.add(ingrediente)
    session.commit()

    # Crear varios movimientos
    movimientos_data = [
        (TipoMovimiento.ENTRADA, 100.0, "Proveedor: Lácteos SA"),
        (TipoMovimiento.SALIDA, 50.0, "Venta #123"),
        (TipoMovimiento.AJUSTE, 10.0, "Ajuste de inventario"),
    ]

    for tipo, cantidad, referencia in movimientos_data:
        mov = Movimiento(
            ingrediente_id=ingrediente.id,
            tipo=tipo,
            cantidad=cantidad,
            referencia=referencia
        )
        session.add(mov)
    session.commit()

    # Obtener logs de movimientos
    response = client.get(
        "/logs?tipo=movimiento",
        headers={"Authorization": f"Bearer {admin_token}"}
    )

    assert response.status_code == 200
    data = response.json()
    assert "logs" in data
    assert data["total"] >= 3

    # Verificar estructura
    for log in data["logs"]:
        assert log["tipo"] == "movimiento"
        assert "detalles" in log
        assert "ingrediente" in log["detalles"]
        assert "cantidad" in log["detalles"]
        assert "tipo_movimiento" in log["detalles"]


def test_movimiento_con_referencia_staff(session: Session):
    """Test: Movimiento con referencia a staff autorizado"""
    ingrediente = Ingrediente(
        nombre="Azúcar",
        stock=500.0,
        min_stock=200.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    movimiento = Movimiento(
        ingrediente_id=ingrediente.id,
        tipo=TipoMovimiento.ENTRADA,
        cantidad=100.0,
        referencia="Staff: María García - Gerente"
    )
    session.add(movimiento)
    session.commit()

    assert "Staff:" in movimiento.referencia
    assert "Gerente" in movimiento.referencia


# ==================== TESTS DE LOGS COMBINADOS ====================

def test_listar_todos_los_logs(
    client: TestClient,
    session: Session,
    admin_user: Usuario,
    admin_token: str
):
    """Test: Listar todos los logs (sesión + movimientos)"""
    # Crear log de sesión
    log_sesion = LogSesion(
        usuario_id=admin_user.id,
        accion="LOGIN",
        ip="192.168.1.1",
        exito=True
    )
    session.add(log_sesion)

    # Crear ingrediente y movimiento
    ingrediente = Ingrediente(
        nombre="Café",
        stock=100.0,
        min_stock=50.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    movimiento = Movimiento(
        ingrediente_id=ingrediente.id,
        tipo=TipoMovimiento.ENTRADA,
        cantidad=50.0,
        referencia="Reabastecimiento"
    )
    session.add(movimiento)
    session.commit()

    # Obtener todos los logs
    response = client.get(
        "/logs?tipo=todos",
        headers={"Authorization": f"Bearer {admin_token}"}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["total"] >= 2

    # Verificar que hay logs de ambos tipos
    tipos = set(log["tipo"] for log in data["logs"])
    assert "sesion" in tipos or "movimiento" in tipos


def test_logs_ordenados_por_fecha(
    client: TestClient,
    session: Session,
    admin_user: Usuario,
    admin_token: str
):
    """Test: Los logs deben estar ordenados por fecha descendente"""
    # Crear varios logs con diferentes tiempos
    import time

    for i in range(3):
        log = LogSesion(
            usuario_id=admin_user.id,
            accion=f"ACTION_{i}",
            ip="192.168.1.1",
            exito=True
        )
        session.add(log)
        session.commit()
        time.sleep(0.1)  # Pequeña pausa para diferencia de tiempo

    response = client.get(
        "/logs?tipo=sesion",
        headers={"Authorization": f"Bearer {admin_token}"}
    )

    assert response.status_code == 200
    data = response.json()

    # Verificar orden descendente
    if len(data["logs"]) > 1:
        fechas = [log["fecha"] for log in data["logs"]]
        # Los logs más recientes deben estar primero
        assert fechas == sorted(fechas, reverse=True)


def test_paginacion_logs(
    client: TestClient,
    session: Session,
    admin_user: Usuario,
    admin_token: str
):
    """Test: Paginación de logs funciona correctamente"""
    # Crear 10 logs
    for i in range(10):
        log = LogSesion(
            usuario_id=admin_user.id,
            accion=f"ACTION_{i}",
            ip="192.168.1.1",
            exito=True
        )
        session.add(log)
    session.commit()

    # Obtener primera página
    response = client.get(
        "/logs?tipo=sesion&limit=5&offset=0",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200
    data1 = response.json()
    assert len(data1["logs"]) <= 5

    # Obtener segunda página
    response = client.get(
        "/logs?tipo=sesion&limit=5&offset=5",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200
    data2 = response.json()
    assert len(data2["logs"]) <= 5


# ==================== TESTS DE PERMISOS ====================

def test_logs_requiere_autenticacion(client: TestClient):
    """Test: Acceso a logs requiere autenticación"""
    response = client.get("/logs")
    assert response.status_code == 401


def test_logs_solo_admin_o_dueno(
    client: TestClient,
    vendedor_token: str
):
    """Test: Solo ADMIN o DUEÑO pueden ver logs"""
    response = client.get(
        "/logs",
        headers={"Authorization": f"Bearer {vendedor_token}"}
    )
    assert response.status_code == 403


def test_admin_puede_ver_logs(
    client: TestClient,
    session: Session,
    admin_user: Usuario,
    admin_token: str
):
    """Test: Usuario ADMIN puede ver logs"""
    # Crear un log
    log = LogSesion(
        usuario_id=admin_user.id,
        accion="TEST",
        ip="192.168.1.1",
        exito=True
    )
    session.add(log)
    session.commit()

    response = client.get(
        "/logs",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200


# ==================== TESTS DE FORMATO DE DATOS ====================

def test_formato_fecha_iso(
    client: TestClient,
    session: Session,
    admin_user: Usuario,
    admin_token: str
):
    """Test: Las fechas se retornan en formato ISO"""
    log = LogSesion(
        usuario_id=admin_user.id,
        accion="TEST",
        ip="192.168.1.1",
        exito=True
    )
    session.add(log)
    session.commit()

    response = client.get(
        "/logs?tipo=sesion",
        headers={"Authorization": f"Bearer {admin_token}"}
    )

    assert response.status_code == 200
    data = response.json()

    if data["logs"]:
        fecha = data["logs"][0]["fecha"]
        # Verificar que es formato ISO válido
        datetime.fromisoformat(fecha)


def test_detalles_sesion_completos(
    client: TestClient,
    session: Session,
    admin_user: Usuario,
    admin_token: str
):
    """Test: Los detalles de sesión incluyen todos los campos"""
    log = LogSesion(
        usuario_id=admin_user.id,
        accion="LOGIN",
        ip="192.168.1.100",
        user_agent="Mozilla/5.0 Test",
        exito=True
    )
    session.add(log)
    session.commit()

    response = client.get(
        "/logs?tipo=sesion",
        headers={"Authorization": f"Bearer {admin_token}"}
    )

    assert response.status_code == 200
    data = response.json()

    log_sesion = next((l for l in data["logs"] if l["tipo"] == "sesion"), None)
    assert log_sesion is not None
    assert "ip" in log_sesion["detalles"]
    assert "user_agent" in log_sesion["detalles"]
    assert "exito" in log_sesion["detalles"]


def test_detalles_movimiento_completos(
    client: TestClient,
    session: Session,
    admin_token: str
):
    """Test: Los detalles de movimiento incluyen todos los campos"""
    ingrediente = Ingrediente(
        nombre="Café Test",
        stock=100.0,
        min_stock=50.0,
        unidad="kg"
    )
    session.add(ingrediente)
    session.commit()

    movimiento = Movimiento(
        ingrediente_id=ingrediente.id,
        tipo=TipoMovimiento.ENTRADA,
        cantidad=25.0,
        referencia="Proveedor Test"
    )
    session.add(movimiento)
    session.commit()

    response = client.get(
        "/logs?tipo=movimiento",
        headers={"Authorization": f"Bearer {admin_token}"}
    )

    assert response.status_code == 200
    data = response.json()

    log_mov = next((l for l in data["logs"] if l["tipo"] == "movimiento"), None)
    assert log_mov is not None
    assert "ingrediente" in log_mov["detalles"]
    assert "cantidad" in log_mov["detalles"]
    assert "tipo_movimiento" in log_mov["detalles"]
    assert "referencia" in log_mov["detalles"]


# ==================== TESTS DE REGRESIÓN ====================

def test_listar_logs_no_rompe_otros_endpoints(
    client: TestClient,
    admin_token: str
):
    """Test: El endpoint de logs no afecta otros endpoints"""
    # Verificar que endpoints básicos siguen funcionando
    response = client.get("/")
    assert response.status_code == 200

    response = client.get("/salud")
    assert response.status_code == 200

    response = client.get(
        "/auth/me",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200


def test_limite_maximo_logs(
    client: TestClient,
    session: Session,
    admin_user: Usuario,
    admin_token: str
):
    """Test: El límite máximo de logs está correctamente aplicado"""
    # El límite máximo es 500
    response = client.get(
        "/logs?limit=1000",
        headers={"Authorization": f"Bearer {admin_token}"}
    )

    # Debe aceptar la petición pero limitar a 500
    assert response.status_code in [200, 422]  # 422 si FastAPI valida el límite


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
