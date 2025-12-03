#!/usr/bin/env python3
"""
🔍 Script de verificación de login
Prueba que las credenciales del sistema funcionan correctamente
"""
import sys
import requests
from pathlib import Path

# Agregar nucleo-api al path
REPO_ROOT = Path(__file__).resolve().parent
NUCLEO_DIR = REPO_ROOT / "nucleo-api"
sys.path.insert(0, str(NUCLEO_DIR))


def verificar_login_api():
    """Verifica login usando la API HTTP"""
    print("=" * 60)
    print("🔍 VERIFICADOR DE LOGIN - EL CAFÉ SIN LÍMITES")
    print("=" * 60)
    print()

    base_url = "http://localhost:8000"

    # Verificar que el servidor esté corriendo
    print("1. Verificando que el servidor esté activo...")
    try:
        response = requests.get(f"{base_url}/salud", timeout=5)
        if response.status_code == 200:
            print("   ✅ Servidor activo")
        else:
            print(f"   ❌ Servidor respondió con código {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("   ❌ ERROR: No se puede conectar al servidor")
        print("   💡 Asegúrate de que el backend esté corriendo:")
        print("      ./start_all.sh")
        print("      O:")
        print("      cd nucleo-api && python main.py")
        return False
    except Exception as e:
        print(f"   ❌ ERROR: {e}")
        return False

    print()

    # Intentar login
    print("2. Intentando login con credenciales por defecto...")
    print("   Username: admin")
    print("   Password: admin123")

    try:
        response = requests.post(
            f"{base_url}/auth/login",
            data={
                "username": "admin",
                "password": "admin123"
            },
            headers={
                "Content-Type": "application/x-www-form-urlencoded"
            },
            timeout=5
        )

        if response.status_code == 200:
            data = response.json()
            token = data.get("access_token")

            print("   ✅ Login exitoso")
            print()
            print("3. Token recibido:")
            print(f"   {token[:50]}...")
            print()

            # Obtener perfil del usuario
            print("4. Obteniendo perfil del usuario...")
            profile_response = requests.get(
                f"{base_url}/auth/me",
                headers={
                    "Authorization": f"Bearer {token}"
                },
                timeout=5
            )

            if profile_response.status_code == 200:
                perfil = profile_response.json()
                print("   ✅ Perfil obtenido correctamente")
                print()
                print("=" * 60)
                print("📋 INFORMACIÓN DEL USUARIO")
                print("=" * 60)
                print(f"Username: {perfil.get('username')}")
                print(f"Nombre: {perfil.get('nombre')}")
                print(f"Rol: {perfil.get('rol')}")
                print(f"Activo: {perfil.get('activo')}")
                print(f"ID: {perfil.get('id')}")
                print("=" * 60)
                print()
                print("✅ ¡TODO FUNCIONA CORRECTAMENTE!")
                print()
                print("Puedes usar estas credenciales en:")
                print("  - Frontend QML")
                print("  - API Docs: http://localhost:8000/docs")
                print("  - Cualquier cliente HTTP")
                print()
                return True
            else:
                print(f"   ❌ Error al obtener perfil: {profile_response.status_code}")
                print(f"   Respuesta: {profile_response.text}")
                return False

        elif response.status_code == 401:
            print("   ❌ ERROR: Credenciales incorrectas")
            print()
            print("   Esto puede significar:")
            print("   1. El usuario 'admin' no existe")
            print("   2. La contraseña es incorrecta")
            print("   3. La base de datos no ha sido inicializada")
            print()
            print("   💡 Solución: Ejecuta el script de inicialización")
            print("      python populate_db.py")
            print()
            return False
        else:
            print(f"   ❌ ERROR: Código de respuesta {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return False

    except Exception as e:
        print(f"   ❌ ERROR durante el login: {e}")
        return False


def verificar_base_datos():
    """Verifica que la base de datos tenga el usuario admin"""
    print("=" * 60)
    print("🗄️  VERIFICANDO BASE DE DATOS")
    print("=" * 60)
    print()

    try:
        from sqlmodel import Session, select, create_engine
        from sistema.entidades import Usuario

        db_path = NUCLEO_DIR / "almacen_cuantico.db"

        if not db_path.exists():
            print("❌ Base de datos no existe")
            print(f"   Ruta esperada: {db_path}")
            print()
            print("   💡 Solución: Ejecuta")
            print("      python populate_db.py")
            print()
            return False

        print(f"✅ Base de datos encontrada: {db_path}")
        print(f"   Tamaño: {db_path.stat().st_size / 1024:.2f} KB")
        print()

        engine = create_engine(f"sqlite:///{db_path}")

        with Session(engine) as session:
            # Buscar usuario admin
            admin = session.exec(
                select(Usuario).where(Usuario.username == "admin")
            ).first()

            if admin:
                print("✅ Usuario 'admin' encontrado en la base de datos")
                print(f"   ID: {admin.id}")
                print(f"   Nombre: {admin.nombre}")
                print(f"   Rol: {admin.rol}")
                print(f"   Activo: {admin.activo}")
                print()

                if not admin.activo:
                    print("⚠️  ADVERTENCIA: El usuario está INACTIVO")
                    print("   No podrá hacer login")
                    print()

                return True
            else:
                print("❌ Usuario 'admin' NO encontrado")
                print()
                print("   💡 Solución: Ejecuta")
                print("      python populate_db.py")
                print()
                return False

    except Exception as e:
        print(f"❌ ERROR al verificar base de datos: {e}")
        print()
        return False


if __name__ == "__main__":
    print()

    # Primero verificar la base de datos
    bd_ok = verificar_base_datos()

    print()

    if not bd_ok:
        print("❌ Verifica la base de datos antes de probar el login")
        sys.exit(1)

    # Luego verificar el login por API
    login_ok = verificar_login_api()

    if login_ok:
        sys.exit(0)
    else:
        print("❌ El login no funcionó correctamente")
        print()
        print("PASOS PARA SOLUCIONAR:")
        print("1. Asegúrate de que el backend esté corriendo:")
        print("   ./start_all.sh")
        print()
        print("2. Si el problema persiste, reinicializa la base de datos:")
        print("   python populate_db.py")
        print()
        sys.exit(1)
