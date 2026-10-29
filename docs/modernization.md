# Modernización Legacy - Arquitectura Híbrida

## 🎯 Objetivo

Integrar el sistema bancario COBOL legacy con tecnologías modernas mediante una API REST, demostrando la capacidad de trabajar en entornos de transformación digital donde coexisten sistemas antiguos críticos con nuevas aplicaciones.

---

## 🏗️ Arquitectura del Sistema Híbrido

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CAPA DE PRESENTACIÓN                           │
├─────────────────────────────────────────────────────────────────────────┤
│  • Dashboard Web (React/Angular/Vue)                                    │
│  • Aplicación Móvil (React Native/Flutter)                              │
│  • Portal de Cliente                                                     │
│  • Sistema de Notificaciones                                             │
└────────────────────────────┬────────────────────────────────────────────┘
                             │ HTTP/REST (JSON)
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CAPA DE INTEGRACIÓN                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │              API REST - FastAPI (Python)                         │  │
│  │  • Puerto: 8000                                                  │  │
│  │  • Documentación: Swagger UI / ReDoc                            │  │
│  │  • Autenticación: JWT (producción)                              │  │
│  │  • Rate Limiting: Configurable                                  │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │              Servicios Adicionales (Futuro)                      │  │
│  │  • Cache Redis                                                   │  │
│  │  • Message Queue (RabbitMQ/Kafka)                               │  │
│  │  • API Gateway (Kong/AWS API Gateway)                           │  │
│  │  • Load Balancer (Nginx/HAProxy)                                │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└────────────────────────────┬────────────────────────────────────────────┘
                             │ Lectura/Escritura de ficheros
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      CAPA DE PROCESAMIENTO LEGACY                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │           Sistema COBOL - BANKPROC                               │  │
│  │  • Lenguaje: COBOL (GnuCOBOL)                                   │  │
│  │  • Procesamiento: Batch diario                                  │  │
│  │  • Ficheros de entrada: MOVIMIENTOS.DAT                         │  │
│  │  • Ficheros de salida: REPORT.DAT, AUDIT.DAT, ERRORS.DAT        │  │
│  │  • Fichero maestro: CUENTAS.DAT (I-O)                           │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │           JCL - Job Control Language                             │  │
│  │  • BANKJOB.jcl: Job de procesamiento principal                  │  │
│  │  • SORTJOB.jcl: Job de ordenación previa                        │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        CAPA DE ALMACENAMIENTO                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────┐  ┌─────────────────────┐                      │
│  │  Ficheros COBOL     │  │  Ficheros de Salida │                      │
│  │  • CUENTAS.DAT      │  │  • REPORT.DAT       │                      │
│  │  • MOVIMIENTOS.DAT  │  │  • AUDIT.DAT        │                      │
│  │  • CLIENTES.DAT     │  │  • ERRORS.DAT       │                      │
│  └─────────────────────┘  │  • HISTORICO.DAT    │                      │
│                            └─────────────────────┘                      │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  Futuro: Migración a Base de Datos                               │  │
│  │  • PostgreSQL / MySQL (datos transaccionales)                   │  │
│  │  • MongoDB (logs y auditoría)                                   │  │
│  │  • Elasticsearch (búsqueda y analytics)                         │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Datos

### Escenario 1: Consulta en Tiempo Real

```
1. Cliente → Dashboard Web
   └─> Solicita saldo de cuenta 000001

2. Dashboard Web → API REST (FastAPI)
   └─> GET /api/accounts/000001

3. API REST → Sistema de Ficheros COBOL
   └─> Lee CUENTAS.DAT (registro fixed-width)

4. Parseo de Datos
   └─> Convierte formato COBOL a JSON
       • PIC 9(6) → String
       • PIC S9(10)V99 → Float (divide entre 100)
       • PIC X(30) → String (trim)

5. API REST → Dashboard Web
   └─> Response: JSON con datos de la cuenta

6. Dashboard Web → Cliente
   └─> Muestra saldo actualizado
```

### Escenario 2: Procesamiento Batch + Notificación

```
1. Sistema COBOL (ejecución nocturna)
   └─> BANKPROC procesa MOVIMIENTOS.DAT
   └─> Actualiza CUENTAS.DAT
   └─> Genera REPORT.DAT y AUDIT.DAT

2. API REST (monitoreo continuo)
   └─> Detecta nuevos ficheros generados
   └─> Parsea REPORT.DAT
   └─> Actualiza caché (si está configurado)

3. Servicio de Notificaciones
   └─> GET /api/report desde API REST
   └─> Compara con métricas anteriores
   └─> Envía alertas si hay anomalías

4. Cliente
   └─> Recibe notificación push
   └─> Consulta detalles en Dashboard
   └─> GET /api/audit para ver movimientos
```

---

## 🛠️ Tecnologías Implementadas

### Sistema Legacy (COBOL)

| Componente | Tecnología | Propósito |
|------------|------------|-----------|
| **Lenguaje** | COBOL (GnuCOBOL 3.x) | Procesamiento batch transaccional |
| **Compilador** | cobc | Compilación de programas COBOL |
| **Ficheros** | LINE SEQUENTIAL | Almacenamiento de datos |
| **JCL** | IBM z/OS compatible | Automatización de jobs |
| **Scripts** | Bash | Automatización de compilación y ejecución |

