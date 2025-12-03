"""
Arranque rápido de emergencia para la API.

Este script está pensado para situaciones donde se necesita levantar el
servidor sin depender de scripts externos o contenedores. Ejecuta uvicorn
apuntando directamente a ``sistema.motor_principal:app`` y habilita recarga
automática para facilitar la depuración.
"""

import uvicorn


if __name__ == "__main__":
    uvicorn.run(
        "sistema.motor_principal:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
