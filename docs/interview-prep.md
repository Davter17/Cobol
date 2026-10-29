# Preparación para Entrevistas - COBOL Banking Batch System

## Elevator Pitch (2 minutos)

### Introducción (30 segundos)
"Soy Mario Pico y he desarrollado un sistema de procesamiento batch bancario en COBOL que gestiona transacciones financieras de forma segura y eficiente. El sistema procesa diariamente transferencias, ingresos, retiradas y pagos, aplicando validaciones de negocio, calculando comisiones y generando informes profesionales con trazabilidad completa."

### Qué hace el sistema (30 segundos)
"El sistema procesa ficheros de movimientos bancarios aplicando validaciones en cascada: verifica que las cuentas existan, tengan saldo suficiente, estén activas y no excedan límites diarios. Los movimientos válidos actualizan saldos, calculan comisiones según el tipo de operación y se registran en múltiples ficheros de salida: informes profesionales, logs de auditoría y registros de errores. Los movimientos inválidos se rechazan con códigos de error específicos (E001-E007) para su posterior análisis."

### Tecnologías y conceptos (30 segundos)
"El proyecto está desarrollado en COBOL usando GnuCOBOL como compilador, siguiendo estándares empresariales de la industria bancaria. Implementa conceptos clave como: estructuras de datos con copybooks reutilizables, manejo de ficheros secuenciales con acceso I-O para actualizaciones in-place, validaciones en cascada con niveles 88 para condiciones nombradas, cálculos financieros con formatos de edición profesional (PIC Z,ZZZ,ZZ9.99), JCL para ejecución en mainframe IBM z/OS, y scripts de automatización en Bash para compilación, ejecución, testing y limpieza del proyecto."

### Retos técnicos y aprendizaje (30 segundos)
"Entre los retos técnicos que superé están: implementar búsquedas secuenciales eficientes en ficheros de cuentas para cada transacción, manejar correctamente la actualización in-place de saldos usando OPEN I-O y REWRITE, diseñar un sistema de validación en cascada que detecta múltiples tipos de errores, y crear scripts de verificación automática que garantizan la integridad de datos con 29 pruebas diferentes. Este proyecto me permitió dominar los fundamentos de COBOL empresarial y entender cómo funcionan los sistemas legacy que procesan billones de transacciones diarias en la industria bancaria."

---

## Preguntas Frecuentes de Entrevistas

### P: ¿Por qué COBOL en 2026?
**R:** "COBOL sigue procesando el 95% de las transacciones ATM y el 80% de las transacciones bancarias mundiales. Más de 200 mil millones de líneas de código COBOL están en producción. Las empresas financieras buscan desesperadamente desarrolladores que puedan mantener y modernizar estos sistemas. Este proyecto demuestra que puedo trabajar con tecnologías legacy que son críticas para la industria."

### P: ¿Cómo manejas la integridad de datos?
**R:** "Implemento múltiples mecanismos de verificación: validaciones en cascada antes de procesar cada transacción, actualización atómica de saldos con REWRITE, generación de logs de auditoría completos en AUDIT.DAT, y scripts de verificación automática que comprueban que Total = Aceptados + Rechazados, que la suma de errores por tipo coincide con el total de rechazados, y que los ficheros de salida son coherentes entre sí. El sistema tiene 29 pruebas automatizadas que verifican la integridad."

### P: ¿Cómo funciona el procesamiento batch?
**R:** "El programa BANKPROC lee secuencialmente el fichero MOVIMIENTOS.DAT, para cada movimiento busca la cuenta origen y destino en CUENTAS.DAT, aplica validaciones en cascada (E001-E007), y si es válido: calcula la comisión según el tipo de operación, actualiza saldos con REWRITE, y registra en HISTORICO.DAT y AUDIT.DAT. Si es inválido, registra el error en ERRORS.DAT y AUDIT.DAT con el código específico. Al final genera un informe profesional en REPORT.DAT con resumen ejecutivo."

### P: ¿Qué tipos de errores maneja el sistema?
**R:** "El sistema maneja 7 tipos de errores principales: E001 (cuenta inexistente), E002 (saldo insuficiente), E003 (cuenta bloqueada), E004 (importe inválido), E005 (movimiento duplicado), E006 (cuenta inactiva), y E007 (límite diario excedido). Cada error se registra con timestamp, ID de transacción, código de error, descripción, cuenta afectada e importe, permitiendo análisis posterior y auditoría completa."

### P: ¿Cómo calculas las comisiones?
**R:** "Las comisiones varían según el tipo de operación: transferencias cobran 0.1% del importe con un mínimo de 0.50 EUR, retiradas cobran 2.00 EUR fijos, ingresos son gratuitos, y pagos cobran 0.05% del importe. Uso COMPUTE con campos PIC S9(10)V99 para precisión decimal y PIC Z,ZZZ,ZZ9.99 para formateo profesional de los importes en los informes."

