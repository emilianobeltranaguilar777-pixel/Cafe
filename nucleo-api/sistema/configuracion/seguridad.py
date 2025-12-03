"""
🔐 SEGURIDAD Y AUTENTICACIÓN - ELCAFESIN
JWT, hashing de passwords, y sistema de permisos
"""
from datetime import datetime, timedelta
from typing import Optional, List
import bcrypt
from jose import jwt, JWTError
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlmodel import Session, select

from .ajustes import obtener_ajustes
from .base_datos import obtener_sesion

# Esquema OAuth2 (para el token Bearer)
esquema_oauth2 = OAuth2PasswordBearer(tokenUrl="/auth/login")

ajustes = obtener_ajustes()


# ==================== HASHING DE PASSWORDS ====================

def hash_password(password: str) -> str:
    """Hashea una contraseña usando bcrypt"""
    # Convertir a bytes y hashear
    password_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode('utf-8')


def verificar_password(password_plano: str, password_hash: str) -> bool:
    """Verifica si una contraseña coincide con su hash"""
    password_bytes = password_plano.encode('utf-8')
    hash_bytes = password_hash.encode('utf-8')
    return bcrypt.checkpw(password_bytes, hash_bytes)


# ==================== JWT TOKENS ====================

def crear_token(username: str, expires_delta: Optional[timedelta] = None, extra_data: dict = None) -> str:
    """
    Crea un token JWT
    
    Args:
        username: Nombre de usuario
        expires_delta: Tiempo de expiración (por defecto usa configuración)
        extra_data: Datos adicionales a incluir en el token (ej: rol)
    """
    to_encode = {"sub": username}
    
    if extra_data:
        to_encode.update(extra_data)
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ajustes.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    
    encoded_jwt = jwt.encode(to_encode, ajustes.SECRET_KEY, algorithm=ajustes.ALGORITHM)
    return encoded_jwt


def decodificar_token(token: str) -> dict:
    """
    Decodifica y valida un token JWT
    
    Raises:
        HTTPException: Si el token es inválido o expiró
    """
    try:
        payload = jwt.decode(token, ajustes.SECRET_KEY, algorithms=[ajustes.ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token inválido: no contiene username",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )


# ==================== OBTENER USUARIO ACTUAL ====================

async def obtener_usuario_actual(
    token: str = Depends(esquema_oauth2),
    session: Session = Depends(obtener_sesion)
):
    """
    Dependency: Obtiene el usuario autenticado desde el token
    
    Uso en endpoints:
        usuario_actual: Usuario = Depends(obtener_usuario_actual)
    """
    # Importación diferida para evitar imports circulares
    from sistema.entidades.usuario import Usuario
    
    payload = decodificar_token(token)
    username = payload.get("sub")
    
    # Buscar usuario en BD
    usuario = session.exec(
        select(Usuario).where(Usuario.username == username)
    ).first()
    
    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no encontrado"
        )
    
    if not usuario.activo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuario inactivo"
        )
    
    return usuario


# ==================== RESTRICCIÓN POR ROLES ====================

def requiere_roles(roles_permitidos: List[str]):
    """
    Dependency factory: Restringe acceso a ciertos roles
    
    Uso:
        @router.get("/admin", dependencies=[Depends(requiere_roles(["ADMIN", "DUENO"]))])
    """
    async def verificar_rol(usuario_actual = Depends(obtener_usuario_actual)):
        if usuario_actual.rol not in roles_permitidos:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Acceso denegado. Requiere uno de estos roles: {', '.join(roles_permitidos)}"
            )
        return usuario_actual
    
    return verificar_rol


# ==================== RESTRICCIÓN POR PERMISOS ====================

def requiere_permiso(recurso: str, accion: str):
    """
    Dependency factory: Verifica que el usuario tenga un permiso específico
    
    Uso:
        @router.post("/ventas", dependencies=[Depends(requiere_permiso("ventas", "crear"))])
    """
    async def verificar_permiso(
        usuario_actual = Depends(obtener_usuario_actual),
        session: Session = Depends(obtener_sesion)
    ):
        # Importaciones diferidas
        from sistema.entidades.permiso import PermisoRol, UsuarioPermiso
        
        # 1. Verificar si hay excepción específica para este usuario
        permiso_usuario = session.exec(
            select(UsuarioPermiso).where(
                UsuarioPermiso.usuario_id == usuario_actual.id,
                UsuarioPermiso.recurso == recurso,
                UsuarioPermiso.accion == accion
            )
        ).first()
        
        if permiso_usuario:
            # Si existe excepción, usarla
            if not permiso_usuario.permitido:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Permiso denegado: {recurso}.{accion}"
                )
            return usuario_actual
        
        # 2. Si no hay excepción, verificar permisos del rol
        permiso_rol = session.exec(
            select(PermisoRol).where(
                PermisoRol.rol == usuario_actual.rol,
                PermisoRol.recurso == recurso,
                PermisoRol.accion == accion
            )
        ).first()
        
        if not permiso_rol:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Permiso denegado: {recurso}.{accion}"
            )
        
        return usuario_actual
    
    return verificar_permiso
