# Códigos de Error - COBOL Banking Batch System

Documentación completa de todos los códigos de error del sistema bancario.

---

## Tabla de Contenidos

1. [Resumen de Códigos](#resumen-de-códigos)
2. [Detalle de Errores](#detalle-de-errores)
3. [Flujo de Validación](#flujo-de-validación)
4. [Ejemplos de Errores](#ejemplos-de-errores)
5. [Referencia Técnica](#referencia-técnica)

---

## Resumen de Códigos

| Código | Descripción Corta | severidad | Frecuencia |
|--------|-------------------|-----------|------------|
| E001 | Cuenta no encontrada | Alta | Media |
| E002 | Saldo insuficiente | Alta | Alta |
| E003 | Cuenta inactiva | Alta | Baja |
| E004 | Importe inválido | Media | Baja |
| E005 | Movimiento duplicado | Media | Baja |
| E006 | Cuenta bloqueada | Alta | Baja |
| E007 | Límite diario excedido | Media | Media |
| E008 | Error de formato | Alta | Baja |
| E009 | Fecha inválida | Media | Baja |
| E010 | Error de E/S | Crítica | Muy baja |

---

## Detalle de Errores

### E001 - Cuenta No Encontrada

**Descripción:** La cuenta especificada (origen o destino) no existe en el maestro CUENTAS.DAT

**Causas:**
- Número de cuenta incorrecto en el movimiento
- Cuenta eliminada o no creada aún
- Error de transcripción en los datos de entrada

**Validación:**
```cobol
PERFORM 3200-VALIDATE-ORIGIN
    IF NOT WS-FOUND-ORIGIN
        MOVE "E001" TO WS-CURRENT-ERROR-CODE
    END-IF

PERFORM 3300-VALIDATE-DESTINATION
    IF NOT WS-FOUND-DESTINATION
        MOVE "E001" TO WS-CURRENT-ERROR-CODE
    END-IF
```

**Acción del Sistema:**
- Rechaza el movimiento
- Registra en ERRORS.DAT con código E001
- Registra en AUDIT.DAT con resultado "E001"
- NO actualiza saldos
- NO genera comisión
- Continúa con el siguiente movimiento

**Ejemplo:**
```
Input:  0000000041T99999900000100000001000020260301140000CUENTA INEXISTENTE ORIGEN
Error:  20261029 162645 0000000041 E001 CUENTA ORIGEN NO ENCONTRADA           999999 000000010000
Audit:  2026-10-29 16:26:45 0000000041 T 999999 000001 100.00 E001         CUENTA INEXISTENTE ORIGEN
```

**Prevención:**
- Validar datos de entrada antes del procesamiento batch
- Verificar que todas las cuentas existan en CUENTAS.DAT
- Usar scripts de generación de datos de prueba consistentes

---

### E002 - Saldo Insuficiente

**Descripción:** La cuenta origen no tiene saldo suficiente para cubrir el importe de la transacción

**Causas:**
- Intentar retirar/transferir más dinero del disponible
- Saldo actual menor que el importe del movimiento
- No considerar comisiones previas

**Validación:**
```cobol
PERFORM 3400-VALIDATE-BALANCE
    IF WS-ACCOUNT-BALANCE < WS-TRANSACTION-AMOUNT
        MOVE "E002" TO WS-CURRENT-ERROR-CODE
    END-IF
```

**Fórmula:**
```
SI saldo_actual < importe_movimiento
    ENTONCES error E002
```

**Acción del Sistema:**
- Rechaza el movimiento
- Registra en ERRORS.DAT con código E002
- Registra en AUDIT.DAT con resultado "E002"
- NO actualiza saldos
- NO genera comisión
- Continúa con el siguiente movimiento

**Ejemplo:**
```
Cuenta 000005 tiene saldo: 10.00 EUR
Movimiento: Retirar 100.00 EUR
Error: E002 (10.00 < 100.00)

Input:  0000000047R00000500000000000010000020260301170000RETIRADA EXCESIVA
Error:  20261029 162645 0000000047 E002 SALDO INSUFICIENTE EN CUENTA ORIGEN   000005 000000100000
```

**Prevención:**
- Consultar saldo disponible antes de realizar transacciones
- Implementar límites de overdraft si es necesario
- Notificar al cliente cuando el saldo sea bajo

---

### E003 - Cuenta Inactiva

**Descripción:** La cuenta tiene estado "I" (Inactiva) en CUENTAS.DAT y no puede realizar operaciones

**Causas:**
- Cuenta cerrada por el cliente
- Cuenta suspendida administrativamente
- Cuenta no activada aún después de creación

**Validación:**
```cobol
PERFORM 3500-VALIDATE-STATUS
    IF WS-ACCOUNT-STATUS = "I"
        MOVE "E003" TO WS-CURRENT-ERROR-CODE
    END-IF
```

**Estados de Cuenta:**
| Código | Estado | Puede Operar |
|--------|--------|--------------|
| A | Activa | Sí |
| B | Bloqueada | No (→ E006) |
| I | Inactiva | No (→ E003) |

**Acción del Sistema:**
- Rechaza el movimiento
- Registra en ERRORS.DAT con código E003
- Registra en AUDIT.DAT con resultado "E003"
- NO actualiza saldos
- NO genera comisión
- Continúa con el siguiente movimiento

**Ejemplo:**
```
Cuenta 000009 tiene estado: I (Inactiva)
Error: E003

Input:  0000000053R00000900000000000001000020260301200000RETIRADA CUENTA INACTIVA
Error:  20261029 162645 0000000053 E003 CUENTA ORIGEN INACTIVA              000009 000000010000
```

**Prevención:**
- Verificar estado de cuenta antes de procesar
- Reactivar cuentas si es necesario
- Notificar al cliente sobre el estado de su cuenta

---

### E004 - Importe Inválido

**Descripción:** El importe de la transacción es menor o igual a cero, o excede el máximo permitido

**Causas:**
- Error en los datos de entrada
- Importe negativo o cero
- Importe que excede el límite máximo del sistema (99,999,999.99 EUR)

**Validación:**
```cobol
PERFORM 3600-VALIDATE-AMOUNT
    IF WS-TRANSACTION-AMOUNT <= 0
        MOVE "E004" TO WS-CURRENT-ERROR-CODE
    ELSE IF WS-TRANSACTION-AMOUNT > WS-MAX-AMOUNT
        MOVE "E004" TO WS-CURRENT-ERROR-CODE
    END-IF
```

**Límites:**
```cobol
01 WS-MIN-AMOUNT    PIC 9(10)V99 VALUE 0.01.
01 WS-MAX-AMOUNT    PIC 9(10)V99 VALUE 99999999.99.
```

**Acción del Sistema:**
- Rechaza el movimiento
- Registra en ERRORS.DAT con código E004
- Registra en AUDIT.DAT con resultado "E004"
- NO actualiza saldos
- NO genera comisión
- Continúa con el siguiente movimiento

**Ejemplo:**
```
Importe: 0.00 EUR (inválido)
Error: E004

Input:  0000000054T00000100000200000000000020260301203000IMPORTE CERO
Error:  20261029 162645 0000000054 E004 IMPORTE INVALIDO: MENOR O IGUAL A CERO 000001 000000000000
```

**Prevención:**
- Validar importes antes del procesamiento batch
- Implementar límites en los canales de entrada
- Verificar que los importes sean positivos

---

### E005 - Movimiento Duplicado

**Descripción:** Se ha detectado un movimiento con el mismo ID que uno ya procesado anteriormente

**Causas:**
- Reprocesamiento accidental del fichero de movimientos
- Error en la generación de IDs de transacción
- Retry automático de una transacción ya completada

**Validación:**
```cobol
* Nota: En la versión actual, esta validación NO está implementada
* Se planifica para futuras versiones
```

**Estado Actual:**
⚠️ **NO IMPLEMENTADO** - El sistema actualmente permite duplicados. Ver `tests/test-cases.md` TC-016 para más detalles.

**Acción del Sistema (cuando se implemente):**
- Rechazará el movimiento duplicado
- Registrará en ERRORS.DAT con código E005
- Registrará en AUDIT.DAT con resultado "E005"
- NO actualizará saldos
- NO generará comisión
- Continuará con el siguiente movimiento

**Prevención:**
- Implementar tabla de IDs procesados
- Verificar unicidad de IDs antes del procesamiento
- Usar secuencias o timestamps únicos para IDs

---

### E006 - Cuenta Bloqueada

**Descripción:** La cuenta tiene estado "B" (Bloqueada) en CUENTAS.DAT y no puede realizar operaciones

**Causas:**
- Cuenta bloqueada por actividad sospechosa
- Bloqueo administrativo
- Bloqueo por múltiples intentos fallidos
- Orden judicial o regulatoria

**Validación:**
```cobol
PERFORM 3500-VALIDATE-STATUS
    IF WS-ACCOUNT-STATUS = "B"
        MOVE "E006" TO WS-CURRENT-ERROR-CODE
    END-IF
```

**Diferencia con E003:**
| Código | Estado | Causa Típica | Duración |
|--------|--------|--------------|----------|
| E003 | I (Inactiva) | Cierre voluntario | Permanente |
| E006 | B (Bloqueada) | Suspensión temporal | Temporal |

**Acción del Sistema:**
- Rechaza el movimiento
- Registra en ERRORS.DAT con código E006
- Registra en AUDIT.DAT con resultado "E006"
- NO actualiza saldos
- NO genera comisión
- Continúa con el siguiente movimiento

**Ejemplo:**
```
Cuenta 000007 tiene estado: B (Bloqueada)
Error: E006

Input:  0000000051T00000700000100000001000020260301190000CUENTA BLOQUEADA ORIGEN
Error:  20261029 162645 0000000051 E006 CUENTA ORIGEN BLOQUEADA             000007 000000010000
```

**Prevención:**
- Verificar estado de cuenta antes de procesar
- Implementar procedimientos de desbloqueo
- Notificar al cliente sobre el bloqueo

---

### E007 - Límite Diario Excedido

**Descripción:** El importe de la transacción excede el límite diario configurado para la cuenta

**Causas:**
- Intentar transferir/retirar más del límite diario permitido
- Límite diario configurado demasiado bajo
- Acumulación de múltiples transacciones en el mismo día

**Validación:**
```cobol
PERFORM 3700-VALIDATE-LIMIT
    IF WS-TRANSACTION-AMOUNT > WS-ACCOUNT-DAILY-LIMIT
        MOVE "E007" TO WS-CURRENT-ERROR-CODE
    END-IF
```

**Límites Configuracion:**
```cobol
01 WS-MAX-DAILY-LIMIT PIC 9(10)V99 VALUE 50000.00.
```

**Acción del Sistema:**
- Rechaza el movimiento
- Registra en ERRORS.DAT con código E007
- Registra en AUDIT.DAT con resultado "E007"
- NO actualiza saldos
- NO genera comisión
- Continúa con el siguiente movimiento

**Ejemplo:**
```
Cuenta 000005 tiene límite diario: 500.00 EUR
Movimiento: Transferir 1000.00 EUR
Error: E007 (1000.00 > 500.00)

Input:  0000000050R00000500000000000010000020260301183000RETIRADA NO PERMITIDA
Error:  20261029 162645 0000000050 E007 IMPORTE EXCEDE LIMITE DIARIO        000005 000000100000
```

**Prevención:**
- Consultar límite diario antes de realizar transacciones grandes
- Implementar límites progresivos (día, semana, mes)
- Permitir al cliente ajustar sus límites

---

### E008 - Error de Formato

**Descripción:** El registro de movimiento no cumple con el formato esperado (longitud o estructura incorrecta)

**Causas:**
- Fichero de movimientos corrupto
- Longitud de registro incorrecta
- Campos con caracteres inválidos
- Estructura de datos incorrecta

**Validación:**
```cobol
* Nota: En la versión actual, esta validación NO está implementada
* Se planifica para futuras versiones
```

**Estado Actual:**
⚠️ **NO IMPLEMENTADO** - El sistema asume que los datos de entrada tienen el formato correcto.

**Acción del Sistema (cuando se implemente):**
- Rechazará el movimiento
- Registrará en ERRORS.DAT con código E008
- Registrará en AUDIT.DAT con resultado "E008"
- NO actualizará saldos
- NO generará comisión
- Continuará con el siguiente movimiento

**Prevención:**
- Validar formato de ficheros antes del procesamiento
- Implementar controles de calidad de datos
- Usar esquemas de validación estrictos

---

### E009 - Fecha Inválida

**Descripción:** La fecha del movimiento es inválida (formato incorrecto, fecha futura, o fecha muy antigua)

**Causas:**
- Error en los datos de entrada
- Fecha en formato incorrecto (no YYYYMMDD)
- Fecha futura (más allá del día actual)
- Fecha muy antigua (más de X años)

**Validación:**
```cobol
* Nota: En la versión actual, esta validación NO está implementada
* Se planifica para futuras versiones
```

**Estado Actual:**
⚠️ **NO IMPLEMENTADO** - El sistema acepta cualquier fecha en el formato correcto.

**Acción del Sistema (cuando se implemente):**
- Rechazará el movimiento
- Registrará en ERRORS.DAT con código E009
- Registrará en AUDIT.DAT con resultado "E009"
- NO actualizará saldos
- NO generará comisión
- Continuará con el siguiente movimiento

**Prevención:**
- Validar fechas antes del procesamiento
- Implementar reglas de negocio para fechas válidas
- Usar funciones de fecha del sistema

---

### E010 - Error de E/S

**Descripción:** Error crítico al intentar leer o escribir en un fichero

**Causas:**
- Fichero no accesible (permisos)
- Fichero corrupto
- Error de disco o almacenamiento
- Fichero bloqueado por otro proceso

**Validación:**
```cobol
READ MOVEMENTS-FILE
    AT END
        SET WS-EOF TO TRUE
    NOT AT END
        CONTINUE
END-READ

IF WS-FILE-STATUS NOT = "00"
    MOVE "E010" TO WS-CURRENT-ERROR-CODE
END-IF
```

**FILE STATUS Codes:**
| Código | Significado |
|--------|-------------|
| 00 | Operación exitosa |
| 02 | Fichero no encontrado |
| 04 | Fichero bloqueado |
| 10 | Fin de fichero (EOF) |
| 30 | Error permanente |
| 35 | Fichero no existe |
| 39 | Error de E/S |

**Acción del Sistema:**
- Detiene el procesamiento
- Muestra mensaje de error crítico
- Termina el programa con código de error
- NO cierra ficheros abiertos correctamente
- Requiere intervención manual

**Ejemplo:**
```
Error: No se puede abrir CUENTAS.DAT
Causa: Fichero no existe o permisos incorrectos
Acción: Verificar existencia y permisos del fichero
```

**Prevención:**
- Verificar existencia de ficheros antes del procesamiento
- Implementar manejo robusto de errores de E/S
- Usar backups automáticos
- Implementar procedimientos de recuperación

---

## Flujo de Validación

```
┌─────────────────────────────────────────┐
│  Leer Movimiento de MOVIMIENTOS.DAT     │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  E010: Error de E/S?                    │──► Sí ──► Detener procesamiento
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E008: Formato inválido?                │──► Sí ──► Rechazar (no implementado)
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E009: Fecha inválida?                  │──► Sí ──► Rechazar (no implementado)
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E004: Importe inválido?                │──► Sí ──► Rechazar
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  Buscar Cuenta Origen                   │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  E001: Cuenta origen no existe?         │──► Sí ──► Rechazar
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E006: Cuenta origen bloqueada?         │──► Sí ──► Rechazar
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E003: Cuenta origen inactiva?          │──► Sí ──► Rechazar
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E002: Saldo insuficiente?              │──► Sí ──► Rechazar
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E007: Límite diario excedido?          │──► Sí ──► Rechazar
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  Buscar Cuenta Destino (si aplica)      │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  E001: Cuenta destino no existe?        │──► Sí ──► Rechazar
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E006: Cuenta destino bloqueada?        │──► Sí ──► Rechazar
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E003: Cuenta destino inactiva?         │──► Sí ──► Rechazar
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  E005: Movimiento duplicado?            │──► Sí ──► Rechazar (no implementado)
└────────────┬────────────────────────────┘
             │ No
             ▼
┌─────────────────────────────────────────┐
│  ✓ MOVIMIENTO VÁLIDO                    │
│  - Calcular comisión                    │
│  - Actualizar saldos                    │
│  - Registrar en HISTORICO.DAT           │
│  - Registrar en AUDIT.DAT (K)           │
└─────────────────────────────────────────┘
```

---

## Ejemplos de Errores

### Ejemplo 1: Múltiples errores en una ejecución

```
Movimientos procesados: 58
Aceptados: 35
Rechazados: 23

Desglose de errores:
  E001: 6 (Cuentas no encontradas)
  E002: 8 (Saldo insuficiente)
  E003: 5 (Cuentas inactivas)
  E004: 1 (Importe inválido)
  E005: 0 (Duplicados - no implementado)
  E006: 3 (Cuentas bloqueadas)
  E007: 0 (Límite diario no excedido)
  E008: 0 (Errores de formato - no implementado)
  E009: 0 (Fechas inválidas - no implementado)
  E010: 0 (Errores de E/S)
```

### Ejemplo 2: Registro de error en ERRORS.DAT

```
Formato: Timestamp(19) + ID(10) + Código(4) + Descripción(45) + Cuenta(6) + Importe(12)

20261029 162645 0000000041 E001 CUENTA ORIGEN NO ENCONTRADA           999999 000000010000
20261029 162645 0000000047 E002 SALDO INSUFICIENTE EN CUENTA ORIGEN   000005 000000100000
20261029 162645 0000000051 E006 CUENTA ORIGEN BLOQUEADA               000007 000000010000
```

### Ejemplo 3: Registro de auditoría con error

```
Formato: Timestamp(19) + ID(10) + Tipo(1) + Origen(6) + Destino(6) + Importe(16) + Resultado(4) + Comisión(10) + Concepto(40)

2026-10-29 16:26:45 0000000041 T 999999 000001 100.00 E001         CUENTA INEXISTENTE ORIGEN
2026-10-29 16:26:45 0000000047 R 000005 000000 1000.00 E002        RETIRADA EXCESIVA
2026-10-29 16:26:45 0000000051 T 000007 000001 100.00 E006         CUENTA BLOQUEADA ORIGEN
```

---

## Referencia Técnica

### Definición en Copybook

```cobol
COPY BANK-ERRORS.

01 ERROR-CODES.
    05 ERR-ACCOUNT-NOT-FOUND    PIC X(4) VALUE "E001".
    05 ERR-INSUFFICIENT-BAL     PIC X(4) VALUE "E002".
    05 ERR-ACCOUNT-INACTIVE     PIC X(4) VALUE "E003".
    05 ERR-INVALID-AMOUNT       PIC X(4) VALUE "E004".
    05 ERR-DUPLICATE-MOV        PIC X(4) VALUE "E005".
    05 ERR-ACCOUNT-BLOCKED      PIC X(4) VALUE "E006".
    05 ERR-DAILY-LIMIT          PIC X(4) VALUE "E007".
    05 ERR-RECORD-FORMAT        PIC X(4) VALUE "E008".
    05 ERR-INVALID-DATE         PIC X(4) VALUE "E009".
    05 ERR-IO-ERROR             PIC X(4) VALUE "E010".
```

### FILE STATUS Codes

```cobol
01 WS-FILE-STATUS PIC XX.

* Códigos de estado de ficheros:
* 00 - Operación exitosa
* 02 - Fichero no encontrado
* 04 - Fichero bloqueado
* 10 - Fin de fichero (EOF)
* 30 - Error permanente
* 35 - Fichero no existe
* 39 - Error de E/S
```

### Manejo de Errores en COBOL

```cobol
PERFORM 3000-VALIDATE-MOVEMENT

IF WS-VALID
    PERFORM 4000-PROCESS-VALID
ELSE
    PERFORM 5000-PROCESS-ERROR
END-IF

*-----------------------------------------------
* 5000-PROCESS-ERROR
*-----------------------------------------------
5000-PROCESS-ERROR.
    ADD 1 TO WS-ERROR-COUNT
    
    * Registrar en ERRORS.DAT
    WRITE ERROR-RECORD
    
    * Registrar en AUDIT.DAT con código de error
    MOVE WS-ERROR-CODE TO WS-AUDIT-RESULT
    WRITE AUDIT-RECORD
    
    * Continuar con el siguiente movimiento
    CONTINUE.
```

### Estadísticas de Errores

```cobol
01 WS-ERROR-COUNTS.
    05 WS-E001-COUNT PIC 9(4) VALUE 0.
    05 WS-E002-COUNT PIC 9(4) VALUE 0.
    05 WS-E003-COUNT PIC 9(4) VALUE 0.
    05 WS-E004-COUNT PIC 9(4) VALUE 0.
    05 WS-E005-COUNT PIC 9(4) VALUE 0.
    05 WS-E006-COUNT PIC 9(4) VALUE 0.
    05 WS-E007-COUNT PIC 9(4) VALUE 0.
    05 WS-E008-COUNT PIC 9(4) VALUE 0.
    05 WS-E009-COUNT PIC 9(4) VALUE 0.
    05 WS-E010-COUNT PIC 9(4) VALUE 0.

* Actualizar contadores
EVALUATE WS-ERROR-CODE
    WHEN "E001" ADD 1 TO WS-E001-COUNT
    WHEN "E002" ADD 1 TO WS-E002-COUNT
    WHEN "E003" ADD 1 TO WS-E003-COUNT
    WHEN "E004" ADD 1 TO WS-E004-COUNT
    WHEN "E005" ADD 1 TO WS-E005-COUNT
    WHEN "E006" ADD 1 TO WS-E006-COUNT
    WHEN "E007" ADD 1 TO WS-E007-COUNT
    WHEN "E008" ADD 1 TO WS-E008-COUNT
    WHEN "E009" ADD 1 TO WS-E009-COUNT
    WHEN "E010" ADD 1 TO WS-E010-COUNT
END-EVALUATE
```

---

## Estado de Implementación

| Código | Implementado | Probado | Documentado |
|--------|--------------|---------|-------------|
| E001 | ✅ Sí | ✅ Sí | ✅ Sí |
| E002 | ✅ Sí | ✅ Sí | ✅ Sí |
| E003 | ✅ Sí | ✅ Sí | ✅ Sí |
| E004 | ✅ Sí | ✅ Sí | ✅ Sí |
| E005 | ❌ No | ⚠️ Parcial | ✅ Sí |
| E006 | ✅ Sí | ✅ Sí | ✅ Sí |
| E007 | ✅ Sí | ✅ Sí | ✅ Sí |
| E008 | ❌ No | ❌ No | ✅ Sí |
| E009 | ❌ No | ❌ No | ✅ Sí |
| E010 | ✅ Sí | ✅ Sí | ✅ Sí |

**Progreso:** 7/10 códigos implementados (70%)

---

## Recomendaciones

### Para Desarrolladores

1. **Implementar E005, E008, E009** para completar la validación
2. **Agregar logging detallado** para facilitar debugging
3. **Implementar retry logic** para errores transitorios
4. **Agregar métricas** de frecuencia de errores

### Para Operaciones

1. **Monitorear frecuencias** de errores E002 (saldo insuficiente)
2. **Alertar** cuando E010 (error de E/S) ocurra
3. **Revisar** E001 (cuentas no encontradas) regularmente
4. **Documentar** patrones de errores recurrentes

### Para Negocio

1. **Revisar límites diarios** si E007 es frecuente
2. **Analizar E003** (cuentas inactivas) para políticas de reactivación
3. **Evaluar E006** (cuentas bloqueadas) para mejorar seguridad
4. **Optimizar** procesos para reducir E002 (saldo insuficiente)

---

**Versión del documento:** 1.0  
**Última actualización:** Octubre 2026  
**Autor:** Sistema COBOL Banking Batch
