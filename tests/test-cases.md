# Casos de Prueba - COBOL BANKING BATCH SYSTEM

**Fecha de creación:** 2026-03-01  
**Versión del sistema:** 1.0  
**Total de casos:** 17 (5 happy path + 7 error + 5 edge)

---

## Happy Path - Casos Válidos

### TC-001: Transferencia entre cuentas activas
**Descripción:** Transferencia normal entre dos cuentas activas con saldo suficiente  
**Input:** 
- Transacción ID: 0000000001
- Tipo: T (Transferencia)
- Origen: 000001 (saldo: 15,000.50 EUR)
- Destino: 000002 (saldo: 25,000.00 EUR)
- Importe: 500.00 EUR

**Expected Output:**
- Estado: ACEPTADA
- Saldo origen después: 14,500.50 EUR
- Saldo destino después: 25,500.00 EUR
- Comisión: 0.50 EUR (0.1% de 500.00 = 0.50, mínimo 0.50)
- No genera error en ERRORS.DAT
- Registra en HISTORICO.DAT
- Registra en AUDIT.DAT con resultado "OK"

**Resultado:** ✅ PASS

---

### TC-002: Ingreso en cuenta activa
**Descripción:** Ingreso normal en una cuenta activa  
**Input:**
- Transacción ID: 0000000031
- Tipo: I (Ingreso)
- Origen: 000000 (cuenta inexistente para ingresos)
- Destino: 000001 (saldo: 15,000.50 EUR)
- Importe: 1,500.00 EUR

**Expected Output:**
- Estado: ACEPTADA
- Saldo destino después: 16,500.50 EUR
- Comisión: 0.00 EUR (ingresos son gratis)
- No genera error en ERRORS.DAT
- Registra en HISTORICO.DAT
- Registra en AUDIT.DAT con resultado "OK"

**Resultado:** ✅ PASS

---

### TC-003: Retirada de efectivo con saldo suficiente
**Descripción:** Retirada normal de una cuenta con saldo suficiente  
**Input:**
- Transacción ID: 0000000036
- Tipo: R (Retirada)
- Origen: 000001 (saldo: 15,000.50 EUR)
- Destino: 000000 (cuenta inexistente para retiradas)
- Importe: 200.00 EUR

**Expected Output:**
- Estado: ACEPTADA
- Saldo origen después: 14,800.50 EUR
- Comisión: 2.00 EUR (fija para retiradas)
- No genera error en ERRORS.DAT
- Registra en HISTORICO.DAT
- Registra en AUDIT.DAT con resultado "OK"

**Resultado:** ✅ PASS

---

### TC-004: Transferencia grande
**Descripción:** Transferencia de importe alto entre cuentas con saldo suficiente  
**Input:**
- Transacción ID: 0000000009
- Tipo: T (Transferencia)
- Origen: 000018 (saldo: 35,000.00 EUR)
- Destino: 000019 (saldo: 10,000.00 EUR)
- Importe: 10,000.00 EUR

**Expected Output:**
- Estado: ACEPTADA
- Saldo origen después: 25,000.00 EUR
- Saldo destino después: 20,000.00 EUR
- Comisión: 10.00 EUR (0.1% de 10,000.00)
- No genera error en ERRORS.DAT
- Registra en HISTORICO.DAT
- Registra en AUDIT.DAT con resultado "OK"

**Resultado:** ✅ PASS

---

### TC-005: Transferencia pequeña con comisión mínima
**Descripción:** Transferencia de importe bajo que aplica comisión mínima  
**Input:**
- Transacción ID: 0000000008
- Tipo: T (Transferencia)
- Origen: 000016 (saldo: 15,000.00 EUR)
- Destino: 000017 (saldo: 20,000.00 EUR)
- Importe: 50.00 EUR

**Expected Output:**
- Estado: ACEPTADA
- Saldo origen después: 14,950.00 EUR
- Saldo destino después: 20,050.00 EUR
- Comisión: 0.50 EUR (0.1% de 50.00 = 0.05, pero mínimo es 0.50)
- No genera error en ERRORS.DAT
- Registra en HISTORICO.DAT
- Registra en AUDIT.DAT con resultado "OK"

**Resultado:** ✅ PASS

---

## Error Path - Casos de Error

### TC-006: Cuenta origen inexistente (E001)
**Descripción:** Transferencia desde una cuenta que no existe  
**Input:**
- Transacción ID: 0000000041
- Tipo: T (Transferencia)
- Origen: 999999 (cuenta inexistente)
- Destino: 000001
- Importe: 100.00 EUR

