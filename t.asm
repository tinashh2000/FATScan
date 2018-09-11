;****************************************************************************************
;* Copyright (C) 2018 Tinashe Mutandagayi                                               *
;*                                                                                      *
;* This file is part of the MT-Operating System source code. The author(s) of this file *
;* is/are not liable for any damages, loss or loss of information, deaths, sicknesses   *
;* or other bad things resulting from use of this file or software, either direct or    *
;* indirect.                                                                            *
;* Terms and conditions for use and distribution can be found in the license file named *
;* LICENSE.TXT. If you distribute this file or continue using it,                       *
;* it means you understand and agree with the terms and conditions in the license file. *
;* binding this file.                                                                   *
;*                                                                                      *
;* Happy Coding :)                                                                      *
;****************************************************************************************

ORG 100h
    MOV SI,(MyData)
    MOV DI,(MyProg)
    MOV CX,5Ah-3
    ADD SI,3
    ADD DI,3
    REP MOVSB

    MOV AH,3Ch
    MOV DX,(OutProg)
    MOV CX,0
    INT 21h

    MOV BX,AX
    MOV AH,40h
    MOV CX,512
    MOV DX,(MyProg)
    INT 21h

    MOV AH,4Ch
    INT 21h

    MOV AX,201h
    MOV BX,(BtSect)
    MOV CX,1
    MOV DX,182h
    INT 13h

    MOV DX,(OutFile)
    MOV CX,0
    MOV AH,3Ch
    INT 21h

    MOV BX,AX

    MOV AH,40h
    MOV CX,512
    MOV DX,(BtSect)
    INT 21h

    MOV AH,4Ch
    INT 21h

OutFile DB  "BOOTSECT.PRG",0
OutProg DB  "\BOOTSECT.DOS",0
    DB  512-($ AND 1FFh)    DUP(0)
MyData:
INCLUDEBIN "BOOTSECT.DOS"
MyProg:
INCLUDEBIN "BOOTSECT.PRG"

ALIGN 512
BtSect  DB  512 DUP(?)
