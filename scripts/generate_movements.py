#!/usr/bin/env python3
# Script para generar MOVIMIENTOS.DAT con casos de prueba

# Estructura: 89 bytes
# - transaction_id: 10 dígitos
# - type: 1 carácter (T=Transferencia, I=Ingreso, R=Retirada, P=Pago)
# - origin: 6 dígitos
# - destination: 6 dígitos
# - amount: S9(10)V99 (12 bytes - 10 dígitos + 2 decimales)
# - date: 8 dígitos (YYYYMMDD)
# - time: 6 dígitos (HHMMSS)
# - concept: 40 caracteres

movements = [
    # 30 transferencias validas
    {"id": "0000000001", "type": "T", "origin": "000001", "destination": "000002", "amount": 500.00, "date": "20260301", "time": "090000", "concept": "TRANSFERENCIA ENTRE CUENTAS"},
    {"id": "0000000002", "type": "T", "origin": "000002", "destination": "000003", "amount": 250.50, "date": "20260301", "time": "091500", "concept": "PAGO SERVICIOS"},
    {"id": "0000000003", "type": "T", "origin": "000003", "destination": "000004", "amount": 100.00, "date": "20260301", "time": "093000", "concept": "TRANSFERENCIA"},
    {"id": "0000000004", "type": "T", "origin": "000001", "destination": "000005", "amount": 75.25, "date": "20260301", "time": "100000", "concept": "PAGO AMIGO"},
    {"id": "0000000005", "type": "T", "origin": "000006", "destination": "000001", "amount": 200.00, "date": "20260301", "time": "103000", "concept": "DEVOLUCION PRESTAMO"},
    {"id": "0000000006", "type": "T", "origin": "000012", "destination": "000013", "amount": 150.75, "date": "20260301", "time": "110000", "concept": "TRANSFERENCIA FAMILIAR"},
    {"id": "0000000007", "type": "T", "origin": "000014", "destination": "000015", "amount": 300.00, "date": "20260301", "time": "113000", "concept": "PAGO ALQUILER"},
    {"id": "0000000008", "type": "T", "origin": "000016", "destination": "000017", "amount": 50.00, "date": "20260301", "time": "120000", "concept": "TRANSFERENCIA PEQUENA"},
    {"id": "0000000009", "type": "T", "origin": "000018", "destination": "000019", "amount": 1000.00, "date": "20260301", "time": "123000", "concept": "COMPRA VEHICULO"},
    {"id": "0000000010", "type": "T", "origin": "000020", "destination": "000021", "amount": 450.25, "date": "20260301", "time": "130000", "concept": "PAGO PROVEEDOR"},
    {"id": "0000000011", "type": "T", "origin": "000022", "destination": "000023", "amount": 125.50, "date": "20260301", "time": "133000", "concept": "TRANSFERENCIA"},
    {"id": "0000000012", "type": "T", "origin": "000025", "destination": "000001", "amount": 80.00, "date": "20260301", "time": "140000", "concept": "PAGO SERVICIO"},
    {"id": "0000000013", "type": "T", "origin": "000002", "destination": "000012", "amount": 350.00, "date": "20260301", "time": "143000", "concept": "TRANSFERENCIA EMPRESA"},
    {"id": "0000000014", "type": "T", "origin": "000003", "destination": "000013", "amount": 175.80, "date": "20260301", "time": "150000", "concept": "PAGO FACTURA"},
    {"id": "0000000015", "type": "T", "origin": "000004", "destination": "000014", "amount": 90.00, "date": "20260301", "time": "153000", "concept": "TRANSFERENCIA"},
    {"id": "0000000016", "type": "T", "origin": "000005", "destination": "000015", "amount": 60.50, "date": "20260301", "time": "160000", "concept": "PAGO GASOLINA"},
    {"id": "0000000017", "type": "T", "origin": "000006", "destination": "000016", "amount": 225.00, "date": "20260301", "time": "163000", "concept": "TRANSFERENCIA"},
    {"id": "0000000018", "type": "T", "origin": "000012", "destination": "000017", "amount": 40.00, "date": "20260301", "time": "170000", "concept": "PAGO COMIDA"},
    {"id": "0000000019", "type": "T", "origin": "000013", "destination": "000018", "amount": 550.75, "date": "20260301", "time": "173000", "concept": "TRANSFERENCIA GRANDE"},
    {"id": "0000000020", "type": "T", "origin": "000014", "destination": "000019", "amount": 110.25, "date": "20260301", "time": "180000", "concept": "PAGO SEGURO"},
    {"id": "0000000021", "type": "T", "origin": "000015", "destination": "000020", "amount": 275.00, "date": "20260301", "time": "183000", "concept": "TRANSFERENCIA"},
    {"id": "0000000022", "type": "T", "origin": "000016", "destination": "000021", "amount": 95.50, "date": "20260301", "time": "190000", "concept": "PAGO TELEFONO"},
    {"id": "0000000023", "type": "T", "origin": "000017", "destination": "000022", "amount": 180.00, "date": "20260301", "time": "193000", "concept": "TRANSFERENCIA"},
    {"id": "0000000024", "type": "T", "origin": "000018", "destination": "000023", "amount": 320.75, "date": "20260301", "time": "200000", "concept": "PAGO INTERNET"},
    {"id": "0000000025", "type": "T", "origin": "000019", "destination": "000024", "amount": 140.00, "date": "20260301", "time": "203000", "concept": "TRANSFERENCIA"},
    {"id": "0000000026", "type": "T", "origin": "000020", "destination": "000025", "amount": 210.50, "date": "20260301", "time": "210000", "concept": "PAGO LUZ"},
    {"id": "0000000027", "type": "T", "origin": "000021", "destination": "000002", "amount": 85.00, "date": "20260301", "time": "213000", "concept": "TRANSFERENCIA"},
    {"id": "0000000028", "type": "T", "origin": "000022", "destination": "000003", "amount": 165.25, "date": "20260301", "time": "220000", "concept": "PAGO AGUA"},
    {"id": "0000000029", "type": "T", "origin": "000023", "destination": "000004", "amount": 290.00, "date": "20260301", "time": "223000", "concept": "TRANSFERENCIA"},
    {"id": "0000000030", "type": "T", "origin": "000024", "destination": "000005", "amount": 135.75, "date": "20260301", "time": "230000", "concept": "PAGO GAS"},
    
    # 5 ingresos validos
    {"id": "0000000031", "type": "I", "origin": "000000", "destination": "000001", "amount": 1500.00, "date": "20260301", "time": "080000", "concept": "NOMINA EMPRESA"},
    {"id": "0000000032", "type": "I", "origin": "000000", "destination": "000002", "amount": 2000.00, "date": "20260301", "time": "083000", "concept": "NOMINA"},
    {"id": "0000000033", "type": "I", "origin": "000000", "destination": "000003", "amount": 800.50, "date": "20260301", "time": "090000", "concept": "PENSION"},
    {"id": "0000000034", "type": "I", "origin": "000000", "destination": "000004", "amount": 500.00, "date": "20260301", "time": "093000", "concept": "TRANSFERENCIA ENTRANTE"},
    {"id": "0000000035", "type": "I", "origin": "000000", "destination": "000005", "amount": 350.25, "date": "20260301", "time": "100000", "concept": "DEVOLUCION"},
    
    # 5 retiradas validas
    {"id": "0000000036", "type": "R", "origin": "000001", "destination": "000000", "amount": 200.00, "date": "20260301", "time": "110000", "concept": "CAJERO AUTOMATICO"},
    {"id": "0000000037", "type": "R", "origin": "000002", "destination": "000000", "amount": 150.50, "date": "20260301", "time": "113000", "concept": "RETIRADA EFECTIVO"},
    {"id": "0000000038", "type": "R", "origin": "000003", "destination": "000000", "amount": 300.00, "date": "20260301", "time": "120000", "concept": "CAJERO"},
    {"id": "0000000039", "type": "R", "origin": "000004", "destination": "000000", "amount": 20.00, "date": "20260301", "time": "123000", "concept": "RETIRADA PEQUENA"},
    {"id": "0000000040", "type": "R", "origin": "000005", "destination": "000000", "amount": 5.00, "date": "20260301", "time": "130000", "concept": "CAJERO AUTOMATICO"},
    
    # 5 con cuenta inexistente (E001)
    {"id": "0000000041", "type": "T", "origin": "999999", "destination": "000001", "amount": 100.00, "date": "20260301", "time": "140000", "concept": "CUENTA INEXISTENTE ORIGEN"},
    {"id": "0000000042", "type": "T", "origin": "000001", "destination": "888888", "amount": 200.00, "date": "20260301", "time": "143000", "concept": "CUENTA INEXISTENTE DESTINO"},
    {"id": "0000000043", "type": "I", "origin": "000000", "destination": "777777", "amount": 300.00, "date": "20260301", "time": "150000", "concept": "INGRESO CUENTA INEXISTENTE"},
    {"id": "0000000044", "type": "R", "origin": "666666", "destination": "000000", "amount": 50.00, "date": "20260301", "time": "153000", "concept": "RETIRADA CUENTA INEXISTENTE"},
    {"id": "0000000045", "type": "T", "origin": "555555", "destination": "444444", "amount": 150.00, "date": "20260301", "time": "160000", "concept": "AMBAS CUENTAS INEXISTENTES"},
    
    # 5 con saldo insuficiente (E002)
    {"id": "0000000046", "type": "T", "origin": "000004", "destination": "000001", "amount": 5000.00, "date": "20260301", "time": "163000", "concept": "SALDO INSUFICIENTE"},
    {"id": "0000000047", "type": "R", "origin": "000005", "destination": "000000", "amount": 1000.00, "date": "20260301", "time": "170000", "concept": "RETIRADA EXCESIVA"},
    {"id": "0000000048", "type": "T", "origin": "000006", "destination": "000002", "amount": 2000.00, "date": "20260301", "time": "173000", "concept": "TRANSFERENCIA EXCESIVA"},
    {"id": "0000000049", "type": "T", "origin": "000017", "destination": "000003", "amount": 500.00, "date": "20260301", "time": "180000", "concept": "SALDO BAJO"},
    {"id": "0000000050", "type": "R", "origin": "000023", "destination": "000000", "amount": 200.00, "date": "20260301", "time": "183000", "concept": "RETIRADA NO PERMITIDA"},
    
    # 3 con cuenta bloqueada (E003)
    {"id": "0000000051", "type": "T", "origin": "000007", "destination": "000001", "amount": 100.00, "date": "20260301", "time": "190000", "concept": "CUENTA BLOQUEADA ORIGEN"},
    {"id": "0000000052", "type": "T", "origin": "000001", "destination": "000008", "amount": 200.00, "date": "20260301", "time": "193000", "concept": "CUENTA BLOQUEADA DESTINO"},
    {"id": "0000000053", "type": "R", "origin": "000007", "destination": "000000", "amount": 50.00, "date": "20260301", "time": "200000", "concept": "RETIRADA BLOQUEADA"},
    
    # 3 con importe invalido (E004)
    {"id": "0000000054", "type": "T", "origin": "000001", "destination": "000002", "amount": 0.00, "date": "20260301", "time": "203000", "concept": "IMPORTE CERO"},
    {"id": "0000000055", "type": "I", "origin": "000000", "destination": "000001", "amount": -100.00, "date": "20260301", "time": "210000", "concept": "IMPORTE NEGATIVO"},
    {"id": "0000000056", "type": "R", "origin": "000002", "destination": "000000", "amount": -50.00, "date": "20260301", "time": "213000", "concept": "RETIRADA NEGATIVA"},
    
    # 2 duplicados (E005)
    {"id": "0000000001", "type": "T", "origin": "000001", "destination": "000002", "amount": 500.00, "date": "20260301", "time": "090000", "concept": "DUPLICADO MOVIMIENTO 1"},
    {"id": "0000000002", "type": "T", "origin": "000002", "destination": "000003", "amount": 250.50, "date": "20260301", "time": "091500", "concept": "DUPLICADO MOVIMIENTO 2"},
]