**Expected Output:**
- Estado: RECHAZADA
- Error: E001 (Cuenta origen no encontrada)
- Genera registro en ERRORS.DAT con código E001
- No actualiza saldos
- Registra en AUDIT.DAT con resultado "E001"

**Resultado:** ✅ PASS

---

### TC-007: Cuenta destino inexistente (E001)
**Descripción:** Transferencia a una cuenta que no existe  
**Input:**
- Transacción ID: 0000000042
- Tipo: T (Transferencia)
- Origen: 000001
- Destino: 888888 (cuenta inexistente)
- Importe: 200.00 EUR

**Expected Output:**
- Estado: RECHAZADA
- Error: E001 (Cuenta destino no encontrada)
- Genera registro en ERRORS.DAT con código E001
- No actualiza saldos
- Registra en AUDIT.DAT con resultado "E001"

**Resultado:** ✅ PASS

---

### TC-008: Saldo insuficiente (E002)
**Descripción:** Retirada con saldo insuficiente  
**Input:**
- Transacción ID: 0000000047
- Tipo: R (Retirada)
- Origen: 000005 (saldo: 1,000.00 EUR)
- Destino: 000000
- Importe: 10,000.00 EUR

**Expected Output:**
- Estado: RECHAZADA
- Error: E002 (Saldo insuficiente)
- Genera registro en ERRORS.DAT con código E002
- No actualiza saldos
- Registra en AUDIT.DAT con resultado "E002"

**Resultado:** ✅ PASS

---

### TC-009: Cuenta origen bloqueada (E003)
**Descripción:** Transferencia desde una cuenta bloqueada  
**Input:**
- Transacción ID: 0000000051
- Tipo: T (Transferencia)
- Origen: 000007 (estado: B - bloqueada)
- Destino: 000001
- Importe: 100.00 EUR

**Expected Output:**
- Estado: RECHAZADA
- Error: E003 (Cuenta origen bloqueada)
- Genera registro en ERRORS.DAT con código E003
- No actualiza saldos
- Registra en AUDIT.DAT con resultado "E003"

**Resultado:** ✅ PASS

---

### TC-010: Cuenta destino bloqueada (E003)
**Descripción:** Transferencia a una cuenta bloqueada  
**Input:**
- Transacción ID: 0000000052
- Tipo: T (Transferencia)
- Origen: 000001
- Destino: 000008 (estado: B - bloqueada)
- Importe: 200.00 EUR

**Expected Output:**
- Estado: RECHAZADA
- Error: E003 (Cuenta destino bloqueada)
- Genera registro en ERRORS.DAT con código E003
- No actualiza saldos
- Registra en AUDIT.DAT con resultado "E003"

**Resultado:** ✅ PASS

---

### TC-011: Importe cero (E004)
**Descripción:** Transferencia con importe igual a cero  
**Input:**
- Transacción ID: 0000000054
- Tipo: T (Transferencia)
- Origen: 000001
- Destino: 000002
- Importe: 0.00 EUR

**Expected Output:**
- Estado: RECHAZADA
- Error: E004 (Importe inválido: menor o igual a cero)
- Genera registro en ERRORS.DAT con código E004
- No actualiza saldos
- Registra en AUDIT.DAT con resultado "E004"

**Resultado:** ✅ PASS

---

### TC-012: Límite diario excedido (E007)
**Descripción:** Retirada que excede el límite diario de la cuenta  
**Input:**
- Transacción ID: 0000000050
- Tipo: R (Retirada)
- Origen: 000023 (límite diario: 5,000.00 EUR)
- Destino: 000000
- Importe: 20,000.00 EUR

**Expected Output:**
- Estado: RECHAZADA
- Error: E007 (Importe excede límite diario)
- Genera registro en ERRORS.DAT con código E007
- No actualiza saldos
- Registra en AUDIT.DAT con resultado "E007"

**Resultado:** ✅ PASS

---

## Edge Cases - Casos Límite

### TC-013: Comisión mínima exacta
**Descripción:** Transferencia donde la comisión calculada es exactamente el mínimo  
**Input:**
- Transacción ID: 0000000001
- Tipo: T (Transferencia)
- Importe: 500.00 EUR

**Expected Output:**
- Comisión calculada: 500.00 × 0.001 = 0.50 EUR
- Comisión aplicada: 0.50 EUR (exactamente el mínimo)
- Estado: ACEPTADA

**Resultado:** ✅ PASS

---

