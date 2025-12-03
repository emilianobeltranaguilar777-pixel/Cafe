"""
⚙️ CONFIGURACIÓN GLOBAL - ELCAFESIN
Carga variables de entorno y configuración del sistema
"""
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Ajustes(BaseSettings):
    """Configuración global del sistema"""
    
    # 🗄️ Base de datos
    DATABASE_URL: str = "sqlite:///./almacen_cuantico.db"
    
    # 🔐 Seguridad
    SECRET_KEY: str = "CAMBIAR_EN_PRODUCCION"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 120
    ALGORITHM: str = "HS256"
    
    # 💰 Negocio
    MARGIN_DEFAULT: float = 0.40
    
    # 🎨 Metadata
    PROJECT_NAME: str = "EL CAFÉ SIN LÍMITES"
    PROJECT_VERSION: str = "2.0.0-NEON"
    
    model_config = SettingsConfigDict(
        env_file=".env.ELCAFESIN",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


@lru_cache
def obtener_ajustes() -> Ajustes:
    """Singleton para configuración (se carga una sola vez)"""
    return Ajustes()