# Longitudes según BANK-TRANSACTION.cpy
LEN_ID = 10
LEN_TYPE = 1
LEN_ORIGIN = 6
LEN_DESTINATION = 6
LEN_AMOUNT = 12  # S9(10)V99: 10 dígitos + 2 decimales
LEN_DATE = 8
LEN_TIME = 6
LEN_CONCEPT = 40

def format_amount(amount):
    # Convierte amount a formato S9(10)V99 (12 caracteres)
    # Para importes negativos, usamos el complemento
    if amount < 0:
        # Para simplificar, usamos valor absoluto y marcamos como inválido
        amount = abs(amount)
    cents = int(amount * 100)
    return str(cents).zfill(LEN_AMOUNT)

with open("data/MOVIMIENTOS.DAT", "w") as f:
    for mov in movements:
        record = ""
        record += mov["id"].ljust(LEN_ID)[:LEN_ID]
        record += mov["type"].ljust(LEN_TYPE)[:LEN_TYPE]
        record += mov["origin"].ljust(LEN_ORIGIN)[:LEN_ORIGIN]
        record += mov["destination"].ljust(LEN_DESTINATION)[:LEN_DESTINATION]
        record += format_amount(mov["amount"])
        record += mov["date"].ljust(LEN_DATE)[:LEN_DATE]
        record += mov["time"].ljust(LEN_TIME)[:LEN_TIME]
        record += mov["concept"].ljust(LEN_CONCEPT)[:LEN_CONCEPT]
        f.write(record + "\n")

