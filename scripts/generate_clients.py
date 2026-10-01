#!/usr/bin/env python3
# Script para generar CLIENTES.DAT con longitudes exactas

clients = [
    {
        "dni": "12345678A",
        "name": "MARIO PICO BUSQUIER",
        "address": "CALLE MAYOR 15 3A MADRID",
        "phone": "612345678",
        "email": "MARIO.PICO@EMAIL.COM",
        "date": "20240115"
    },
    {
        "dni": "87654321B",
        "name": "ANA GARCIA LOPEZ",
        "address": "AVENIDA DE LA CONSTITUCION 45 BARCELONA",
        "phone": "623456789",
        "email": "ANA.GARCIA@EMAIL.COM",
        "date": "20240220"
    },
    {
        "dni": "11223345C",
        "name": "CARLOS MARTINEZ RUIZ",
        "address": "CALLE REAL 23 SEVILLA",
        "phone": "634567890",
        "email": "CARLOS.MARTINEZ@EMAIL.COM",
        "date": "20240310"
    },
    {
        "dni": "99887766D",
        "name": "LAURA FERNANDEZ SANZ",
        "address": "PLAZA ESPAÑA 7 VALENCIA",
        "phone": "645678901",
        "email": "LAURA.FERNANDEZ@EMAIL.COM",
        "date": "20240405"
    },
    {
        "dni": "55443321E",
        "name": "PEDRO JIMENEZ MORENO",
        "address": "CALLE ALCALA 100 MADRID",
        "phone": "656789012",
        "email": "PEDRO.JIMENEZ@EMAIL.COM",
        "date": "20240512"
    },
    {
        "dni": "66778899F",
        "name": "SANDRA LOPEZ DIAZ",
        "address": "RAMBLA CATALUÑA 88 BARCELONA",
        "phone": "667890123",
        "email": "SANDRA.LOPEZ@EMAIL.COM",
        "date": "20240618"
    },
    {
        "dni": "22334455G",
        "name": "DAVID GOMEZ RUIZ",
        "address": "CALLE SIERPES 15 SEVILLA",
        "phone": "678901234",
        "email": "DAVID.GOMEZ@EMAIL.COM",
        "date": "20240722"
    },
    {
        "dni": "33445567H",
        "name": "CRISTINA RUIZ GARCIA",
        "address": "GRAN VIA 200 VALENCIA",
        "phone": "689012345",
        "email": "CRISTINA.RUIZ@EMAIL.COM",
        "date": "20240830"
    },
    {
        "dni": "44556678I",
        "name": "JAVIER SANCHEZ LOPEZ",
        "address": "CALLE GENOVA 5 MADRID",
        "phone": "690123456",
        "email": "JAVIER.SANCHEZ@EMAIL.COM",
        "date": "20240914"
    },
    {
        "dni": "55667789J",
        "name": "MERCEDES MORENO FERNANDEZ",
        "address": "PASSEIG DE GRACIA 150 BARCELONA",
        "phone": "601234567",
        "email": "MERCEDES.MORENO@EMAIL.COM",
        "date": "20241025"
    },
    {
        "dni": "66778800K",
        "name": "ROBERTO DIAZ JIMENEZ",
        "address": "CALLE COLON 30 VALENCIA",
        "phone": "612345670",
        "email": "ROBERTO.DIAZ@EMAIL.COM",
        "date": "20241108"
    },
    {
        "dni": "77889911L",
        "name": "PATRICIA RUIZ SANCHEZ",
        "address": "CALLE VELAZQUEZ 45 SEVILLA",
        "phone": "623456781",
        "email": "PATRICIA.RUIZ@EMAIL.COM",
        "date": "20241201"
    }
]

# Longitudes según BANK-CLIENT.cpy
LEN_DNI = 9
LEN_NAME = 40
LEN_ADDRESS = 50
LEN_PHONE = 15
LEN_EMAIL = 50
LEN_DATE = 8

with open("data/CLIENTES.DAT", "w") as f:
    for client in clients:
        record = ""
        record += client["dni"].ljust(LEN_DNI)[:LEN_DNI]
        record += client["name"].ljust(LEN_NAME)[:LEN_NAME]
        record += client["address"].ljust(LEN_ADDRESS)[:LEN_ADDRESS]
        record += client["phone"].ljust(LEN_PHONE)[:LEN_PHONE]
        record += client["email"].ljust(LEN_EMAIL)[:LEN_EMAIL]
        record += client["date"].ljust(LEN_DATE)[:LEN_DATE]
        f.write(record + "\n")

print("CLIENTES.DAT generado correctamente")
print(f"Total registros: {len(clients)}")
print(f"Longitud por registro: {LEN_DNI + LEN_NAME + LEN_ADDRESS + LEN_PHONE + LEN_EMAIL + LEN_DATE} bytes")
