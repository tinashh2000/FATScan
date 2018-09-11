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

INCLUDE "INT13.INC"
INCLUDE "FAT.INC"
INCLUDE "DISK.INC"
INCLUDE "SCAN.INC"
.LANG STDCALL

    MOV AH,48h
    MOV SI,(DiskParams)
    MOV [SI].dspSize,1Ah
    MOV DL,80h
    INT 13h
    JC  i13MonDone
    MOV EAX,[SI].dspHeads
    MOV [Heads],EAX
    MOV EAX,[SI].dspSectorsPerTrack
    MOV [SPT],EAX
    MOV EAX,[SI].dspCylinders
    MOV [Cyl],EAX

    MOV SI,(DiskStruc)

    XOR EAX,EAX
    MOV [SI].dpSector,EAX
    MOV [SI][4].dpSector,EAX

    MOV [SI],(SIZE DiskStruct)
    MOV [SI].dpNumSectors,1
    MOV BX,DS
    SHL EBX,16
    MOV BX,(DiskBuffer)
    MOV [SI].dpBuffer,EBX

    MOV AH,42h
    MOV DL,80h
    INT 13h
    JC  i13MonDone

    MOVZX   EBX,BX
    MOV EAX,[BX].mbrBeginAbsSector

    PUSH    [BX].mbrTotalAbsSector  ;Params for DetectFAT,contents will change
    PUSH    EAX

    MOV [SI].dpSector,EAX
    MOV AH,42h
    INT 13h
    JC  i13MonDone

    CALL    DetectFAT       ;Params pushed above

    JC  i13MonDone

;    CALL    ClusterToSector,DWORD (10)
;    CALL    SectorToCluster,EAX
;    CALL    PrintInt,EAX
    XOR AX,AX
    MOV FS,AX

    MOV EAX,FS:[13h*4]
    MOV CS:[OldInt13],EAX

    CLI
    MOV AX,CS
    SHL EAX,16
    MOV AX,(Int13Mon)

    MOV FS:[13h*4],EAX
    STI

    MOV DX,(MyCodeEnd)
    INT 27h

 i13MonDone:
    MOV AX,4C00h
    INT 21h

Int13Mon:
    PUSH    ESI
    PUSHF

    CMP DL,80h
    JNZ i13Invoke

    CMP AH,42h
    JZ  i13Read

;    CMP AH,43h
;    JZ  i13Read

;    CMP AH,3
;    JZ  i13CHS

    CMP AH,2
    JNZ i13Invoke

 i13CHS:

    PUSH    AX,CX,DX
    MOVZX   AX,CL   ;Sector
    SHR CL,6
    ROR CX,8        ;Cyl
    MOVZX   DX,DH   ;Head

    CALL    ToLBA,AX,DX,CX
    MOV ESI,EAX
    POP DX,CX,AX
    JMP i13Read
 i13xRead:
    MOV ESI,[SI].dpSector
 i13Read:
    PUSH    EAX

    PUSH    BP
    MOV BP,SP
    AND BYTE [BP][4][8],NOT 1   ;Reset original CF
    POP BP

    CALL    GetTicks
    MOV CS:[FirstTick],EAX

    POP EAX

    CALL    DWORD CS:[OldInt13]

    PUSH    EAX
    JNC i13ReadOK

    PUSH    BP
    OR  BYTE [BP][4][4],1       ;Set CF
    POP BP
    JMP i13Delay

 i13ReadOK:
    CALL    GetTicks

    SUB EAX,CS:[FirstTick]
    CMP EAX,5
    JB  i13IRet

    MOV EAX,[SI].dpSector
    CMP EAX,CS:[DataSector]
    JB  i13IRet

 i13Delay:
    PUSHAD
    MOV AX,0E07h
    INT 10h
    POPAD

    PUSH    EDX

    MOV AH,0
    MOV DL,80h
    INT 13h

    MOV EAX,[SI].dpSector
    MOV EDX,[SI][4].dpSector
    CALL    SectorToCluster,EAX

    CALL    DrPrint,EAX,EDX,0

    MOVZX   EAX,WORD [SI].dpNumSectors
    XOR EDX,EDX
    CALL    DrPrint,EAX,EDX,10

    POP EDX
 i13IRet:
    POP EAX
    POP ESI
    IRET
 i13Invoke:
    POPF
    POP ESI
    JMP     DWORD CS:[OldInt13]

GetTicks:
    PUSH    ES
    XOR EAX,EAX
    MOV ES,AX
    MOV EAX,ES:[46Ch]
    POP ES
    RET

DrPrint PROC    dpValue:QWORD,dpOffset:WORD
    PUSH    ES
    PUSH    AX,CX,DI
    PUSH    EDX

    MOV AX,0B800h
    MOV ES,AX

    MOV DI,[dpOffset]
    SHL DI,1
    MOV EDX,[dpValue]   ;[4]
    MOV AH,7

    MOV CX,208h

    ADD DI,0A0h

 dpLoop:
    ROL EDX,4
    MOV AL,DL
    AND AL,0Fh
    ADD AL,30h
    CMP AL,39h
    JBE dpLoopShow
    ADD AL,7
 dpLoopShow:
    STOSW
    DEC CL
    JNZ dpLoop
    MOV EDX,[dpValue]
    MOV CL,8
    DEC CH
;    JNZ dpLoop

    MOV EAX,0720_0720h
    STOSD
    STOSD

    POP EDX
    POP DI,CX,AX
    POP ES
    RET
DrPrint ENDP

ToCHS   PROC    tcSector:DWORD    
    MOV EAX,[tcSector]
    XOR EDX,EDX
    DIV [SPT]           ;SectorNum=Mod(Sector/SPT)
    MOV EBX,EDX         ;SectorNum
    XOR EDX,EDX
    DIV [Heads]         ;HeadNum=Mod((Sector/SPT)/NumHeads)
    XCHG    EAX,EBX
    MOV ECX,EDX         ;Cyl=Sector/SPT/NumHeads
    RET    
ToCHS   ENDP

ToLBA   PROC    tlSector:WORD,tlHead:WORD,tlCylinder:WORD
    PUSH    EBX,ECX,EDX

    MOVZX   EAX,[tlHead]    ;Head*SectorsPerTrack
    MOVZX   EBX,[tlSector]
    MOV ECX,[SPT]
    MUL ECX
    ADD EBX,EAX             ;+SectorsPerTrack

    MOV EAX,[Heads]         ;CylinderSize=NumHeads*SectorsPerTrack
    MUL ECX
    MOVZX ECX,WORD [tlCylinder] ;TotalCylinderSize=CylinderSize*CylinderNum
    MUL ECX
    ADD EAX,EBX

    POP EDX,ECX,EBX
    RET
ToLBA   ENDP

INCLUDE "FAT.ASM"
INCLUDE "DISK.ASM"
INCLUDE "INT13.ASM"
INCLUDE "PRINT.ASM"
INCLUDE "STR32.ASM"
INCLUDE "MATH64.ASM"
;INCLUDE "PATH.ASM"

INCLUDE "SCAN.AS"
DiskStruc   DB  (SIZE DiskStruct) DUP(0)
DiskParams  DB  (SIZE DiskParam)  DUP(0)
FirstTick   DD  ?
OldInt13    DD  ?

Heads       DD  ?
Cyl         DD  ?
SPT         DD  ?

INCLUDE "SCAN.8"
MyCodeEnd:
