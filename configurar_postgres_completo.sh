#!/bin/bash
echo "🔧 =========================================="
echo "🔧 CONFIGURANDO POSTGRESQL PARA ELCAFESIN"
echo "🔧 =========================================="

# 1. Crear archivo de configuración nuevo
cat > /tmp/pg_hba_elcafesin.conf << 'EOF'
# PostgreSQL Client Authentication Configuration File - ELCAFESIN
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                trust
local   all             all                                     trust
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
local   replication     all                                     md5
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
EOF

# 2. Backup y reemplazar
echo "📦 Creando backup..."
sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.backup
echo "✅ Backup creado"

echo "📝 Aplicando nueva configuración..."
sudo cp /tmp/pg_hba_elcafesin.conf /etc/postgresql/16/main/pg_hba.conf
echo "✅ Configuración aplicada"

# 3. Reiniciar PostgreSQL
echo "🔄 Reiniciando PostgreSQL..."
sudo systemctl restart postgresql
sleep 2
echo "✅ PostgreSQL reiniciado"

# 4. Crear usuario y base de datos
echo ""
echo "🗄️ Creando usuario y base de datos..."
sudo -u postgres psql << 'EOSQL'
DROP DATABASE IF EXISTS almacen_cuantico;
DROP USER IF EXISTS barista_master;
CREATE USER barista_master WITH PASSWORD 'cafeteria_secreta_2025';
ALTER USER barista_master WITH SUPERUSER;
CREATE DATABASE almacen_cuantico OWNER barista_master;
EOSQL
echo "✅ Usuario y base de datos creados"

# 5. Verificar conexión
echo ""
echo "🔍 Verificando conexión al Almacén Cuántico..."
PGPASSWORD='cafeteria_secreta_2025' psql -h localhost -U barista_master -d almacen_cuantico -c "SELECT 'Conexión exitosa!' AS estado;"

echo ""
echo "🔧 =========================================="
echo "🔧 CONFIGURACIÓN COMPLETA"
echo "🔧 =========================================="
echo ""
echo "📝 Información de conexión:"
echo "   Host: localhost"
echo "   Puerto: 5432"
echo "   Base de datos: almacen_cuantico"
echo "   Usuario: barista_master"
echo "   Contraseña: cafeteria_secreta_2025"
echo ""
echo "🚀 ¡Listo para DESPEGAR!"
