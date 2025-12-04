"""
🔐 RUTAS DE PERMISOS - ELCAFESIN
Gestión de permisos por rol y por usuario
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlmodel import Session, select
from typing import List

from sistema.configuracion import (
    obtener_sesion, obtener_usuario_actual, requiere_roles
)
from sistema.entidades import Usuario, PermisoRol, UsuarioPermiso, Accion
from sistema.contratos.permisos_contratos import (
    PermisoRolCreate, PermisoRolOut,
    PermisoUsuarioCreate, PermisoUsuarioOut
)

router = APIRouter(prefix="/permisos", tags=["🔐 Permisos"])


# ==================== PERMISOS POR ROL ====================

@router.get("/rol/{rol}", response_model=List[PermisoRolOut])
def listar_permisos_rol(
    rol: str,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    📋 Listar permisos de un rol
    Requiere rol ADMIN o DUENO
    """
    permisos = session.exec(
        select(PermisoRol).where(PermisoRol.rol == rol.upper())
    ).all()
    return permisos


@router.post("/rol/{rol}", response_model=PermisoRolOut)
def crear_permiso_rol(
    rol: str,
    datos: PermisoRolCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    ➕ Crear permiso para un rol
    Requiere rol ADMIN o DUENO
    """
    # Verificar si ya existe
    existe = session.exec(
        select(PermisoRol).where(
            PermisoRol.rol == rol.upper(),
            PermisoRol.recurso == datos.recurso,
            PermisoRol.accion == datos.accion
        )
    ).first()

    if existe:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"El permiso ya existe para el rol {rol}"
        )

    # Crear permiso
    nuevo_permiso = PermisoRol(
        rol=rol.upper(),
        recurso=datos.recurso,
        accion=datos.accion
    )

    session.add(nuevo_permiso)
    session.commit()
    session.refresh(nuevo_permiso)

    return nuevo_permiso


@router.delete("/rol/{rol}")
def eliminar_permiso_rol(
    rol: str,
    recurso: str = Query(..., description="Recurso del permiso"),
    accion: str = Query(..., description="Acción del permiso"),
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    ❌ Eliminar permiso de un rol
    Requiere rol ADMIN o DUENO
    """
    permiso = session.exec(
        select(PermisoRol).where(
            PermisoRol.rol == rol.upper(),
            PermisoRol.recurso == recurso,
            PermisoRol.accion == accion
        )
    ).first()

    if not permiso:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Permiso no encontrado"
        )

    session.delete(permiso)
    session.commit()

    return {"message": "Permiso eliminado exitosamente"}


# ==================== PERMISOS POR USUARIO ====================

@router.get("/usuario/{usuario_id}", response_model=List[PermisoUsuarioOut])
def listar_permisos_usuario(
    usuario_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    📋 Listar permisos excepcionales de un usuario
    Requiere rol ADMIN o DUENO
    """
    # Verificar que el usuario existe
    usuario = session.get(Usuario, usuario_id)
    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )

    permisos = session.exec(
        select(UsuarioPermiso).where(UsuarioPermiso.usuario_id == usuario_id)
    ).all()
    return permisos


@router.post("/usuario/{usuario_id}", response_model=PermisoUsuarioOut)
def crear_permiso_usuario(
    usuario_id: int,
    datos: PermisoUsuarioCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    ➕ Crear permiso excepcional para un usuario
    Requiere rol ADMIN o DUENO
    """
    # Verificar que el usuario existe
    usuario = session.get(Usuario, usuario_id)
    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )

    # Verificar si ya existe
    existe = session.exec(
        select(UsuarioPermiso).where(
            UsuarioPermiso.usuario_id == usuario_id,
            UsuarioPermiso.recurso == datos.recurso,
            UsuarioPermiso.accion == datos.accion
        )
    ).first()

    if existe:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"El permiso ya existe para el usuario {usuario_id}"
        )

    # Crear permiso
    nuevo_permiso = UsuarioPermiso(
        usuario_id=usuario_id,
        recurso=datos.recurso,
        accion=datos.accion,
        permitido=datos.permitido
    )

    session.add(nuevo_permiso)
    session.commit()
    session.refresh(nuevo_permiso)

    return nuevo_permiso


@router.delete("/usuario/{usuario_id}")
def eliminar_permiso_usuario(
    usuario_id: int,
    recurso: str = Query(..., description="Recurso del permiso"),
    accion: str = Query(..., description="Acción del permiso"),
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(requiere_roles(["ADMIN", "DUENO"]))
):
    """
    ❌ Eliminar permiso excepcional de un usuario
    Requiere rol ADMIN o DUENO
    """
    permiso = session.exec(
        select(UsuarioPermiso).where(
            UsuarioPermiso.usuario_id == usuario_id,
            UsuarioPermiso.recurso == recurso,
            UsuarioPermiso.accion == accion
        )
    ).first()

    if not permiso:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Permiso no encontrado"
        )

    session.delete(permiso)
    session.commit()

    return {"message": "Permiso eliminado exitosamente"}