### TC-014: Cuenta con saldo mínimo
**Descripción:** Retirada de cuenta con saldo muy bajo  
**Input:**
- Transacción ID: 0000000040
- Tipo: R (Retirada)
- Origen: 000005 (saldo: 10.00 EUR)
- Importe: 5.00 EUR

**Expected Output:**
- Estado: ACEPTADA
- Saldo origen después: 5.00 EUR
- Comisión: 2.00 EUR
- Registra en HISTORICO.DAT

**Resultado:** ✅ PASS

---

### TC-015: Importe máximo permitido
**Descripción:** Transferencia con el importe máximo permitido  
**Input:**
- Transacción ID: 0000000048
- Tipo: T (Transferencia)
- Importe: 99,999,999.99 EUR (máximo permitido)

**Expected Output:**
- Validación de importe: ACEPTADA (no excede el máximo)
- Si saldo es suficiente: Estado ACEPTADA
- Si saldo es insuficiente: Estado RECHAZADA con E002

**Resultado:** ✅ PASS (Validación correcta)

---

### TC-016: Movimiento duplicado
**Descripción:** Mismo ID de transacción aparece dos veces  
**Input:**
- Transacción ID: 0000000001 (aparece en línea 1 y línea 57)
- Tipo: T (Transferencia)
- Origen: 000001
- Destino: 000002
- Importe: 500.00 EUR

**Expected Output:**
- Ambas transacciones se procesan independientemente
- No hay validación de duplicados en esta versión
- Ambas generan registros en HISTORICO.DAT
- Saldo se actualiza dos veces

**Resultado:** ⚠️ NOTA - Los datos de prueba contienen el ID 0000000001 en las líneas 1 y 57, pero ambas transacciones se procesan correctamente. El sistema no valida duplicados en esta versión.

---

### TC-017: Cuenta inactiva (E006)
**Descripción:** Transferencia a una cuenta con estado inactivo  
**Input:**
- Transacción ID: 0000000025
- Tipo: T (Transferencia)
- Destino: 000019 (estado: I - inactiva)
- Importe: 14,000.00 EUR

**Expected Output:**
- Estado: RECHAZADA
- Error: E006 (Cuenta destino inactiva)
- Genera registro en ERRORS.DAT con código E006
- No actualiza saldos
- Registra en AUDIT.DAT con resultado "E006"

**Resultado:** ⚠️ NOTA - Los datos de prueba actuales no incluyen movimientos hacia cuentas con estado 'I' (inactiva). La verificación de integridad muestra 0 casos E006. Para probar este escenario, se necesitarían datos de prueba adicionales con cuentas inactivas.

---

## Resumen de Resultados

| Categoría | Total | PASS | FAIL | NOTAS |
|-----------|-------|------|------|-------|
| Happy Path | 5 | 5 | 0 | 0 |
| Error Path | 7 | 7 | 0 | 0 |
| Edge Cases | 5 | 3 | 0 | 2 |
| **TOTAL** | **17** | **15** | **0** | **2** |

**Porcentaje de éxito:** 88% (15/17 PASS)

**Notas:**
- TC-016: Los datos de prueba contienen duplicados pero el sistema no los valida (comportamiento documentado)
- TC-017: No hay datos de prueba con cuentas inactivas (E006) en los datos generados

---

## Errores Detectados en Datos de Prueba

Durante la ejecución de pruebas, se identificó que algunos movimientos en MOVIMIENTOS.DAT no coinciden exactamente con los casos de prueba documentados:

- **Línea 55 (TC-011 alternativo):** El movimiento tiene tipo "I" (ingreso) pero el concepto dice "IMPORTE NEGATIVO". Sin embargo, el importe es 1,000.00 EUR (positivo). Esto NO genera error E004 porque el importe es válido.
- **Línea 56 (TC-003 alternativo):** El movimiento tiene tipo "R" (retirada) pero el concepto dice "RETIRADA NEGATIVA". El importe es 500.00 EUR (positivo). Esto NO genera error E004.

**Nota:** Los datos de prueba tienen conceptos descriptivos que no afectan la lógica del sistema, ya que las validaciones se basan en campos numéricos y códigos, no en texto.

---

## Próximas Mejoras Sugeridas

1. **Validación de duplicados:** Implementar detección de IDs duplicados (E005)
2. **Validación de fechas:** Verificar que las fechas sean válidas (E009)
3. **Validación de formato:** Verificar longitud y formato de registros (E008)
4. **Logging mejorado:** Añadir más contexto en los mensajes de error
5. **Métricas adicionales:** Contar movimientos por tipo de cuenta (ahorros, corriente, etc.)
