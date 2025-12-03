"""Pruebas directas sobre el flujo CRUD de recetas con ingredientes."""
from pathlib import Path
import sys
from typing import Iterator

from sqlmodel import Session, SQLModel, create_engine

BASE_DIR = Path(__file__).resolve().parents[1]
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))

from sistema.entidades import Ingrediente, Rol  # noqa: E402
from sistema.rutas import recetas_rutas  # noqa: E402

engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})


def reset_db():
    SQLModel.metadata.drop_all(engine)
    SQLModel.metadata.create_all(engine)


def get_session() -> Iterator[Session]:
    with Session(engine) as session:
        yield session


class DummyUser:
    def __init__(self):
        self.id = 999
        self.username = "tester"
        self.rol = Rol.ADMIN
        self.activo = True


def test_recetas_crud_flow():
    reset_db()
    dummy = DummyUser()

    with Session(engine) as session:
        cafe = Ingrediente(
            nombre="Café espresso",
            unidad="kg",
            costo_por_unidad=10.0,
            stock=5,
            min_stock=2,
        )
        leche = Ingrediente(
            nombre="Leche entera",
            unidad="l",
            costo_por_unidad=5.0,
            stock=1,
            min_stock=2,
        )
        session.add_all([cafe, leche])
        session.commit()
        session.refresh(cafe)
        session.refresh(leche)

        creada = recetas_rutas.crear_receta(
            datos=recetas_rutas.RecetaCreate(
                nombre="Moka clásico",
                descripcion="Espresso con leche y cacao",
                margen=0.5,
                items=[
                    recetas_rutas.RecetaItemPayload(ingrediente_id=cafe.id, cantidad=1.5, merma=0.1),
                    recetas_rutas.RecetaItemPayload(ingrediente_id=leche.id, cantidad=0.5),
                ],
            ),
            session=session,
            usuario_actual=dummy,
        )

        assert creada.id is not None
        assert creada.costo_total == 19.0
        assert any(item.ingrediente_id == leche.id for item in creada.items)

        listado = recetas_rutas.listar_recetas(session=session, usuario_actual=dummy)
        assert len(listado) == 1
        assert listado[0].precio_sugerido == 28.5

        actualizada = recetas_rutas.actualizar_receta(
            receta_id=creada.id,
            datos=recetas_rutas.RecetaUpdate(
                nombre="Moka ligero",
                descripcion="Espresso con leche ligera",
                margen=0.2,
                items=[recetas_rutas.RecetaItemPayload(ingrediente_id=leche.id, cantidad=0.75)],
            ),
            session=session,
            usuario_actual=dummy,
        )

        assert actualizada.nombre == "Moka ligero"
        assert actualizada.costo_total == 3.75
        assert len(actualizada.items) == 1
        assert actualizada.items[0].min_stock == leche.min_stock

        recetas_rutas.eliminar_receta(
            receta_id=creada.id,
            session=session,
            usuario_actual=dummy,
        )

        listado_final = recetas_rutas.listar_recetas(session=session, usuario_actual=dummy)
        assert listado_final == []
