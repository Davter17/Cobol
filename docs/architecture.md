# Arquitectura del Sistema - COBOL Banking Batch System

## Diagrama de Arquitectura General

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         COBOL BANKING BATCH SYSTEM                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              FASE 1: ENTRADA                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐         ┌──────────────────┐                         │
│  │  CLIENTES.DAT    │         │  CUENTAS.DAT     │                         │
│  │  (125 bytes)     │         │  (78 bytes)      │                         │
│  │                  │         │  20 cuentas      │                         │
│  │  Maestro de      │         │  Maestro de      │                         │
│  │  clientes        │         │  cuentas         │                         │
│  └──────────────────┘         └──────────────────┘                         │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    MOVIMIENTOS.DAT (89 bytes)                        │  │
│  │                    58 movimientos diarios                            │  │
│  │                                                                      │  │
│  │  Tipos: Transferencias (T), Ingresos (I),                            │  │
│  │         Retiradas (R), Pagos (P)                                     │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FASE 2: PRE-PROCESAMIENTO                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                    SORTJOB.jcl (DFSORT)                            │   │
│  │                    Ordenar movimientos por cuenta                  │   │
│  │                    SORT FIELDS=(12,6,CH,A)                         │   │
│  └────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │              MOVIMIENTOS.DAT (ordenado opcionalmente)              │   │
│  └────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FASE 3: PROCESAMIENTO BATCH                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                    BANKPROC.cob                                    │   │
│  │                    Programa Principal                              │   │
│  │                                                                    │   │
│  │  ┌─────────────────────────────────────────────────────────────┐ │   │
│  │  │  1. INICIALIZACION                                          │ │   │
│  │  │     - Abrir ficheros                                        │ │   │
│  │  │     - Validar configuración                                 │ │   │
│  │  └─────────────────────────────────────────────────────────────┘ │   │
│  │                              │                                     │   │
│  │                              ▼                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐ │   │
│  │  │  2. BUCLE PRINCIPAL (PERFORM UNTIL EOF)                     │ │   │
│  │  │     - Leer movimiento                                       │ │   │
│  │  │     - Validar y procesar                                    │ │   │
│  │  │     - Actualizar contadores                                 │ │   │
│  │  └─────────────────────────────────────────────────────────────┘ │   │
│  │                              │                                     │   │
│  │                              ▼                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐ │   │
│  │  │  3. VALIDACION EN CASCADA                                   │ │   │
│  │  │     - E001: Cuenta existe?                                  │ │   │
│  │  │     - E002: Saldo suficiente?                               │ │   │
│  │  │     - E003: Cuenta activa?                                  │ │   │
│  │  │     - E004: Importe válido?                                 │ │   │
│  │  │     - E007: Límite diario?                                  │ │   │
│  │  └─────────────────────────────────────────────────────────────┘ │   │
│  │                              │                                     │   │
│  │                    ┌─────────┴─────────┐                          │   │
│  │                    ▼                   ▼                          │   │
│  │          ┌─────────────────┐   ┌─────────────────┐              │   │
│  │          │   VÁLIDO (K)    │   │   ERROR (E00x)  │              │   │
│  │          └─────────────────┘   └─────────────────┘              │   │
│  │                    │                   │                          │   │
│  │                    ▼                   ▼                          │   │
│  │  ┌─────────────────────────┐   ┌─────────────────────────┐     │   │
│  │  │  4. PROCESAMIENTO       │   │  5. MANEJO DE ERROR     │     │   │
│  │  │     - Calcular comisión │   │     - Registrar error   │     │   │
│  │  │     - Actualizar saldos │   │     - Continuar         │     │   │
│  │  │     - Generar histórico │   │                         │     │   │
│  │  └─────────────────────────┘   └─────────────────────────┘     │   │
│  │                              │                                     │   │
│  │                              ▼                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐ │   │
│  │  │  6. FINALIZACION                                            │ │   │
│  │  │     - Cerrar ficheros                                       │ │   │
│  │  │     - Generar informe                                       │ │   │
│  │  │     - Mostrar resumen                                       │ │   │
│  │  └─────────────────────────────────────────────────────────────┘ │   │
│  │                                                                    │   │
│  └────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FASE 4: SALIDA                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐         │
│  │  ERRORS.DAT      │  │  HISTORICO.DAT   │  │  AUDIT.DAT       │         │
│  │  (108 bytes)     │  │  (118 bytes)     │  │  (112 bytes)     │         │
│  │                  │  │                  │  │                  │         │
│  │  Movimientos     │  │  Operaciones     │  │  Log completo    │         │
│  │  rechazados      │  │  exitosas        │  │  (todos)         │         │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘         │
│                                                                             │
│  ┌──────────────────┐  ┌──────────────────────────────────────────────┐   │
│  │  REPORT.DAT      │  │           CUENTAS.DAT (actualizado)          │   │
│  │  (80 bytes)      │  │                                              │   │
│  │                  │  │  Saldos actualizados después del             │   │
│  │  Informe diario  │  │  procesamiento batch                         │   │
│  │  profesional     │  │                                              │   │
│  └──────────────────┘  └──────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Diagrama de Flujo de Datos