### Capa Moderna (Python)

| Componente | Tecnología | Propósito |
|------------|------------|-----------|
| **Framework** | FastAPI | API REST de alto rendimiento |
| **Servidor** | Uvicorn | Servidor ASGI |
| **Validación** | Pydantic | Validación de datos y schemas |
| **Documentación** | OpenAPI/Swagger | Documentación automática |
| **Parseo** | Python file I/O | Lectura de ficheros fixed-width |

### Herramientas de Desarrollo

| Herramienta | Uso |
|-------------|-----|
| **Git** | Control de versiones |
| **VS Code** | Desarrollo (con extensión COBOL) |
| **curl/httpie** | Testing de API |
| **Postman** | Testing visual de API |
| **Docker** | (Futuro) Contenerización |

---

## 💡 Casos de Uso Reales

### Caso 1: Dashboard de Operaciones en Tiempo Real

**Problema:** Los operadores necesitan ver el estado actual de las cuentas sin ejecutar el batch COBOL.

**Solución:**
```javascript
// Frontend (React)
const fetchAccounts = async () => {
  const response = await fetch('http://localhost:8000/api/accounts');
  const accounts = await response.json();
  
  // Mostrar en dashboard
  accounts.forEach(account => {
    updateDashboard(account.number, account.balance);
  });
};

// Actualizar cada 30 segundos
setInterval(fetchAccounts, 30000);
```

**Beneficios:**
- ✅ Visibilidad en tiempo real
- ✅ No requiere modificar el sistema COBOL
- ✅ Interfaz moderna y amigable
- ✅ Acceso desde cualquier dispositivo

---

### Caso 2: Sistema de Alertas Tempranas

**Problema:** Detectar cuentas con saldo bajo o movimientos sospechosos.

**Solución:**
```python
# Microservicio de monitoreo (Python)
import requests
import time

def check_low_balance_accounts():
    response = requests.get('http://localhost:8000/api/accounts?status=A')
    accounts = response.json()
    
    for account in accounts:
        if account['balance'] < 100:
            send_alert(
                account['number'],
                f"Saldo bajo: {account['balance']} EUR"
            )

# Ejecutar cada hora
while True:
    check_low_balance_accounts()
    time.sleep(3600)
```

**Beneficios:**
- ✅ Detección proactiva de problemas
- ✅ Notificaciones automáticas
- ✅ Integración con sistemas existentes (email, SMS, Slack)

---

### Caso 3: Aplicación Móvil de Banca

**Problema:** Los clientes quieren consultar sus cuentas desde el móvil.

**Solución:**
```dart
// Flutter (App Móvil)
Future<void> loadAccountDetails() async {
  final response = await http.get(
    Uri.parse('http://api.banco.com/api/accounts/$accountNumber')
  );
  
  if (response.statusCode == 200) {
    final account = jsonDecode(response.body);
    setState(() {
      balance = account['balance'];
      status = account['status'];
    });
  }
}
```

**Beneficios:**
- ✅ Experiencia móvil nativa
- ✅ Acceso 24/7 desde cualquier lugar
- ✅ Push notifications para movimientos

---

### Caso 4: Migración Gradual a Microservicios

**Problema:** Modernizar el sistema sin riesgo de romper la funcionalidad existente.

**Solución - Estrategia Strangler Fig:**

```
FASE 1: API como facade
┌─────────────┐
│  Frontend   │
└──────┬──────┘
       │
       ▼
┌─────────────┐      ┌──────────────┐
│  API REST   │─────>│  COBOL Batch │
│  (Nuevas    │      │  (Legacy)    │
│   funciones)│      └──────────────┘
└─────────────┘

FASE 2: Migración gradual
┌─────────────┐
│  Frontend   │
└──────┬──────┘
       │
       ▼
┌─────────────┐      ┌──────────────┐
│  API REST   │─────>│  Microserv.  │
│             │      │  (Nuevo)     │
│             │      └──────────────┘
│             │      ┌──────────────┐
│             │─────>│  COBOL Batch │
│             │      │  (Legacy)    │
└─────────────┘      └──────────────┘

FASE 3: Sistema completamente moderno
┌─────────────┐
│  Frontend   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  API REST   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Microservicios│
│  (Cloud)    │
└─────────────┘
```

**Beneficios:**
- ✅ Migración sin downtime
- ✅ Riesgo mínimo
- ✅ ROI inmediato
- ✅ Flexibilidad para probar nuevas tecnologías

---

## 🔐 Consideraciones de Seguridad

### Producción - Checklist

- [ ] **Autenticación**: Implementar JWT o OAuth2
- [ ] **HTTPS**: Configurar certificados SSL/TLS
- [ ] **Rate Limiting**: Prevenir abuso de la API
- [ ] **Validación**: Sanitizar todas las entradas
- [ ] **Logs**: Registrar todas las operaciones
- [ ] **Backups**: Copias de seguridad de ficheros COBOL
- [ ] **Monitoreo**: Alertas de errores y rendimiento
- [ ] **CORS**: Configurar dominios permitidos
- [ ] **API Keys**: Para acceso de terceros
- [ ] **Auditoría**: Tracking de accesos a datos sensibles

