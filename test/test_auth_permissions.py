import asyncio
import sys
import unittest
from pathlib import Path
from typing import Dict

from fastapi import HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, SQLModel, create_engine, select

# Asegurar que la carpeta "nucleo-api" esté en el PYTHONPATH
REPO_ROOT = Path(__file__).resolve().parents[1]
NUCLEO_DIR = REPO_ROOT / "nucleo-api"
if str(NUCLEO_DIR) not in sys.path:
    sys.path.insert(0, str(NUCLEO_DIR))

from sistema.motor_principal import app  # noqa: E402
from sistema.configuracion import (  # noqa: E402
    base_datos,
    hash_password,
    obtener_usuario_actual,
    requiere_permiso,
    requiere_roles,
)
from sistema.configuracion.seguridad import decodificar_token  # noqa: E402
from sistema.utilidades.seed_inicial import inicializar_datos  # noqa: E402
from sistema.entidades import (  # noqa: E402
    Usuario,
    Rol,
    Ingrediente,
    Receta,
    RecetaItem,
    Cliente,
    LogSesion,
)
from sistema.rutas import (  # noqa: E402
    auth_rutas,
    clientes_rutas,
    ingredientes_rutas,
    logs_rutas,
    reportes_rutas,
    ventas_rutas,
)


class APISmokeTests(unittest.TestCase):
    """Recorridos básicos para validar login, ventas, clientes y permisos."""

    @classmethod
    def setUpClass(cls):
        cls.engine = create_engine(
            "sqlite://",
            echo=False,
            connect_args={"check_same_thread": False},
        )
        base_datos.engine = cls.engine
        SQLModel.metadata.create_all(cls.engine)

        with Session(cls.engine) as session:
            inicializar_datos(session)
            cls.vendor = cls._ensure_vendor(session)
            cls.ingredient_id, cls.recipe_id = cls._ensure_recipe(session)
            cls.log_entries = cls._seed_logs(session)

    @classmethod
    def tearDownClass(cls):
        cls.engine.dispose()

    @staticmethod
    def _ensure_vendor(session: Session) -> Usuario:
        vendor = session.exec(
            select(Usuario).where(Usuario.username == "vendedor")
        ).first()
        if vendor:
            return vendor

        vendor = Usuario(
            username="vendedor",
            nombre="Vendedor Demo",
            password_hash=hash_password("venta123"),
            rol=Rol.VENDEDOR,
            activo=True,
        )
        session.add(vendor)
        session.commit()
        session.refresh(vendor)
        return vendor

    @staticmethod
    def _ensure_recipe(session: Session) -> tuple[int, int]:
        ingrediente = session.exec(
            select(Ingrediente).where(Ingrediente.nombre == "Café espresso")
        ).first()
        if not ingrediente:
            ingrediente = Ingrediente(
                nombre="Café espresso",
                unidad="g",
                costo_por_unidad=0.5,
                stock=500.0,
                min_stock=10.0,
            )
            session.add(ingrediente)
            session.commit()
            session.refresh(ingrediente)

        receta = session.exec(
            select(Receta).where(Receta.nombre == "Espresso de prueba")
        ).first()
        if not receta:
            receta = Receta(
                nombre="Espresso de prueba",
                descripcion="Shot de espresso para pruebas",
                margen=0.3,
            )
            session.add(receta)
            session.commit()
            session.refresh(receta)

            receta_item = RecetaItem(
                receta_id=receta.id,
                ingrediente_id=ingrediente.id,
                cantidad=10.0,
                merma=0.0,
            )
            session.add(receta_item)
            session.commit()

        return ingrediente.id, receta.id

    @staticmethod
    def _seed_logs(session: Session) -> int:
        admin = session.exec(select(Usuario).where(Usuario.username == "admin")).first()
        if not admin:
            return 0

        existing = session.exec(select(LogSesion)).all()
        if existing:
            return len(existing)

        session.add_all(
            [
                LogSesion(
                    usuario_id=admin.id,
                    accion="login",
                    ip="127.0.0.1",
                    user_agent="smoke-tests",
                    exito=True,
                ),
                LogSesion(
                    usuario_id=admin.id,
                    accion="ver_dashboard",
                    ip="127.0.0.1",
                    user_agent="smoke-tests",
                    exito=True,
                ),
            ]
        )
        session.commit()
        return 2

    def _login(self, session: Session, username: str, password: str) -> Dict[str, str]:
        form = OAuth2PasswordRequestForm(username=username, password=password, scope="")
        token = auth_rutas.login(form_data=form, session=session)
        return token.model_dump()

    def test_login_and_profile(self):
        with Session(self.engine) as session:
            token_data = self._login(session, "admin", "admin123")
            payload = decodificar_token(token_data["access_token"])
            usuario_actual = asyncio.run(
                obtener_usuario_actual(
                    token=token_data["access_token"],
                    session=session,
                )
            )

        self.assertEqual(payload["sub"], "admin")
        self.assertEqual(usuario_actual.username, "admin")

    def test_client_crud_cycle(self):
        with Session(self.engine) as session:
            admin = session.exec(select(Usuario).where(Usuario.username == "admin")).first()

            created = clientes_rutas.crear_cliente(
                cliente=Cliente(
                    nombre="Cliente Demo",
                    correo="demo@example.com",
                    telefono="555-1234",
                    direccion="Calle Falsa 123",
                    alergias="ninguna",
                ),
                session=session,
                usuario_actual=admin,
            )
            clientes = clientes_rutas.listar_clientes(
                limit=100,
                offset=0,
                session=session,
                usuario_actual=admin,
            )
            actualizado = clientes_rutas.actualizar_cliente(
                cliente_id=created.id,
                datos=Cliente(
                    nombre="Cliente Actualizado",
                    correo="nuevo@example.com",
                    telefono="555-9999",
                    direccion="Calle Renovada 456",
                    alergias="lactosa",
                ),
                session=session,
                usuario_actual=admin,
            )
            clientes_rutas.eliminar_cliente(
                cliente_id=created.id,
                session=session,
                usuario_actual=admin,
            )

        self.assertIn(created.id, [cliente.id for cliente in clientes])
        self.assertEqual(actualizado.nombre, "Cliente Actualizado")

    def test_vendor_permissions_and_inventory_access(self):
        with Session(self.engine) as session:
            vendor = session.exec(select(Usuario).where(Usuario.username == "vendedor")).first()

            role_guard = requiere_roles([Rol.ADMIN, Rol.DUENO])
            with self.assertRaises(HTTPException):
                asyncio.run(role_guard(usuario_actual=vendor))

            inventario = ingredientes_rutas.listar_ingredientes(
                limit=100,
                offset=0,
                session=session,
                usuario_actual=vendor,
            )
            perm_guard = requiere_permiso("reportes", "ver")
            with self.assertRaises(HTTPException):
                asyncio.run(perm_guard(usuario_actual=vendor, session=session))

        self.assertGreaterEqual(len(inventario), 1)

    def test_sales_flow_updates_stock(self):
        with Session(self.engine) as session:
            vendor = session.exec(select(Usuario).where(Usuario.username == "vendedor")).first()
            inventario_guard = requiere_permiso("inventario", "ver")
            asyncio.run(inventario_guard(usuario_actual=vendor, session=session))
            ventas_guard = requiere_permiso("ventas", "crear")
            asyncio.run(ventas_guard(usuario_actual=vendor, session=session))

            before = ingredientes_rutas.obtener_ingrediente(
                ingrediente_id=self.ingredient_id,
                session=session,
                usuario_actual=vendor,
            ).stock

            venta_creada = ventas_rutas.crear_venta(
                datos=ventas_rutas.VentaCreate(
                    cliente_id=None,
                    sucursal="Principal",
                    items=[ventas_rutas.ItemVentaCreate(receta_id=self.recipe_id, cantidad=2)],
                ),
                session=session,
                usuario_actual=vendor,
            )

            after = ingredientes_rutas.obtener_ingrediente(
                ingrediente_id=self.ingredient_id,
                session=session,
                usuario_actual=vendor,
            ).stock

        self.assertGreater(venta_creada.total, 0)
        self.assertAlmostEqual(before - after, 20.0, places=4)

    def test_admin_can_read_logs_and_dashboard(self):
        with Session(self.engine) as session:
            admin = session.exec(select(Usuario).where(Usuario.username == "admin")).first()

            logs = logs_rutas.listar_logs(
                limit=10,
                offset=0,
                session=session,
                usuario_actual=admin,
            )
            dashboard = reportes_rutas.obtener_dashboard(
                session=session,
                usuario_actual=admin,
            )

        self.assertGreaterEqual(len(logs), self.log_entries)
        self.assertIn("accion", logs[0])
        self.assertIn("usuario_nombre", logs[0])
        self.assertIn("ventas_hoy", dashboard)


if __name__ == "__main__":
    unittest.main(verbosity=2)
