*>================================================*
*> BANK-TRANSACTION.cpy                           *
*> Estructura de registro de transaccion          *
*>================================================*

*>--- ESTRUCTURA DE TRANSACCION
01 WS-TRANSACTION-RECORD.
    05 WS-TRANSACTION-ID         PIC 9(10).
    05 WS-TRANSACTION-TYPE       PIC X(1).
        88 TRANSFERENCIA         VALUE "T".
        88 INGRESO               VALUE "I".
        88 RETIRADA              VALUE "R".
        88 PAGO                  VALUE "P".
    05 WS-TRANSACTION-ORIGIN     PIC 9(6).
    05 WS-TRANSACTION-DESTINATION PIC 9(6).
    05 WS-TRANSACTION-AMOUNT     PIC S9(10)V99.
    05 WS-TRANSACTION-DATE       PIC 9(8).
    05 WS-TRANSACTION-TIME       PIC 9(6).
    05 WS-TRANSACTION-CONCEPT    PIC X(40).
