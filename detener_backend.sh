#!/bin/bash
# 🛑 Script para detener el backend de El Café Sin Límites

# Colores para output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}🛑 Deteniendo Backend - El Café Sin Límites${NC}"
echo -e "${CYAN}============================================${NC}"

# Verificar si el puerto 8000 está en uso
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${CYAN}📍 Encontrado proceso en puerto 8000...${NC}"

    # Obtener el PID del proceso
    PID=$(lsof -t -i:8000)

    # Detener el proceso
    kill $PID 2>/dev/null

    # Esperar un momento para que se detenga
    sleep 2

    # Verificar si se detuvo
    if ! lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend detenido correctamente${NC}"
    else
        echo -e "${RED}⚠️  El proceso no se detuvo, forzando...${NC}"
        kill -9 $PID 2>/dev/null
        echo -e "${GREEN}✅ Backend detenido forzosamente${NC}"
    fi
else
    echo -e "${RED}❌ No hay ningún proceso corriendo en el puerto 8000${NC}"
fi

echo -e "${CYAN}============================================${NC}"
