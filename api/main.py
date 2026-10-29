"""
COBOL Banking System - REST API
API moderna para integración con sistema legacy COBOL

Esta API lee directamente los ficheros de datos COBOL y proporciona
endpoints REST para consultar cuentas, transacciones e informes.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
import os

app = FastAPI(
    title="COBOL Banking System API",
    description="API REST para integración con sistema bancario COBOL legacy",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configuración CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Paths a los ficheros COBOL
DATA_DIR = "../data"
OUTPUT_DIR = "../output"
CUENTAS_FILE = os.path.join(DATA_DIR, "CUENTAS.DAT")
MOVIMIENTOS_FILE = os.path.join(DATA_DIR, "MOVIMIENTOS.DAT")
REPORT_FILE = os.path.join(OUTPUT_DIR, "REPORT.DAT")
AUDIT_FILE = os.path.join(OUTPUT_DIR, "AUDIT.DAT")


# ============================================
# Modelos de datos (Pydantic)
# ============================================

class Account(BaseModel):
    """Modelo de cuenta bancaria"""
    number: str
    dni: str
    name: str
    balance: float
    status: str
    open_date: str
    daily_limit: float


class Transaction(BaseModel):
    """Modelo de transacción"""
    id: str
    type: str
    origin: str
    destination: str
    amount: float
    date: str
    time: str
    concept: str


class AuditRecord(BaseModel):
    """Modelo de registro de auditoría"""
    timestamp: str
    transaction_id: str
    type: str
    origin: str
    destination: str
    amount: float
    result: str
    commission: float
    concept: str


class ReportSummary(BaseModel):
    """Modelo de resumen del informe"""
    total_movements: int
    accepted: int
    rejected: int
    total_debited: float
    total_credited: float
    total_commissions: float
    error_counts: dict
    report_date: str


# ============================================
# Funciones de parseo de ficheros COBOL
# ============================================

def parse_cuentas_file():
    """
    Parsea el fichero CUENTAS.DAT con formato fixed-width
    
    Layout del registro (78 bytes):
    - WS-ACCOUNT-NUMBER: PIC 9(6) - posición 1-6
    - WS-ACCOUNT-DNI: PIC X(9) - posición 7-15
    - WS-ACCOUNT-NAME: PIC X(30) - posición 16-45
    - WS-ACCOUNT-BALANCE: PIC S9(10)V99 - posición 46-57 (12 bytes)
    - WS-ACCOUNT-STATUS: PIC X(1) - posición 58
    - WS-ACCOUNT-OPEN-DATE: PIC 9(8) - posición 59-66
    - WS-ACCOUNT-DAILY-LIMIT: PIC 9(10)V99 - posición 67-78
    """
    accounts = []
    
    if not os.path.exists(CUENTAS_FILE):
        return accounts
    
    with open(CUENTAS_FILE, 'r', encoding='ascii') as f:
        for line in f:
            if len(line.strip()) < 78:
                continue
                
            account = Account(
                number=line[0:6].strip(),
                dni=line[6:15].strip(),
                name=line[15:45].strip(),
                balance=int(line[45:57].strip()) / 100,  # V99 = 2 decimales implícitos
                status=line[57:58].strip(),
                open_date=line[58:66].strip(),
                daily_limit=int(line[66:78].strip()) / 100
            )
            accounts.append(account)
    
    return accounts


def parse_movimientos_file():
    """
    Parsea el fichero MOVIMIENTOS.DAT con formato fixed-width
    
    Layout del registro (89 bytes):
    - WS-TRANSACTION-ID: PIC 9(10) - posición 1-10
    - WS-TRANSACTION-TYPE: PIC X(1) - posición 11
    - WS-TRANSACTION-ORIGIN: PIC 9(6) - posición 12-17
    - WS-TRANSACTION-DESTINATION: PIC 9(6) - posición 18-23
    - WS-TRANSACTION-AMOUNT: PIC S9(10)V99 - posición 24-35
    - WS-TRANSACTION-DATE: PIC 9(8) - posición 36-43
    - WS-TRANSACTION-TIME: PIC 9(6) - posición 44-49
    - WS-TRANSACTION-CONCEPT: PIC X(40) - posición 50-89
    """
    transactions = []
    
    if not os.path.exists(MOVIMIENTOS_FILE):
        return transactions
    
    with open(MOVIMIENTOS_FILE, 'r', encoding='ascii') as f:
        for line in f:
            line = line.rstrip('\n\r')  # Solo eliminar saltos de línea, no espacios
            if len(line) < 89:
                continue
                
            transaction = Transaction(
                id=line[0:10].strip(),
                type=line[10:11].strip(),
                origin=line[11:17].strip(),
                destination=line[17:23].strip(),
                amount=int(line[23:35].strip()) / 100,
                date=line[35:43].strip(),
                time=line[43:49].strip(),
                concept=line[49:89].strip()
            )
            transactions.append(transaction)
    
    return transactions


def parse_audit_file():
    """
    Parsea el fichero AUDIT.DAT con formato fixed-width
    
    Layout del registro (112 bytes):
    - WS-AUDIT-TIMESTAMP: PIC X(19) - posición 1-19
    - WS-AUDIT-TRANSACTION-ID: PIC 9(10) - posición 20-29
    - WS-AUDIT-TYPE: PIC X(1) - posición 30
    - WS-AUDIT-ORIGIN: PIC 9(6) - posición 31-36
    - WS-AUDIT-DESTINATION: PIC 9(6) - posición 37-42
    - WS-AUDIT-AMOUNT-STR: PIC X(16) - posición 43-58
    - WS-AUDIT-RESULT: PIC X(4) - posición 59-62
    - WS-AUDIT-COMMISSION-STR: PIC X(10) - posición 63-72
    - WS-AUDIT-CONCEPT: PIC X(40) - posición 73-112
    """
    audit_records = []
    
    if not os.path.exists(AUDIT_FILE):
        return audit_records
    
    with open(AUDIT_FILE, 'r', encoding='ascii') as f:
        for line in f:
            if len(line.strip()) < 112:
                continue
            
            try:
                # Parsear el monto (puede tener formato con comas)
                amount_str = line[42:58].strip().replace(',', '')
                amount = float(amount_str) if amount_str else 0.0
                
                # Parsear la comisión
                commission_str = line[62:72].strip().replace(',', '')
                commission = float(commission_str) if commission_str else 0.0
                
                record = AuditRecord(
                    timestamp=line[0:19].strip(),
                    transaction_id=line[19:29].strip(),
                    type=line[29:30].strip(),
                    origin=line[30:36].strip(),
                    destination=line[36:42].strip(),
                    amount=amount,
                    result=line[58:62].strip(),
                    commission=commission,
                    concept=line[72:112].strip()
                )
                audit_records.append(record)
            except (ValueError, IndexError):
                continue
    
    return audit_records


def parse_report_file():
    """
    Parsea el fichero REPORT.DAT para extraer el resumen
    """
    summary = ReportSummary(
        total_movements=0,
        accepted=0,
        rejected=0,
        total_debited=0.0,
        total_credited=0.0,
        total_commissions=0.0,
        error_counts={},
        report_date=""
    )
    
    if not os.path.exists(REPORT_FILE):
        return summary
    
    with open(REPORT_FILE, 'r', encoding='ascii') as f:
        lines = f.readlines()
    
    for line in lines:
        # Extraer fecha del reporte
        if 'REPORT DATE:' in line:
            parts = line.split('REPORT DATE:')
            if len(parts) > 1:
                summary.report_date = parts[1].strip()
        
        # Extraer totales
        elif 'TOTAL MOVEMENTS PROCESSED:' in line:
            parts = line.split(':')
            if len(parts) > 1:
                summary.total_movements = int(parts[1].strip())
        
        elif 'ACCEPTED:' in line and 'TOTAL' not in line:
            parts = line.split(':')
            if len(parts) > 1:
                summary.accepted = int(parts[1].strip())
        
        elif 'REJECTED:' in line:
            parts = line.split(':')
            if len(parts) > 1:
                summary.rejected = int(parts[1].strip())
        
        elif 'TOTAL DEBITED:' in line:
            parts = line.split(':')
            if len(parts) > 1:
                amount_str = parts[1].strip().replace(',', '').replace('EUR', '').strip()
                summary.total_debited = float(amount_str)
        
        elif 'TOTAL CREDITED:' in line:
            parts = line.split(':')
            if len(parts) > 1:
                amount_str = parts[1].strip().replace(',', '').replace('EUR', '').strip()
                summary.total_credited = float(amount_str)
        
        elif 'TOTAL COMMISSIONS:' in line:
            parts = line.split(':')
            if len(parts) > 1:
                amount_str = parts[1].strip().replace(',', '').replace('EUR', '').strip()
                summary.total_commissions = float(amount_str)
        
        # Extraer conteo de errores
        elif 'E00' in line:
            for i in range(1, 8):
                error_code = f'E00{i}'
                if error_code in line:
                    parts = line.split(':')
                    if len(parts) > 1:
                        count = int(parts[1].strip())
                        summary.error_counts[error_code] = count
    
    return summary


# ============================================
# Endpoints de la API
# ============================================

@app.get("/")
def root():
    """Endpoint raíz con información de la API"""
    return {
        "message": "COBOL Banking System API",
        "version": "1.0.0",
        "description": "API REST para integración con sistema bancario COBOL legacy",
        "endpoints": {
            "accounts": "/api/accounts",
            "account_by_id": "/api/accounts/{id}",
            "transactions": "/api/transactions",
            "audit": "/api/audit",
            "report": "/api/report",
            "health": "/health"
        },
        "documentation": {
            "swagger": "/docs",
            "redoc": "/redoc"
        }
    }


@app.get("/health")
def health_check():
    """Verifica el estado de la API"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "cobol_files": {
            "cuentas": os.path.exists(CUENTAS_FILE),
            "movimientos": os.path.exists(MOVIMIENTOS_FILE),
            "report": os.path.exists(REPORT_FILE),
            "audit": os.path.exists(AUDIT_FILE)
        }
    }


