#!/bin/bash
# 🚀 Script de inicio automático para el backend de El Café Sin Límites

# Colores para output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}🚀 Iniciando Backend - El Café Sin Límites${NC}"
echo -e "${CYAN}============================================${NC}"

# Cambiar al directorio del backend
cd "$(dirname "$0")/nucleo-api" || {
    echo -e "${RED}❌ Error: No se pudo encontrar el directorio nucleo-api${NC}"
    exit 1
}

# Verificar si el entorno virtual existe
if [ ! -d "cafeina-env" ]; then
    echo -e "${RED}❌ Error: No existe el entorno virtual cafeina-env${NC}"
    echo -e "${CYAN}Creando entorno virtual...${NC}"
    python3 -m venv cafeina-env
fi

# Activar entorno virtual
echo -e "${CYAN}📦 Activando entorno virtual...${NC}"
source cafeina-env/bin/activate

# Verificar si las dependencias están instaladas
echo -e "${CYAN}🔍 Verificando dependencias...${NC}"
if ! python -c "import fastapi" 2>/dev/null; then
    echo -e "${CYAN}📥 Instalando dependencias...${NC}"
    pip install -q -r dependencias-python.txt

    # Instalar cffi si es necesario
    if ! python -c "import cffi" 2>/dev/null; then
        pip install -q cffi
    fi
fi

# Verificar si el puerto 8000 está ocupado
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${RED}⚠️  El puerto 8000 ya está en uso${NC}"
    echo -e "${CYAN}Deseas detener el proceso existente? (s/n)${NC}"
    read -r respuesta
    if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
        kill $(lsof -t -i:8000) 2>/dev/null
        echo -e "${GREEN}✅ Proceso anterior detenido${NC}"
        sleep 2
    else
        echo -e "${RED}❌ No se puede iniciar el backend en un puerto ocupado${NC}"
        exit 1
    fi
fi

# Iniciar el servidor
echo -e "${GREEN}✅ Iniciando servidor en http://localhost:8000${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
python main.py
