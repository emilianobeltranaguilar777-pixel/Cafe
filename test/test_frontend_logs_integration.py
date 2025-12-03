"""
🧪 TESTS DE INTEGRACIÓN FRONTEND/QML - ELCAFESIN
Verifica que la pantalla de logs QML carga correctamente
"""
from pathlib import Path
import pytest
import requests

BASE_DIR = Path(__file__).resolve().parent.parent
QML_ROOT = BASE_DIR / "interfaz-neon" / "quantum"
PANTALLA_LOGS = QML_ROOT / "pantallas" / "pantalla_logs.qml"
DIMENSION_PRINCIPAL = QML_ROOT / "dimension_principal.qml"
COMPONENTES = [
    QML_ROOT / "componentes" / "TarjetaGlow.qml",
    QML_ROOT / "componentes" / "BotonNeon.qml",
    QML_ROOT / "componentes" / "InputAnimado.qml",
]
PALETA_NEON = QML_ROOT / "cerebro" / "PaletaNeon.qml"
GESTOR_AUTH = QML_ROOT / "cerebro" / "GestorAuth.qml"


def test_pantalla_logs_qml_existe():
    """Test: El archivo pantalla_logs.qml existe"""
    assert PANTALLA_LOGS.exists(), f"El archivo {PANTALLA_LOGS} no existe"


def test_pantalla_logs_tiene_contenido_valido():
    """Test: La pantalla de logs tiene contenido QML válido"""
    with PANTALLA_LOGS.open("r", encoding="utf-8") as f:
        contenido = f.read()

    # Verificar elementos básicos de QML
    assert "import QtQuick" in contenido
    assert "import quantum" in contenido
    assert "PaletaNeon" in contenido

    # Verificar elementos específicos de la pantalla de logs
    assert "Sistema de Auditoría" in contenido or "Logs" in contenido
    assert "GestorAuth.request" in contenido
    assert "/logs" in contenido

    # Verificar que tiene las funciones necesarias
    assert "function cargarLogs" in contenido
    assert "function logsFiltrados" in contenido or "logsFiltrados()" in contenido


def test_pantalla_logs_usa_tema_neon():
    """Test: La pantalla usa correctamente el tema neon"""
    with PANTALLA_LOGS.open("r", encoding="utf-8") as f:
        contenido = f.read()

    # Verificar que usa los colores del tema
    assert "PaletaNeon.primario" in contenido

    # Verificar que usa componentes neon
    assert "TarjetaGlow" in contenido or "BotonNeon" in contenido

    # Verificar efectos glow
    assert "Glow" in contenido or "layer.effect" in contenido

    # Verificar que usa variables del tema
    assert "PaletaNeon." in contenido


def test_logs_agregado_al_menu_navegacion():
    """Test: Logs fue agregado al menú de navegación"""
    with DIMENSION_PRINCIPAL.open("r", encoding="utf-8") as f:
        contenido = f.read()

    # Verificar que está en el ListModel
    assert "pantalla_logs.qml" in contenido
    assert '"Logs"' in contenido or 'nombre: "Logs"' in contenido


def test_pantalla_logs_tiene_filtros():
    """Test: La pantalla tiene controles de filtrado"""
    with PANTALLA_LOGS.open("r", encoding="utf-8") as f:
        contenido = f.read()

    # Verificar filtros
    assert "filtroActual" in contenido or "filtro" in contenido
    assert "sesion" in contenido
    assert "movimiento" in contenido


def test_pantalla_logs_tiene_formato_fecha():
    """Test: La pantalla tiene funciones de formato de fecha"""
    with PANTALLA_LOGS.open("r", encoding="utf-8") as f:
        contenido = f.read()

    # Verificar funciones de formato
    assert "formatearFecha" in contenido or "formatear" in contenido
    assert "formatearHora" in contenido or "hora" in contenido.lower()


def test_pantalla_logs_es_scrollable():
    """Test: La pantalla tiene lista scrollable"""
    with PANTALLA_LOGS.open("r", encoding="utf-8") as f:
        contenido = f.read()

    # Verificar que tiene ListView
    assert "ListView" in contenido
    assert "clip: true" in contenido


def test_backend_responde_a_logs():
    """Test: El backend responde correctamente al endpoint de logs"""
    # Este test requiere que el backend esté corriendo
    try:
        # Intentar login primero
        response = requests.post(
            "http://localhost:8000/auth/login",
            data={"username": "admin", "password": "admin123"},
            timeout=5,
        )

        if response.status_code == 200:
            token = response.json()["access_token"]

            # Probar endpoint de logs
            response = requests.get(
                "http://localhost:8000/logs",
                headers={"Authorization": f"Bearer {token}"},
                timeout=5,
            )

            assert response.status_code == 200
            data = response.json()
            assert "logs" in data
            assert "total" in data
        else:
            pytest.skip("Backend no disponible o credenciales incorrectas")

    except requests.exceptions.ConnectionError:
        pytest.skip("Backend no está corriendo")
    except requests.exceptions.Timeout:
        pytest.skip("Backend no responde a tiempo")


def test_estructura_componentes_qml_correcta():
    """Test: Los componentes QML necesarios existen"""
    for componente in COMPONENTES:
        assert componente.exists(), f"Componente {componente} no encontrado"


def test_singleton_paletaneon_existe():
    """Test: El singleton PaletaNeon existe y es válido"""
    assert PALETA_NEON.exists()

    with PALETA_NEON.open("r", encoding="utf-8") as f:
        contenido = f.read()

    # Verificar que es un singleton
    assert "pragma Singleton" in contenido

    # Verificar que tiene los colores necesarios
    assert "primario" in contenido
    assert "fondo" in contenido
    assert "tarjeta" in contenido


def test_gestor_auth_existe():
    """Test: El singleton GestorAuth existe"""
    assert GESTOR_AUTH.exists()

    with GESTOR_AUTH.open("r", encoding="utf-8") as f:
        contenido = f.read()

    # Verificar que tiene la función request
    assert "function request" in contenido
    assert "XMLHttpRequest" in contenido


def test_no_errores_sintaxis_qml():
    """Test: No hay errores obvios de sintaxis en el QML"""
    with PANTALLA_LOGS.open("r", encoding="utf-8") as f:
        contenido = f.read()

    # Verificar balance de llaves
    assert contenido.count("{") == contenido.count("}"), "Llaves desbalanceadas"

    # Verificar que no hay comentarios TODO sin resolver (opcional)
    lineas_todo = [line for line in contenido.split("\n") if "TODO" in line or "FIXME" in line]
    assert len(lineas_todo) == 0, f"Hay TODOs sin resolver: {lineas_todo}"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
