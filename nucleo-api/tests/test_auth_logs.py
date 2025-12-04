"""
🧪 TESTS - AUTH LOGS (MODULE 1)
Tests para validar que los eventos de autenticación se registran en audit_logs
"""
import pytest
from sqlmodel import select
from sistema.entidades import AuditLog


@pytest.mark.integration
def test_login_success_creates_log(client, test_session, admin_user, seed_permisos):
    """✅ Login exitoso debe crear un log de auditoría"""
    # Act - realizar login
    response = client.post(
        "/auth/login",
        data={"username": "admin_test", "password": "admin123"}
    )

    # Assert - login exitoso
    assert response.status_code == 200
    assert "access_token" in response.json()

    # Assert - log de auditoría creado
    logs = test_session.exec(
        select(AuditLog).where(AuditLog.action == "login_success")
    ).all()

    assert len(logs) >= 1

    log = logs[-1]  # último log creado
    assert log.success is True
    assert log.user_id == admin_user.id

    # Verificar detalles
    details = log.get_details()
    assert "username" in details
    assert details["username"] == "admin_test"
    assert "method" in details
    assert details["method"] == "password"


@pytest.mark.integration
def test_login_failure_creates_log(client, test_session, admin_user, seed_permisos):
    """❌ Login fallido debe crear un log de auditoría"""
    # Act - intentar login con password incorrecta
    response = client.post(
        "/auth/login",
        data={"username": "admin_test", "password": "wrong_password"}
    )

    # Assert - login fallido
    assert response.status_code == 401

    # Assert - log de auditoría creado
    logs = test_session.exec(
        select(AuditLog).where(AuditLog.action == "login_failed")
    ).all()

    assert len(logs) >= 1

    log = logs[-1]  # último log creado
    assert log.success is False

    # Verificar detalles
    details = log.get_details()
    assert "username" in details
    assert details["username"] == "admin_test"


@pytest.mark.integration
def test_logout_creates_log(client, test_session, auth_headers, admin_user, seed_permisos):
    """✅ Logout debe crear un log de auditoría"""
    # Act - realizar logout
    response = client.post("/auth/logout", headers=auth_headers)

    # Assert - logout exitoso
    assert response.status_code == 200

    # Assert - log de auditoría creado
    logs = test_session.exec(
        select(AuditLog).where(AuditLog.action == "logout")
    ).all()

    assert len(logs) >= 1

    log = logs[-1]  # último log creado
    assert log.success is True
    assert log.user_id == admin_user.id