### Ejemplo de Configuración Segura

```python
# main.py (producción)
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt

security = HTTPBearer()

async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        payload = jwt.decode(
            credentials.credentials,
            SECRET_KEY,
            algorithms=["HS256"]
        )
        return payload
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido"
        )

@app.get("/api/accounts", dependencies=[Depends(verify_token)])
def get_accounts():
    # Endpoint protegido
    pass
```

---

## 📊 Métricas y Monitoreo

### Métricas de API

```python
# Prometheus metrics
from prometheus_fastapi_instrumentator import Instrumentator

Instrumentator().instrument(app).expose(app)

# Métricas disponibles:
# - http_requests_total
# - http_request_duration_seconds
# - http_request_size_bytes
# - http_response_size_bytes
```

### Dashboard de Monitoreo

```yaml
# docker-compose.yml (ejemplo)
version: '3'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
  
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
  
  api:
    build: ./api
    ports:
      - "8000:8000"
```

---

## 🚀 Roadmap de Evolución

### Fase 1: API como Facade (✅ Actual)
- [x] API REST lee ficheros COBOL
- [x] Documentación Swagger/OpenAPI
- [x] Endpoints básicos (accounts, transactions, report)
- [x] Parseo de formatos fixed-width

### Fase 2: Caché y Optimización (Próximo)
- [ ] Redis para caché de cuentas frecuentes
- [ ] Connection pooling para ficheros
- [ ] Background tasks para reportes pesados
- [ ] API versioning (v1, v2, etc.)

### Fase 3: Base de Datos Híbrida (Futuro)
- [ ] PostgreSQL para datos transaccionales
- [ ] Sincronización bidireccional COBOL ↔ DB
- [ ] Migración gradual de datos
- [ ] Queries SQL complejos

### Fase 4: Microservicios (Largo Plazo)
- [ ] Separar servicios por dominio
- [ ] Message queue (RabbitMQ/Kafka)
- [ ] Event-driven architecture
- [ ] Kubernetes para orquestación

### Fase 5: Cloud Native (Transformación Completa)
- [ ] Migración a AWS/Azure/GCP
- [ ] Serverless functions
- [ ] CI/CD pipelines
- [ ] Infrastructure as Code (Terraform)

---

## 🎓 Aprendizajes Clave

### 1. Convivencia de Tecnologías
- Los sistemas legacy no desaparecen de la noche a la mañana
- La integración es más segura que la reescritura completa
- Las APIs son el puente natural entre old y new

### 2. Retos Técnicos Superados
- **Parseo de formatos COBOL**: Fixed-width, decimales implícitos (V99)
- **Conversión de tipos**: PIC X → String, PIC 9 → Int/Float
- **Manejo de errores**: Ficheros corruptos, formatos inesperados
- **Rendimiento**: Lectura eficiente de ficheros grandes

### 3. Mejores Prácticas
- **Documentación**: Swagger/OpenAPI automático
- **Versionado**: APIs versionadas desde el inicio
- **Testing**: Pruebas automatizadas de integración
- **Monitoreo**: Logs y métricas desde el día 1

### 4. Valor para el Negocio
- **ROI inmediato**: Nuevas funcionalidades sin tocar COBOL
- **Reducción de riesgo**: Cambios graduales y controlados
- **Atracción de talento**: stack moderno atrae desarrolladores
- **Competitividad**: Tiempo de mercado más rápido

---

## 📚 Recursos Adicionales

### Documentación Técnica
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [GnuCOBOL Manual](https://gnucobol.sourceforge.io/)
- [COBOL File Formats](https://www.ibm.com/docs/en/cobol-zos)

### Artículos Relacionados
- "Modernizing Legacy COBOL Systems with REST APIs"
- "The Strangler Fig Pattern for Legacy Migration"
- "Building Hybrid Architectures: COBOL + Cloud"

### Herramientas Recomendadas
- **Postman**: Testing de APIs
- **Docker**: Contenerización
- **Kubernetes**: Orquestación
- **Grafana**: Monitoreo y visualización

---

## ✅ Conclusión

Esta arquitectura híbrida demuestra que es posible:

1. **Preservar la inversión** en sistemas legacy probados
2. **Innovar rápidamente** con tecnologías modernas
3. **Reducir el riesgo** mediante integración gradual
4. **Atraer talento** con stack tecnológico actual
5. **Competir efectivamente** en el mercado digital

El sistema COBOL, construido hace décadas, sigue procesando millones de transacciones diarias. La API REST permite que estas capacidades legacy sean accesibles desde aplicaciones web, móviles y microservicios modernos, creando un puente entre el pasado y el futuro.

---

**Estado:** ✅ Completado  
**Versión:** 1.0.0  
**Última actualización:** Octubre 2026  
**Autor:** Mario Pico - COBOL Banking System