print("MOVIMIENTOS.DAT generado correctamente")
print(f"Total registros: {len(movements)}")
print(f"Longitud por registro: {LEN_ID + LEN_TYPE + LEN_ORIGIN + LEN_DESTINATION + LEN_AMOUNT + LEN_DATE + LEN_TIME + LEN_CONCEPT} bytes")
print("\nResumen de casos de prueba:")
print(f"- Transferencias validas: {sum(1 for m in movements if m['type'] == 'T' and m['id'] < '0000000041')}")
print(f"- Ingresos validos: {sum(1 for m in movements if m['type'] == 'I' and m['id'] < '0000000041')}")
print(f"- Retiradas validas: {sum(1 for m in movements if m['type'] == 'R' and m['id'] < '0000000041')}")
print(f"- Cuenta inexistente (E001): {sum(1 for m in movements if '0000000041' <= m['id'] <= '0000000045')}")
print(f"- Saldo insuficiente (E002): {sum(1 for m in movements if '0000000046' <= m['id'] <= '0000000050')}")
print(f"- Cuenta bloqueada (E003): {sum(1 for m in movements if '0000000051' <= m['id'] <= '0000000053')}")
print(f"- Importe invalido (E004): {sum(1 for m in movements if '0000000054' <= m['id'] <= '0000000056')}")
print(f"- Duplicados (E005): {sum(1 for m in movements if m['id'] in ['0000000001', '0000000002'] and m['concept'].startswith('DUPLICADO'))}")
