#!/bin/bash

# ============================================
# BANKPROC Verification Script
# Fase 8 - Generación de Informes
# ============================================

echo "=========================================="
echo "  BANKPROC VERIFICATION SCRIPT"
echo "=========================================="
echo ""

# Contadores de pruebas
PASS=0
FAIL=0

# Función para mostrar resultado
check_result() {
    if [ $1 -eq 0 ]; then
        echo "✓ PASS: $2"
        ((PASS++))
    else
        echo "✗ FAIL: $2"
        echo "  → $3"
        ((FAIL++))
    fi
}

# ============================================
# 1. Verificar archivos de salida
# ============================================
echo "1. Verificando archivos de salida..."

if [ -f "output/REPORT.DAT" ]; then
    check_result 0 "REPORT.DAT existe"
else
    check_result 1 "REPORT.DAT existe" "Archivo no encontrado"
fi

if [ -f "output/AUDIT.DAT" ]; then
    check_result 0 "AUDIT.DAT existe"
else
    check_result 1 "AUDIT.DAT existe" "Archivo no encontrado"
fi

if [ -f "output/ERRORS.DAT" ]; then
    check_result 0 "ERRORS.DAT existe"
else
    check_result 1 "ERRORS.DAT existe" "Archivo no encontrado"
fi

if [ -f "output/HISTORICO.DAT" ]; then
    check_result 0 "HISTORICO.DAT existe"
else
    check_result 1 "HISTORICO.DAT existe" "Archivo no encontrado"
fi

echo ""

# ============================================
# 2. Verificar número de registros
# ============================================
echo "2. Verificando número de registros..."

AUDIT_LINES=$(wc -l < output/AUDIT.DAT)
if [ "$AUDIT_LINES" -eq 58 ]; then
    check_result 0 "AUDIT.DAT tiene 58 registros (uno por movimiento)"
else
    check_result 1 "AUDIT.DAT tiene 58 registros" "Tiene $AUDIT_LINES registros"
fi

ERRORS_LINES=$(wc -l < output/ERRORS.DAT)
if [ "$ERRORS_LINES" -eq 20 ]; then
    check_result 0 "ERRORS.DAT tiene 20 registros (movimientos rechazados)"
else
    check_result 1 "ERRORS.DAT tiene 20 registros" "Tiene $ERRORS_LINES registros"
fi

echo ""

# ============================================
# 3. Verificar coherencia en AUDIT.DAT
# ============================================
echo "3. Verificando coherencia en AUDIT.DAT..."

OK_COUNT=$(grep -c "  K " output/AUDIT.DAT)
if [ "$OK_COUNT" -eq 38 ]; then
    check_result 0 "AUDIT.DAT tiene 38 movimientos aceptados (K)"
else
    check_result 1 "AUDIT.DAT tiene 38 movimientos OK" "Tiene $OK_COUNT"
fi

ERROR_COUNT=$(grep -c "E00" output/AUDIT.DAT)
if [ "$ERROR_COUNT" -eq 20 ]; then
    check_result 0 "AUDIT.DAT tiene 20 movimientos con error"
else
    check_result 1 "AUDIT.DAT tiene 20 movimientos con error" "Tiene $ERROR_COUNT"
fi

echo ""

# ============================================
# 4. Verificar formato de números en REPORT.DAT
# ============================================
echo "4. Verificando formato de números..."

if grep -q "7,087.55 EUR" output/REPORT.DAT; then
    check_result 0 "Total DEBITED formateado correctamente (7,087.55 EUR)"
else
    check_result 1 "Total DEBITED formateado" "No se encontró '7,087.55 EUR'"
fi

if grep -q "11,612.80 EUR" output/REPORT.DAT; then
    check_result 0 "Total CREDITED formateado correctamente (11,612.80 EUR)"
else
    check_result 1 "Total CREDITED formateado" "No se encontró '11,612.80 EUR'"
fi

if grep -q "25.55 EUR" output/REPORT.DAT; then
    check_result 0 "Total COMMISSIONS formateado correctamente (25.55 EUR)"
else
    check_result 1 "Total COMMISSIONS formateado" "No se encontró '25.55 EUR'"
fi

echo ""

# ============================================
# 5. Verificar estructura de REPORT.DAT
# ============================================
echo "5. Verificando estructura de REPORT.DAT..."

if grep -q "COBOL BANKING SYSTEM" output/REPORT.DAT; then
    check_result 0 "REPORT.DAT tiene cabecera 'COBOL BANKING SYSTEM'"
else
    check_result 1 "Cabecera de REPORT.DAT" "No se encontró 'COBOL BANKING SYSTEM'"
fi

if grep -q "DAILY BANKING REPORT" output/REPORT.DAT; then
    check_result 0 "REPORT.DAT tiene título 'DAILY BANKING REPORT'"
else
    check_result 1 "Título de REPORT.DAT" "No se encontró 'DAILY BANKING REPORT'"
fi

