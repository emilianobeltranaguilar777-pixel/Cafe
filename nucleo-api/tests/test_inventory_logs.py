"""
🧪 TESTS - INVENTORY LOGS (MODULE 1)
Tests para validar que los eventos de inventario (restock) se registran en audit_logs
"""
import pytest
from sqlmodel import select
from sistema.entidades import AuditLog, Ingrediente


@pytest.mark.integration
def test_restock_creates_log(client, test_session, auth_headers, sample_ingrediente, seed_permisos):
    """✅ Restock de ingrediente debe crear un log de auditoría"""
    # Arrange - capturar stock inicial
    stock_inicial = sample_ingrediente.stock

    # Act - hacer restock (actualización parcial de stock)
    nuevo_stock = stock_inicial + 5.0
    response = client.patch(
        f"/ingredientes/{sample_ingrediente.id}",
        json={"stock": nuevo_stock},
        headers=auth_headers
    )

    # Assert - restock exitoso
    assert response.status_code == 200
    data = response.json()
    assert data["stock"] == nuevo_stock

    # Assert - log de auditoría creado
    logs = test_session.exec(
        select(AuditLog).where(AuditLog.action == "stock_restock")
    ).all()

    assert len(logs) >= 1

    log = logs[-1]  # último log creado
    assert log.entity == "ingrediente"
    assert log.entity_id == sample_ingrediente.id
    assert log.success is True


@pytest.mark.integration
def test_restock_log_has_details(client, test_session, auth_headers, sample_ingrediente, seed_permisos):
    """✅ El log de restock debe contener detalles completos"""
    # Arrange
    stock_inicial = sample_ingrediente.stock
    cantidad_agregada = 10.0
    nuevo_stock = stock_inicial + cantidad_agregada

    # Act - hacer restock
    response = client.patch(
        f"/ingredientes/{sample_ingrediente.id}",
        json={"stock": nuevo_stock},
        headers=auth_headers
    )

    # Assert - restock exitoso
    assert response.status_code == 200

    # Assert - verificar detalles del log
    logs = test_session.exec(
        select(AuditLog).where(
            AuditLog.action == "stock_restock",
            AuditLog.entity_id == sample_ingrediente.id
        )
    ).all()

    assert len(logs) >= 1

    log = logs[-1]
    details = log.get_details()

    # Verificar que tiene los campos requeridos
    assert "ingrediente_nombre" in details
    assert details["ingrediente_nombre"] == sample_ingrediente.nombre

    assert "cantidad_anterior" in details
    assert details["cantidad_anterior"] == stock_inicial

    assert "cantidad_nueva" in details
    assert details["cantidad_nueva"] == nuevo_stock

    assert "cantidad_agregada" in details
    assert details["cantidad_agregada"] == cantidad_agregada
