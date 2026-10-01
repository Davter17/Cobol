IDENTIFICATION DIVISION.
PROGRAM-ID. TEST-COMMON.
AUTHOR. MARIO PICO BUSQUIER.
DATE-WRITTEN. 2026-09-26.

DATA DIVISION.
WORKING-STORAGE SECTION.
COPY BANK-COMMON.

PROCEDURE DIVISION.
    DISPLAY "========================================".
    DISPLAY "       BANK-COMMON.cpy TEST".
    DISPLAY "========================================".
    DISPLAY "BANK CODE:       " WS-BANK-CODE.
    DISPLAY "BANK NAME:       " WS-BANK-NAME.
    DISPLAY "VERSION:         " WS-SYSTEM-VERSION.
    DISPLAY "----------------------------------------".
    DISPLAY "MIN AMOUNT:      " WS-MIN-AMOUNT.
    DISPLAY "MAX AMOUNT:      " WS-MAX-AMOUNT.
    DISPLAY "DAILY LIMIT:     " WS-MAX-DAILY-LIMIT.
    DISPLAY "----------------------------------------".
    DISPLAY "TRANSFER COMM%:  " WS-COMM-TRANSFER-PCT.
    DISPLAY "TRANSFER MIN:    " WS-COMM-TRANSFER-MIN.
    DISPLAY "WITHDRAWAL FIX:  " WS-COMM-WITHDRAWAL-FIX.
    DISPLAY "PAYMENT COMM%:   " WS-COMM-PAYMENT-PCT.
    DISPLAY "========================================".

    MOVE "A" TO WS-ACCOUNT-STATUS.
    IF STATUS-ACTIVE
        DISPLAY "STATUS TEST:     ACTIVE (OK)"
    END-IF.

    MOVE "T" TO WS-TRANSACTION-TYPE.
    IF TYPE-TRANSFER
        DISPLAY "TYPE TEST:       TRANSFER (OK)"
    END-IF.

    DISPLAY "========================================".
    STOP RUN.
