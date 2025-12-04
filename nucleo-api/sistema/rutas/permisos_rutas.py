"""
🔐 RUTAS DE PERMISOS RBAC - ELCAFESIN
"""
from typing import List, Optional

from fastapi import APIRouter, Body, Depends, HTTPException
from sqlmodel import Session, select

from sistema.configuracion import obtener_sesion, requiere_permiso
from sistema.entidades.permiso import PermisoRol, PermisoCreate, PermisoResponse
from sistema.entidades.usuario import Usuario

router = APIRouter(prefix="/permisos", tags=["🔐 Permisos"])

permiso_ver_permisos = requiere_permiso("usuarios", "ver")
permiso_gestionar_permisos = requiere_permiso("usuarios", "editar")


@router.get("/rol/{rol}", response_model=List[PermisoResponse])
def listar_permisos_por_rol(
    rol: str,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_ver_permisos),
):
    """📋 Listar permisos asignados a un rol"""
    rol_normalizado = rol.upper()
    permisos = session.exec(
        select(PermisoRol).where(PermisoRol.rol == rol_normalizado)
    ).all()
    return permisos


@router.post("/rol/{rol}", response_model=PermisoResponse, status_code=201)
def crear_permiso_para_rol(
    rol: str,
    datos: PermisoCreate,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_gestionar_permisos),
):
    """➕ Crear un permiso para el rol indicado"""
    rol_normalizado = rol.upper()

    existente = session.exec(
        select(PermisoRol).where(
            PermisoRol.rol == rol_normalizado,
            PermisoRol.recurso == datos.recurso,
            PermisoRol.accion == datos.accion,
        )
    ).first()

    if existente:
        raise HTTPException(
            status_code=400,
            detail="Permiso ya existe para este rol",
        )

    permiso = PermisoRol(rol=rol_normalizado, recurso=datos.recurso, accion=datos.accion)
    session.add(permiso)
    session.commit()
    session.refresh(permiso)
    return permiso


@router.delete("/rol/{rol}")
def eliminar_permiso_de_rol(
    rol: str,
    recurso: Optional[str] = None,
    accion: Optional[str] = None,
    datos: PermisoCreate | None = Body(default=None),
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(permiso_gestionar_permisos),
):
    """🗑️ Eliminar un permiso de un rol"""
    rol_normalizado = rol.upper()

    if datos is None:
        if not recurso or not accion:
            raise HTTPException(status_code=400, detail="Debe especificar recurso y acción")
        datos = PermisoCreate(recurso=recurso, accion=accion)

    permiso = session.exec(
        select(PermisoRol).where(
            PermisoRol.rol == rol_normalizado,
            PermisoRol.recurso == datos.recurso,
            PermisoRol.accion == datos.accion,
        )
    ).first()

    if not permiso:
        raise HTTPException(status_code=404, detail="Permiso no encontrado para el rol")

    session.delete(permiso)
    session.commit()
    return {"mensaje": "Permiso eliminado"}
