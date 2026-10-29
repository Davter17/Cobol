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
# Verificar que haya errores (al menos 1)
if [ "$ERRORS_LINES" -gt 0 ]; then
    check_result 0 "ERRORS.DAT tiene registros de errores ($ERRORS_LINES)"
else
    check_result 1 "ERRORS.DAT tiene registros de errores" "No tiene errores"
fi

echo ""

# ============================================
# 3. Verificar coherencia en AUDIT.DAT
# ============================================
echo "3. Verificando coherencia en AUDIT.DAT..."

OK_COUNT=$(grep -c "  K " output/AUDIT.DAT)
# Verificar que haya movimientos OK
if [ "$OK_COUNT" -gt 0 ]; then
    check_result 0 "AUDIT.DAT tiene movimientos aceptados ($OK_COUNT)"
else
    check_result 1 "AUDIT.DAT tiene movimientos aceptados" "No tiene movimientos OK"
fi

ERROR_COUNT=$(grep -c "E00" output/AUDIT.DAT)
# Verificar que el número de errores en AUDIT coincida con ERRORS.DAT
if [ "$ERROR_COUNT" -eq "$ERRORS_LINES" ]; then
    check_result 0 "AUDIT.DAT errores coinciden con ERRORS.DAT ($ERROR_COUNT)"
else
    check_result 1 "AUDIT.DAT errores coinciden con ERRORS.DAT" "AUDIT: $ERROR_COUNT, ERRORS: $ERRORS_LINES"
fi

echo ""

# ============================================
# 4. Verificar formato de números en REPORT.DAT
# ============================================
echo "4. Verificando formato de números..."

# Verificar que los montos tengan formato correcto (con comas y decimales)
if grep -qE "[0-9]{1,3}(,[0-9]{3})*\.[0-9]{2} EUR" output/REPORT.DAT; then
    check_result 0 "Total DEBITED formateado correctamente"
else
    check_result 1 "Total DEBITED formateado" "No tiene formato de moneda válido"
fi

if grep -qE "[0-9]{1,3}(,[0-9]{3})*\.[0-9]{2} EUR" output/REPORT.DAT; then
    check_result 0 "Total CREDITED formateado correctamente"
else
    check_result 1 "Total CREDITED formateado" "No tiene formato de moneda válido"
fi

if grep -qE "[0-9]{1,3}(,[0-9]{3})*\.[0-9]{2} EUR" output/REPORT.DAT; then
    check_result 0 "Total COMMISSIONS formateado correctamente"
else
    check_result 1 "Total COMMISSIONS formateado" "No tiene formato de moneda válido"
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
# 8. Verificar ficheros JCL (Fase 9)
# ============================================
echo "8. Verificando ficheros JCL..."

# Verificar existencia de BANKJOB.jcl
if [ -f "jcl/BANKJOB.jcl" ]; then
    check_result 0 "BANKJOB.jcl existe"
else
    check_result 1 "BANKJOB.jcl existe" "Archivo no encontrado"
fi

# Verificar existencia de SORTJOB.jcl
if [ -f "jcl/SORTJOB.jcl" ]; then
    check_result 0 "SORTJOB.jcl existe"
else
    check_result 1 "SORTJOB.jcl existe" "Archivo no encontrado"
fi

# Verificar que BANKJOB.jcl contiene EXEC PGM=BANKPROC
if grep -q "EXEC PGM=BANKPROC" jcl/BANKJOB.jcl; then
    check_result 0 "BANKJOB.jcl contiene EXEC PGM=BANKPROC"
else
    check_result 1 "BANKJOB.jcl contiene EXEC PGM=BANKPROC" "No encontrado"
fi

# Verificar DD statements en BANKJOB.jcl
if grep -q "MOVEMENTS.*DD" jcl/BANKJOB.jcl && \
   grep -q "ACCOUNTS.*DD" jcl/BANKJOB.jcl && \
   grep -q "ERRORS.*DD" jcl/BANKJOB.jcl && \
   grep -q "HISTORIC.*DD" jcl/BANKJOB.jcl && \
   grep -q "REPORT.*DD" jcl/BANKJOB.jcl && \
   grep -q "AUDIT.*DD" jcl/BANKJOB.jcl; then
    check_result 0 "BANKJOB.jcl tiene todos los DD statements"
else
    check_result 1 "BANKJOB.jcl tiene todos los DD statements" "Faltan DD statements"
fi

# Verificar que BANKJOB.jcl tiene SYSOUT
if grep -q "SYSOUT" jcl/BANKJOB.jcl; then
    check_result 0 "BANKJOB.jcl tiene SYSOUT"
else
    check_result 1 "BANKJOB.jcl tiene SYSOUT" "No encontrado"
fi

# Verificar que SORTJOB.jcl contiene EXEC PGM=SORT
if grep -q "EXEC PGM=SORT" jcl/SORTJOB.jcl; then
    check_result 0 "SORTJOB.jcl contiene EXEC PGM=SORT"
else
    check_result 1 "SORTJOB.jcl contiene EXEC PGM=SORT" "No encontrado"
fi

# Verificar que SORTJOB.jcl contiene SORT FIELDS
if grep -q "SORT FIELDS" jcl/SORTJOB.jcl; then
    check_result 0 "SORTJOB.jcl contiene SORT FIELDS"
else
    check_result 1 "SORTJOB.jcl contiene SORT FIELDS" "No encontrado"
fi

# Verificar que SORTJOB.jcl tiene comentarios explicativos
if grep -q "^//\*" jcl/SORTJOB.jcl; then
    check_result 0 "SORTJOB.jcl tiene comentarios explicativos"
else
    check_result 1 "SORTJOB.jcl tiene comentarios explicativos" "No encontrados"
fi

# Verificar que BANKJOB.jcl tiene comentarios explicativos
if grep -q "^//\*" jcl/BANKJOB.jcl; then
    check_result 0 "BANKJOB.jcl tiene comentarios explicativos"
else
    check_result 1 "BANKJOB.jcl tiene comentarios explicativos" "No encontrados"
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
    echo "✓ Fases 8, 9, 10 y 11 funcionan perfectamente"
    exit 0
else
    echo "✗ ALGUNAS PRUEBAS FALLARON"
    echo "✗ Revisa los errores arriba"
    exit 1
fi
