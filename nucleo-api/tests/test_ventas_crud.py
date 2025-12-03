"""Pruebas de ventas sobre recetas existentes."""
from pathlib import Path
import sys
from typing import Iterator
import math

from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy.pool import StaticPool

BASE_DIR = Path(__file__).resolve().parents[1]
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))

from sistema.entidades import Ingrediente, Rol  # noqa: E402
from sistema.rutas import recetas_rutas, ventas_rutas  # noqa: E402

engine = create_engine(
    "sqlite:///:memory:",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)


def reset_db():
    SQLModel.metadata.drop_all(engine)
    SQLModel.metadata.create_all(engine)


def get_session() -> Iterator[Session]:
    with Session(engine) as session:
        yield session


class DummyUser:
    def __init__(self):
        self.id = 777
        self.username = "ventas-tester"
        self.rol = Rol.ADMIN
        self.activo = True


def test_venta_con_receta_en_historial():
    reset_db()
    dummy = DummyUser()

    with Session(engine) as session:
        cafe = Ingrediente(
            nombre="Café", unidad="kg", costo_por_unidad=10.0, stock=10, min_stock=2
        )
        leche = Ingrediente(
            nombre="Leche", unidad="l", costo_por_unidad=5.0, stock=5, min_stock=1
        )
        session.add_all([cafe, leche])
        session.commit()
        session.refresh(cafe)
        session.refresh(leche)

        receta = recetas_rutas.crear_receta(
            datos=recetas_rutas.RecetaCreate(
                nombre="Latte", descripcion="Café con leche", margen=0.2,
                items=[
                    recetas_rutas.RecetaItemPayload(ingrediente_id=cafe.id, cantidad=1.0, merma=0.1),
                    recetas_rutas.RecetaItemPayload(ingrediente_id=leche.id, cantidad=0.5),
                ],
            ),
            session=session,
            usuario_actual=dummy,
        )

        venta = ventas_rutas.crear_venta(
            datos=ventas_rutas.VentaCreate(
                sucursal="Centro",
                items=[ventas_rutas.ItemVentaCreate(receta_id=receta.id, cantidad=2)],
            ),
            session=session,
            usuario_actual=dummy,
        )

        assert venta.id is not None
        assert math.isclose(venta.total, 32.4, rel_tol=1e-5)

        session.refresh(cafe)
        session.refresh(leche)
        assert math.isclose(cafe.stock, 7.8, rel_tol=1e-5)
        assert math.isclose(leche.stock, 4.0, rel_tol=1e-5)

        ventas = ventas_rutas.listar_ventas(session=session, usuario_actual=dummy, limit=20, offset=0)
        assert len(ventas) == 1
        assert ventas[0].total == venta.total

        detalle = ventas_rutas.obtener_venta_detallada(
            venta_id=venta.id, session=session, usuario_actual=dummy
        )
        assert detalle["id"] == venta.id
        assert detalle["items"][0]["receta_id"] == receta.id
        assert math.isclose(detalle["items"][0]["subtotal"], venta.total, rel_tol=1e-5)
