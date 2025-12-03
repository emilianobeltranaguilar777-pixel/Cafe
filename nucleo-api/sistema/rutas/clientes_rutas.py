"""
👥 RUTAS DE CLIENTES - ELCAFESIN
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, or_
from typing import List, Optional

from sistema.configuracion import obtener_sesion, obtener_usuario_actual
from sistema.entidades import Cliente, Usuario

router = APIRouter(prefix="/clientes", tags=["👥 Clientes"])


@router.post("/", response_model=Cliente)
def crear_cliente(
    cliente: Cliente,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """➕ Crear nuevo cliente"""
    session.add(cliente)
    session.commit()
    session.refresh(cliente)
    return cliente


@router.get("/", response_model=List[Cliente])
def listar_clientes(
    q: Optional[str] = None,
    limit: int = Query(100, le=500),
    offset: int = 0,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """
    📋 Listar clientes con búsqueda
    - q: Buscar en nombre, correo, teléfono
    """
    query = select(Cliente)
    
    if q:
        query = query.where(
            or_(
                Cliente.nombre.contains(q),
                Cliente.correo.contains(q),
                Cliente.telefono.contains(q)
            )
        )
    
    query = query.offset(offset).limit(limit)
    clientes = session.exec(query).all()
    
    return clientes


@router.get("/{cliente_id}", response_model=Cliente)
def obtener_cliente(
    cliente_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """🔍 Obtener cliente por ID"""
    cliente = session.get(Cliente, cliente_id)
    
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    
    return cliente


@router.put("/{cliente_id}", response_model=Cliente)
def actualizar_cliente(
    cliente_id: int,
    datos: Cliente,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """✏️ Actualizar cliente"""
    cliente = session.get(Cliente, cliente_id)
    
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    
    cliente.nombre = datos.nombre
    cliente.correo = datos.correo
    cliente.telefono = datos.telefono
    cliente.direccion = datos.direccion
    cliente.alergias = datos.alergias
    
    session.add(cliente)
    session.commit()
    session.refresh(cliente)
    
    return cliente


@router.delete("/{cliente_id}")
def eliminar_cliente(
    cliente_id: int,
    session: Session = Depends(obtener_sesion),
    usuario_actual: Usuario = Depends(obtener_usuario_actual)
):
    """🗑️ Eliminar cliente"""
    cliente = session.get(Cliente, cliente_id)
    
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    
    session.delete(cliente)
    session.commit()
    
    return {"mensaje": "Cliente eliminado"}