```
MOVIMIENTOS.DAT
       │
       ▼
┌─────────────────┐
│  Leer Movimiento│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Validar Cuenta  │──── E001 ────► ERRORS.DAT
│     Origen      │                 AUDIT.DAT
└────────┬────────┘
         │ OK
         ▼
┌─────────────────┐
│ Validar Cuenta  │──── E001 ────► ERRORS.DAT
│     Destino     │                 AUDIT.DAT
└────────┬────────┘
         │ OK
         ▼
┌─────────────────┐
│ Validar Saldo   │──── E002 ────► ERRORS.DAT
│    Suficiente   │                 AUDIT.DAT
└────────┬────────┘
         │ OK
         ▼
┌─────────────────┐
│ Validar Estado  │──── E003 ────► ERRORS.DAT
│    de Cuenta    │                 AUDIT.DAT
└────────┬────────┘
         │ OK
         ▼
┌─────────────────┐
│ Validar Importe │──── E004 ────► ERRORS.DAT
│     Válido      │                 AUDIT.DAT
└────────┬────────┘
         │ OK
         ▼
┌─────────────────┐
│ Validar Límite  │──── E007 ────► ERRORS.DAT
│     Diario      │                 AUDIT.DAT
└────────┬────────┘
         │ OK
         ▼
┌─────────────────┐
│ Calcular        │
│    Comisión     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Actualizar      │
│    Saldo Origen │─────────────► CUENTAS.DAT (REWRITE)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Actualizar      │
│    Saldo Destino│─────────────► CUENTAS.DAT (REWRITE)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Registrar en    │
│    Histórico    │─────────────► HISTORICO.DAT
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Registrar en    │
│    Auditoría    │─────────────► AUDIT.DAT
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Leer Siguiente  │
│   Movimiento    │
└────────┬────────┘
         │
         └──── (loop until EOF)
```

## Componentes del Sistema

### Programas COBOL

| Programa | Descripción | Tipo de Acceso |
|----------|-------------|----------------|
| **BANKPROC.cob** | Programa principal de procesamiento batch | Batch |

### Ficheros de Entrada

| Fichero | Longitud | Registros | Descripción |
|---------|----------|-----------|-------------|
| **CLIENTES.DAT** | 125 bytes | 12 | Maestro de clientes |
| **CUENTAS.DAT** | 78 bytes | 20 | Maestro de cuentas bancarias |
| **MOVIMIENTOS.DAT** | 89 bytes | 58 | Movimientos del día a procesar |

### Ficheros de Salida

| Fichero | Longitud | Registros | Descripción |
|---------|----------|-----------|-------------|
| **ERRORS.DAT** | 108 bytes | Variable | Movimientos rechazados con códigos de error |
| **HISTORICO.DAT** | 118 bytes | Variable | Histórico de operaciones exitosas |
| **AUDIT.DAT** | 112 bytes | Variable | Log completo de auditoría (todos los movimientos) |
| **REPORT.DAT** | 80 bytes/linea | ~54 lineas | Informe profesional diario |
| **CUENTAS.DAT** | 78 bytes | 20 | Saldos actualizados (I-O) |

### Copybooks (Estructuras de Datos)

| Copybook | Descripción | Usado Por |
|----------|-------------|-----------|
| **BANK-CLIENT.cpy** | Estructura de cliente | CLIENTES.DAT |
| **BANK-ACCOUNT.cpy** | Estructura de cuenta bancaria | CUENTAS.DAT |
| **BANK-TRANSACTION.cpy** | Estructura de transacción | MOVIMIENTOS.DAT |
| **BANK-ERRORS.cpy** | Estructura de error y códigos | ERRORS.DAT |
| **BANK-COMMON.cpy** | Constantes globales del sistema | Todos los programas |

