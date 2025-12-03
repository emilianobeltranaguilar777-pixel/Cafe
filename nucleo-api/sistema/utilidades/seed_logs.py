"""
🌱 SEED DE LOGS DE EJEMPLO - ELCAFESIN
Carga datos de ejemplo para desarrollo y preview del visor de logs
"""
from sqlmodel import Session, select
from datetime import datetime, timedelta
import random

from sistema.entidades import (
    LogSesion, Usuario, Ingrediente, Movimiento, TipoMovimiento
)


def seed_logs_ejemplo(session: Session):
    """
    Crea logs de ejemplo para desarrollo
    Incluye logs de sesión y movimientos de inventario
    """
    print("🌱 Creando logs de ejemplo...")

    # Obtener usuarios existentes
    usuarios = session.exec(select(Usuario)).all()
    if not usuarios:
        print("   ⚠️  No hay usuarios. Crea usuarios primero.")
        return

    # Obtener ingredientes existentes
    ingredientes = session.exec(select(Ingrediente)).all()

    # ==================== LOGS DE SESIÓN ====================
    acciones_sesion = [
        ("LOGIN", True, "Inicio de sesión exitoso"),
        ("LOGIN", False, "Intento de login fallido"),
        ("LOGOUT", True, "Cierre de sesión"),
        ("PASSWORD_CHANGE", True, "Cambio de contraseña"),
        ("PROFILE_UPDATE", True, "Actualización de perfil"),
    ]

    ips_ejemplo = [
        "192.168.1.100",
        "192.168.1.101",
        "192.168.1.102",
        "10.0.0.50",
        "172.16.0.10"
    ]

    user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)",
        "Mozilla/5.0 (iPad; CPU OS 13_0 like Mac OS X)"
    ]

    # Crear 20 logs de sesión en los últimos 7 días
    logs_sesion_creados = 0
    for i in range(20):
        dias_atras = random.randint(0, 7)
        horas_atras = random.randint(0, 23)
        minutos_atras = random.randint(0, 59)

        fecha_log = datetime.utcnow() - timedelta(
            days=dias_atras,
            hours=horas_atras,
            minutes=minutos_atras
        )

        accion, exito, _ = random.choice(acciones_sesion)
        usuario = random.choice(usuarios)

        log = LogSesion(
            usuario_id=usuario.id,
            accion=accion,
            ip=random.choice(ips_ejemplo),
            user_agent=random.choice(user_agents),
            exito=exito
        )
        # Establecer fecha manualmente
        session.add(log)
        session.flush()
        log.creado_en = fecha_log

        logs_sesion_creados += 1

    session.commit()
    print(f"   ✅ {logs_sesion_creados} logs de sesión creados")

    # ==================== LOGS DE MOVIMIENTOS ====================
    if ingredientes:
        tipos_movimiento = [
            (TipoMovimiento.ENTRADA, "Reabastecimiento - Proveedor: Café Premium SA"),
            (TipoMovimiento.ENTRADA, "Reabastecimiento - Staff: María García (Gerente)"),
            (TipoMovimiento.ENTRADA, "Compra - Proveedor: Lácteos del Valle"),
            (TipoMovimiento.SALIDA, "Venta #1234 - Cliente: Restaurante El Buen Sabor"),
            (TipoMovimiento.SALIDA, "Consumo interno - Staff: Juan Pérez"),
            (TipoMovimiento.AJUSTE, "Ajuste de inventario - Staff: Ana López (Supervisor)"),
            (TipoMovimiento.AJUSTE, "Corrección de stock - Sistema automático"),
            (TipoMovimiento.MERMA, "Merma por vencimiento - Staff: Carlos Ruiz"),
            (TipoMovimiento.MERMA, "Producto dañado - Staff: Laura Martínez"),
        ]

        # Crear 30 movimientos de inventario en los últimos 7 días
        movimientos_creados = 0
        for i in range(30):
            dias_atras = random.randint(0, 7)
            horas_atras = random.randint(0, 23)
            minutos_atras = random.randint(0, 59)

            fecha_mov = datetime.utcnow() - timedelta(
                days=dias_atras,
                hours=horas_atras,
                minutes=minutos_atras
            )

            tipo, referencia = random.choice(tipos_movimiento)
            ingrediente = random.choice(ingredientes)

            # Cantidad varía según el tipo
            if tipo == TipoMovimiento.ENTRADA:
                cantidad = round(random.uniform(10.0, 200.0), 2)
            elif tipo == TipoMovimiento.SALIDA:
                cantidad = round(random.uniform(5.0, 50.0), 2)
            elif tipo == TipoMovimiento.AJUSTE:
                cantidad = round(random.uniform(-10.0, 10.0), 2)
            else:  # MERMA
                cantidad = round(random.uniform(1.0, 20.0), 2)

            movimiento = Movimiento(
                ingrediente_id=ingrediente.id,
                tipo=tipo,
                cantidad=cantidad,
                referencia=referencia
            )
            session.add(movimiento)
            session.flush()
            movimiento.creado_en = fecha_mov

            movimientos_creados += 1

        session.commit()
        print(f"   ✅ {movimientos_creados} movimientos de inventario creados")
    else:
        print("   ⚠️  No hay ingredientes. Los movimientos de inventario no se crearon.")

    print("🎉 Logs de ejemplo creados exitosamente")


def limpiar_logs_ejemplo(session: Session):
    """Elimina todos los logs (útil para resetear datos de desarrollo)"""
    print("🧹 Limpiando logs...")

    # Eliminar logs de sesión
    logs_sesion = session.exec(select(LogSesion)).all()
    for log in logs_sesion:
        session.delete(log)

    # Eliminar movimientos
    movimientos = session.exec(select(Movimiento)).all()
    for mov in movimientos:
        session.delete(mov)

    session.commit()
    print("✅ Logs limpiados")


if __name__ == "__main__":
    """Ejecutar este script directamente para crear logs de ejemplo"""
    from sistema.configuracion.base_datos import obtener_sesion

    print("=" * 60)
    print("🌱 SEED DE LOGS DE EJEMPLO")
    print("=" * 60)

    for session in obtener_sesion():
        try:
            seed_logs_ejemplo(session)
            print("\n✅ Proceso completado exitosamente")
        except Exception as e:
            print(f"\n❌ Error: {e}")
            session.rollback()
        break
