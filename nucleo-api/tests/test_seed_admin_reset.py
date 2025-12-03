from typing import Iterator

import pytest
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, SQLModel, create_engine, select

from sistema.configuracion import verificar_password
from sistema.entidades import Usuario, Rol
from sistema.rutas import auth_rutas
from sistema.utilidades.seed_inicial import inicializar_datos


@pytest.fixture()
def session(tmp_path) -> Iterator[Session]:
    engine = create_engine(
        f"sqlite:///{tmp_path / 'seed_reset.db'}",
        connect_args={"check_same_thread": False},
    )
    SQLModel.metadata.create_all(engine)

    with Session(engine) as seed_session:
        seed_session.add(
            Usuario(
                username="admin",
                nombre="Admin previo",
                password_hash="hash_invalido",
                rol=Rol.VENDEDOR,
                activo=False,
            )
        )
        seed_session.commit()

    with Session(engine) as test_session:
        yield test_session


def test_admin_reset_to_default(session: Session):
    inicializar_datos(session)

    admin = session.exec(select(Usuario).where(Usuario.username == "admin")).one()

    assert admin.rol == Rol.ADMIN
    assert admin.activo is True
    assert verificar_password("admin123", admin.password_hash)

    form = OAuth2PasswordRequestForm(username="admin", password="admin123")
    token = auth_rutas.login(form_data=form, session=session)
    assert token.access_token
