# COBOL Banking System - REST API

API REST moderna en Python (FastAPI) para integración con el sistema bancario COBOL legacy.

## 🎯 Propósito

Esta API demuestra la capacidad de integrar sistemas legacy COBOL con tecnologías modernas, proporcionando una capa de abstracción REST que permite a aplicaciones web, móviles y otros sistemas consumir los datos del sistema bancario sin necesidad de entender el formato de ficheros COBOL.

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    APLICACIONES MODERNAS                     │
│              (Web, Mobile, Microservicios)                   │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/REST (JSON)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              FASTAPI REST API (Python)                       │
│                    Puerto 8000                               │
├─────────────────────────────────────────────────────────────┤
│  • Parser de ficheros COBOL (fixed-width)                   │
│  • Conversión a JSON                                         │
│  • Validación con Pydantic                                  │
│  • Documentación automática (Swagger/OpenAPI)               │
└────────────────────────┬────────────────────────────────────┘
                         │ Lectura de ficheros
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              SISTEMA COBOL LEGACY                            │
├─────────────────────────────────────────────────────────────┤
│  • data/CUENTAS.DAT      - Maestro de cuentas               │
│  • data/MOVIMIENTOS.DAT  - Transacciones                    │
│  • output/REPORT.DAT     - Informes                         │
│  • output/AUDIT.DAT      - Auditoría                        │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Requisitos

- Python 3.8 o superior
- Ficheros de datos COBOL generados (ejecutar primero el sistema COBOL)

## 🚀 Instalación

### 1. Crear entorno virtual (recomendado)

```bash
cd api
python3 -m venv venv

# Activar en Linux/Mac
source venv/bin/activate

# Activar en Windows
venv\Scripts\activate
```

### 2. Instalar dependencias

```bash
pip install -r requirements.txt
```

## ▶️ Ejecución

### Opción 1: Ejecución directa

```bash
cd api
python main.py
```

### Opción 2: Usando uvicorn

```bash
cd api
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

La API estará disponible en: http://localhost:8000

## 📚 Documentación de la API

Una vez ejecutada, la API proporciona documentación interactiva automática:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## 🔌 Endpoints

### Información General

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/` | Información de la API |
| GET | `/health` | Estado de salud de la API |

### Cuentas

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/accounts` | Obtener todas las cuentas |
| GET | `/api/accounts?status=A` | Filtrar cuentas por estado |
| GET | `/api/accounts/{id}` | Obtener cuenta específica |

**Parámetros de consulta:**
- `status`: Filtrar por estado (A=Activa, B=Bloqueada, I=Inactiva)

**Ejemplo de respuesta:**
```json
{
  "number": "000001",
  "dni": "12345678A",
  "name": "MARIO PICO BUSQUIER",
  "balance": 14500.50,
  "status": "A",
  "open_date": "20240115",
  "daily_limit": 5000.00
}
```

### Transacciones

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/transactions` | Obtener todas las transacciones |
| GET | `/api/transactions?type=T` | Filtrar por tipo |
| GET | `/api/transactions?origin=000001` | Filtrar por cuenta origen |
| GET | `/api/transactions?destination=000002` | Filtrar por cuenta destino |

**Parámetros de consulta:**
- `type`: Filtrar por tipo (T=Transferencia, I=Ingreso, R=Retirada, P=Pago)
- `origin`: Filtrar por cuenta origen
- `destination`: Filtrar por cuenta destino

**Ejemplo de respuesta:**
```json
{
  "id": "0000000001",
  "type": "T",
  "origin": "000001",
  "destination": "000002",
  "amount": 500.00,
  "date": "20260301",
  "time": "090000",
  "concept": "TRANSFERENCIA ENTRE CUENTAS"
}
```

### Auditoría

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/audit` | Obtener todos los registros de auditoría |
| GET | `/api/audit?result=K` | Filtrar por resultado |

**Parámetros de consulta:**
- `result`: Filtrar por resultado (K=OK, o código de error E00X)

### Reportes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/report` | Obtener resumen del reporte de procesamiento |

