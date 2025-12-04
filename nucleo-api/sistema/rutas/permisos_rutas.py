"""
🔐 RUTAS DE PERMISOS (RBAC) - ELCAFESIN
Gestión de permisos por rol sin modificar las tablas existentes
"""
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select

from sistema.configuracion import obtener_sesion, requiere_permiso
from sistema.entidades import PermisoRol, Accion, Usuario
from sistema.entidades.permiso import PermisoRolCreate, PermisoRolResponse

router = APIRouter(prefix="/permisos", tags=["🔐 Permisos"])

permiso_ver = requiere_permiso("usuarios", "ver")
permiso_gestionar = requiere_permiso("usuarios", "editar")


@router.get("/rol/{rol}", response_model=List[PermisoRolResponse])
def listar_permisos_por_rol(
    rol: str,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_ver)
):
    """📋 Listar permisos asociados a un rol"""
    permisos = session.exec(
        select(PermisoRol).where(PermisoRol.rol == rol)
    ).all()
    return permisos


@router.post(
    "/rol/{rol}",
    response_model=PermisoRolResponse,
    status_code=status.HTTP_201_CREATED
)
def crear_permiso_para_rol(
    rol: str,
    permiso: PermisoRolCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_gestionar)
):
    """➕ Crear un permiso para un rol específico"""
    existente = session.exec(
        select(PermisoRol).where(
            PermisoRol.rol == rol,
            PermisoRol.recurso == permiso.recurso,
            PermisoRol.accion == permiso.accion,
        )
    ).first()

    if existente:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El permiso ya existe para este rol"
        )

    nuevo_permiso = PermisoRol(
        rol=rol,
        recurso=permiso.recurso,
        accion=permiso.accion,
    )
    session.add(nuevo_permiso)
    session.commit()
    session.refresh(nuevo_permiso)
    return nuevo_permiso


@router.delete("/rol/{rol}")
def eliminar_permiso_de_rol(
    rol: str,
    permiso: PermisoRolCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_gestionar)
):
    """🗑️ Eliminar un permiso específico de un rol"""
    existente = session.exec(
        select(PermisoRol).where(
            PermisoRol.rol == rol,
            PermisoRol.recurso == permiso.recurso,
            PermisoRol.accion == permiso.accion,
        )
    ).first()

    if not existente:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Permiso no encontrado para este rol"
        )

    session.delete(existente)
    session.commit()

    return {"mensaje": "Permiso eliminado"}
