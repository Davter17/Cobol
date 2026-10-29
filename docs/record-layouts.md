# Record Layouts - COBOL Banking Batch System

Documentación detallada de las estructuras de registros de todos los ficheros del sistema.

---

## Tabla de Contenidos

1. [CLIENTES.DAT](#clientesdat)
2. [CUENTAS.DAT](#cuentasdat)
3. [MOVIMIENTOS.DAT](#movimientosdat)
4. [ERRORS.DAT](#errorsdat)
5. [HISTORICO.DAT](#historicodat)
6. [REPORT.DAT](#reportdat)
7. [AUDIT.DAT](#auditdat)

---

## CLIENTES.DAT

**Descripción:** Maestro de clientes del sistema bancario  
**Longitud total:** 125 bytes  
**Formato:** LINE SEQUENTIAL (FB)

| Campo | Posición | Longitud | Tipo | Descripción |
|-------|----------|----------|------|-------------|
| WS-CLIENT-DNI | 1-9 | 9 | X(9) | DNI/NIF del cliente (clave primaria) |
| WS-CLIENT-NAME | 10-39 | 30 | X(30) | Nombre completo del cliente |
| WS-CLIENT-ADDRESS | 40-69 | 30 | X(30) | Dirección postal |
| WS-CLIENT-PHONE | 70-78 | 9 | X(9) | Teléfono de contacto |
| WS-CLIENT-EMAIL | 79-108 | 30 | X(30) | Correo electrónico |
| WS-CLIENT-DATE | 109-116 | 8 | 9(8) | Fecha de alta (YYYYMMDD) |
| WS-CLIENT-STATUS | 117 | 1 | X(1) | Estado del cliente (A=Activo, I=Inactivo) |
| FILLER (padding) | 118-125 | 8 | X(8) | Relleno para alineación |

**Ejemplo de registro:**
```
12345678A MARIO PICO BUSQUIER              CALLE MAYOR 123 MADRID         555123456mario.pico@email.com          20240115A        
```

**Copybook de referencia:** `copybooks/BANK-CLIENT.cpy`

---

## CUENTAS.DAT

**Descripción:** Maestro de cuentas bancarias  
**Longitud total:** 78 bytes  
**Formato:** LINE SEQUENTIAL (FB)  
**Acceso:** I-O (lectura/escritura para actualizaciones)

| Campo | Posición | Longitud | Tipo | Descripción |
|-------|----------|----------|------|-------------|
| WS-ACCOUNT-NUMBER | 1-6 | 6 | 9(6) | Número de cuenta (clave primaria) |
| WS-ACCOUNT-DNI | 7-15 | 9 | X(9) | DNI del titular |
| WS-ACCOUNT-NAME | 16-45 | 30 | X(30) | Nombre del titular |
| WS-ACCOUNT-BALANCE | 46-57 | 12 | S9(10)V99 | Saldo actual (con signo, 2 decimales implícitos) |
| WS-ACCOUNT-STATUS | 58 | 1 | X(1) | Estado de la cuenta (A=Activa, B=Bloqueada, I=Inactiva) |
| WS-ACCOUNT-OPEN-DATE | 59-66 | 8 | 9(8) | Fecha de apertura (YYYYMMDD) |
| WS-ACCOUNT-DAILY-LIMIT | 67-78 | 12 | 9(10)V99 | Límite diario de operaciones (2 decimales implícitos) |

**Notas importantes:**
- El saldo tiene signo (S9), permitiendo valores negativos
- Los decimales son implícitos (V), no se almacena el punto decimal
- Ejemplo: `000001500050` representa `0000015000.50` (15,000.50 EUR)

**Ejemplo de registro:**
```
00000112345678AMARIO PICO BUSQUIER           000001500050A20240115000000500000
```

**Desglose del ejemplo:**
- Cuenta: `000001`
- DNI: `12345678A`
- Nombre: `MARIO PICO BUSQUIER           ` (30 chars)
- Saldo: `000001500050` → 15,000.50 EUR
- Estado: `A` (Activa)
- Fecha apertura: `20240115`
- Límite diario: `000000500000` → 5,000.00 EUR

**Copybook de referencia:** `copybooks/BANK-ACCOUNT.cpy`

---

## MOVIMIENTOS.DAT

**Descripción:** Fichero de entrada con los movimientos del día a procesar  
**Longitud total:** 89 bytes  
**Formato:** LINE SEQUENTIAL (FB)  
**Acceso:** INPUT (solo lectura)

| Campo | Posición | Longitud | Tipo | Descripción |
|-------|----------|----------|------|-------------|
| WS-TRANSACTION-ID | 1-10 | 10 | 9(10) | Identificador único de la transacción |
| WS-TRANSACTION-TYPE | 11 | 1 | X(1) | Tipo de operación (T=Transferencia, I=Ingreso, R=Retirada, P=Pago) |
| WS-TRANSACTION-ORIGIN | 12-17 | 6 | 9(6) | Cuenta origen (000000 para ingresos) |
| WS-TRANSACTION-DESTINATION | 18-23 | 6 | 9(6) | Cuenta destino (000000 para retiradas) |
| WS-TRANSACTION-AMOUNT | 24-35 | 12 | S9(10)V99 | Importe de la operación (con signo, 2 decimales implícitos) |
| WS-TRANSACTION-DATE | 36-43 | 8 | 9(8) | Fecha de la transacción (YYYYMMDD) |
| WS-TRANSACTION-TIME | 44-49 | 6 | 9(6) | Hora de la transacción (HHMMSS) |
| WS-TRANSACTION-CONCEPT | 50-89 | 40 | X(40) | Concepto/descripción de la operación |

**Notas importantes:**
- Para ingresos (I), el campo origen contiene `000000`
- Para retiradas (R), el campo destino contiene `000000`
- El importe tiene signo (S9), aunque normalmente es positivo
- Los decimales son implícitos (V)

**Ejemplo de registro:**
```
0000000001T00000100000200000005000020260301090000TRANSFERENCIA ENTRE CUENTAS             
```

**Desglose del ejemplo:**
- ID: `0000000001`
- Tipo: `T` (Transferencia)
- Origen: `000001`
- Destino: `000002`
- Importe: `000000050000` → 500.00 EUR
- Fecha: `20260301`
- Hora: `090000` (09:00:00)
- Concepto: `TRANSFERENCIA ENTRE CUENTAS             ` (40 chars)

**Copybook de referencia:** `copybooks/BANK-TRANSACTION.cpy`

---

## ERRORS.DAT

**Descripción:** Registro de movimientos rechazados con códigos de error  
**Longitud total:** 108 bytes  
**Formato:** LINE SEQUENTIAL (FB)  
**Acceso:** OUTPUT (escritura)

| Campo | Posición | Longitud | Tipo | Descripción |
|-------|----------|----------|------|-------------|
| WS-ERR-TIMESTAMP | 1-26 | 26 | X(26) | Timestamp del procesamiento (YYYYMMDD HHMMSS + padding) |
| WS-ERR-TRANSACTION-ID | 27-36 | 10 | 9(10) | ID de la transacción rechazada |
| WS-ERR-CODE | 37-40 | 4 | X(4) | Código de error (E001-E010) |
| WS-ERR-DESCRIPTION | 41-90 | 50 | X(50) | Descripción del error |
| WS-ERR-ACCOUNT-ID | 91-96 | 6 | 9(6) | Cuenta asociada al error |
| WS-ERR-AMOUNT | 97-108 | 12 | S9(10)V99 | Importe de la transacción rechazada |

**Ejemplo de registro:**
```
20261029 162645           0000000041E001CUENTA ORIGEN NO ENCONTRADA                       999999000000010000
```

**Copybook de referencia:** `copybooks/BANK-ERRORS.cpy`

**Ver también:** [error-codes.md](error-codes.md) para la lista completa de códigos de error

---

## HISTORICO.DAT

**Descripción:** Registro histórico de todas las operaciones procesadas exitosamente  
**Longitud total:** 118 bytes  
**Formato:** LINE SEQUENTIAL (FB)  
**Acceso:** EXTEND (append, solo escritura al final)

| Campo | Posición | Longitud | Tipo | Descripción |
|-------|----------|----------|------|-------------|
| WS-HIST-TIMESTAMP | 1-26 | 26 | X(26) | Timestamp del procesamiento |
| WS-HIST-TRANSACTION-ID | 27-36 | 10 | 9(10) | ID de la transacción |
| WS-HIST-TRANSACTION-TYPE | 37 | 1 | X(1) | Tipo de operación (T/I/R/P) |
| WS-HIST-ORIGIN-ACCOUNT | 38-43 | 6 | 9(6) | Cuenta origen |
| WS-HIST-DESTINATION-ACCOUNT | 44-49 | 6 | 9(6) | Cuenta destino |
| WS-HIST-AMOUNT | 50-61 | 12 | S9(10)V99 | Importe de la operación |
| WS-HIST-DATE | 62-69 | 8 | 9(8) | Fecha original de la transacción |
| WS-HIST-TIME | 70-75 | 6 | 9(6) | Hora original de la transacción |
| WS-HIST-CONCEPT | 76-115 | 40 | X(40) | Concepto de la operación |
| FILLER (padding) | 116-118 | 3 | X(3) | Relleno para alineación |

**Notas importantes:**
- Este fichero se abre en modo EXTEND, por lo que se acumulan registros en cada ejecución
- Contiene solo operaciones exitosas (las rechazadas están en ERRORS.DAT)
- Mantiene la fecha y hora originales de la transacción, no del procesamiento

**Ejemplo de registro:**
```
20261029 162645           0000000001T00000100000200000005000020260301090000TRANSFERENCIA ENTRE CUENTAS             
```

---

## REPORT.DAT

**Descripción:** Informe profesional con resumen del procesamiento diario  
**Longitud total:** 80 bytes por línea  
**Formato:** LINE SEQUENTIAL (FB)  
**Acceso:** OUTPUT (escritura)

| Campo | Posición | Longitud | Tipo | Descripción |
|-------|----------|----------|------|-------------|
| WS-REPORT-LINE | 1-80 | 80 | X(80) | Línea de texto del informe |

**Estructura del informe:**

El informe tiene una estructura fija de líneas:

| Línea | Contenido |
|-------|-----------|
| 1-5 | Cabecera con separadores y título "DAILY BANKING REPORT" |
| 6-8 | Información del banco y fecha del informe |
| 9-20 | Sección "PROCESSING SUMMARY" con totales |
| 21-28 | Sección "OPERATIONS BY TYPE" con desglose por tipo |
| 29-35 | Sección "FINANCIAL SUMMARY" con importes formateados |
| 36-50 | Sección "ERRORS BREAKDOWN" con conteo de errores por tipo |
| 51-54 | Pie con "END OF REPORT" |

**Formato de números:**
- Los importes se formatean con PIC `ZZZ,ZZZ,ZZ9.99`
- Ejemplo: `7,087.55 EUR`, `11,612.80 EUR`, `25.55 EUR`

**Ejemplo de contenido:**
```
================================================================================

              COBOL BANKING SYSTEM
            DAILY BANKING REPORT

================================================================================
  BANK CODE: 0001
  REPORT DATE: 2026-10-29

  PROCESSING SUMMARY
--------------------------------------------------------------------------------
  TOTAL MOVEMENTS PROCESSED: 000058
  ACCEPTED:                    000035
  REJECTED:                    000023
  ACCOUNTS UPDATED:            0035

  FINANCIAL SUMMARY
--------------------------------------------------------------------------------
  TOTAL DEBITED:            8,205.36 EUR
  TOTAL CREDITED:          12,730.61 EUR
  TOTAL COMMISSIONS:           24.40 EUR
```

**Generado por:** Párrafo `9200-GENERATE-REPORT` en `cobol/BANKPROC.cob`

---

## AUDIT.DAT

**Descripción:** Log de auditoría con detalle de cada movimiento procesado (aceptado o rechazado)  
**Longitud total:** 112 bytes  
**Formato:** LINE SEQUENTIAL (FB)  
**Acceso:** OUTPUT (escritura)

| Campo | Posición | Longitud | Tipo | Descripción |
|-------|----------|----------|------|-------------|
| WS-AUDIT-TIMESTAMP | 1-19 | 19 | X(19) | Timestamp compacto (YYYY-MM-DD HH:MM:SS) |
| WS-AUDIT-TRANSACTION-ID | 20-29 | 10 | 9(10) | ID de la transacción |
| WS-AUDIT-TYPE | 30 | 1 | X(1) | Tipo de operación (T/I/R/P) |
| WS-AUDIT-ORIGIN | 31-36 | 6 | 9(6) | Cuenta origen |
| WS-AUDIT-DESTINATION | 37-42 | 6 | 9(6) | Cuenta destino |
| WS-AUDIT-AMOUNT-STR | 43-58 | 16 | X(16) | Importe formateado (PIC ZZZ,ZZZ,ZZ9.99) |
| WS-AUDIT-RESULT | 59-62 | 4 | X(4) | Resultado: "K" (OK) o código de error (E001-E010) |
| WS-AUDIT-COMMISSION-STR | 63-72 | 10 | X(10) | Comisión formateada (PIC ZZ,ZZ9.99) o espacios si error |
| WS-AUDIT-CONCEPT | 73-112 | 40 | X(40) | Concepto de la operación |

**Notas importantes:**
- Contiene TODOS los movimientos procesados (aceptados y rechazados)
- Para movimientos aceptados, WS-AUDIT-RESULT contiene "K"
- Para movimientos rechazados, contiene el código de error (E001, E002, etc.)
- El campo de comisión está vacío para movimientos rechazados
- El número de registros en AUDIT.DAT debe ser igual al total de movimientos procesados

**Ejemplos de registros:**

Movimiento aceptado:
```
2026-10-29 16:26:450000000001T000001000002        500.00  K        0.50 TRANSFERENCIA ENTRE CUENTAS
```

Movimiento rechazado:
```
2026-10-29 16:26:450000000041T999999000001        100.00  E001          CUENTA INEXISTENTE ORIGEN
```

**Generado por:** Párrafos `4500-WRITE-AUDIT-OK` y `5300-WRITE-AUDIT-ERROR` en `cobol/BANKPROC.cob`

---

## Convenciones de Notación

### Tipos de Datos COBOL

| Notación | Significado | Ejemplo |
|----------|-------------|---------|
| `X(n)` | Alfanumérico de n caracteres | `X(30)` = 30 caracteres |
| `9(n)` | Numérico de n dígitos | `9(6)` = 6 dígitos |
| `S9(n)` | Numérico con signo de n dígitos | `S9(10)` = 10 dígitos con signo |
| `V` | Punto decimal implícito | `9(10)V99` = 10 enteros + 2 decimales |

### Formatos de Edición

| Notación | Significado | Ejemplo |
|----------|-------------|---------|
| `Z` | Supresión de ceros a la izquierda | `ZZZ,ZZZ,ZZ9.99` |
| `,` | Separador de miles | `7,087.55` |
| `.` | Punto decimal | `25.55` |

### Estados de Cuenta

| Código | Significado |
|--------|-------------|
| A | Activa (puede operar) |
| B | Bloqueada (no puede operar) |
| I | Inactiva (no puede operar) |

### Tipos de Operación

| Código | Significado |
|--------|-------------|
| T | Transferencia entre cuentas |
| I | Ingreso/deposito en cuenta |
| R | Retirada de efectivo |
| P | Pago a proveedor |

---

## Referencias Cruzadas

- **Copybooks fuente:**
  - `copybooks/BANK-CLIENT.cpy` → CLIENTES.DAT
  - `copybooks/BANK-ACCOUNT.cpy` → CUENTAS.DAT
  - `copybooks/BANK-TRANSACTION.cpy` → MOVIMIENTOS.DAT
  - `copybooks/BANK-ERRORS.cpy` → ERRORS.DAT

- **Programas COBOL que usan estas estructuras:**
  - `cobol/BANKPROC.cob` → Programa principal que procesa todos los ficheros

- **JCL que referencia estos ficheros:**
  - `jcl/BANKJOB.jcl` → Job de ejecución principal
  - `jcl/SORTJOB.jcl` → Job de ordenación previa

---

**Última actualización:** Octubre 2026  
**Versión del documento:** 1.0
