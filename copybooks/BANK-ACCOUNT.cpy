*>================================================*
*> BANK-ACCOUNT.cpy                               *
*> Estructura de registro de cuenta bancaria      *
*>================================================*

*>--- ESTRUCTURA DE CUENTA BANCARIA
01 WS-ACCOUNT-RECORD.
    05 WS-ACCOUNT-NUMBER       PIC 9(6).
    05 WS-ACCOUNT-DNI          PIC X(9).
    05 WS-ACCOUNT-NAME         PIC X(30).
    05 WS-ACCOUNT-BALANCE      PIC S9(10)V99.
    05 WS-ACCOUNT-STATUS       PIC X(1).
    05 WS-ACCOUNT-OPEN-DATE    PIC 9(8).
    05 WS-ACCOUNT-DAILY-LIMIT  PIC 9(10)V99.
