"""
🌱 SEED INICIAL - ELCAFESIN
Carga datos iniciales: usuarios, roles y permisos
"""
from sqlmodel import Session, select
from sistema.entidades import Usuario, Rol, PermisoRol, Accion
from sistema.configuracion import hash_password, verificar_password


def inicializar_datos(session: Session):
    """
    Inicializa datos base del sistema:
    1. Usuario admin (si no existe)
    2. Permisos por rol
    """
    print("🌱 Verificando datos iniciales...")
    
    # ==================== USUARIO ADMIN ====================
    admin_existente = session.exec(
        select(Usuario).where(Usuario.username == "admin")
    ).first()
    
    if not admin_existente:
        print("   📝 Creando usuario admin...")
        admin = Usuario(
            username="admin",
            nombre="Administrador",
            password_hash=hash_password("admin123"),
            rol=Rol.ADMIN,
            activo=True
        )
        session.add(admin)
        session.commit()
        print("   ✅ Usuario admin creado (user: admin, pass: admin123)")
    else:
        print("   ℹ️  Usuario admin ya existe")
        actualizado = False

        try:
            password_valida = verificar_password("admin123", admin_existente.password_hash)
        except ValueError:
            password_valida = False

        if not password_valida:
            print("   🔄 Restableciendo contraseña por defecto para admin")
            admin_existente.password_hash = hash_password("admin123")
            actualizado = True

        if admin_existente.rol != Rol.ADMIN:
            print("   🔄 Ajustando rol de admin a ADMIN")
            admin_existente.rol = Rol.ADMIN
            actualizado = True

        if not admin_existente.activo:
            print("   🔄 Activando usuario admin")
            admin_existente.activo = True
            actualizado = True

        if actualizado:
            session.add(admin_existente)
            session.commit()
    
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
