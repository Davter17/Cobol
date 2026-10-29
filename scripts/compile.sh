#!/bin/bash

# ============================================
# Script de Compilación COBOL
# Compila todos los programas del proyecto
# ============================================

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  COMPILADOR COBOL - BANCO"
echo "=========================================="
echo ""

# Contadores
TOTAL=0
EXITOS=0
ERRORES=0

# Directorios
COBOL_DIR="cobol"
COPYBOOK_DIR="copybooks"

# Verificar que existen los directorios
if [ ! -d "$COBOL_DIR" ]; then
    echo -e "${RED}ERROR: No existe el directorio $COBOL_DIR${NC}"
    exit 1
fi

if [ ! -d "$COPYBOOK_DIR" ]; then
    echo -e "${RED}ERROR: No existe el directorio $COPYBOOK_DIR${NC}"
    exit 1
fi

echo "Compilando programas COBOL..."
echo ""

# Compilar cada archivo .cob
for cob_file in "$COBOL_DIR"/*.cob; do
    if [ -f "$cob_file" ]; then
        TOTAL=$((TOTAL + 1))
        filename=$(basename "$cob_file" .cob)
        
        echo -n "Compilando $filename.cob... "
        
        # Compilar con cobc
        if cobc -x -free -I "$COPYBOOK_DIR" "$cob_file" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ OK${NC}"
            EXITOS=$((EXITOS + 1))
        else
            echo -e "${RED}✗ ERROR${NC}"
            ERRORES=$((ERRORES + 1))
            # Mostrar el error real
            cobc -x -free -I "$COPYBOOK_DIR" "$cob_file" 2>&1 | head -5
        fi
    fi
done

echo ""
echo "=========================================="
echo "  RESUMEN DE COMPILACIÓN"
echo "=========================================="
echo "Total programas:  $TOTAL"
echo -e "Compilados OK:    ${GREEN}$EXITOS${NC}"
echo -e "Errores:          ${RED}$ERRORES${NC}"
echo "=========================================="

# Salir con código de error si hubo fallos
if [ $ERRORES -gt 0 ]; then
    echo -e "${RED}✗ La compilación tuvo errores${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Todos los programas compilados correctamente${NC}"
    exit 0
fi
