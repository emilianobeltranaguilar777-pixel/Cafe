"""
📦 RUTAS DE PROVEEDORES - ELCAFESIN
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select
from typing import List, Optional

from sistema.configuracion import obtener_sesion, obtener_usuario_actual
from sistema.entidades import Proveedor, Usuario

router = APIRouter(prefix="/proveedores", tags=["📦 Proveedores"])


@router.post("/", response_model=Proveedor)
def crear_proveedor(
    proveedor: Proveedor,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """➕ Crear nuevo proveedor"""
    session.add(proveedor)
    session.commit()
    session.refresh(proveedor)
    return proveedor


@router.get("/", response_model=List[Proveedor])
def listar_proveedores(
    q: Optional[str] = None,
    limit: int = Query(100, le=500),
    offset: int = 0,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """📋 Listar proveedores con búsqueda"""
    query = select(Proveedor)
    
    if q:
        query = query.where(Proveedor.nombre.contains(q))
    
    query = query.offset(offset).limit(limit)
    proveedores = session.exec(query).all()
    
    return proveedores


@router.get("/{proveedor_id}", response_model=Proveedor)
def obtener_proveedor(
    proveedor_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """🔍 Obtener proveedor por ID"""
    proveedor = session.get(Proveedor, proveedor_id)
    
    if not proveedor:
        raise HTTPException(status_code=404, detail="Proveedor no encontrado")
    
    return proveedor


@router.put("/{proveedor_id}", response_model=Proveedor)
def actualizar_proveedor(
    proveedor_id: int,
    datos: Proveedor,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """✏️ Actualizar proveedor"""
    proveedor = session.get(Proveedor, proveedor_id)
    
    if not proveedor:
        raise HTTPException(status_code=404, detail="Proveedor no encontrado")
    
    proveedor.nombre = datos.nombre
    proveedor.empresa = datos.empresa
    proveedor.correo = datos.correo
    proveedor.telefono = datos.telefono
    proveedor.direccion = datos.direccion
    proveedor.notas = datos.notas
    
    session.add(proveedor)
    session.commit()
    session.refresh(proveedor)
    
    return proveedor


@router.delete("/{proveedor_id}")
def eliminar_proveedor(
    proveedor_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """🗑️ Eliminar proveedor"""
    proveedor = session.get(Proveedor, proveedor_id)
    
    if not proveedor:
        raise HTTPException(status_code=404, detail="Proveedor no encontrado")
    
    session.delete(proveedor)
    session.commit()
    
    return {"mensaje": "Proveedor eliminado"}
