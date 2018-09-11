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

ScanDrive:    
    CALL    PrintLF
    CALL    PrintLF
    CALL    ReadDSSector,DWORD (0),DWORD (1)
    MOV EBX,(DiskBuffer)
    MOV EDI,(_Choices)
    MOV ECX,(PartTypes)
    MOV DWORD [ExtBase],0
    MOV DWORD [FirstExt],0
 scGetCode:
    MOV AL,[EBX].mbrFileSysCode
    CMP AL,0
    JZ  scNext
    CMP AL,1
    JZ  scFat12
    CMP AL,4
    JZ  scFat16
    CMP AL,5
    JZ  scExt
    CMP AL,6
    JZ  scFat16
    CMP AL,0Bh
    JZ  scFat32
    CMP AL,0Ch
    JZ  scFat32
    CMP AL,0Eh
    JZ  scFat32
    JMP scNext
 scExt:
    MOV EAX,[EBX].mbrBeginAbsSector
    PUSH    EAX
    CALL    ReadDSSector,EAX,DWORD (1)
    POP EAX
    XCHG    EAX,[ExtBase]

    MOV EDX,DWORD [ExtTrackPTR]
    MOV [EDX],EAX
    MOV [EDX][4],EBX

    ADD DWORD [ExtTrackPTR],8
    MOV EBX,(DiskBuffer)

    INC [ExtPart]
    CMP [ExtPart],1
    JA  scGetCode
    MOV EAX,[ExtBase]
    MOV [FirstExt],EAX
    JMP scGetCode
 scFat12:
    MOV EDX,(_FAT12)
    JMP scPrintPartType
 scFat16:
    MOV EDX,(_FAT16)
    JMP scPrintPartType
 scFat32:
    MOV EDX,(_FAT32)
 scPrintPartType:
    MOV [ECX][8],AL
    MOV EAX,[EBX].mbrBeginAbsSector
    ADD EAX,[FirstExt]
    MOV [ECX],EAX
    MOV EAX,[EBX].mbrTotalAbsSector
    MOV [ECX][4],EAX
    ADD ECX,12

    CALL    PrintStr,EDI
    ADD EDI,4
    CALL    PrintStr,EDX
    MOV EAX,[EBX].mbrBeginAbsSector
    ADD EAX,[FirstExt]
    CALL    PrintCommaInt,EAX
    MOV AL,"-"
    CALL    PrintChar
    MOV EAX,[EBX].mbrBeginAbsSector
    ADD EAX,[FirstExt]
    ADD EAX,[EBX].mbrTotalAbsSector
    CALL    PrintCommaInt,EAX

    CMP [EBX].mbrBootFlag,80h
    JNZ scpptBootOK
    CALL    PrintStr,DWORD (_Bootable)
 scpptBootOK:
    CALL    PrintLF
 scNext:
    ADD EBX,16
    CMP EBX,(DiskBuffer+64)
    JB  scGetCode
    CMP [ExtPart],0
    JZ  scGetPart
    DEC [ExtPart]
    MOV EDX,[ExtTrackPTR]
    SUB EDX,8
    MOV EAX,[EDX]       ;Sector
    MOV EBX,[EDX][4]    ;EBX pointer
    MOV [ExtBase],EAX
    CALL    ReadDSSector,EAX,DWORD (1)
    JMP scNext
 scGetPart:
    SUB ECX,(PartTypes)
    JBE scNoPart
    MOV BYTE [_sdrvEnd][-2],"1"
    CALL    PrintStr,DWORD (_SelectDrive)
    MOV EAX,ECX
    XOR EDX,EDX
    MOV EBX,12
    DIV EBX
    MOV ECX,EAX
    ADD CL,48
 scGetLoop:
;    MOV AH,0
;    INT 16h
    CALL    GetChar
    CMP AL,27
    JZ  scExit
    CMP AL,13
    JZ  scSelect
    CMP AL,"1"
    JB  scBeep
    CMP AL,CL
    JA  scBeep
    PUSH    AX
    SUB AL,"1"
    MOV [Partition],AL

    MOV AX,0E08h
    INT 10h
    POP AX
    MOV AH,0Eh
    INT 10h
    JMP scGetLoop

 scBeep:
    MOV AX,0E07h
    INT 10h
    JMP scGetLoop
 scNoPart:
    CALL    PrintStr,DWORD (_NoPartitions)
 scExit:
    STC
    RET

 scSelect:
    CALL    PrintLF
    MOVZX   EDI,[Partition]
    IMUL    EDI,EDI,12
    ADD EDI,(PartTypes)

    MOV EAX,[EDI]
    MOV ECX,[EDI][4]
    PUSH    EAX,ECX
    CALL    ReadDSSector,EAX,DWORD (1)
    POP ECX,EAX
    JC  scDone

    MOV EBX,(DiskBuffer)
    MOV [PartStart],EAX
    CALL    DetectFAT,EAX,ECX
    JC  scDone
    CALL    ScanDisk
 scDone:
    RET


BrowseDisk  PROC
    XOR EAX,EAX
 brLoop:
    PUSH    EAX
    CALL    ReadFSSector,EAX,DWORD (7Fh)

    XOR EAX,EAX
 FindClue:
    CMP WORD FS:[EAX],0FFF8h
;    JZ  ffClue

    CMP WORD FS:[EAX][32],".."
;    JZ  ffClue

    CMP DWORD FS:[EAX][3],"IWSM"
;    JZ  ffClue
    MOV ESI,EAX
    PUSH    EAX

    FS:LODSB
    CMP AL,20h
    JB  ffResume
    CMP AL,"Z"
    JA  ffResume
    
    FS:LODSB
    CMP AL,20h
    JB  ffResume
    CMP AL,"Z"
    JA  ffResume

    FS:LODSB
    CMP AL,20h
    JB  ffResume
    CMP AL,"Z"
    JA  ffResume
    POP EAX
    MOV FS:[SI][10],0
    PUSH    EAX

    PUSH    DS

    PUSH    FS
    POP DS
    CALL    PrintStr,EAX
    POP DS
    CALL    PrintLF
    MOV AH,0
    INT 16h
    CMP AL,27
    POP EAX
    JNZ ffX
    JMP ffX
 ffResume:
    POP    EAX
 ffX:
    ADD EAX,200h
    CMP EAX,10000h
    JB  FindClue
    POP EAX
    ADD EAX,7Fh
    CMP EAX,17500
    JBE brLoop
    RET

 ffClue:
    JMP ffResume
BrowseDisk  ENDP
