"""
🔐 RUTAS DE PERMISOS POR USUARIO (OVERRIDE)
Gestión de excepciones individuales que priorizan sobre los roles
"""
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select

from sistema.configuracion import obtener_sesion, requiere_permiso
from sistema.entidades import Usuario, UsuarioPermiso
from sistema.contratos.permisos_usuario_contratos import (
    PermisoUsuarioCreate,
    PermisoUsuarioResponse,
)

router = APIRouter(prefix="/permisos/usuario", tags=["🔐 Permisos Usuario"])

permiso_ver = requiere_permiso("usuarios", "ver")
permiso_gestionar = requiere_permiso("usuarios", "editar")


@router.get("/{usuario_id}", response_model=List[PermisoUsuarioResponse])
def listar_permisos_por_usuario(
    usuario_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_ver)
):
    """📋 Listar overrides configurados para un usuario"""
    permisos = session.exec(
        select(UsuarioPermiso).where(UsuarioPermiso.usuario_id == usuario_id)
    ).all()
    return permisos


@router.post(
    "/{usuario_id}",
    response_model=PermisoUsuarioResponse,
    status_code=status.HTTP_201_CREATED
)
def crear_permiso_para_usuario(
    usuario_id: int,
    permiso: PermisoUsuarioCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_gestionar)
):
    """➕ Crear un permiso específico para un usuario"""
    usuario = session.get(Usuario, usuario_id)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    existente = session.exec(
        select(UsuarioPermiso).where(
            UsuarioPermiso.usuario_id == usuario_id,
            UsuarioPermiso.recurso == permiso.recurso,
            UsuarioPermiso.accion == permiso.accion,
        )
    ).first()

    if existente:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El permiso ya existe para este usuario"
        )

    nuevo_permiso = UsuarioPermiso(
        usuario_id=usuario_id,
        recurso=permiso.recurso,
        accion=permiso.accion,
        permitido=permiso.permitido,
    )
    session.add(nuevo_permiso)
    session.commit()
    session.refresh(nuevo_permiso)
    return nuevo_permiso


@router.delete("/{usuario_id}")
def eliminar_permiso_de_usuario(
    usuario_id: int,
    permiso: PermisoUsuarioCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_gestionar)
):
    """🗑️ Eliminar un override de permiso para un usuario"""
    existente = session.exec(
        select(UsuarioPermiso).where(
            UsuarioPermiso.usuario_id == usuario_id,
            UsuarioPermiso.recurso == permiso.recurso,
            UsuarioPermiso.accion == permiso.accion,
        )
    ).first()

    if not existente:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Permiso no encontrado para este usuario"
        )

    session.delete(existente)
    session.commit()

    return {"mensaje": "Permiso eliminado"}
