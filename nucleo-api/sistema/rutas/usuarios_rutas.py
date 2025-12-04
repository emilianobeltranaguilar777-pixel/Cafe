"""
👤 RUTAS DE USUARIOS - ELCAFESIN
CRUD completo de usuarios
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List

from sistema.configuracion import (
    obtener_sesion, hash_password, obtener_usuario_actual, requiere_roles
)
from sistema.entidades import Usuario, Rol
from sistema.contratos.auth_contratos import (
    UsuarioCreate, UsuarioOut, UsuarioUpdate
)

router = APIRouter(prefix="/usuarios", tags=["👤 Usuarios"])


@router.get("/", response_model=List[UsuarioOut])
def listar_usuarios(
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    📋 Listar todos los usuarios
    Requiere rol ADMIN o DUENO
    """
    usuarios = session.exec(select(Usuario)).all()
    return usuarios


@router.post("/", response_model=UsuarioOut)
def crear_usuario(
    datos: UsuarioCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    ➕ Crear nuevo usuario
    Requiere rol ADMIN o DUENO
    """
    # Verificar que username no exista
    existe = session.exec(
        select(Usuario).where(Usuario.username == datos.username)
    ).first()

    if existe:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"El username '{datos.username}' ya existe"
        )

    # Crear usuario
    nuevo_usuario = Usuario(
        username=datos.username,
        nombre=datos.nombre,
        password_hash=hash_password(datos.password),
        rol=datos.rol,
        activo=True
    )

    session.add(nuevo_usuario)
    session.commit()
    session.refresh(nuevo_usuario)

    return nuevo_usuario


@router.put("/{usuario_id}", response_model=UsuarioOut)
def actualizar_usuario(
    usuario_id: int,
    datos: UsuarioUpdate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    ✏️ Actualizar datos de usuario
    Requiere rol ADMIN o DUENO
    """
    usuario = session.get(Usuario, usuario_id)

    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )

    # Actualizar campos
    if datos.nombre is not None:
        usuario.nombre = datos.nombre

    if datos.rol is not None:
        usuario.rol = datos.rol

    if datos.password is not None:
        usuario.password_hash = hash_password(datos.password)

    session.add(usuario)
    session.commit()
    session.refresh(usuario)

    return usuario


@router.patch("/{usuario_id}/activar", response_model=UsuarioOut)
def activar_usuario(
    usuario_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    ✅ Activar usuario
    Requiere rol ADMIN o DUENO
    """
    usuario = session.get(Usuario, usuario_id)

    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )

    usuario.activo = True
    session.add(usuario)
    session.commit()
    session.refresh(usuario)

    return usuario


@router.patch("/{usuario_id}/desactivar", response_model=UsuarioOut)
def desactivar_usuario(
    usuario_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    ❌ Desactivar usuario
    Requiere rol ADMIN o DUENO
    """
    usuario = session.get(Usuario, usuario_id)

    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )

    usuario.activo = False
    session.add(usuario)
    session.commit()
    session.refresh(usuario)

    return usuario