@app.get("/api/accounts", response_model=List[Account])
def get_accounts(status: Optional[str] = None):
    """
    Obtiene todas las cuentas bancarias
    
    Parámetros:
    - status: Filtrar por estado (A=Activa, B=Bloqueada, I=Inactiva)
    """
    accounts = parse_cuentas_file()
    
    if status:
        accounts = [acc for acc in accounts if acc.status == status.upper()]
    
    return accounts


@app.get("/api/accounts/{account_id}", response_model=Account)
def get_account_by_id(account_id: str):
    """
    Obtiene una cuenta específica por su número
    
    Parámetros:
    - account_id: Número de cuenta (6 dígitos)
    """
    accounts = parse_cuentas_file()
    
    for account in accounts:
        if account.number == account_id:
            return account
    
    raise HTTPException(status_code=404, detail=f"Account {account_id} not found")


@app.get("/api/transactions", response_model=List[Transaction])
def get_transactions(
    type: Optional[str] = None,
    origin: Optional[str] = None,
    destination: Optional[str] = None
):
    """
    Obtiene todas las transacciones
    
    Parámetros:
    - type: Filtrar por tipo (T=Transferencia, I=Ingreso, R=Retirada, P=Pago)
    - origin: Filtrar por cuenta origen
    - destination: Filtrar por cuenta destino
    """
    transactions = parse_movimientos_file()
    
    if type:
        transactions = [t for t in transactions if t.type == type.upper()]
    if origin:
        transactions = [t for t in transactions if t.origin == origin]
    if destination:
        transactions = [t for t in transactions if t.destination == destination]
    
    return transactions


@app.get("/api/audit", response_model=List[AuditRecord])
def get_audit_records(result: Optional[str] = None):
    """
    Obtiene todos los registros de auditoría
    
    Parámetros:
    - result: Filtrar por resultado (K=OK, o código de error E00X)
    """
    records = parse_audit_file()
    
    if result:
        records = [r for r in records if r.result == result.upper()]
    
    return records


@app.get("/api/report", response_model=ReportSummary)
def get_report():
    """
    Obtiene el resumen del reporte de procesamiento
    """
    return parse_report_file()


# ============================================
# Main
# ============================================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
