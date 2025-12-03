"""Pruebas directas sobre el flujo CRUD de ingredientes."""
from pathlib import Path
import sys
from typing import Iterator

from sqlmodel import Session, SQLModel, create_engine

BASE_DIR = Path(__file__).resolve().parents[1]
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))

from sistema.entidades.ingrediente import Ingrediente  # noqa: E402
from sistema.entidades.usuario import Rol  # noqa: E402
from sistema.rutas import ingredientes_rutas  # noqa: E402

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


def test_ingredientes_crud_flow():
    reset_db()
    dummy = DummyUser()

    with Session(engine) as session:
        creado = ingredientes_rutas.crear_ingrediente(
            ingrediente=Ingrediente(
                nombre="Cacao en polvo",
                unidad="kg",
                costo_por_unidad=12.5,
                stock=8,
                min_stock=2,
            ),
            session=session,
            usuario_actual=dummy,
        )

        assert creado.id is not None
        assert creado.nombre == "Cacao en polvo"

        listado = ingredientes_rutas.listar_ingredientes(
            session=session,
            usuario_actual=dummy,
            limit=100,
            offset=0,
        )
        assert any(item.id == creado.id for item in listado)

        actualizado = ingredientes_rutas.actualizar_ingrediente(
            ingrediente_id=creado.id,
            datos=Ingrediente(
                nombre="Cacao premium",
                unidad="kg",
                costo_por_unidad=12.5,
                stock=10,
                min_stock=2,
            ),
            session=session,
            usuario_actual=dummy,
        )

        assert actualizado.nombre == "Cacao premium"
        assert actualizado.stock == 10

        ingredientes_rutas.eliminar_ingrediente(
            ingrediente_id=creado.id,
            session=session,
            usuario_actual=dummy,
        )

        listado_final = ingredientes_rutas.listar_ingredientes(
            session=session,
            usuario_actual=dummy,
            limit=100,
            offset=0,
        )
        assert all(item.id != creado.id for item in listado_final)
