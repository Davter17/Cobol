#!/bin/bash

# ============================================
# Script de Ejecución de la API REST
# Inicia la API FastAPI para el sistema bancario
# ============================================

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "  COBOL BANKING SYSTEM - API REST"
echo "=========================================="
echo ""

# Verificar que existe el directorio api
if [ ! -d "api" ]; then
    echo -e "${RED}ERROR: No existe el directorio api/${NC}"
    exit 1
fi

cd api

# Verificar que existe requirements.txt
if [ ! -f "requirements.txt" ]; then
    echo -e "${RED}ERROR: No existe api/requirements.txt${NC}"
    exit 1
fi

# Verificar si existe el entorno virtual
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Creando entorno virtual de Python...${NC}"
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: No se pudo crear el entorno virtual${NC}"
        echo "Asegúrate de tener Python 3.8+ instalado"
        exit 1
    fi
    echo -e "${GREEN}✓ Entorno virtual creado${NC}"
fi

# Activar entorno virtual
echo -e "${BLUE}Activando entorno virtual...${NC}"
source venv/bin/activate

# Instalar/actualizar dependencias
echo -e "${BLUE}Verificando dependencias...${NC}"
pip install -q -r requirements.txt
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: No se pudieron instalar las dependencias${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Dependencias instaladas${NC}"
echo ""

# Verificar que existen los ficheros de datos COBOL
echo -e "${BLUE}Verificando ficheros COBOL...${NC}"
cd ..
if [ ! -f "data/CUENTAS.DAT" ]; then
    echo -e "${YELLOW}ADVERTENCIA: data/CUENTAS.DAT no encontrado${NC}"
    echo "Ejecuta primero: ./scripts/generate-test-data.sh"
fi
if [ ! -f "output/REPORT.DAT" ]; then
    echo -e "${YELLOW}ADVERTENCIA: output/REPORT.DAT no encontrado${NC}"
    echo "Ejecuta primero: ./scripts/run.sh"
fi
cd api
echo ""

# Iniciar la API
echo "=========================================="
echo -e "${GREEN}✓ Iniciando API REST en puerto 8000${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}Documentación disponible en:${NC}"
echo "  • Swagger UI: http://localhost:8000/docs"
echo "  • ReDoc:      http://localhost:8000/redoc"
echo ""
echo -e "${BLUE}Endpoints principales:${NC}"
echo "  • GET /api/accounts      - Todas las cuentas"
echo "  • GET /api/accounts/{id} - Cuenta específica"
echo "  • GET /api/transactions  - Todas las transacciones"
echo "  • GET /api/audit         - Registros de auditoría"
echo "  • GET /api/report        - Resumen del reporte"
echo "  • GET /health            - Estado de salud"
echo ""
echo -e "${YELLOW}Presiona Ctrl+C para detener la API${NC}"
echo ""

# Ejecutar la API
python main.py
