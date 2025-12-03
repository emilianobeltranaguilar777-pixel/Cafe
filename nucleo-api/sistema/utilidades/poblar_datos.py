"""
📦 SCRIPT PARA POBLAR BASE DE DATOS - ELCAFESIN
Crea datos de prueba realistas para el sistema
"""
from sqlmodel import Session, select
from sistema.configuracion.base_datos import engine
from sistema.entidades import (
    Cliente, Proveedor, Ingrediente, Receta, RecetaItem,
    Venta, VentaItem, Movimiento, TipoMovimiento
)
from datetime import datetime, timedelta
import random


def poblar_proveedores(session: Session):
    """Crear proveedores"""
    proveedores = [
        Proveedor(
            nombre="Juan Pérez",
            empresa="Café Premium S.A.",
            correo="juan@cafepremium.com",
            telefono="442-123-4567",
            direccion="Av. 5 de Febrero 123, Querétaro",
            notas="Proveedor principal de café"
        ),
        Proveedor(
            nombre="María González",
            empresa="Lácteos del Valle",
            correo="maria@lacteosv.com",
            telefono="442-234-5678",
            direccion="Blvd. Bernardo Quintana 456, Querétaro",
            notas="Entrega diaria de lácteos"
        ),
        Proveedor(
            nombre="Carlos Rodríguez",
            empresa="Distribuidora Azúcar Dulce",
            correo="carlos@azucardulce.com",
            telefono="442-345-6789",
            direccion="Calle Zaragoza 789, Querétaro"
        )
    ]
    
    for proveedor in proveedores:
        session.add(proveedor)
    
    session.commit()
    print(f"✅ {len(proveedores)} proveedores creados")
    return proveedores


def poblar_ingredientes(session: Session, proveedores: list):
    """Crear ingredientes"""
    ingredientes_data = [
        # Café
        ("Café Arábica Premium", "kg", 350.00, 25.0, 5.0, proveedores[0].id),
        ("Café Robusta", "kg", 280.00, 20.0, 5.0, proveedores[0].id),
        
        # Lácteos
        ("Leche Entera", "l", 22.00, 50.0, 10.0, proveedores[1].id),
        ("Leche Descremada", "l", 24.00, 30.0, 8.0, proveedores[1].id),
        ("Crema para batir", "l", 85.00, 15.0, 3.0, proveedores[1].id),
        
        # Endulzantes
        ("Azúcar Refinada", "kg", 18.00, 40.0, 10.0, proveedores[2].id),
        ("Miel de Abeja", "kg", 120.00, 8.0, 2.0, proveedores[2].id),
        ("Stevia", "kg", 450.00, 3.0, 1.0, proveedores[2].id),
        
        # Saborizantes
        ("Jarabe de Vainilla", "l", 95.00, 12.0, 3.0, proveedores[0].id),
        ("Jarabe de Caramelo", "l", 98.00, 10.0, 2.0, proveedores[0].id),
        ("Chocolate en polvo", "kg", 180.00, 15.0, 3.0, proveedores[1].id),
        
        # Otros
        ("Canela en polvo", "kg", 250.00, 2.0, 0.5, proveedores[2].id),
        ("Hielo", "kg", 5.00, 100.0, 20.0, proveedores[1].id),
    ]
    
    ingredientes = []
    for nombre, unidad, costo, stock, min_stock, prov_id in ingredientes_data:
        ing = Ingrediente(
            nombre=nombre,
            unidad=unidad,
            costo_por_unidad=costo,
            stock=stock,
            min_stock=min_stock,
            proveedor_id=prov_id
        )
        session.add(ing)
        ingredientes.append(ing)
    
    session.commit()
    print(f"✅ {len(ingredientes)} ingredientes creados")
    return ingredientes


def poblar_recetas(session: Session, ingredientes: list):
    """Crear recetas de bebidas"""
    # Obtener ingredientes por nombre para facilidad
    ings = {ing.nombre: ing for ing in ingredientes}
    
    recetas_data = [
        # (nombre, descripción, margen, [(ingrediente, cantidad, merma)])
        (
            "Cappuccino Clásico",
            "Espresso con leche vaporizada y espuma",
            0.50,
            [
                (ings["Café Arábica Premium"], 0.018, 0.05),  # 18g de café
                (ings["Leche Entera"], 0.150, 0.02),  # 150ml de leche
                (ings["Azúcar Refinada"], 0.010, 0.0),  # 10g azúcar opcional
            ]
        ),
        (
            "Latte Vainilla",
            "Café latte con jarabe de vainilla",
            0.55,
            [
                (ings["Café Arábica Premium"], 0.018, 0.05),
                (ings["Leche Entera"], 0.200, 0.02),
                (ings["Jarabe de Vainilla"], 0.030, 0.0),
            ]
        ),
        (
            "Mocha Chocolate",
            "Espresso con chocolate y leche",
            0.60,
            [
                (ings["Café Arábica Premium"], 0.018, 0.05),
                (ings["Leche Entera"], 0.180, 0.02),
                (ings["Chocolate en polvo"], 0.025, 0.0),
                (ings["Crema para batir"], 0.030, 0.0),
            ]
        ),
        (
            "Americano",
            "Espresso con agua caliente",
            0.45,
            [
                (ings["Café Arábica Premium"], 0.018, 0.05),
            ]
        ),
        (
            "Café con Leche",
            "Café con leche tradicional",
            0.40,
            [
                (ings["Café Robusta"], 0.015, 0.05),
                (ings["Leche Entera"], 0.150, 0.02),
                (ings["Azúcar Refinada"], 0.010, 0.0),
            ]
        ),
        (
            "Frappé Caramelo",
            "Bebida fría de café con caramelo",
            0.65,
            [
                (ings["Café Arábica Premium"], 0.018, 0.05),
                (ings["Leche Entera"], 0.200, 0.02),
                (ings["Jarabe de Caramelo"], 0.040, 0.0),
                (ings["Hielo"], 0.150, 0.1),
                (ings["Crema para batir"], 0.040, 0.0),
            ]
        ),
    ]
    
    recetas = []
    for nombre, desc, margen, items in recetas_data:
        receta = Receta(
            nombre=nombre,
            descripcion=desc,
            margen=margen
        )
        session.add(receta)
        session.commit()
        session.refresh(receta)
        
        # Agregar items
        for ingrediente, cantidad, merma in items:
            item = RecetaItem(
                receta_id=receta.id,
                ingrediente_id=ingrediente.id,
                cantidad=cantidad,
                merma=merma
            )
            session.add(item)
        
        session.commit()
        recetas.append(receta)
    
    print(f"✅ {len(recetas)} recetas creadas")
    return recetas


