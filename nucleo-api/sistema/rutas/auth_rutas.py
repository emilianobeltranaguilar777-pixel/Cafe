"""
🔐 RUTAS DE AUTENTICACIÓN - ELCAFESIN
Login, registro, gestión de usuarios
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select
from typing import List

from sistema.configuracion import (
    obtener_sesion, hash_password, verificar_password,
    crear_token, obtener_usuario_actual, requiere_roles
)
from sistema.entidades import Usuario, Rol
from sistema.contratos.auth_contratos import (
    UsuarioCreate, UsuarioOut, TokenOut, UsuarioUpdate
)

router = APIRouter(prefix="/auth", tags=["🔐 Autenticación"])


@router.post("/login", response_model=TokenOut)
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    session: Session = Depends(obtener_sesion)
):
    """
    🔑 Login con username y password
    Retorna token JWT
    """
    # Buscar usuario
    usuario = session.exec(
        select(Usuario).where(Usuario.username == form_data.username)
    ).first()
    
    if not usuario or not verificar_password(form_data.password, usuario.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales incorrectas"
        )
    
    if not usuario.activo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuario inactivo"
        )
    
    # Crear token
    token = crear_token(
        username=usuario.username,
        extra_data={"rol": usuario.rol}
    )
    
    return TokenOut(access_token=token, token_type="bearer")


@router.get("/me", response_model=UsuarioOut)
def obtener_perfil(usuario_actual: Usuario = Depends(obtener_usuario_actual)):
    """👤 Obtener perfil del usuario actual"""
    return usuario_actual


@router.post("/usuarios", response_model=UsuarioOut)
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


@router.get("/usuarios", response_model=List[UsuarioOut])
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


@router.patch("/usuarios/{usuario_id}/estado", response_model=UsuarioOut)
def cambiar_estado_usuario(
    usuario_id: int,
    activo: bool,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    🔄 Activar/Desactivar usuario
    Requiere rol ADMIN o DUENO
    """
    usuario = session.get(Usuario, usuario_id)
    
    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    
    usuario.activo = activo
    session.add(usuario)
    session.commit()
    session.refresh(usuario)
    
    return usuario


@router.put("/usuarios/{usuario_id}", response_model=UsuarioOut)
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
