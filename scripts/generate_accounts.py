#!/usr/bin/env python3
# Script para generar CUENTAS.DAT con casos de prueba

# Estructura: 78 bytes
# - account_number: 6 dígitos
# - dni: 9 caracteres
# - name: 30 caracteres
# - balance: S9(10)V99 (10 dígitos + 2 decimales, con signo)
# - status: 1 carácter (A=Activa, B=Bloqueada, I=Inactiva)
# - open_date: 8 dígitos (YYYYMMDD)
# - daily_limit: 9(10)V99 (10 dígitos + 2 decimales)

accounts = [
    # 3 cuentas con saldo alto (>10000)
    {"number": "000001", "dni": "12345678A", "name": "MARIO PICO BUSQUIER", "balance": 15000.50, "status": "A", "date": "20240115", "limit": 5000.00},
    {"number": "000002", "dni": "87654321B", "name": "ANA GARCIA LOPEZ", "balance": 25000.00, "status": "A", "date": "20240220", "limit": 10000.00},
    {"number": "000003", "dni": "11223345C", "name": "CARLOS MARTINEZ RUIZ", "balance": 12500.75, "status": "A", "date": "20240310", "limit": 8000.00},
    
    # 3 cuentas con saldo bajo (<50)
    {"number": "000004", "dni": "99887766D", "name": "LAURA FERNANDEZ SANZ", "balance": 25.30, "status": "A", "date": "20240405", "limit": 1000.00},
    {"number": "000005", "dni": "55443321E", "name": "PEDRO JIMENEZ MORENO", "balance": 10.00, "status": "A", "date": "20240512", "limit": 500.00},
    {"number": "000006", "dni": "66778899F", "name": "SANDRA LOPEZ DIAZ", "balance": 45.99, "status": "A", "date": "20240618", "limit": 2000.00},
    
    # 2 cuentas bloqueadas
    {"number": "000007", "dni": "22334455G", "name": "DAVID GOMEZ RUIZ", "balance": 5000.00, "status": "B", "date": "20240722", "limit": 3000.00},
    {"number": "000008", "dni": "33445567H", "name": "CRISTINA RUIZ GARCIA", "balance": 8000.25, "status": "B", "date": "20240830", "limit": 4000.00},
    
    # 1 cuenta con saldo 0
    {"number": "000009", "dni": "44556678I", "name": "JAVIER SANCHEZ LOPEZ", "balance": 0.00, "status": "A", "date": "20240914", "limit": 1500.00},
    
    # 2 cuentas con límite diario bajo
    {"number": "000010", "dni": "55667789J", "name": "MERCEDES MORENO FERNANDEZ", "balance": 3000.00, "status": "A", "date": "20241025", "limit": 100.00},
    {"number": "000011", "dni": "66778800K", "name": "ROBERTO DIAZ JIMENEZ", "balance": 4500.50, "status": "A", "date": "20241108", "limit": 200.00},
    
    # Cuentas adicionales para tener 20-30 registros
    {"number": "000012", "dni": "77889911L", "name": "PATRICIA RUIZ SANCHEZ", "balance": 7500.00, "status": "A", "date": "20241201", "limit": 3500.00},
    {"number": "000013", "dni": "12345678A", "name": "MARIO PICO BUSQUIER", "balance": 2000.00, "status": "A", "date": "20250110", "limit": 1000.00},
    {"number": "000014", "dni": "87654321B", "name": "ANA GARCIA LOPEZ", "balance": 950.75, "status": "A", "date": "20250115", "limit": 500.00},
    {"number": "000015", "dni": "11223345C", "name": "CARLOS MARTINEZ RUIZ", "balance": 150.00, "status": "A", "date": "20250120", "limit": 300.00},
    {"number": "000016", "dni": "99887766D", "name": "LAURA FERNANDEZ SANZ", "balance": 6200.30, "status": "A", "date": "20250125", "limit": 2500.00},
    {"number": "000017", "dni": "55443321E", "name": "PEDRO JIMENEZ MORENO", "balance": 35.50, "status": "A", "date": "20250201", "limit": 150.00},
    {"number": "000018", "dni": "66778899F", "name": "SANDRA LOPEZ DIAZ", "balance": 18000.00, "status": "A", "date": "20250210", "limit": 7000.00},
    {"number": "000019", "dni": "22334455G", "name": "DAVID GOMEZ RUIZ", "balance": 420.00, "status": "A", "date": "20250215", "limit": 200.00},
    {"number": "000020", "dni": "33445567H", "name": "CRISTINA RUIZ GARCIA", "balance": 11000.99, "status": "A", "date": "20250220", "limit": 5000.00},
    {"number": "000021", "dni": "44556678I", "name": "JAVIER SANCHEZ LOPEZ", "balance": 350.25, "status": "A", "date": "20250225", "limit": 175.00},
    {"number": "000022", "dni": "55667789J", "name": "MERCEDES MORENO FERNANDEZ", "balance": 9200.00, "status": "A", "date": "20250301", "limit": 4500.00},
    {"number": "000023", "dni": "66778800K", "name": "ROBERTO DIAZ JIMENEZ", "balance": 55.80, "status": "A", "date": "20250310", "limit": 100.00},
    {"number": "000024", "dni": "77889911L", "name": "PATRICIA RUIZ SANCHEZ", "balance": 3100.40, "status": "I", "date": "20250315", "limit": 1500.00},
    {"number": "000025", "dni": "12345678A", "name": "MARIO PICO BUSQUIER", "balance": 800.00, "status": "A", "date": "20250320", "limit": 400.00},
]