def poblar_clientes(session: Session):
    """Crear clientes"""
    clientes_data = [
        ("Ana Martínez", "ana.martinez@email.com", "442-111-2222", "Av. Universidad 100", None),
        ("Luis Hernández", "luis.h@email.com", "442-222-3333", "Calle Madero 200", "Intolerante a lactosa"),
        ("Carmen Soto", "carmen.s@email.com", "442-333-4444", "Blvd. Zaragoza 300", None),
        ("Roberto Jiménez", "roberto.j@email.com", "442-444-5555", "Av. Constituyentes 400", None),
        ("Patricia López", "patricia.l@email.com", "442-555-6666", "Calle 16 de Septiembre 500", "Alérgica a la canela"),
    ]
    
    clientes = []
    for nombre, correo, tel, dir, alergias in clientes_data:
        cliente = Cliente(
            nombre=nombre,
            correo=correo,
            telefono=tel,
            direccion=dir,
            alergias=alergias
        )
        session.add(cliente)
        clientes.append(cliente)
    
    session.commit()
    print(f"✅ {len(clientes)} clientes creados")
    return clientes


def poblar_ventas(session: Session, recetas: list, clientes: list):
    """Crear ventas de ejemplo de los últimos 7 días"""
    print("📊 Generando ventas de los últimos 7 días...")
    
    ventas_creadas = 0
    
    for dias_atras in range(7):
        fecha = datetime.utcnow() - timedelta(days=dias_atras)
        
        # 5-15 ventas por día
        num_ventas_dia = random.randint(5, 15)
        
        for _ in range(num_ventas_dia):
            # Cliente aleatorio (70% con cliente, 30% sin cliente)
            cliente_id = random.choice(clientes).id if random.random() > 0.3 else None
            
            # Sucursal
            sucursal = random.choice(["Centro", "Plaza Juriquilla", "Antea"])
            
            # Crear venta
            venta = Venta(
                cliente_id=cliente_id,
                sucursal=sucursal,
                total=0.0,
                creado_en=fecha
            )
            session.add(venta)
            session.commit()
            session.refresh(venta)
            
            # 1-3 items por venta
            num_items = random.randint(1, 3)
            total_venta = 0.0
            
            for _ in range(num_items):
                receta = random.choice(recetas)
                cantidad = random.randint(1, 3)
                
                # Calcular precio (simplificado - en producción usaría el endpoint)
                receta_items = session.exec(
                    select(RecetaItem).where(RecetaItem.receta_id == receta.id)
                ).all()
                
                costo_receta = 0.0
                for item in receta_items:
                    ing = session.get(Ingrediente, item.ingrediente_id)
                    if ing:
                        costo_receta += item.cantidad * (1 + item.merma) * ing.costo_por_unidad
                
                precio_unitario = costo_receta * (1 + receta.margen)
                subtotal = precio_unitario * cantidad
                
                venta_item = VentaItem(
                    venta_id=venta.id,
                    receta_id=receta.id,
                    cantidad=cantidad,
                    precio_unitario=precio_unitario,
                    subtotal=subtotal
                )
                session.add(venta_item)
                total_venta += subtotal
            
            # Actualizar total
            venta.total = total_venta
            session.add(venta)
            session.commit()
            
            ventas_creadas += 1
    
    print(f"✅ {ventas_creadas} ventas creadas")


def main():
    """Ejecutar población de datos"""
    print("=" * 60)
    print("📦 POBLANDO BASE DE DATOS - ELCAFESIN")
    print("=" * 60)
    
    session = Session(engine)
    
    try:
        # Verificar si ya hay datos
        existe_proveedores = session.exec(select(Proveedor)).first()
        if existe_proveedores:
            print("⚠️  Ya existen datos en la base de datos")
            respuesta = input("¿Deseas continuar y agregar más datos? (s/n): ")
            if respuesta.lower() != 's':
                print("❌ Operación cancelada")
                return
        
        # Poblar datos
        proveedores = poblar_proveedores(session)
        ingredientes = poblar_ingredientes(session, proveedores)
        recetas = poblar_recetas(session, ingredientes)
        clientes = poblar_clientes(session)
        poblar_ventas(session, recetas, clientes)
        
        print("\n" + "=" * 60)
        print("🎉 BASE DE DATOS POBLADA EXITOSAMENTE")
        print("=" * 60)
        print(f"📊 Resumen:")
        print(f"   - {len(proveedores)} proveedores")
        print(f"   - {len(ingredientes)} ingredientes")
        print(f"   - {len(recetas)} recetas")
        print(f"   - {len(clientes)} clientes")
        print(f"   - ~70-100 ventas de ejemplo")
        print("=" * 60)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        session.rollback()
    finally:
        session.close()


if __name__ == "__main__":
    main()