### JCL (Job Control Language)

| Job | Descripción | Ejecuta |
|-----|-------------|---------|
| **BANKJOB.jcl** | Job principal de procesamiento batch | BANKPROC |
| **SORTJOB.jcl** | Job de ordenación de movimientos | DFSORT |

## Flujo de Ejecución

### Escenario 1: Ejecución Directa

```
1. Compilar:  cobc -x -free cobol/BANKPROC.cob
2. Ejecutar:  ./BANKPROC
3. Verificar: ./scripts/verify.sh
```

### Escenario 2: Usando Scripts de Automatización

```
1. Compilar:  ./scripts/compile.sh
2. Ejecutar:  ./scripts/run.sh
   └─► Crea backup de CUENTAS.DAT
   └─► Ejecuta BANKPROC
   └─► Muestra informe
   └─► Indica ficheros de salida
3. Verificar: ./scripts/verify.sh
```

### Escenario 3: En Mainframe (z/OS)

```
1. Compilar en desarrollo
2. Cargar en biblioteca de producción (BANK.COBOL.LOAD)
3. Ejecutar BANKJOB.jcl
   └─► JOB CARD → EXEC PGM=BANKPROC
   └─► DD statements para todos los ficheros
   └─► SYSOUT para salida de consola
4. Verificar outputs en spool y ficheros
```

## Reglas de Negocio Implementadas

### Validaciones (en orden de ejecución)

| Orden | Código | Validación | Acción si falla |
|-------|--------|------------|-----------------|
| 1 | E001 | Cuenta origen existe | Rechazar movimiento |
| 2 | E001 | Cuenta destino existe | Rechazar movimiento |
| 3 | E002 | Saldo suficiente | Rechazar movimiento |
| 4 | E003 | Cuenta activa (no bloqueada/inactiva) | Rechazar movimiento |
| 5 | E004 | Importe > 0 | Rechazar movimiento |
| 6 | E007 | Importe ≤ límite diario | Rechazar movimiento |

### Cálculo de Comisiones

| Tipo | Código | Fórmula | Ejemplo |
|------|--------|---------|---------|
| **Transferencia** | T | 0.1% del importe (mínimo 0.50€) | 500.00€ → 0.50€ |
| **Ingreso** | I | Gratis | 1000.00€ → 0.00€ |
| **Retirada** | R | 2.00€ fijo | 200.00€ → 2.00€ |
| **Pago** | P | 0.05% del importe | 10000.00€ → 5.00€ |

### Lógica de Actualización de Saldos

```
Si movimiento es VÁLIDO:
    Si tipo = T (Transferencia):
        Saldo_Origen = Saldo_Origen - Importe - Comisión
        Saldo_Destino = Saldo_Destino + Importe
    
    Si tipo = I (Ingreso):
        Saldo_Destino = Saldo_Destino + Importe
        (No hay comisión)
    
    Si tipo = R (Retirada):
        Saldo_Origen = Saldo_Origen - Importe - Comisión
    
    Si tipo = P (Pago):
        Saldo_Origen = Saldo_Origen - Importe - Comisión

Registrar en HISTORICO.DAT
Registrar en AUDIT.DAT con resultado "K"
```

## Integridad de Datos

### Invariantes del Sistema

```
1. Total Movimientos = Aceptados + Rechazados

2. Suma de errores por tipo = Total Rechazados
   E001 + E002 + E003 + E004 + E005 + E006 + E007 = Rechazados

3. Registros en AUDIT.DAT = Total Movimientos

4. Registros en HISTORICO.DAT = Aceptados

5. Registros en ERRORS.DAT = Rechazados

6. Conservación del dinero:
   Suma_Saldos_Antes + Suma_Ingresos - Suma_Retiradas - Suma_Comisiones
   = Suma_Saldos_Después
```

## Scripts de Automatización

| Script | Propósito | Entrada | Salida |
|--------|-----------|---------|--------|
| **compile.sh** | Compilar todos los programas | *.cob | Ejecutables |
| **run.sh** | Ejecutar batch completo | CUENTAS.DAT, MOVIMIENTOS.DAT | Todos los outputs |
| **generate-test-data.sh** | Generar datos de prueba | - | CLIENTES.DAT, CUENTAS.DAT, MOVIMIENTOS.DAT |
| **verify.sh** | Verificar integridad | Todos los outputs | Reporte de PASS/FAIL |
| **run-tests.sh** | Ejecutar casos de prueba | Datos de prueba | Resultados de pruebas |

