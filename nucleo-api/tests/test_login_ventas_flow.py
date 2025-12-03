from typing import Iterator

import pytest
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, SQLModel, create_engine

from sistema.configuracion import obtener_usuario_actual, requiere_permiso
from sistema.entidades import Ingrediente
from sistema.rutas import auth_rutas, recetas_rutas, ventas_rutas, ingredientes_rutas
from sistema.utilidades.seed_inicial import inicializar_datos


@pytest.fixture()
def session(tmp_path) -> Iterator[Session]:
    engine = create_engine(
        f"sqlite:///{tmp_path / 'login_ventas.db'}",
        connect_args={"check_same_thread": False},
    )
    SQLModel.metadata.create_all(engine)

    with Session(engine) as seed_session:
        inicializar_datos(seed_session)

    with Session(engine) as test_session:
        yield test_session


@pytest.mark.anyio
async def test_admin_login_and_register_sale(session: Session):
    form = OAuth2PasswordRequestForm(username="admin", password="admin123")
    token_out = auth_rutas.login(form_data=form, session=session)
    token = token_out.access_token

    usuario = await obtener_usuario_actual(token=token, session=session)
    assert usuario.username == "admin"

    permiso_crear_venta = requiere_permiso("ventas", "crear")
    # Debe pasar sin lanzar excepción gracias al permiso sembrado para ADMIN
    usuario_con_permiso = await permiso_crear_venta(usuario_actual=usuario, session=session)
    assert usuario_con_permiso.id == usuario.id

    cafe = ingredientes_rutas.crear_ingrediente(
        ingrediente=Ingrediente(
            nombre="Café en grano", unidad="kg", costo_por_unidad=12.5, stock=10, min_stock=2
        ),
        session=session,
        usuario_actual=usuario,
    )

    leche = ingredientes_rutas.crear_ingrediente(
        ingrediente=Ingrediente(
            nombre="Leche entera", unidad="l", costo_por_unidad=8.0, stock=8, min_stock=1
        ),
        session=session,
        usuario_actual=usuario,
    )

    receta = recetas_rutas.crear_receta(
        datos=recetas_rutas.RecetaCreate(
            nombre="Latte de prueba",
            descripcion="Receta para flujo de ventas",
            margen=0.25,
            items=[
                recetas_rutas.RecetaItemPayload(ingrediente_id=cafe.id, cantidad=1.0, merma=0.1),
                recetas_rutas.RecetaItemPayload(ingrediente_id=leche.id, cantidad=0.5, merma=0.0),
            ],
        ),
        session=session,
        usuario_actual=usuario,
    )

    venta = ventas_rutas.crear_venta(
        datos=ventas_rutas.VentaCreate(items=[ventas_rutas.ItemVentaCreate(receta_id=receta.id, cantidad=2)]),
        session=session,
        usuario_actual=usuario,
    )

    assert venta.id is not None
    assert venta.total > 0

    ventas = ventas_rutas.listar_ventas(session=session, usuario_actual=usuario, limit=10, offset=0)
    assert any(v.id == venta.id for v in ventas)

    detalle = ventas_rutas.obtener_venta_detallada(venta_id=venta.id, session=session, usuario_actual=usuario)
    assert detalle["id"] == venta.id
    assert detalle["items"][0]["receta_id"] == receta.id