### P: ¿Cómo asegurarías la calidad del código?
**R:** "Implemento múltiples niveles de verificación: scripts de compilación automática que reportan éxitos y errores, scripts de ejecución que crean backups antes de procesar, 17 casos de prueba documentados (5 happy path, 7 error path, 5 edge cases) con 88% de cobertura, script de verificación de integridad con 29 pruebas automatizadas, y documentación completa de arquitecturas, estructuras de datos y códigos de error. Además, el código sigue estándares empresariales con comentarios explicativos y estructura modular."

### P: ¿Cómo escalarías este sistema?
**R:** "Para escalar el sistema: implementaría procesamiento en paralelo dividiendo movimientos por rangos de cuentas, usaría VSAM o bases de datos en lugar de ficheros secuenciales para acceso indexado, agregaría un sistema de colas para procesamiento asíncrono, implementaría logs centralizados con ELK stack, crearía APIs REST para integración con sistemas modernos (como muestra la Fase 14 opcional del proyecto), y usaría contenedores Docker para despliegue consistente."

### P: ¿Qué harías diferente si empezaras de nuevo?
**R:** "Implementaría desde el inicio: control de versiones más granular con commits por funcionalidad, pruebas unitarias para cada módulo de validación, configuración externa para parámetros como comisiones y límites en lugar de constantes en el código, manejo más robusto de errores de E/S con reintentos, y un sistema de logging estructurado con niveles (INFO, WARN, ERROR) en lugar de DISPLAY simples."

---

## Conceptos Técnicos Clave para Mencionar

### COBOL
- **Divisiones:** IDENTIFICATION, ENVIRONMENT, DATA, PROCEDURE
- **Niveles 88:** Condiciones nombradas para validaciones legibles
- **PIC con edición:** Z,ZZZ,ZZ9.99 para formato financiero
- **FILE STATUS:** Manejo de errores de E/S
- **REWRITE:** Actualización in-place de registros
- **COPY books:** Reutilización de estructuras de datos
- **PERFORM UNTIL:** Bucles de procesamiento secuencial
- **EVALUATE:** Estructura de control tipo switch/case

### Mainframe
- **JCL:** Job Control Language para ejecución batch
- **DD statements:** Definición de ficheros de entrada/salida
- **DISP:** Control de disposición de ficheros (NEW, OLD, SHR)
- **SYSOUT:** Salida de mensajes a consola
- **DFSORT:** Utilidad de ordenación de IBM

### Buenas Prácticas
- **Validación en cascada:** Verificar condiciones en orden de importancia
- **Trazabilidad:** Logs completos de auditoría
- **Integridad:** Verificación de invariantes post-procesamiento
- **Automatización:** Scripts para compilación, ejecución, testing
- **Documentación:** Record layouts, arquitectura, códigos de error

---

## Métricas del Proyecto para Mencionar

- **Líneas de código:** ~2,000 líneas de COBOL
- **Casos de prueba:** 17 casos con 88% de cobertura
- **Pruebas de integridad:** 29 verificaciones automatizadas
- **Tipos de error:** 7 códigos de error gestionados
- **Ficheros de salida:** 4 ficheros (REPORT, AUDIT, ERRORS, HISTORICO)
- **Scripts de automatización:** 6 scripts (compile, run, clean, verify, run-tests, generate-test-data)
- **Documentación:** 4 documentos técnicos (README, record-layouts, architecture, error-codes)
- **Progreso del desarrollo:** 47/54 pasos completados (87%)

---

## Demo en Vivo (si te lo piden)

```bash
# 1. Mostrar estructura del proyecto
tree -L 2 -I '.git|bin|backups'

# 2. Compilar
./scripts/compile.sh

# 3. Ejecutar el batch
./scripts/run.sh

# 4. Mostrar el informe
cat output/REPORT.DAT

# 5. Verificar integridad
./scripts/verify.sh

# 6. Mostrar casos de prueba
cat tests/test-cases.md | head -50
```

---

## Consejos para la Entrevista

1. **Habla con confianza** sobre COBOL, no te disculpes por usar tecnología legacy
2. **Enfatiza el valor empresarial:** sistemas legacy procesan billones de dólares diarios
3. **Muestra tu capacidad de aprendizaje:** dominaste COBOL desde cero
4. **Destaca las buenas prácticas:** documentación, testing, automatización
5. **Conecta con el negocio:** explica cómo tu sistema resuelve problemas reales
6. **Prepara preguntas:** ¿Qué sistemas legacy mantienen en la empresa? ¿Están migrando a nuevas tecnologías? ¿Cómo integran sistemas antiguos con modernos?

---

**Última actualización:** Octubre 2026  
**Versión:** 1.0
