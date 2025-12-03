"""
🗄️ MOTOR DE BASE DE DATOS - ELCAFESIN
Configuración de SQLModel y SQLite
"""
from sqlmodel import SQLModel, Session, create_engine
from typing import Generator
from .ajustes import obtener_ajustes

# Obtener configuración
ajustes = obtener_ajustes()

# Crear engine (connect_args solo para SQLite)
engine = create_engine(
    ajustes.DATABASE_URL,
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
