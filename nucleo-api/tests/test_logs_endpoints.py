"""
🧪 TESTS - LOGS ENDPOINTS (MODULE 1)
Tests para el endpoint /logs y su comportamiento
"""
import pytest
from datetime import datetime, timedelta
from sistema.entidades import AuditLog


@pytest.mark.integration
def test_get_logs_no_filters(client, test_session, auth_headers):
    """✅ GET /logs sin filtros debe retornar todos los logs"""
    # Arrange: crear algunos logs
    log1 = AuditLog(action="login_success", user_id=1, success=True)
    log2 = AuditLog(action="login_failed", user_id=None, success=False)
    log3 = AuditLog(action="stock_restock", entity="ingrediente", entity_id=1, success=True)

    test_session.add(log1)
    test_session.add(log2)
    test_session.add(log3)
    test_session.commit()

    # Act
    response = client.get("/logs", headers=auth_headers)

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert "total" in data
    assert "logs" in data
    assert data["total"] >= 3
    assert len(data["logs"]) >= 3


@pytest.mark.integration
def test_get_logs_filter_by_action(client, test_session, auth_headers):
    """✅ GET /logs?action=login_success debe filtrar por acción"""
    # Arrange
    log1 = AuditLog(action="login_success", user_id=1, success=True)
    log2 = AuditLog(action="login_failed", user_id=None, success=False)
    log3 = AuditLog(action="login_success", user_id=2, success=True)

    test_session.add(log1)
    test_session.add(log2)
    test_session.add(log3)
    test_session.commit()

    # Act
    response = client.get("/logs?action=login_success", headers=auth_headers)

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 2
    for log in data["logs"]:
        assert log["action"] == "login_success"


@pytest.mark.integration
def test_get_logs_filter_by_entity(client, test_session, auth_headers):
    """✅ GET /logs?entity=ingrediente debe filtrar por entidad"""
    # Arrange
    log1 = AuditLog(action="stock_restock", entity="ingrediente", entity_id=1, success=True)
    log2 = AuditLog(action="login_success", entity=None, user_id=1, success=True)
    log3 = AuditLog(action="stock_restock", entity="ingrediente", entity_id=2, success=True)

    test_session.add(log1)
    test_session.add(log2)
    test_session.add(log3)
    test_session.commit()

    # Act
    response = client.get("/logs?entity=ingrediente", headers=auth_headers)

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 2
    for log in data["logs"]:
        assert log["entity"] == "ingrediente"


@pytest.mark.integration
def test_get_logs_filter_by_user(client, test_session, auth_headers, admin_user):
    """✅ GET /logs?user_id=X debe filtrar por usuario"""
    # Arrange
    log1 = AuditLog(action="login_success", user_id=admin_user.id, success=True)
    log2 = AuditLog(action="login_failed", user_id=None, success=False)
    log3 = AuditLog(action="logout", user_id=admin_user.id, success=True)

    test_session.add(log1)
    test_session.add(log2)
    test_session.add(log3)
    test_session.commit()

    # Act
    response = client.get(f"/logs?user_id={admin_user.id}", headers=auth_headers)

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 2
    for log in data["logs"]:
        assert log["user_id"] == admin_user.id


@pytest.mark.integration
def test_get_logs_filter_by_date_range(client, test_session, auth_headers):
    """✅ GET /logs?date_from=...&date_to=... debe filtrar por rango de fechas"""
    # Arrange
    now = datetime.utcnow()
    yesterday = now - timedelta(days=1)
    two_days_ago = now - timedelta(days=2)

    log1 = AuditLog(action="login_success", user_id=1, success=True)
    log1.timestamp = two_days_ago
    log2 = AuditLog(action="login_success", user_id=2, success=True)
    log2.timestamp = yesterday
    log3 = AuditLog(action="login_success", user_id=3, success=True)
    log3.timestamp = now

    test_session.add(log1)
    test_session.add(log2)
    test_session.add(log3)
    test_session.commit()

    # Act - filtrar solo yesterday
    date_from = (yesterday - timedelta(hours=1)).isoformat()
    date_to = (yesterday + timedelta(hours=1)).isoformat()
    response = client.get(f"/logs?date_from={date_from}&date_to={date_to}", headers=auth_headers)

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 1


@pytest.mark.integration
def test_get_logs_pagination(client, test_session, auth_headers):
    """✅ GET /logs con limit y offset debe paginar correctamente"""
    # Arrange: crear 10 logs
    for i in range(10):
        log = AuditLog(action=f"action_{i}", user_id=1, success=True)
        test_session.add(log)
    test_session.commit()

    # Act - primera página
    response1 = client.get("/logs?limit=5&offset=0", headers=auth_headers)
    # Act - segunda página
    response2 = client.get("/logs?limit=5&offset=5", headers=auth_headers)

    # Assert
    assert response1.status_code == 200
    assert response2.status_code == 200

    data1 = response1.json()
    data2 = response2.json()

    assert len(data1["logs"]) == 5
    assert len(data2["logs"]) == 5
    assert data1["total"] == 10
    assert data2["total"] == 10


@pytest.mark.integration
def test_logs_require_permission(client, vendedor_auth_headers):
    """❌ GET /logs sin permisos debe retornar 403"""
    # Act
    response = client.get("/logs", headers=vendedor_auth_headers)

    # Assert
    assert response.status_code == 403
