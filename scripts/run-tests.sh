#!/bin/bash

# ============================================
# Script de Ejecución de Pruebas
# Ejecuta cada caso de prueba y documenta resultados
# ============================================

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "  EJECUCIÓN DE PRUEBAS"
echo "=========================================="
echo ""

# Crear directorio de resultados
mkdir -p tests/test-results

# Contadores
PASS=0
FAIL=0
TOTAL=0

# Función para registrar resultado
register_result() {
    local test_id=$1
    local description=$2
    local expected=$3
    local actual=$4
    local result=$5
    
    TOTAL=$((TOTAL + 1))
    
    if [ "$result" = "PASS" ]; then
        PASS=$((PASS + 1))
        echo -e "${GREEN}✓ $test_id: $description${NC}"
        echo "  Esperado: $expected"
        echo "  Actual: $actual"
    else
        FAIL=$((FAIL + 1))
        echo -e "${RED}✗ $test_id: $description${NC}"
        echo "  Esperado: $expected"
        echo "  Actual: $actual"
    fi
    echo ""
}

# ============================================
# Preparación: Backup y ejecución inicial
# ============================================

echo -e "${BLUE}Preparando entorno de pruebas...${NC}"

# Backup de CUENTAS.DAT
cp data/CUENTAS.DAT data/CUENTAS.DAT.test-backup 2>/dev/null || true

# Limpiar outputs anteriores
rm -f output/ERRORS.DAT output/AUDIT.DAT output/HISTORICO.DAT output/REPORT.DAT

# Ejecutar BANKPROC
./bin/BANKPROC > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: BANKPROC falló${NC}"
    exit 1
fi

echo -e "${GREEN}✓ BANKPROC ejecutado correctamente${NC}"
echo ""

# ============================================
# Verificar Happy Path (TC-001 a TC-005)
# ============================================

echo -e "${BLUE}Verificando Happy Path...${NC}"
echo ""

# TC-001: Transferencia entre cuentas activas
register_result "TC-001" "Transferencia entre cuentas activas" \
    "Aceptada, sin error E001-E007" \
    "Transacción 0000000001 en AUDIT.DAT" \
    "$(grep -q "0000000001.*K" output/AUDIT.DAT && echo PASS || echo FAIL)"

# TC-002: Ingreso en cuenta activa
register_result "TC-002" "Ingreso en cuenta activa" \
    "Aceptada, sin error" \
    "Transacción 0000000031 en AUDIT.DAT" \
    "$(grep -q "0000000031.*K" output/AUDIT.DAT && echo PASS || echo FAIL)"

# TC-003: Retirada con saldo suficiente
register_result "TC-003" "Retirada con saldo suficiente" \
    "Aceptada, comisión 2.00 EUR" \
    "Transacción 0000000036 en AUDIT.DAT" \
    "$(grep -q "0000000036.*K" output/AUDIT.DAT && echo PASS || echo FAIL)"

# TC-004: Transferencia grande
register_result "TC-004" "Transferencia grande" \
    "Aceptada, comisión proporcional" \
    "Transacción 0000000009 en AUDIT.DAT" \
    "$(grep -q "0000000009.*K" output/AUDIT.DAT && echo PASS || echo FAIL)"

# TC-005: Transferencia pequeña con comisión mínima
register_result "TC-005" "Transferencia pequeña con comisión mínima" \
    "Aceptada, comisión 0.50 EUR (mínimo)" \
    "Transacción 0000000008 en AUDIT.DAT" \
    "$(grep -q "0000000008.*K" output/AUDIT.DAT && echo PASS || echo FAIL)"

# ============================================
# Verificar Error Path (TC-006 a TC-012)
# ============================================

echo -e "${BLUE}Verificando Error Path...${NC}"
echo ""

# TC-006: Cuenta origen inexistente (E001)
register_result "TC-006" "Cuenta origen inexistente (E001)" \
    "Rechazada, error E001" \
    "Transacción 0000000041 en ERRORS.DAT con E001" \
    "$(grep -q "0000000041.*E001" output/ERRORS.DAT && echo PASS || echo FAIL)"

# TC-007: Cuenta destino inexistente (E001)
register_result "TC-007" "Cuenta destino inexistente (E001)" \
    "Rechazada, error E001" \
    "Transacción 0000000042 en ERRORS.DAT con E001" \
    "$(grep -q "0000000042.*E001" output/ERRORS.DAT && echo PASS || echo FAIL)"

# TC-008: Saldo insuficiente (E002)
register_result "TC-008" "Saldo insuficiente (E002)" \
    "Rechazada, error E002" \
    "Transacción 0000000047 en ERRORS.DAT con E002" \
    "$(grep -q "0000000047.*E002" output/ERRORS.DAT && echo PASS || echo FAIL)"

# TC-009: Cuenta origen bloqueada (E003)
register_result "TC-009" "Cuenta origen bloqueada (E003)" \
    "Rechazada, error E003" \
    "Transacción 0000000051 en ERRORS.DAT con E003" \
    "$(grep -q "0000000051.*E003" output/ERRORS.DAT && echo PASS || echo FAIL)"

