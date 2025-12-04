"""
🧪 TESTS CRUD DE PERMISOS POR USUARIO (MÓDULO 6)
"""
import pytest
from sqlmodel import Session, select

from sistema.entidades import UsuarioPermiso, Accion, Ingrediente


@pytest.fixture
def usuario_objetivo(vendedor_user):
    return vendedor_user


def test_crear_permiso_usuario(client, auth_headers, usuario_objetivo):
    payload = {"recurso": "inventario", "accion": Accion.EDITAR, "permitido": True}

    response = client.post(
        f"/permisos/usuario/{usuario_objetivo.id}", json=payload, headers=auth_headers
    )

    assert response.status_code == 201
    data = response.json()
    assert data["usuario_id"] == usuario_objetivo.id
    assert data["recurso"] == "inventario"
    assert data["accion"] == Accion.EDITAR
    assert data["permitido"] is True


def test_listar_permisos_usuario(client, auth_headers, usuario_objetivo, test_session: Session):
    permiso = UsuarioPermiso(
        usuario_id=usuario_objetivo.id,
        recurso="inventario",
        accion=Accion.VER,
        permitido=False,
    )
    test_session.add(permiso)
    test_session.commit()

    response = client.get(
        f"/permisos/usuario/{usuario_objetivo.id}", headers=auth_headers
    )

    assert response.status_code == 200
    data = response.json()
    assert any(p["recurso"] == "inventario" and p["permitido"] is False for p in data)


def test_eliminar_permiso_usuario(client, auth_headers, usuario_objetivo, test_session: Session):
    permiso = UsuarioPermiso(
        usuario_id=usuario_objetivo.id,
        recurso="inventario",
        accion=Accion.CREAR,
        permitido=True,
    )
    test_session.add(permiso)
    test_session.commit()

    response = client.delete(
        f"/permisos/usuario/{usuario_objetivo.id}",
        json={"recurso": "inventario", "accion": Accion.CREAR, "permitido": True},
        headers=auth_headers,
    )

    assert response.status_code == 200
    data = response.json()
    assert data["mensaje"] == "Permiso eliminado"

    restante = test_session.exec(
        select(UsuarioPermiso).where(
            UsuarioPermiso.usuario_id == usuario_objetivo.id,
            UsuarioPermiso.recurso == "inventario",
            UsuarioPermiso.accion == Accion.CREAR,
        )
    ).first()
    assert restante is None


def test_override_allow_anula_deny_por_rol(
    client,
    auth_headers,
    vendedor_auth_headers,
    usuario_objetivo,
    sample_ingrediente: Ingrediente,
):
    update_payload = {
        "nombre": sample_ingrediente.nombre,
        "unidad": sample_ingrediente.unidad,
        "costo_por_unidad": sample_ingrediente.costo_por_unidad,
        "stock": sample_ingrediente.stock + 1,
        "min_stock": sample_ingrediente.min_stock,
        "proveedor_id": sample_ingrediente.proveedor_id,
    }

    # Sin override debería ser denegado (VENDEDOR no puede editar inventario)
    sin_override = client.put(
        f"/ingredientes/{sample_ingrediente.id}",
        json=update_payload,
        headers=vendedor_auth_headers,
    )
    assert sin_override.status_code == 403

    # Crear override que permita editar inventario
    crear_override = client.post(
        f"/permisos/usuario/{usuario_objetivo.id}",
        json={"recurso": "inventario", "accion": Accion.EDITAR, "permitido": True},
        headers=auth_headers,
    )
    assert crear_override.status_code == 201

    con_override = client.put(
        f"/ingredientes/{sample_ingrediente.id}",
        json=update_payload,
        headers=vendedor_auth_headers,
    )
    assert con_override.status_code == 200
    assert con_override.json()["stock"] == update_payload["stock"]


def test_override_deny_anula_allow_por_rol(
    client,
    auth_headers,
    vendedor_auth_headers,
    usuario_objetivo,
):
    # VENDEDOR puede ver inventario por rol
    permitido_por_rol = client.get("/ingredientes", headers=vendedor_auth_headers)
    assert permitido_por_rol.status_code == 200

    # Override que deniega VER inventario
    crear_override = client.post(
        f"/permisos/usuario/{usuario_objetivo.id}",
        json={"recurso": "inventario", "accion": Accion.VER, "permitido": False},
        headers=auth_headers,
    )
    assert crear_override.status_code == 201

    denegado = client.get("/ingredientes", headers=vendedor_auth_headers)
    assert denegado.status_code == 403


def test_validacion_accion_y_recurso(client, auth_headers, usuario_objetivo):
    recurso_invalido = client.post(
        f"/permisos/usuario/{usuario_objetivo.id}",
        json={"recurso": "galaxias", "accion": "ver", "permitido": True},
        headers=auth_headers,
    )
    assert recurso_invalido.status_code == 422

    accion_invalida = client.post(
        f"/permisos/usuario/{usuario_objetivo.id}",
        json={"recurso": "ventas", "accion": "navegar", "permitido": True},
        headers=auth_headers,
    )
    assert accion_invalida.status_code == 422


def test_seed_admin_se_mantiene(client, auth_headers, seed_permisos):
    response = client.get("/permisos/rol/ADMIN", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert any(p["recurso"] == "usuarios" for p in data)