## Estructura de Directorios

```
CobolFinal/
│
├── cobol/                          # Programas COBOL fuente
│   └── BANKPROC.cob               # Programa principal
│
├── copybooks/                      # Estructuras de datos compartidas
│   ├── BANK-CLIENT.cpy
│   ├── BANK-ACCOUNT.cpy
│   ├── BANK-TRANSACTION.cpy
│   ├── BANK-ERRORS.cpy
│   └── BANK-COMMON.cpy
│
├── data/                           # Ficheros de datos
│   ├── CLIENTES.DAT               # Entrada: maestro de clientes
│   ├── CUENTAS.DAT                # Entrada/Salida: maestro de cuentas
│   └── MOVIMIENTOS.DAT            # Entrada: movimientos del día
│
├── output/                         # Ficheros de salida (generados)
│   ├── ERRORS.DAT                 # Salida: errores
│   ├── HISTORICO.DAT              # Salida: histórico
│   ├── AUDIT.DAT                  # Salida: auditoría
│   └── REPORT.DAT                 # Salida: informe
│
├── jcl/                            # Job Control Language
│   ├── BANKJOB.jcl                # Job de ejecución
│   └── SORTJOB.jcl                # Job de ordenación
│
├── scripts/                        # Scripts de automatización
│   ├── compile.sh
│   ├── run.sh
│   ├── generate-test-data.sh
│   ├── verify.sh
│   └── run-tests.sh
│
├── tests/                          # Documentación de pruebas
│   ├── test-cases.md
│   └── test-results/
│
├── docs/                           # Documentación técnica
│   ├── record-layouts.md          # Estructuras de registros
│   ├── architecture.md            # Este documento
│   └── error-codes.md             # Códigos de error
│
├── README.md                       # Documentación principal
├── Guide.txt                       # Guía de desarrollo
└── .gitignore                      # Git ignore
```

## Tecnologías y Herramientas

| Componente | Tecnología | Propósito |
|------------|------------|-----------|
| **Lenguaje** | COBOL (GnuCOBOL 3.x) | Programación batch |
| **Compilador** | cobc (GnuCOBOL) | Compilar programas COBOL |
| **Sistema Operativo** | Linux (WSL) | Entorno de ejecución |
| **Mainframe** | IBM z/OS (simulado) | Entorno de producción |
| **Control de Versiones** | Git | Gestión de código fuente |
| **Scripts** | Bash | Automatización |
| **Ordenación** | DFSORT (simulado) | Ordenación de ficheros |

## Métricas del Sistema

### Rendimiento

| Métrica | Valor |
|---------|-------|
| **Tiempo de procesamiento** | < 1 segundo para 58 movimientos |
| **Throughput** | ~58 movimientos/segundo |
| **Uso de memoria** | Mínimo (procesamiento secuencial) |

### Cobertura de Pruebas

| Categoría | Total | Pasadas | % Cobertura |
|-----------|-------|---------|-------------|
| Happy Path | 5 | 5 | 100% |
| Error Path | 7 | 7 | 100% |
| Edge Cases | 5 | 3 | 60% |
| **Total** | **17** | **15** | **88%** |

## Seguridad y Auditoría

### Características de Seguridad

1. **Validación exhaustiva**: Todas las transacciones pasan por 6 validaciones
2. **Trazabilidad completa**: Cada movimiento se registra en AUDIT.DAT
3. **Backups automáticos**: El script run.sh crea backups antes de procesar
4. **Códigos de error específicos**: Cada tipo de error tiene un código único
5. **Integridad de datos**: Verificación de invariantes post-procesamiento

### Auditoría

- **AUDIT.DAT**: Log completo de todos los movimientos procesados
- **HISTORICO.DAT**: Solo movimientos exitosos
- **ERRORS.DAT**: Solo movimientos rechazados con detalles del error
- **REPORT.DAT**: Resumen ejecutivo del procesamiento

---

**Versión del documento:** 1.0  
**Última actualización:** Octubre 2026  
**Autor:** Sistema COBOL Banking Batch
