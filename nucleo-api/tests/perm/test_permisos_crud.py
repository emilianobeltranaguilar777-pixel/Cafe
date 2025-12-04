"""
🧪 TESTS CRUD DE PERMISOS RBAC (MÓDULO 5)
"""
import pytest
from sqlmodel import Session, select

from sistema.entidades import PermisoRol, Accion


@pytest.fixture
def rol_objetivo():
    return "GERENTE"


def test_crear_permiso_para_rol(client, auth_headers, rol_objetivo):
    payload = {"recurso": "clientes", "accion": Accion.VER}

    response = client.post(
        f"/permisos/rol/{rol_objetivo}", json=payload, headers=auth_headers
    )

    assert response.status_code == 201
    data = response.json()
    assert data["rol"] == rol_objetivo
    assert data["recurso"] == "clientes"
    assert data["accion"] == Accion.VER


def test_listar_permisos_por_rol(client, auth_headers, rol_objetivo, test_session: Session):
    permiso = PermisoRol(rol=rol_objetivo, recurso="ventas", accion=Accion.VER)
    test_session.add(permiso)
    test_session.commit()

    response = client.get(f"/permisos/rol/{rol_objetivo}", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert any(p["recurso"] == "ventas" and p["accion"] == Accion.VER for p in data)


def test_eliminar_permiso(client, auth_headers, rol_objetivo, test_session: Session):
    permiso = PermisoRol(rol=rol_objetivo, recurso="inventario", accion=Accion.EDITAR)
    test_session.add(permiso)
    test_session.commit()

    response = client.delete(
        f"/permisos/rol/{rol_objetivo}",
        json={"recurso": "inventario", "accion": Accion.EDITAR},
        headers=auth_headers,
    )

    assert response.status_code == 200
    data = response.json()
    assert data["mensaje"] == "Permiso eliminado"

    restante = test_session.exec(
        select(PermisoRol).where(
            PermisoRol.rol == rol_objetivo,
            PermisoRol.recurso == "inventario",
            PermisoRol.accion == Accion.EDITAR,
        )
    ).first()
    assert restante is None


def test_crear_permiso_duplicado(client, auth_headers, rol_objetivo):
    payload = {"recurso": "clientes", "accion": Accion.VER}

    primera = client.post(f"/permisos/rol/{rol_objetivo}", json=payload, headers=auth_headers)
    assert primera.status_code == 201

    duplicado = client.post(
        f"/permisos/rol/{rol_objetivo}", json=payload, headers=auth_headers
    )

    assert duplicado.status_code == 400
    assert "ya existe" in duplicado.json()["detail"]


def test_crear_permiso_accion_invalida(client, auth_headers, rol_objetivo):
    response = client.post(
        f"/permisos/rol/{rol_objetivo}",
        json={"recurso": "ventas", "accion": "navegar"},
        headers=auth_headers,
    )

    assert response.status_code == 422


def test_crear_permiso_recurso_invalido(client, auth_headers, rol_objetivo):
    response = client.post(
        f"/permisos/rol/{rol_objetivo}",
        json={"recurso": "galaxias", "accion": "ver"},
        headers=auth_headers,
    )

    assert response.status_code == 422


def test_no_afecta_permisos_seed(client, auth_headers, seed_permisos):
    response = client.get("/permisos/rol/ADMIN", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert any(p["recurso"] == "usuarios" for p in data)
