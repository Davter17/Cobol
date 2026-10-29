#!/bin/bash

# ============================================
# Script de Limpieza
# Elimina archivos compilados y temporales
# ============================================

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  LIMPIEZA DEL PROYECTO"
echo "=========================================="
echo ""

# Directorio de binarios
BIN_DIR="bin"

# Contador de archivos eliminados
ELIMINADOS=0

# Limpiar directorio bin/
if [ -d "$BIN_DIR" ]; then
    echo -e "${YELLOW}Limpiando directorio $BIN_DIR/...${NC}"
    rm -rf "$BIN_DIR"
    echo -e "${GREEN}✓ Directorio $BIN_DIR/ eliminado${NC}"
    ELIMINADOS=$((ELIMINADOS + 1))
fi

# Limpiar archivos de salida antiguos (opcional, descomentar si se desea)
# OUTPUT_DIR="output"
# if [ -d "$OUTPUT_DIR" ]; then
#     echo -e "${YELLOW}Limpiando archivos de salida...${NC}"
#     rm -f "$OUTPUT_DIR"/*.DAT
#     echo -e "${GREEN}✓ Archivos de salida eliminados${NC}"
# fi

# Limpiar backups antiguos (opcional)
# BACKUP_DIR="backups"
# if [ -d "$BACKUP_DIR" ]; then
#     echo -e "${YELLOW}Limpiando backups antiguos...${NC}"
#     find "$BACKUP_DIR" -name "*.DAT" -mtime +7 -delete
#     echo -e "${GREEN}✓ Backups antiguos eliminados${NC}"
# fi

echo ""
echo "=========================================="
echo "  RESUMEN DE LIMPIEZA"
echo "=========================================="
echo -e "${GREEN}✓ Limpieza completada${NC}"
echo ""
echo "Nota: Los archivos de datos (data/*.DAT) y"
echo "resultados (output/*.DAT) no se eliminan."
echo "Para eliminarlos manualmente:"
echo "  rm -f data/*.DAT output/*.DAT"
echo "=========================================="

exit 0
