"""
🗄️ MOTOR DE BASE DE DATOS - ELCAFESIN
Configuración de SQLModel y SQLite
"""
from pathlib import Path
from typing import Generator

from sqlmodel import SQLModel, Session, create_engine

from .ajustes import obtener_ajustes

# Obtener configuración
ajustes = obtener_ajustes()

def _resolver_database_url(url: str) -> str:
    """
    Garantiza que la ruta SQLite sea absoluta usando la carpeta del proyecto
    (el repo ``nucleo-api``) como raíz. Esto evita que ejecuciones con un
    directorio de trabajo distinto generen bases alternativas sin el usuario
    admin sembrado.
    """
    prefix = "sqlite:///"

    if not url.startswith(prefix):
        return url

    ruta_bd = url[len(prefix):]
    # Normalizar posibles prefijos relativos
    if ruta_bd.startswith("./"):
        ruta_bd = ruta_bd[2:]

    ruta = Path(ruta_bd)
    if ruta.is_absolute():
        return f"{prefix}{ruta}"

    base_repo = Path(__file__).resolve().parents[2]
    return f"{prefix}{(base_repo / ruta).resolve()}"


# Crear engine (connect_args solo para SQLite)
engine = create_engine(
    _resolver_database_url(ajustes.DATABASE_URL),
    echo=True,  # Logs SQL en consola (cambiar a False en producción)
    connect_args={"check_same_thread": False}  # Solo para SQLite
)


def crear_tablas():
    """Crea todas las tablas en la base de datos"""
    # Importar todos los modelos para que SQLModel los registre
    from sistema.entidades import (
        usuario, permiso, cliente, proveedor, 
        ingrediente, receta, venta, movimiento, log_sesion
    )
    
    print("🗄️ Creando tablas en almacen_cuantico.db...")
    SQLModel.metadata.create_all(engine)
    print("✅ Tablas creadas exitosamente")


def obtener_sesion() -> Generator[Session, None, None]:
    """
    Dependency para obtener sesión de BD en endpoints
    Uso: session: Session = Depends(obtener_sesion)
    """
    with Session(engine) as session:
        yield session
