from pathlib import Path
import importlib
import sys


def test_sqlite_url_resolves_to_repo_root(tmp_path, monkeypatch):
    """
    Asegura que la URL por defecto de SQLite siempre apunte al archivo
    ``almacen_cuantico.db`` dentro del repo, aun si se inicia el servidor
    desde otro directorio de trabajo.
    """
    # Cambiar cwd para simular un arranque fuera de nucleo-api
    monkeypatch.chdir(tmp_path)

    # Limpiar módulos y ajustes cacheados
    for modulo in ["sistema.configuracion.base_datos", "sistema.configuracion.ajustes"]:
        sys.modules.pop(modulo, None)

    from sistema.configuracion import ajustes as ajustes_module

    ajustes_module.obtener_ajustes.cache_clear()

    base_datos = importlib.import_module("sistema.configuracion.base_datos")

    ruta_esperada = (Path(__file__).resolve().parents[1] / "almacen_cuantico.db").resolve()

    assert Path(base_datos.engine.url.database).resolve() == ruta_esperada
