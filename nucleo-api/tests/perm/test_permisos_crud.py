"""Pruebas CRUD para permisos RBAC."""
import sys
from pathlib import Path

import pytest

BASE_DIR = Path(__file__).resolve().parents[2]
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))


@pytest.fixture(name="auth_headers")
def auth_headers_override(auth_headers):
    """Reutiliza headers de autenticación del admin."""
    return auth_headers


def test_crear_y_listar_permiso_por_rol(client, auth_headers):
    response = client.post(
        "/permisos/rol/GERENTE",
        json={"recurso": "reportes", "accion": "ver"},
        headers=auth_headers,
    )

    assert response.status_code == 201
    data = response.json()
    assert data["rol"] == "GERENTE"
    assert data["recurso"] == "reportes"
    assert data["accion"] == "ver"

    listado = client.get("/permisos/rol/GERENTE", headers=auth_headers)
    assert listado.status_code == 200
    permisos = listado.json()
    assert any(p["recurso"] == "reportes" and p["accion"] == "ver" for p in permisos)


def test_validar_duplicado(client, auth_headers):
    payload = {"recurso": "ventas", "accion": "ver"}
    primera = client.post("/permisos/rol/TESTER", json=payload, headers=auth_headers)
    assert primera.status_code == 201

    duplicado = client.post("/permisos/rol/TESTER", json=payload, headers=auth_headers)
    assert duplicado.status_code == 400
    assert "ya existe" in duplicado.json()["detail"].lower()


def test_eliminar_permiso(client, auth_headers):
    crear = client.post(
        "/permisos/rol/VENDEDOR",
        json={"recurso": "reportes", "accion": "ver"},
        headers=auth_headers,
    )
    assert crear.status_code == 201

    borrar = client.delete(
        "/permisos/rol/VENDEDOR",
        params={"recurso": "reportes", "accion": "ver"},
        headers=auth_headers,
    )
    assert borrar.status_code == 200
    assert "eliminado" in borrar.json()["mensaje"].lower()

    listado = client.get("/permisos/rol/VENDEDOR", headers=auth_headers)
    assert listado.status_code == 200
    assert all(p["recurso"] != "reportes" for p in listado.json())


def test_validar_accion_invalida(client, auth_headers):
    respuesta = client.post(
        "/permisos/rol/GERENTE",
        json={"recurso": "inventario", "accion": "publicar"},
        headers=auth_headers,
    )

    assert respuesta.status_code == 422


def test_validar_recurso_invalido(client, auth_headers):
    respuesta = client.post(
        "/permisos/rol/GERENTE",
        json={"recurso": "desconocido", "accion": "ver"},
        headers=auth_headers,
    )

    assert respuesta.status_code == 422
