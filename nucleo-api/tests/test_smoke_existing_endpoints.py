"""
🧪 SMOKE TESTS - ENDPOINTS EXISTENTES
Tests básicos de humo para validar que todos los endpoints funcionan
"""
import pytest


@pytest.mark.smoke
def test_root_endpoint_ok(client):
    """✅ GET / debe retornar info del sistema"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "proyecto" in data
    assert "version" in data
    assert data["estado"] == "operativo"


@pytest.mark.smoke
def test_health_check_ok(client):
    """✅ GET /salud debe retornar estado saludable"""
    response = client.get("/salud")
    assert response.status_code == 200
    data = response.json()
    assert data["estado"] == "saludable"


@pytest.mark.smoke
def test_login_success(client, admin_user, seed_permisos):
    """✅ POST /auth/login con credenciales correctas debe retornar token"""
    response = client.post(
        "/auth/login",
        data={"username": "admin_test", "password": "admin123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


@pytest.mark.smoke
def test_login_failure(client, admin_user, seed_permisos):
    """❌ POST /auth/login con credenciales incorrectas debe fallar"""
    response = client.post(
        "/auth/login",
        data={"username": "admin_test", "password": "wrong_password"}
    )
    assert response.status_code == 401
    assert "Credenciales incorrectas" in response.json()["detail"]


@pytest.mark.smoke
def test_get_me_authenticated(client, auth_headers):
    """✅ GET /auth/me con token válido debe retornar perfil del usuario"""
    response = client.get("/auth/me", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "admin_test"
    assert data["rol"] == "ADMIN"


@pytest.mark.smoke
def test_get_me_unauthenticated(client):
    """❌ GET /auth/me sin token debe retornar 401"""
    response = client.get("/auth/me")
    assert response.status_code == 401


@pytest.mark.smoke
def test_list_clientes_admin(client, auth_headers, sample_cliente):
    """✅ GET /clientes con usuario autenticado debe retornar lista"""
    response = client.get("/clientes", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1


@pytest.mark.smoke
def test_list_ingredientes_vendedor(client, vendedor_auth_headers, sample_ingrediente):
    """✅ GET /ingredientes con vendedor debe retornar lista (tiene permiso VER)"""
    response = client.get("/ingredientes", headers=vendedor_auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1


@pytest.mark.smoke
def test_list_recetas_admin(client, auth_headers, sample_receta):
    """✅ GET /recetas con admin debe retornar lista con costos calculados"""
    response = client.get("/recetas", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    # Validar que incluye campos calculados
    assert "costo_total" in data[0]
    assert "precio_sugerido" in data[0]


@pytest.mark.smoke
def test_list_ventas_vendedor(client, vendedor_auth_headers):
    """✅ GET /ventas con vendedor debe retornar lista"""
    response = client.get("/ventas", headers=vendedor_auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


@pytest.mark.smoke
def test_list_logs_admin(client, auth_headers):
    """✅ GET /logs con admin debe retornar logs del sistema"""
    response = client.get("/logs", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "total" in data
    assert "logs" in data
    assert isinstance(data["logs"], list)


@pytest.mark.smoke
def test_list_logs_vendedor_forbidden(client, vendedor_auth_headers):
    """❌ GET /logs con vendedor debe retornar 403 (no tiene permiso)"""
    response = client.get("/logs", headers=vendedor_auth_headers)
    assert response.status_code == 403


@pytest.mark.smoke
def test_create_venta_vendedor(client, vendedor_auth_headers, sample_receta):
    """✅ POST /ventas con vendedor debe crear venta exitosamente"""
    payload = {
        "cliente_id": None,
        "sucursal": "Centro",
        "items": [
            {
                "receta_id": sample_receta.id,
                "cantidad": 1.0
            }
        ]
    }
    response = client.post("/ventas", json=payload, headers=vendedor_auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "id" in data
    assert data["total"] > 0


@pytest.mark.smoke
def test_dashboard_admin(client, auth_headers):
    """✅ GET /reportes/dashboard con admin debe retornar estadísticas"""
    response = client.get("/reportes/dashboard", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "ventas_hoy" in data
    assert "ventas_mes" in data
    assert "num_ventas_hoy" in data
    assert "alertas_stock" in data
