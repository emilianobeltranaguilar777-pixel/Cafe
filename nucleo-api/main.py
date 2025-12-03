"""
Punto de entrada principal para la API de "El Café sin Límites".

Expone la instancia de FastAPI definida en ``sistema.motor_principal`` para
que cualquier servidor ASGI (por ejemplo, ``uvicorn``) pueda importarla como
``main:app``.  También permite ejecutar el servidor directamente usando
``python main.py`` durante el desarrollo.
"""

from sistema.motor_principal import app


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app", host="0.0.0.0", port=8000, reload=True
    )