if grep -q "PROCESSING SUMMARY" output/REPORT.DAT; then
    check_result 0 "REPORT.DAT tiene sección 'PROCESSING SUMMARY'"
else
    check_result 1 "Sección PROCESSING SUMMARY" "No encontrada"
fi

if grep -q "FINANCIAL SUMMARY" output/REPORT.DAT; then
    check_result 0 "REPORT.DAT tiene sección 'FINANCIAL SUMMARY'"
else
    check_result 1 "Sección FINANCIAL SUMMARY" "No encontrada"
fi

if grep -q "ERRORS BREAKDOWN" output/REPORT.DAT; then
    check_result 0 "REPORT.DAT tiene sección 'ERRORS BREAKDOWN'"
else
    check_result 1 "Sección ERRORS BREAKDOWN" "No encontrada"
fi

if grep -q "END OF REPORT" output/REPORT.DAT; then
    check_result 0 "REPORT.DAT tiene pie 'END OF REPORT'"
else
    check_result 1 "Pie de REPORT.DAT" "No se encontró 'END OF REPORT'"
fi

echo ""

# ============================================
# 6. Verificar integridad de números
# ============================================
echo "6. Verificando integridad numérica..."

# Eliminar ceros a la izquierda para evitar problemas con bash
TOTAL_MOV=$(grep "TOTAL MOVEMENTS PROCESSED:" output/REPORT.DAT | awk '{print $NF}' | sed 's/^0*//')
ACCEPTED=$(grep "ACCEPTED:" output/REPORT.DAT | head -1 | awk '{print $NF}' | sed 's/^0*//')
REJECTED=$(grep "REJECTED:" output/REPORT.DAT | head -1 | awk '{print $NF}' | sed 's/^0*//')

# Si quedan vacíos (eran todo ceros), ponerlos a 0
TOTAL_MOV=${TOTAL_MOV:-0}
ACCEPTED=${ACCEPTED:-0}
REJECTED=${REJECTED:-0}

SUM=$((ACCEPTED + REJECTED))
if [ "$TOTAL_MOV" -eq "$SUM" ]; then
    check_result 0 "Total = Aceptados + Rechazados ($TOTAL_MOV = $ACCEPTED + $REJECTED)"
else
    check_result 1 "Integridad Total = Acept + Rech" "$TOTAL_MOV ≠ $ACCEPTED + $REJECTED"
fi

# Verificar suma de errores por tipo
E001=$(grep "E001" output/REPORT.DAT | awk '{print $NF}' | sed 's/^0*//')
E002=$(grep "E002" output/REPORT.DAT | awk '{print $NF}' | sed 's/^0*//')
E003=$(grep "E003" output/REPORT.DAT | awk '{print $NF}' | sed 's/^0*//')
E004=$(grep "E004" output/REPORT.DAT | awk '{print $NF}' | sed 's/^0*//')
E005=$(grep "E005" output/REPORT.DAT | awk '{print $NF}' | sed 's/^0*//')
E006=$(grep "E006" output/REPORT.DAT | awk '{print $NF}' | sed 's/^0*//')
E007=$(grep "E007" output/REPORT.DAT | awk '{print $NF}' | sed 's/^0*//')

E001=${E001:-0}; E002=${E002:-0}; E003=${E003:-0}; E004=${E004:-0}
E005=${E005:-0}; E006=${E006:-0}; E007=${E007:-0}

ERROR_SUM=$((E001 + E002 + E003 + E004 + E005 + E006 + E007))
if [ "$ERROR_SUM" -eq "$REJECTED" ]; then
    check_result 0 "Suma de errores por tipo = Rechazados ($ERROR_SUM = $REJECTED)"
else
    check_result 1 "Suma de errores = Rechazados" "$ERROR_SUM ≠ $REJECTED"
fi

echo ""

# ============================================
# 7. Verificar coherencia cruzada
# ============================================
echo "7. Verificando coherencia cruzada..."

if [ "$ERROR_COUNT" -eq "$ERRORS_LINES" ]; then
    check_result 0 "Errores en AUDIT.DAT coinciden con ERRORS.DAT ($ERROR_COUNT)"
else
    check_result 1 "Coherencia AUDIT vs ERRORS" "$ERROR_COUNT ≠ $ERRORS_LINES"
fi

echo ""

# ============================================
# Resumen final
# ============================================
echo "=========================================="
echo "  RESUMEN DE VERIFICACIÓN"
echo "=========================================="
echo "  Pruebas PASADAS: $PASS"
echo "  Pruebas FALLIDAS: $FAIL"
echo "  TOTAL: $((PASS + FAIL))"
echo "=========================================="

if [ $FAIL -eq 0 ]; then
    echo "✓ TODAS LAS PRUEBAS PASARON CORRECTAMENTE"
    echo "✓ Fase 8 funciona perfectamente"
    exit 0
else
    echo "✗ ALGUNAS PRUEBAS FALLARON"
    echo "✗ Revisa los errores arriba"
    exit 1
fi
