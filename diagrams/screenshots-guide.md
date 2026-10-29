# Guía de Capturas de Pantalla

Este documento indica qué capturas de pantalla tomar para documentar el proyecto.

## Capturas Recomendadas

### 1. Estructura del Proyecto
```bash
tree -L 2 -I '.git|bin|backups'
```

**Qué mostrar:** Estructura completa de directorios con las carpetas principales:
- cobol/
- copybooks/
- data/
- output/
- jcl/
- scripts/
- tests/
- docs/

### 2. Compilación Exitosa
```bash
./scripts/compile.sh
```

**Qué mostrar:** Output del script mostrando:
- Compilación de todos los programas .cob
- Mensaje "✓ Todos los programas compilados correctamente"
- Resumen con 0 errores

### 3. Ejecución del Batch
```bash
./scripts/run.sh
```

**Qué mostrar:** Output completo mostrando:
- Creación de backup
- Inicio del procesamiento
- Resumen final con:
  - TOTAL MOVEMENTS: 000058
  - ACCEPTED: 000035
  - REJECTED: 000023
  - Financial Summary con importes formateados
  - Errors Breakdown con todos los códigos E001-E007

### 4. Informe Generado (REPORT.DAT)
```bash
cat output/REPORT.DAT
```

**Qué mostrar:** Informe profesional completo con:
- Cabecera "COBOL BANKING SYSTEM"
- Processing Summary
- Operations by Type
- Financial Summary con números formateados (comas, decimales)
- Errors Breakdown
- END OF REPORT

### 5. Fichero de Errores (ERRORS.DAT)
```bash
head -10 output/ERRORS.DAT
```

**Qué mostrar:** Primeras 10 líneas mostrando:
- Timestamp
- ID de transacción
- Código de error (E001-E007)
- Descripción del error
- Cuenta asociada
- Importe

### 6. Log de Auditoría (AUDIT.DAT)
```bash
head -10 output/AUDIT.DAT
```

**Qué mostrar:** Primeras 10 líneas mostrando:
- Timestamp
- ID de transacción
- Tipo de operación
- Cuentas origen y destino
- Importe
- Resultado (K para OK, o código de error)
- Comisión

## Consejos para las Capturas

1. **Usa un terminal con fondo oscuro** para mejor contraste
2. **Amplía la ventana** para que el texto sea legible
3. **Incluye el prompt** para mostrar que es una ejecución real
4. **Captura la salida completa** sin recortar información importante
5. **Usa herramientas como** ShareX, Greenshot, o la herramienta de recorte de Windows

## Ejemplo de Formato para README

Puedes insertar las capturas en el README así:

```markdown
### Ejecución del Batch
![Ejecución del Batch](diagrams/screenshot-run.png)

### Informe Generado
![Informe](diagrams/screenshot-report.png)
```

## Alternativa: Output en Formato Texto

Si prefieres no usar imágenes, puedes incluir el output directamente en el README:

````markdown
### Ejemplo de Ejecución

```
$ ./scripts/run.sh
==========================================
  EJECUCIÓN BATCH BANCARIO
==========================================

✓ Backup creado: backups/CUENTAS_20261029_201805.DAT

==========================================
  INICIANDO PROCESAMIENTO
==========================================

========================================
    COBOL BANKING BATCH SYSTEM
    DAILY PROCESSING START
========================================

========================================
    DAILY PROCESSING COMPLETE
========================================

TOTAL MOVEMENTS:  000058
ACCEPTED:         000035
REJECTED:         000023

FINANCIAL SUMMARY:
  TOTAL DEBITED:        8,605.38 EUR
  TOTAL CREDITED:      13,130.63 EUR
  COMMISSIONS:             24.90 EUR
```
````
