#!/bin/bash

# ============================================
# Script de Verificación de Integridad
# Verifica que los datos sean consistentes
# ============================================

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "  VERIFICACIÓN DE INTEGRIDAD"
echo "=========================================="
echo ""

PASS=0
FAIL=0

check_integrity() {
    local description=$1
    local result=$2
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ $description${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}✗ $description${NC}"
        FAIL=$((FAIL + 1))
    fi
}

# ============================================
# Verificación 1: Total de movimientos procesados
# ============================================
echo -e "${BLUE}1. Verificando total de movimientos...${NC}"

TOTAL_MOV=$(wc -l < data/MOVIMIENTOS.DAT)
AUDIT_LINES=$(wc -l < output/AUDIT.DAT)

if [ "$TOTAL_MOV" -eq "$AUDIT_LINES" ]; then
    check_integrity "Todos los movimientos procesados ($TOTAL_MOV = $AUDIT_LINES)" "PASS"
else
    check_integrity "Todos los movimientos procesados ($TOTAL_MOV ≠ $AUDIT_LINES)" "FAIL"
fi

echo ""

# ============================================
# Verificación 2: Movimientos aceptados + rechazados = total
# ============================================
echo -e "${BLUE}2. Verificando suma de aceptados y rechazados...${NC}"

ACCEPTED=$(grep -c "K" output/AUDIT.DAT)
REJECTED=$(grep -c "E00" output/AUDIT.DAT)
SUM=$((ACCEPTED + REJECTED))

if [ "$SUM" -eq "$TOTAL_MOV" ]; then
    check_integrity "Aceptados + Rechazados = Total ($ACCEPTED + $REJECTED = $TOTAL_MOV)" "PASS"
else
    check_integrity "Aceptados + Rechazados = Total ($SUM ≠ $TOTAL_MOV)" "FAIL"
fi

echo ""

# ============================================
# Verificación 3: Errores en ERRORS.DAT coinciden con AUDIT.DAT
# ============================================
echo -e "${BLUE}3. Verificando consistencia de errores...${NC}"

ERRORS_LINES=$(wc -l < output/ERRORS.DAT)

if [ "$ERRORS_LINES" -eq "$REJECTED" ]; then
    check_integrity "Errores en ERRORS.DAT coinciden con AUDIT.DAT ($ERRORS_LINES = $REJECTED)" "PASS"
else
    check_integrity "Errores en ERRORS.DAT coinciden con AUDIT.DAT ($ERRORS_LINES ≠ $REJECTED)" "FAIL"
fi

echo ""

# ============================================
# Verificación 4: Tipos de error esperados
# ============================================
echo -e "${BLUE}4. Verificando tipos de error...${NC}"

E001_COUNT=$(grep -c "E001" output/ERRORS.DAT)
E002_COUNT=$(grep -c "E002" output/ERRORS.DAT)
E003_COUNT=$(grep -c "E003" output/ERRORS.DAT)
E004_COUNT=$(grep -c "E004" output/ERRORS.DAT)
E006_COUNT=$(grep -c "E006" output/ERRORS.DAT)
E007_COUNT=$(grep -c "E007" output/ERRORS.DAT)

if [ "$E001_COUNT" -gt 0 ]; then
    check_integrity "E001 (Cuenta no encontrada): $E001_COUNT casos" "PASS"
else
    check_integrity "E001 (Cuenta no encontrada): 0 casos" "FAIL"
fi

if [ "$E002_COUNT" -gt 0 ]; then
    check_integrity "E002 (Saldo insuficiente): $E002_COUNT casos" "PASS"
else
    check_integrity "E002 (Saldo insuficiente): 0 casos" "FAIL"
fi

if [ "$E003_COUNT" -gt 0 ]; then
    check_integrity "E003 (Cuenta bloqueada): $E003_COUNT casos" "PASS"
else
    check_integrity "E003 (Cuenta bloqueada): 0 casos" "FAIL"
fi

if [ "$E004_COUNT" -gt 0 ]; then
    check_integrity "E004 (Importe inválido): $E004_COUNT casos" "PASS"
else
    check_integrity "E004 (Importe inválido): 0 casos" "FAIL"
fi

if [ "$E006_COUNT" -gt 0 ]; then
    check_integrity "E006 (Cuenta inactiva): $E006_COUNT casos" "PASS"
else
    check_integrity "E006 (Cuenta inactiva): 0 casos" "FAIL"
fi

if [ "$E007_COUNT" -gt 0 ]; then
    check_integrity "E007 (Límite diario): $E007_COUNT casos" "PASS"
else
    check_integrity "E007 (Límite diario): 0 casos" "FAIL"
fi

echo ""

# ============================================
# Verificación 5: HISTORICO.DAT contiene solo movimientos aceptados
# ============================================
echo -e "${BLUE}5. Verificando HISTORICO.DAT...${NC}"

HISTORIC_LINES=$(wc -l < output/HISTORICO.DAT)

if [ "$HISTORIC_LINES" -eq "$ACCEPTED" ]; then
    check_integrity "HISTORICO.DAT contiene solo movimientos aceptados ($HISTORIC_LINES = $ACCEPTED)" "PASS"
else
    check_integrity "HISTORICO.DAT contiene solo movimientos aceptados ($HISTORIC_LINES ≠ $ACCEPTED)" "FAIL"
fi

echo ""

# ============================================
# Verificación 6: REPORT.DAT existe y tiene estructura correcta
# ============================================
echo -e "${BLUE}6. Verificando REPORT.DAT...${NC}"

if [ -f output/REPORT.DAT ]; then
    check_integrity "REPORT.DAT existe" "PASS"
    
    if grep -q "DAILY BANKING REPORT" output/REPORT.DAT; then
        check_integrity "REPORT.DAT tiene cabecera correcta" "PASS"
    else
        check_integrity "REPORT.DAT tiene cabecera correcta" "FAIL"
    fi
    
    if grep -q "PROCESSING SUMMARY" output/REPORT.DAT; then
        check_integrity "REPORT.DAT tiene sección de resumen" "PASS"
    else
        check_integrity "REPORT.DAT tiene sección de resumen" "FAIL"
    fi
    
    if grep -q "END OF REPORT" output/REPORT.DAT; then
        check_integrity "REPORT.DAT tiene pie correcto" "PASS"
    else
        check_integrity "REPORT.DAT tiene pie correcto" "FAIL"
    fi
else
    check_integrity "REPORT.DAT existe" "FAIL"
fi

echo ""

# ============================================
# Verificación 7: Números formateados correctamente
# ============================================
echo -e "${BLUE}7. Verificando formato de números...${NC}"

if grep -q ",.*\..*EUR" output/REPORT.DAT; then
    check_integrity "Números con separadores de miles" "PASS"
else
    check_integrity "Números con separadores de miles" "FAIL"
fi

echo ""

# ============================================
# Resumen
# ============================================
echo "=========================================="
echo "  RESUMEN DE INTEGRIDAD"
echo "=========================================="
echo -e "${GREEN}Pruebas PASADAS: $PASS${NC}"
echo -e "${RED}Pruebas FALLIDAS: $FAIL${NC}"
echo "=========================================="

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ TODAS LAS VERIFICACIONES DE INTEGRIDAD PASARON${NC}"
    exit 0
else
    echo -e "${RED}✗ ALGUNAS VERIFICACIONES FALLARON${NC}"
    exit 1
fi
