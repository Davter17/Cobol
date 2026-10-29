//*=====================================================
//* BANKJOB - JOB DE PROCESAMIENTO DIARIO BANCARIO
//*=====================================================
//*
//* DESCRIPCION:
//*   Job principal del sistema bancario COBOL.
//*   Ejecuta el programa BANKPROC que procesa todos
//*   los movimientos del dia: valida, actualiza
//*   saldos, calcula comisiones y genera informes.
//*
//* AUTOR:    MARIO PICO
//* FECHA:    2026-03-01
//* SISTEMA:  COBOL BANKING BATCH SYSTEM v01
//*
//* FLUJO:
//*   STEP1  - Ejecuta BANKPROC (programa principal)
//*   STEP2  - Verifica codigo de retorno (COND)
//*
//* FICHEROS DE ENTRADA:
//*   MOVIMIENTOS.DAT  - Movimientos del dia a procesar
//*   CUENTAS.DAT      - Fichero maestro de cuentas
//*
//* FICHEROS DE SALIDA:
//*   ERRORS.DAT    - Movimientos rechazados con errores
//*   HISTORICO.DAT - Operaciones procesadas correctamente
//*   REPORT.DAT    - Informe diario de procesamiento
//*   AUDIT.DAT     - Registro de auditoria detallado
//*
//*=====================================================
//*
//* -------------------------------------------------------
//* JOB CARD
//* -------------------------------------------------------
//* El job card identifica el job al sistema operativo.
//*
//* BANKJOB   - Nombre del job (1-8 caracteres)
//* JOB       - Indica que es una sentencia de job
//*
//* Parametros del job:
//*   CLASS=A    - Clase de ejecucion (A = estandar)
//*   MSGCLASS=X - Clase para mensajes del job
//*                (X = se envian al spool de salida)
//*   MSGLEVEL=(1,1) - Nivel de detalle de mensajes:
//*                    1 = mensajes del job y JCL
//*                    1 = también statements JCL
//*   NOTIFY=&SYSUID - Notificar al usuario que lo envio
//*   REGION=0M  - Memoria dinamica (todo lo disponible)
//*
//* TYPRUN=SCAN se puede usar para validar sin ejecutar.
//* -------------------------------------------------------
//BANKJOB  JOB (BANK001),'COBOL BANKING BATCH',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID,
//             REGION=0M
//*
//* =====================================================
//* STEP1: EJECUCION DEL PROGRAMA BANKPROC
//* =====================================================
//* Este step ejecuta el programa COBOL BANKPROC que
//* procesa todos los movimientos del dia.
//*
//* PGM=BANKPROC  - Nombre del modulo a ejecutar
//*                   (debe estar en STEPLIB o LINKLIST)
//* COND=(0,NE)   - Condicion de ejecucion:
//*                   si el paso anterior termino con
//*                   codigo de retorno != 0, no ejecutar.
//* =====================================================
//STEP1    EXEC PGM=BANKPROC,
//             COND=(0,NE)
//*
//* -------------------------------------------------------
//* STEPLIB - BIBLIOTECA DE MODULOS
//* -------------------------------------------------------
//* Indica donde se encuentra el modulo BANKPROC compilado.
//* En un sistema real, estaria en una biblioteca
//* catalogada (PDS/PDSE).
//*
//* DSN=BANK.COBOL.LOAD  - Biblioteca de modulos cargados
//* DISP=SHR             - Compartible (solo lectura)
//*                        SHR = Share (otros jobs pueden
//*                        acceder simultaneamente)
//* -------------------------------------------------------
//STEPLIB  DD DSN=BANK.COBOL.LOAD,
//             DISP=SHR
//*
//* -------------------------------------------------------
//* MOVIMIENTOS - FICHERO DE ENTRADA: MOVIMIENTOS DEL DIA
//* -------------------------------------------------------
//* Contiene todos los movimientos (transferencias,
//* ingresos, retiradas, pagos) que se van a procesar.
//*
//* DSN=BANK.DATA.MOVIMIENTOS  - Fichero catalogado
//*   El DSN (Data Set Name) identifica el fichero en
//*   el sistema z/OS. Sigue la convencion:
//*     BANK.DATA.MOVIMIENTOS
//*     ^    ^    ^
//*     |    |    +-- Nombre del fichero
//*     |    +------- Tipo (datos)
//*     +------------ Prefijo del proyecto/sistema
//*
//* DISP=SHR  - Solo lectura, compartido.
//*   DISP (Disposition) indica como se trata el fichero:
//*     SHR  = Share (solo lectura, otros pueden leer)
//*     Otros valores comunes:
//*       OLD = Old (exclusive lock, solo este job accede)
//*       MOD = Modify (append, se anade al final)
//*       NEW = Crear nuevo (falla si ya existe)
//* -------------------------------------------------------
//MOVEMENTS DD DSN=BANK.DATA.MOVIMIENTOS,
//             DISP=SHR
//*
//* -------------------------------------------------------
//* CUENTAS - FICHERO MAESTRO DE CUENTAS (LECTURA/ESCRITURA)
//* -------------------------------------------------------
//* Fichero maestro que contiene todas las cuentas del
//* banco. BANKPROC lo actualiza in-place (REWRITE).
//*
//* DISP=OLD  - Acceso exclusivo de lectura/escritura.
//*   OLD garantiza que ningun otro job puede acceder
//*   al fichero mientras BANKPROC lo actualiza.
//*   Es critico para mantener la integridad de los
//*   saldos bancarios.
//* -------------------------------------------------------
//ACCOUNTS DD DSN=BANK.DATA.CUENTAS,
//             DISP=OLD
//*
//* -------------------------------------------------------
//* ERRORS - FICHERO DE SALIDA: MOVIMIENTOS RECHAZADOS
//* -------------------------------------------------------
//* Contiene todos los movimientos que no pudieron
//* procesarse por errores (cuenta inexistente,
//* saldo insuficiente, cuenta bloqueada, etc.)
//*
//* DISP=(NEW,CATLG,DELETE) - Disposition en 3 partes:
//*   Parte 1 (Status):  NEW  = Crear fichero nuevo
//*   Parte 2 (Normal):  CATLG = Catalogar si el job
//*                                termina normalmente.
//*                                Catalogar = registrar
//*                                el DSN en el catalogo
//*                                para que otros jobs
//*                                puedan encontrarlo.
//*   Parte 3 (Abnormal): DELETE = Borrar si el job
//*                                falla (asi no quedan
//*                                ficheros parciales).
//*
//* DCB=(RECFM=FB,LRECL=100,BLKSIZE=0)
//*   DCB = Data Control Block
//*   RECFM=FB  - Record Format: Fixed Block
//*               FB = registros de longitud fija,
//*                    agrupados en bloques fisicos.
//*   LRECL=100 - Longitud de cada registro = 100 bytes
//*               (26 timestamp + 10 ID + 4 codigo +
//*                50 descripcion + 6 cuenta + 12 importe)
//*   BLKSIZE=0 - El sistema calcula el tamano de bloque
//*               optimo automaticamente.
//*
//* UNIT=SYSDA  - Tipo de dispositivo (disco)
//* SPACE=(TRK,(10,5)) - Espacio en pistas (tracks):
//*   10  - Pistas iniciales (primary)
//*   5   - Pistas adicionales si se llenan (secondary)
//* -------------------------------------------------------
//ERRORS   DD DSN=BANK.OUTPUT.ERRORS,
//             DISP=(NEW,CATLG,DELETE),
//             UNIT=SYSDA,
//             SPACE=(TRK,(10,5)),
//             DCB=(RECFM=FB,LRECL=100,BLKSIZE=0)
//*
//* -------------------------------------------------------
//* HISTORICO - FICHERO DE SALIDA: OPERACIONES EXITOSAS
//* -------------------------------------------------------
//* Registro permanente de todas las operaciones que
//* se procesaron correctamente. Se usa para auditoria
//* y reconstruccion de historial.
//*
//* DISP=(,CATLG,DELETE) - Disposition:
//*   Parte 1 vacia = usar el fichero existente o
//*                    crearlo si no existe
//*   Parte 2 CATLG  = catalogar si termina bien
//*   Parte 3 DELETE = borrar si falla
//*
//* RECFM=FB - Registros de longitud fija
//* LRECL=118 - Tamano del registro de historico:
//*   (26 timestamp + 10 ID + 1 tipo + 6 origen +
//*    6 destino + 12 importe + 8 fecha + 6 hora +
//*    40 concepto + 3 padding)
//* -------------------------------------------------------
//HISTORIC DD DSN=BANK.OUTPUT.HISTORICO,
//             DISP=(,CATLG,DELETE),
//             UNIT=SYSDA,
//             SPACE=(TRK,(50,10)),
//             DCB=(RECFM=FB,LRECL=118,BLKSIZE=0)
//*
//* -------------------------------------------------------
//* REPORT - FICHERO DE SALIDA: INFORME DIARIO
//* -------------------------------------------------------
//* Informe profesional con resumen del procesamiento.
//* Este es el documento que consultan los usuarios
//* para ver el resultado del batch diario.
//*
//* RECFM=FBA - Fixed Blocked with ASA control chars
//*   FBA = formato fijo con caracteres de control ASA
//*   en la primera posicion de cada linea. Estos
//*   caracteres controlan el salto de linea al
//*   imprimir (1= nueva pagina, espacio=nueva linea).
//* LRECL=80 - Lineas de 80 caracteres (estandar)
//* -------------------------------------------------------
//REPORT   DD DSN=BANK.OUTPUT.REPORT,
//             DISP=(NEW,CATLG,DELETE),
//             UNIT=SYSDA,
//             SPACE=(TRK,(5,1)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=0)
//*
//* -------------------------------------------------------
//* AUDIT - FICHERO DE SALIDA: REGISTRO DE AUDITORIA
//* -------------------------------------------------------
//* Log detallado de TODOS los movimientos procesados
//* (tanto aceptados como rechazados). Obligatorio en
//* sistemas financieros para trazabilidad.
//*
//* LRECL=118 - Tamano del registro de auditoria
//* -------------------------------------------------------
//AUDIT    DD DSN=BANK.OUTPUT.AUDIT,
//             DISP=(NEW,CATLG,DELETE),
//             UNIT=SYSDA,
//             SPACE=(TRK,(50,10)),
//             DCB=(RECFM=FB,LRECL=118,BLKSIZE=0)
//*
//* -------------------------------------------------------
//* SYSOUT - SALIDA DEL SISTEMA (DISPLAY/CONSOLA)
//* -------------------------------------------------------
//* Redirige los DISPLAY del programa COBOL al spool
//* del sistema. Es lo que vemos en la consola o en
//* el output del job cuando termina.
//*
//* SYSOUT=* - La salida va a la clase de spool
//*            definida en MSGCLASS del job card.
//* -------------------------------------------------------
//SYSOUT   DD SYSOUT=*
//*
//* -------------------------------------------------------
//* SYSUDUMP - VOLCADO DE MEMORIA EN CASO DE ABEND
//* -------------------------------------------------------
//* Si el programa falla (ABEND), el volcado de memoria
//* se envia aqui. Imprescindible para depurar errores
//* en produccion.
//* -------------------------------------------------------
//SYSUDUMP DD SYSOUT=*
//*
//* =====================================================
//* STEP2: VERIFICACION DEL RESULTADO
//* =====================================================
//* Step de control que verifica que BANKPROC termino
//* correctamente (codigo de retorno 0).
//*
//* IEFBR14 es un programa "ficticio" de IBM que no
//* hace nada pero permite ejecutar pasos de control.
//* Es el equivalente a un "no-op" en JCL.
//*
//* COND=(0,EQ,STEP1) - Ejecutar este paso SOLO si
//*   el codigo de retorno de STEP1 es 0 (exito).
//*   En realidad la logica es inversa: el step se
//*   SALTA si la condicion es verdadera.
//*   (0,EQ,STEP1) significa "si STEP1 retorno 0,
//*   entonces la condicion es TRUE y se ejecuta".
//* =====================================================
//STEP2    EXEC PGM=IEFBR14,
//             COND=(0,EQ,STEP1)
//*
//* -------------------------------------------------------
//* Mensaje de finalizacion exitosa
//* -------------------------------------------------------
//SYSUDUMP DD SYSOUT=*
//*
//* -------------------------------------------------------
//* Fin del job BANKJOB
//* -------------------------------------------------------