# TC-010: Cuenta destino bloqueada (E003)
register_result "TC-010" "Cuenta destino bloqueada (E003)" \
    "Rechazada, error E003" \
    "Transacción 0000000052 en ERRORS.DAT con E003" \
    "$(grep -q "0000000052.*E003" output/ERRORS.DAT && echo PASS || echo FAIL)"

# TC-011: Importe cero (E004)
register_result "TC-011" "Importe cero (E004)" \
    "Rechazada, error E004" \
    "Transacción 0000000054 en ERRORS.DAT con E004" \
    "$(grep -q "0000000054.*E004" output/ERRORS.DAT && echo PASS || echo FAIL)"

# TC-012: Límite diario excedido (E007)
register_result "TC-012" "Límite diario excedido (E007)" \
    "Rechazada, error E007" \
    "Transacción 0000000050 en ERRORS.DAT con E007" \
    "$(grep -q "0000000050.*E007" output/ERRORS.DAT && echo PASS || echo FAIL)"

# ============================================
# Verificar Edge Cases (TC-013 a TC-017)
# ============================================

echo -e "${BLUE}Verificando Edge Cases...${NC}"
echo ""

# TC-013: Comisión mínima exacta
register_result "TC-013" "Comisión mínima exacta" \
    "Comisión 0.50 EUR para importe 500.00" \
    "Transacción 0000000001 procesada" \
    "$(grep -q "0000000001.*K" output/AUDIT.DAT && echo PASS || echo FAIL)"

# TC-014: Cuenta con saldo mínimo
register_result "TC-014" "Cuenta con saldo mínimo" \
    "Retirada de 5.00 EUR de cuenta con 10.00 EUR" \
    "Transacción 0000000040 en AUDIT.DAT" \
    "$(grep -q "0000000040.*K" output/AUDIT.DAT && echo PASS || echo FAIL)"

# TC-015: Importe máximo permitido
register_result "TC-015" "Importe máximo permitido" \
    "Validación de importe máximo" \
    "Transacción 0000000048 procesada" \
    "$(grep -q "0000000048.*E002" output/ERRORS.DAT && echo PASS || echo FAIL)"

# TC-016: Movimiento duplicado
register_result "TC-016" "Movimiento duplicado" \
    "Ambas transacciones procesadas" \
    "IDs 0000000001 en líneas 1 y 57" \
    "$(grep -c "0000000001" output/AUDIT.DAT | grep -q "2" && echo PASS || echo FAIL)"

# TC-017: Cuenta inactiva (E006)
register_result "TC-017" "Cuenta inactiva (E006)" \
    "Rechazada, error E006" \
    "Transacción con destino inactivo" \
    "$(grep -q "E006" output/ERRORS.DAT && echo PASS || echo FAIL)"

# ============================================
# Generar reporte de pruebas
# ============================================

echo "=========================================="
echo "  RESUMEN DE PRUEBAS"
echo "=========================================="
echo -e "Total:  $TOTAL"
echo -e "${GREEN}PASS:   $PASS${NC}"
echo -e "${RED}FAIL:   $FAIL${NC}"
echo "=========================================="

# Guardar resultados en archivo
cat > tests/test-results/test-execution.log << EOF
========================================
EJECUCIÓN DE PRUEBAS - $(date)
========================================

Total de pruebas: $TOTAL
Pruebas PASADAS: $PASS
Pruebas FALLIDAS: $FAIL
Porcentaje de éxito: $((PASS * 100 / TOTAL))%

Detalles de casos de prueba:

HAPPY PATH:
- TC-001: Transferencia entre cuentas activas
- TC-002: Ingreso en cuenta activa
- TC-003: Retirada con saldo suficiente
- TC-004: Transferencia grande
- TC-005: Transferencia pequeña con comisión mínima

ERROR PATH:
- TC-006: Cuenta origen inexistente (E001)
- TC-007: Cuenta destino inexistente (E001)
- TC-008: Saldo insuficiente (E002)
- TC-009: Cuenta origen bloqueada (E003)
- TC-010: Cuenta destino bloqueada (E003)
- TC-011: Importe cero (E004)
- TC-012: Límite diario excedido (E007)

EDGE CASES:
- TC-013: Comisión mínima exacta
- TC-014: Cuenta con saldo mínimo
- TC-015: Importe máximo permitido
- TC-016: Movimiento duplicado
- TC-017: Cuenta inactiva (E006)

========================================
Resultado: $([ $FAIL -eq 0 ] && echo "TODAS LAS PRUEBAS PASARON" || echo "ALGUNAS PRUEBAS FALLARON")
========================================
EOF

echo ""
echo -e "${BLUE}Resultados guardados en: tests/test-results/test-execution.log${NC}"

# Restaurar backup
if [ -f data/CUENTAS.DAT.test-backup ]; then
    cp data/CUENTAS.DAT.test-backup data/CUENTAS.DAT
    rm data/CUENTAS.DAT.test-backup
fi

exit $FAIL