**Ejemplo de respuesta:**
```json
{
  "total_movements": 58,
  "accepted": 35,
  "rejected": 23,
  "total_debited": 8205.36,
  "total_credited": 12730.61,
  "total_commissions": 24.40,
  "error_counts": {
    "E001": 6,
    "E002": 8,
    "E003": 5,
    "E004": 1,
    "E006": 3
  },
  "report_date": "2026-10-29"
}
```

## 🧪 Pruebas con curl

### Obtener todas las cuentas
```bash
curl http://localhost:8000/api/accounts
```

### Obtener una cuenta específica
```bash
curl http://localhost:8000/api/accounts/000001
```

### Filtrar cuentas activas
```bash
curl "http://localhost:8000/api/accounts?status=A"
```

### Obtener todas las transacciones
```bash
curl http://localhost:8000/api/transactions
```

### Filtrar transferencias
```bash
curl "http://localhost:8000/api/transactions?type=T"
```

### Obtener resumen del reporte
```bash
curl http://localhost:8000/api/report
```

### Verificar estado de salud
```bash
curl http://localhost:8000/health
```

## 🔄 Integración con el Sistema COBOL

### Flujo de trabajo recomendado

1. **Generar datos de prueba:**
   ```bash
   ./scripts/generate-test-data.sh
   ```

2. **Ejecutar el procesamiento COBOL:**
   ```bash
   ./scripts/run.sh
   ```

3. **Iniciar la API REST:**
   ```bash
   cd api
   python main.py
   ```

4. **Consumir los datos desde aplicaciones modernas:**
   - Frontend web (React, Angular, Vue)
   - Aplicaciones móviles (React Native, Flutter)
   - Microservicios
   - Dashboards de análisis

## 🛠️ Tecnologías Utilizadas

- **FastAPI**: Framework web moderno y rápido para Python
- **Uvicorn**: Servidor ASGI de alto rendimiento
- **Pydantic**: Validación de datos usando anotaciones de tipos
- **OpenAPI/Swagger**: Documentación automática de la API

## 📊 Casos de Uso

### 1. Dashboard de Monitorización
Crear un dashboard web en tiempo real que muestre:
- Estado de todas las cuentas
- Transacciones del día
- Métricas de procesamiento
- Alertas de errores

### 2. Aplicación Móvil de Banca
Desarrollar una app móvil que permita:
- Consultar saldo de cuentas
- Ver historial de transacciones
- Recibir notificaciones de movimientos

### 3. Microservicio de Notificaciones
Crear un microservicio que:
- Monitoree transacciones mediante la API
- Envíe notificaciones por email/SMS
- Genere alertas de seguridad

### 4. Sistema de Reportes Avanzado
Construir un sistema de business intelligence que:
- Consuma datos de la API
- Genere gráficos y análisis
- Exporte reportes en múltiples formatos

## 🔒 Seguridad

**Nota:** Esta API es una demostración y no incluye autenticación ni autorización. Para un entorno de producción:

- Implementar autenticación JWT o OAuth2
- Configurar HTTPS
- Agregar rate limiting
- Implementar validación de entrada adicional
- Configurar CORS apropiadamente
- Agregar logs de auditoría

## 📝 Notas Técnicas

### Parseo de Ficheros COBOL

La API lee directamente los ficheros COBOL en formato fixed-width:

- **CUENTAS.DAT**: Registros de 78 bytes
- **MOVIMIENTOS.DAT**: Registros de 89 bytes
- **AUDIT.DAT**: Registros de 112 bytes
- **REPORT.DAT**: Formato de informe de texto

Los campos numéricos con decimales implícitos (V99) se convierten a float dividiendo entre 100.

### Rendimiento

- La API lee los ficheros en cada request (no hay cache)
- Para producción, considerar:
  - Cache de datos en memoria
  - Base de datos intermedia
  - Websockets para actualizaciones en tiempo real

## 🤝 Contribución

Este proyecto es parte del COBOL Banking System. Para contribuir:

1. Seguir las convenciones de código existentes
2. Añadir tests para nuevas funcionalidades
3. Actualizar la documentación
4. Mantener la compatibilidad con los ficheros COBOL

## 📄 Licencia

Parte del proyecto COBOL Banking System - Mario Pico

---

**Estado:** ✅ Completado y funcional  
**Versión:** 1.0.0  
**Última actualización:** Octubre 2026
