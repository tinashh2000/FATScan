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

LINK_ENTRYSIZE  =   12

.LANG STDCALL

INCLUDE "INT13.INC"
INCLUDE "DISK.INC"
INCLUDE "FAT.INC"
INCLUDE "SCAN.INC"
    MOV AX,3
    INT 10h    

    MOV DI,(Uninit)
    XOR EAX,EAX
    MOV CX,(UninitEnd)
    SUB CX,DI
    SHR CX,2
    REP STOSD

    OR  BYTE [ScanMode][1],2

    CALL    PrintStr,DWORD (_Prog)
    MOV SI,80h
    LODSB
    CMP AL,0
    JZ  ArgOK
 GetArg:
    LODSB
    CMP AL,"/"
    JZ  GetOption
    CMP AL,"-"
    JZ  GetOption
    CMP AL,0Dh
    JZ  ArgOK
    CMP AL,32
    JBE GetArg
    LEA AX,[SI][-1]
    XCHG    [PathPTR],AX
    TEST    AX,AX
    JNZ Usage
    OR  BYTE [ScanMode],2
 GetInitPath:
    LODSB
    CMP AL,0Dh
    JZ  ArgOK
    CMP AL,0
    JZ  ArgOK
    CMP AL,32
    JBE GetArg
    JMP GetInitPath

 GetOption:
    LODSB
    OR  AL,20h
    CMP AL,"c"
    JZ  goByCluster
    CMP AL,"f"
    JZ  goFreeOnly
    CMP AL,"a"
    JZ  goAllOnly
    CMP AL,"w"
    JZ  goWriteTest
    CMP AL,"r"
    JZ  goRecover
    CMP AL,"t"
    JZ  goRetest
    CMP AL,"b"
    JZ  goBackFAT
    CMP AL,"x"
    JZ  goX
 Usage:
    CALL    PrintStr,DWORD (_Usage)
    MOV AH,4Ch
    INT 21h

 goX:
    OR  BYTE [ScanMode][1],1
    JMP GetArg

 goRecover:
    OR  BYTE [ScanMode],80h
    JMP GetArg

 goBackFAT:
    OR  BYTE [ScanMode],20h
    JMP GetArg

 goRetest:
    OR  BYTE [ScanMode],40h
    JMP GetArg

 goWriteTest:
    OR  BYTE [ScanMode],10h
    JMP GetArg

 goByCluster:
    OR  BYTE [ScanMode],1
    JMP GetArg

 goFreeOnly:
    OR  BYTE [ScanMode],4
    JMP GetArg

 goAllOnly:
    OR  BYTE [ScanMode],8
    JMP GetArg

 ArgOK:
    MOV BYTE [SI][-1],0
    MOV AH,4Ah
    MOV BX,1000h
    PUSH    CS
    POP ES
    INT 21h

    MOV AH,48h
    MOV BX,2000h        ;128KB mem
    INT 21h
    JC  scMemError
    MOV FS,AX           ;Segment
    ADD AX,1000h
    MOV GS,AX           ;Second Segment

    MOV EDI,(_Choices)
    MOV BL,80h

 PrintDrivesLoop:
    CMP BL,85h
    JAE GetChoice
    MOV DL,BL
    MOV SI,(DiskParams)
    INC BL
    PUSH    BX
    CALL    BIOSGetParam
    POP BX
    JC  PrintDrivesLoop
    CALL    PrintStr,EDI
    ADD EDI,4
    CALL    PrintDriveInfo
    JMP PrintDrivesLoop

 GetChoice:
    CMP EDI,(_Choices)
    JZ  NoFixedDrives
    CALL    PrintStr,DWORD (_SelectDrive)
    MOV BYTE [Drive],80h
 gcLoop:
;    MOV AH,0
;    INT 16h
    CALL    GetChar
    CMP AL,27
    JZ  ScanDone
    CMP AL,0Dh
    JZ  ScanStart
    CMP AL,"1"
    JB  gcBeep
    CMP AL,"4"
    JA  gcBeep
    MOV AH,0Eh
    PUSH    AX
    MOV AL,08h  ;Backspace
    INT 10h
    POP AX
    INT 10h
    ADD AL,(80h-49)
    MOV [Drive],AL
    JMP gcLoop
 gcBeep:
    MOV AX,0E07h
    INT 10h
    JMP gcLoop
 scMemError:
    CALL    PrintStr,DWORD (_MemoryAllocationFail)
    JMP ScanDone
 NoFixedDrives:
    CALL    PrintStr,DWORD (_NoFixedDrives)
 ScanDone:
    MOV AH,4Ch
    INT 21h

 ScanStart:
    MOV SI,(DiskParams)
    MOV DL,[Drive]
    CALL    BIOSGetParam

    MOV EAX,[SI].dspHeads
    MOV [NumHeads],EAX

    MOV EAX,[SI].dspCylinders
    MOV [Cylinders],EAX

    MOV EAX,[SI].dspSectorsPerTrack
    MOV [SectorsPerTrack],EAX

    CALL    ScanDrive

    MOV AH,4Ch
    INT 21h

INCLUDE "PRINT.ASM"
INCLUDE "STR32.ASM"
INCLUDE "MAIN.ASM"
INCLUDE "FAT.ASM"
INCLUDE "DISK.ASM"
INCLUDE "INT13.ASM"
INCLUDE "MATH64.ASM"
INCLUDE "PATH.ASM"

INCLUDE "ACTION.ASM"
INCLUDE "FATDIR.ASM"
INCLUDE "FATFILE.ASM"
INCLUDE "RECOVER.ASM"

INCLUDE "SCAN.AS"
INCLUDE "SCAN.8"
ECHO $
