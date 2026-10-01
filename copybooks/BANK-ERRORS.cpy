*>================================================*
*> BANK-ERRORS.cpy                                *
*> Estructura de registro de error y codigos      *
*>================================================*

*>--- ESTRUCTURA DE REGISTRO DE ERROR
01 WS-ERROR-RECORD.
    05 WS-ERR-TIMESTAMP          PIC X(26).
    05 WS-ERR-TRANSACTION-ID     PIC 9(10).
    05 WS-ERR-CODE               PIC X(4).
        88 ERR-NONE              VALUE "0000".
        88 ERR-ACCOUNT-NOT-FOUND VALUE "E001".
        88 ERR-INSUFFICIENT-BAL  VALUE "E002".
        88 ERR-ACCOUNT-BLOCKED   VALUE "E003".
        88 ERR-INVALID-AMOUNT    VALUE "E004".
        88 ERR-DUPLICATE-MOV     VALUE "E005".
        88 ERR-ACCOUNT-INACTIVE  VALUE "E006".
        88 ERR-DAILY-LIMIT       VALUE "E007".
        88 ERR-RECORD-FORMAT     VALUE "E008".
        88 ERR-INVALID-DATE      VALUE "E009".
        88 ERR-IO-ERROR          VALUE "E010".
    05 WS-ERR-DESCRIPTION        PIC X(50).
    05 WS-ERR-ACCOUNT-ID         PIC 9(6).
    05 WS-ERR-AMOUNT             PIC S9(10)V99.