# Longitudes según BANK-ACCOUNT.cpy
LEN_NUMBER = 6
LEN_DNI = 9
LEN_NAME = 30
LEN_BALANCE = 12  # S9(10)V99: 10 dígitos + 2 decimales
LEN_STATUS = 1
LEN_DATE = 8
LEN_LIMIT = 12    # 9(10)V99: 10 dígitos + 2 decimales

def format_balance(balance):
    # Convierte balance a formato S9(10)V99 (12 caracteres)
    # Ejemplo: 15000.50 -> "+000001500050" o "000001500050"
    # Para simplificar, usamos solo dígitos positivos (el signo S es implícito)
    cents = int(balance * 100)
    return str(cents).zfill(LEN_BALANCE)

def format_limit(limit):
    # Convierte límite a formato 9(10)V99 (12 caracteres)
    cents = int(limit * 100)
    return str(cents).zfill(LEN_LIMIT)

with open("data/CUENTAS.DAT", "w") as f:
    for acc in accounts:
        record = ""
        record += acc["number"].ljust(LEN_NUMBER)[:LEN_NUMBER]
        record += acc["dni"].ljust(LEN_DNI)[:LEN_DNI]
        record += acc["name"].ljust(LEN_NAME)[:LEN_NAME]
        record += format_balance(acc["balance"])
        record += acc["status"]
        record += acc["date"].ljust(LEN_DATE)[:LEN_DATE]
        record += format_limit(acc["limit"])
        f.write(record + "\n")

print("CUENTAS.DAT generado correctamente")
print(f"Total registros: {len(accounts)}")
print(f"Longitud por registro: {LEN_NUMBER + LEN_DNI + LEN_NAME + LEN_BALANCE + LEN_STATUS + LEN_DATE + LEN_LIMIT} bytes")
print("\nResumen de casos de prueba:")
print(f"- Cuentas con saldo alto (>10000): {sum(1 for a in accounts if a['balance'] > 10000)}")
print(f"- Cuentas con saldo bajo (<50): {sum(1 for a in accounts if a['balance'] < 50)}")
print(f"- Cuentas bloqueadas (B): {sum(1 for a in accounts if a['status'] == 'B')}")
print(f"- Cuentas con saldo 0: {sum(1 for a in accounts if a['balance'] == 0)}")
print(f"- Cuentas con límite diario bajo (<300): {sum(1 for a in accounts if a['limit'] < 300)}")
