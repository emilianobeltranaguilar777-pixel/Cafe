"""
🌱 SEED INICIAL - ELCAFESIN
Carga datos iniciales: usuarios, roles y permisos
"""
from sqlmodel import Session, select
from sistema.entidades import Usuario, Rol, PermisoRol, Accion
from sistema.configuracion import hash_password


def inicializar_datos(session: Session):
    """
    Inicializa datos base del sistema:
    1. Usuarios iniciales (admin, dueno, gerente1, vendedor1)
    2. Permisos por rol
    """
    print("🌱 Verificando datos iniciales...")

    # ==================== USUARIOS INICIALES ====================
    usuarios_iniciales = [
        {
            "username": "admin",
            "nombre": "Administrador",
            "password": "admin123",
            "rol": Rol.ADMIN
        },
        {
            "username": "dueno",
            "nombre": "Dueño Principal",
            "password": "dueno123",
            "rol": Rol.DUENO
        },
        {
            "username": "gerente1",
            "nombre": "Gerente Principal",
            "password": "gerente123",
            "rol": Rol.GERENTE
        },
        {
            "username": "vendedor1",
            "nombre": "Vendedor Principal",
            "password": "vendedor123",
            "rol": Rol.VENDEDOR
        }
    ]

    usuarios_creados = 0
    for datos_usuario in usuarios_iniciales:
        existe = session.exec(
            select(Usuario).where(Usuario.username == datos_usuario["username"])
        ).first()

        if not existe:
            nuevo_usuario = Usuario(
                username=datos_usuario["username"],
                nombre=datos_usuario["nombre"],
                password_hash=hash_password(datos_usuario["password"]),
                rol=datos_usuario["rol"],
                activo=True
            )
            session.add(nuevo_usuario)
            usuarios_creados += 1
            print(f"   📝 Usuario '{datos_usuario['username']}' creado (pass: {datos_usuario['password']})")

    if usuarios_creados > 0:
        session.commit()
        print(f"   ✅ {usuarios_creados} usuarios creados")
    else:
        print("   ℹ️  Usuarios ya existen")
    
    # ==================== PERMISOS BASE ====================
    permisos_base = [
        # DUEÑO - acceso total
        ("DUENO", "usuarios", Accion.VER),
        ("DUENO", "usuarios", Accion.CREAR),
        ("DUENO", "usuarios", Accion.EDITAR),
        ("DUENO", "usuarios", Accion.ELIMINAR),
        ("DUENO", "reportes", Accion.VER),
        ("DUENO", "inventario", Accion.VER),
        ("DUENO", "inventario", Accion.EDITAR),
        ("DUENO", "ventas", Accion.VER),
        ("DUENO", "clientes", Accion.VER),
        
        # ADMIN - gestión de usuarios e inventario
        ("ADMIN", "usuarios", Accion.VER),
        ("ADMIN", "usuarios", Accion.CREAR),
        ("ADMIN", "usuarios", Accion.EDITAR),
        ("ADMIN", "inventario", Accion.VER),
        ("ADMIN", "inventario", Accion.CREAR),
        ("ADMIN", "inventario", Accion.EDITAR),
        ("ADMIN", "ventas", Accion.CREAR),
        ("ADMIN", "ventas", Accion.VER),
        ("ADMIN", "reportes", Accion.VER),
        
        # GERENTE - inventario y reportes
        ("GERENTE", "inventario", Accion.VER),
        ("GERENTE", "inventario", Accion.CREAR),
        ("GERENTE", "inventario", Accion.EDITAR),
        ("GERENTE", "ventas", Accion.VER),
        ("GERENTE", "reportes", Accion.VER),
        ("GERENTE", "clientes", Accion.VER),
        
        # VENDEDOR - solo ventas
        ("VENDEDOR", "ventas", Accion.VER),
        ("VENDEDOR", "ventas", Accion.CREAR),
        ("VENDEDOR", "clientes", Accion.VER),
        ("VENDEDOR", "inventario", Accion.VER),  # Solo ver stock
    ]
    
    permisos_creados = 0
    for rol, recurso, accion in permisos_base:
        # Verificar si ya existe
        existe = session.exec(
            select(PermisoRol).where(
                PermisoRol.rol == rol,
                PermisoRol.recurso == recurso,
                PermisoRol.accion == accion
            )
        ).first()
        
        if not existe:
            session.add(PermisoRol(rol=rol, recurso=recurso, accion=accion))
            permisos_creados += 1
    
    if permisos_creados > 0:
        session.commit()
        print(f"   ✅ {permisos_creados} permisos creados")
    else:
        print("   ℹ️  Permisos ya inicializados")
    
    print("🎉 Datos iniciales listos")
