"""
Script para crear la base de datos y cargar los datos iniciales.

Se asegura de añadir la carpeta ``nucleo-api`` al ``PYTHONPATH`` para que se
pueda ejecutar desde la raíz del repositorio con ``python populate_db.py``.
"""
from contextlib import contextmanager
from pathlib import Path
import sys

# Asegurar que "nucleo-api" está en el path
REPO_ROOT = Path(__file__).resolve().parent
NUCLEO_DIR = REPO_ROOT / "nucleo-api"
if str(NUCLEO_DIR) not in sys.path:
    sys.path.insert(0, str(NUCLEO_DIR))

from sistema.configuracion import crear_tablas, obtener_sesion
from sistema.utilidades.seed_inicial import inicializar_datos


@contextmanager
def _session_context():
    """Obtiene una sesión de base de datos y la cierra correctamente."""
    generator = obtener_sesion()
    session = next(generator)
    try:
        yield session
    finally:
        generator.close()


def run():
    """Crea tablas e inserta el seed inicial."""
    crear_tablas()
    with _session_context() as session:
        inicializar_datos(session)


if __name__ == "__main__":
    run()
