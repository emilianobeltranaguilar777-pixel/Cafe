#!/usr/bin/env python3
"""
Script para crear logs de ejemplo - ejecutar desde nucleo-api/
"""
import sys
from pathlib import Path

# Agregar el directorio al path
sys.path.insert(0, str(Path(__file__).parent))

from datetime import datetime, timedelta
import random
from sqlmodel import Session, select

from sistema.configuracion.base_datos import obtener_sesion
from sistema.entidades import (
    Usuario, LogSesion, Ingrediente, Movimiento, TipoMovimiento
)

def crear_logs_ejemplo():
    """Crea logs de ejemplo para testing"""
    print("🌱 Creando logs de ejemplo...")

    for session in obtener_sesion():
        try:
            # Obtener usuario admin
            usuarios = session.exec(select(Usuario)).all()
            if not usuarios:
                print("❌ No hay usuarios. Ejecuta el backend primero.")
                return

            usuario = usuarios[0]
            print(f"✅ Usuario encontrado: {usuario.username}")

            # Crear 10 logs de sesión
            acciones = ["LOGIN", "LOGOUT", "PASSWORD_CHANGE", "PROFILE_UPDATE"]
            ips = ["192.168.1.100", "192.168.1.101", "10.0.0.50"]

            for i in range(10):
                dias_atras = random.randint(0, 7)
                fecha = datetime.utcnow() - timedelta(days=dias_atras, hours=random.randint(0, 23))

                log = LogSesion(
                    usuario_id=usuario.id,
                    accion=random.choice(acciones),
                    ip=random.choice(ips),
                    user_agent="Mozilla/5.0 Test Browser",
                    exito=random.choice([True, True, True, False])  # 75% exitoso
                )
                session.add(log)
                session.flush()
                log.creado_en = fecha

            session.commit()
            print(f"✅ Creados 10 logs de sesión")

            # Crear ingredientes si no existen
            ingredientes = session.exec(select(Ingrediente)).all()
            if not ingredientes:
                print("📦 Creando ingredientes de ejemplo...")
                nombres = ["Café Arábica", "Leche Entera", "Azúcar", "Chocolate", "Vainilla"]
                for nombre in nombres:
                    ing = Ingrediente(
                        nombre=nombre,
                        stock=100.0,
                        min_stock=20.0,
                        unidad="kg" if "Azúcar" in nombre or "Café" in nombre else "litros"
                    )
                    session.add(ing)
                session.commit()
                ingredientes = session.exec(select(Ingrediente)).all()
                print(f"✅ Creados {len(ingredientes)} ingredientes")

            # Crear 15 movimientos de inventario
            tipos = [
                (TipoMovimiento.ENTRADA, "Proveedor: Café Premium SA"),
                (TipoMovimiento.ENTRADA, "Staff: María García - Gerente"),
                (TipoMovimiento.SALIDA, "Venta #1234"),
                (TipoMovimiento.AJUSTE, "Ajuste de inventario"),
                (TipoMovimiento.MERMA, "Producto vencido"),
            ]

            for i in range(15):
                dias_atras = random.randint(0, 7)
                fecha = datetime.utcnow() - timedelta(days=dias_atras, hours=random.randint(0, 23))

                tipo, referencia = random.choice(tipos)
                ingrediente = random.choice(ingredientes)

                cantidad = round(random.uniform(5.0, 50.0), 2)
                if tipo == TipoMovimiento.AJUSTE:
                    cantidad = round(random.uniform(-10.0, 10.0), 2)

                mov = Movimiento(
                    ingrediente_id=ingrediente.id,
                    tipo=tipo,
                    cantidad=cantidad,
                    referencia=f"{referencia} - {ingrediente.nombre}"
                )
                session.add(mov)
                session.flush()
                mov.creado_en = fecha

            session.commit()
            print(f"✅ Creados 15 movimientos de inventario")
            print("🎉 Logs de ejemplo creados exitosamente!")

        except Exception as e:
            print(f"❌ Error: {e}")
            session.rollback()
            raise

        break  # Solo necesitamos una iteración

if __name__ == "__main__":
    crear_logs_ejemplo()
