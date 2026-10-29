//*=====================================================
//* SORTJOB - JOB PARA ORDENAR MOVIMIENTOS
//*=====================================================
//*
//* DESCRIPCION:
//*   Job que ordena el fichero de movimientos por
//*   numero de cuenta origen antes del procesamiento
//*   batch principal.
//*
//*   En sistemas mainframe, es practica comun ordenar
//*   los datos antes del batch para:
//*     1. Mejorar el rendimiento (acceso secuencial
//*        optimizado a cuentas)
//*     2. Detectar duplicados mas facilmente
//*     3. Facilitar el procesamiento por lotes
//*        agrupando movimientos de la misma cuenta
//*
//* AUTOR:    MARIO PICO
//* FECHA:    2026-03-01
//* SISTEMA:  COBOL BANKING BATCH SYSTEM v01
//*
//* CAMPO DE ORDENACION:
//*   POSICION  LONGITUD  TIPO  DESCRIPCION
//*   12-17     6         CH    Cuenta origen
//*
//*   Estructura del registro MOVIMIENTOS:
//*     Pos 1-10:   ID Transaccion
//*     Pos 11:     Tipo operacion (T/I/R/P)
//*     Pos 12-17:  Cuenta origen  <-- CAMPO DE ORDEN
//*     Pos 18-23:  Cuenta destino
//*     Pos 24-35:  Importe
//*     Pos 36-43:  Fecha
//*     Pos 44-49:  Hora
//*     Pos 50-89:  Concepto
//*
//* FLUJO:
//*   STEP1  - Ejecuta DFSORT para ordenar
//*   STEP2  - Verifica codigo de retorno
//*
//* ENTRADA:
//*   BANK.DATA.MOVIMIENTOS (fichero sin ordenar)
//*
//* SALIDA:
//*   BANK.DATA.MOVIMIENTOS.SORTED (fichero ordenado)
//*
//* NOTA:
//*   Despues de ejecutar este job, el fichero
//*   MOVIMIENTOS.SORTED deberia renombrarse o
//*   utilizarse como entrada del BANKJOB.
//*=====================================================
//*
//* -------------------------------------------------------
//* JOB CARD
//* -------------------------------------------------------
//* SORTJOB   - Nombre identificativo del job
//* CLASS=A   - Clase de ejecucion estandar
//* MSGCLASS=X - Salida de mensajes al spool
//* REGION=0M  - Toda la memoria disponible (el sort
//*              puede necesitar mucha memoria para
//*              ordenar ficheros grandes)
//* -------------------------------------------------------
//SORTJOB  JOB (BANK002),'SORT MOVIMIENTOS',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID,
//             REGION=0M
//*
//* =====================================================
//* STEP1: EJECUCION DE DFSORT
//* =====================================================
//* PGM=SORT  - Programa IBM DFSORT (ordenacion)
//*               DFSORT es el utilitario estandar de
//*               IBM para ordenacion y mezcla de
//*               ficheros en z/OS.
//*
//* REGION=0M  - Sobrescribe la region del job card.
//*              El sort necesita toda la memoria
//*              disponible para trabajar eficientemente
//*              con ficheros grandes.
//* =====================================================
//STEP1    EXEC PGM=SORT,REGION=0M
//*
//* -------------------------------------------------------
//* SYSOUT - Salida de mensajes del sort
//* -------------------------------------------------------
//* DFSORT escribe aqui estadisticas del proceso:
//*   - Numero de registros leidos
//*   - Tiempo de procesamiento
//*   - Memoria utilizada
//*   - Numero de bloques escritos
//* -------------------------------------------------------
//SYSOUT   DD SYSOUT=*
//*
//* -------------------------------------------------------
//* SORTIN - FICHERO DE ENTRADA (SIN ORDENAR)
//* -------------------------------------------------------
//* Fichero original de movimientos que necesita ser
//* ordenado por cuenta origen.
//*
//* DISP=SHR - Solo lectura, compartido.
//*   El fichero original no se modifica, solo se lee.
//* -------------------------------------------------------
//SORTIN   DD DSN=BANK.DATA.MOVIMIENTOS,
//             DISP=SHR
//*
//* -------------------------------------------------------
//* SORTOUT - FICHERO DE SALIDA (ORDENADO)
//* -------------------------------------------------------
//* Fichero resultante con los movimientos ordenados
//* alfabeticamente por cuenta origen.
//*
//* DISP=(NEW,CATLG,DELETE):
//*   NEW    - Crear fichero nuevo
//*   CATLG  - Catalogar si termina bien (disponible
//*            para otros jobs como BANK.DATA.MOVIMIENTOS.SORTED)
//*   DELETE - Borrar si falla (no dejar datos parciales)
//*
//* SPACE=(TRK,(50,10)):
//*   Asignar 50 tracks iniciales y 10 adicionales
//*   si es necesario (el fichero tiene el mismo
//*   tamano que el original)
//*
//* DCB=(RECFM=FB,LRECL=89,BLKSIZE=0):
//*   RECFM=FB  - Formato fijo bloqueado
//*   LRECL=89  - Longitud de registro:
//*               (10 ID + 1 tipo + 6 origen + 6 destino +
//*                12 importe + 8 fecha + 6 hora +
//*                40 concepto = 89 bytes)
//*   BLKSIZE=0 - Calcular bloque optimo automaticamente
//* -------------------------------------------------------
//SORTOUT  DD DSN=BANK.DATA.MOVIMIENTOS.SORTED,
//             DISP=(NEW,CATLG,DELETE),
//*             UNIT=SYSDA,
//             SPACE=(TRK,(50,10)),
//             DCB=(RECFM=FB,LRECL=89,BLKSIZE=0)
//*
//* -------------------------------------------------------
//* SORTWK01,SORTWK02,SORTWK03 - ESPACIO DE TRABAJO
//* -------------------------------------------------------
//* DFSORT necesita espacio de trabajo (work space) para
//* realizar la ordenacion. Son ficheros temporales que
//* se usan durante el proceso y se borran al terminar.
//*
//* Se suelen asignar 3 espacios de trabajo en unidades
//* de disco diferentes para maximizar el rendimiento
//* (operaciones de I/O en paralelo).
//*
//* SPACE=(CYL,(50,10)):
//*   CYL = cilindros (1 cilindro = 15 tracks)
//*   50 cilindros iniciales + 10 adicionales
//* -------------------------------------------------------
//SORTWK01 DD UNIT=SYSDA,SPACE=(CYL,(50,10))
//SORTWK02 DD UNIT=SYSDA,SPACE=(CYL,(50,10))
//SORTWK03 DD UNIT=SYSDA,SPACE=(CYL,(50,10))
//*
//* -------------------------------------------------------
//* SYSIN - PARAMETROS DE ORDENACION
//* -------------------------------------------------------
//* SYSIN contiene las instrucciones para DFSORT.
//* Cada sentencia tiene un formato especifico:
//*
//* SORT FIELDS=(inicio,longitud,tipo,orden)
//*
//* Parametros:
//*   inicio   - Posicion del campo en el registro
//*              (empieza en 1, no en 0)
//*   longitud - Tamano del campo en bytes
//*   tipo     - Tipo de dato:
//*                CH = Character (alfabetico)
//*                ZD = Zoned Decimal
//*                BI = Binary
//*                PD = Packed Decimal
//*   orden    - Direccion de ordenacion:
//*                A = Ascendente (A a Z, 0 a 9)
//*                D = Descendente (Z a A, 9 a 0)
//*
//* En nuestro caso:
//*   (12,6,CH,A) significa:
//*     12 = empezar en la posicion 12 (cuenta origen)
//*     6  = longitud de 6 bytes (PIC 9(6))
//*     CH = tipo caracter (alfabetico)
//*     A  = orden ascendente (000001 antes que 999999)
//*
//* Esto agrupa todos los movimientos de la misma cuenta
//* juntos, facilitando el procesamiento posterior.
//* -------------------------------------------------------
//SYSIN    DD *
 SORT FIELDS=(12,6,CH,A)
/*
//*
//* =====================================================
//* STEP2: VERIFICACION DEL RESULTADO
//* =====================================================
//* Step de control que verifica que el sort termino
//* correctamente (codigo de retorno 0).
//*
//* IEFBR14 - Programa "no-op" de IBM.
//*   No ejecuta ninguna instruccion, solo sirve para
//*   tener un paso de control o verificacion.
//*
//* COND=(0,EQ,STEP1) - Ejecutar este paso SOLO si
//*   el codigo de retorno de STEP1 es igual a 0.
//* -------------------------------------------------------
//STEP2    EXEC PGM=IEFBR14,
//             COND=(0,EQ,STEP1)
//*
//* -------------------------------------------------------
//* Fin del job SORTJOB
//* -------------------------------------------------------
