#!/bin/bash

# ============================================
# Script de Ejecución del Batch Bancario
# Ejecuta BANKPROC con toda la seguridad
# ============================================

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  EJECUCIÓN BATCH BANCARIO"
echo "=========================================="
echo ""

# Verificar que existe el ejecutable en bin/
if [ ! -f "bin/BANKPROC" ]; then
    echo -e "${YELLOW}bin/BANKPROC no encontrado. Compilando...${NC}"
    ./scripts/compile.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Error en la compilación. Abortando.${NC}"
        exit 1
    fi
    echo ""
fi

# Verificar que existen los datos de entrada
if [ ! -f "data/CUENTAS.DAT" ]; then
    echo -e "${RED}✗ ERROR: No existe data/CUENTAS.DAT${NC}"
    echo "Ejecute scripts/generate-test-data.sh primero"
    exit 1
fi

if [ ! -f "data/MOVIMIENTOS.DAT" ]; then
    echo -e "${RED}✗ ERROR: No existe data/MOVIMIENTOS.DAT${NC}"
    echo "Ejecute scripts/generate-test-data.sh primero"
    exit 1
fi

# Crear directorio de output si no existe
mkdir -p output

# Backup de seguridad de CUENTAS.DAT
BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/CUENTAS_${TIMESTAMP}.DAT"

echo -e "${BLUE}Creando backup de seguridad...${NC}"
cp data/CUENTAS.DAT "$BACKUP_FILE"
echo -e "${GREEN}✓ Backup creado: $BACKUP_FILE${NC}"
echo ""

# Limpiar ficheros de salida anteriores
echo -e "${BLUE}Limpiando ficheros de salida anteriores...${NC}"
rm -f output/REPORT.DAT
rm -f output/AUDIT.DAT
rm -f output/ERRORS.DAT
rm -f output/HISTORICO.DAT
echo -e "${GREEN}✓ Ficheros de salida limpiados${NC}"
echo ""

# Ejecutar BANKPROC
echo "=========================================="
echo "  INICIANDO PROCESAMIENTO"
echo "=========================================="
echo ""

./bin/BANKPROC
EXIT_CODE=$?

echo ""
echo "=========================================="
echo "  PROCESAMIENTO FINALIZADO"
echo "=========================================="
echo ""

# Verificar código de retorno
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ BANKPROC ejecutado correctamente${NC}"
else
    echo -e "${RED}✗ BANKPROC terminó con código de error: $EXIT_CODE${NC}"
fi

echo ""

# Mostrar ficheros de salida generados
echo -e "${BLUE}FICHEROS DE SALIDA GENERADOS:${NC}"
echo "=========================================="

if [ -f "output/REPORT.DAT" ]; then
    echo -e "${GREEN}✓ output/REPORT.DAT${NC}     - Informe del procesamiento"
    echo ""
    echo "--- Contenido del informe ---"
    cat output/REPORT.DAT
    echo ""
    echo "-----------------------------"
else
    echo -e "${RED}✗ output/REPORT.DAT${NC}     - No generado"
fi

if [ -f "output/AUDIT.DAT" ]; then
    LINES=$(wc -l < output/AUDIT.DAT)
    echo -e "${GREEN}✓ output/AUDIT.DAT${NC}      - Registro de auditoría ($LINES movimientos)"
else
    echo -e "${RED}✗ output/AUDIT.DAT${NC}      - No generado"
fi

if [ -f "output/ERRORS.DAT" ]; then
    LINES=$(wc -l < output/ERRORS.DAT)
    echo -e "${GREEN}✓ output/ERRORS.DAT${NC}     - Registro de errores ($LINES errores)"
else
    echo -e "${RED}✗ output/ERRORS.DAT${NC}     - No generado"
fi

if [ -f "output/HISTORICO.DAT" ]; then
    LINES=$(wc -l < output/HISTORICO.DAT)
    echo -e "${GREEN}✓ output/HISTORICO.DAT${NC}  - Histórico de operaciones ($LINES operaciones)"
else
    echo -e "${RED}✗ output/HISTORICO.DAT${NC}  - No generado"
fi

echo ""
echo "=========================================="
echo -e "${BLUE}Backup de seguridad:${NC} $BACKUP_FILE"
echo -e "${YELLOW}Para restaurar:${NC} cp $BACKUP_FILE data/CUENTAS.DAT"
echo "=========================================="

exit $EXIT_CODE
