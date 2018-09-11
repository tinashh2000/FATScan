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

RecoverNewDir   PROC    rndDir:WORD
    PUSH    AX,BX,DX
    TEST    BYTE [ScanMode],80h
    JZ      rndDone
    MOV     AH,39h
    MOV     DX,[rndDir]
    INT     21h

    MOV     AH,3Bh
    MOV     DX,[rndDir]
    INT     21h

 rndDone:
    POP DX,BX,AX
    RET
RecoverNewDir   ENDP

RecoverPrevDir  PROC
    PUSH   AX,DX
    TEST    BYTE [ScanMode],80h
    JZ      rpdDone

    MOV     AH,3Bh
    MOV     DX,(_DotDot)
    INT     21h

 rpdDone:
    POP DX,AX
    RET
RecoverPrevDir  ENDP

RecoverNewFile  PROC    rnfFile:WORD
    PUSH    AX,DX
    TEST    BYTE [ScanMode],80h
    JZ      rnfDone
    MOV     AX,3D00h
    MOV     DX,[rnfFile]
    INT     21h
;    JNC     rnfExists
 rnfCreate:
    XOR     CX,CX
    MOV     AH,3Ch
    MOV     DX,[rnfFile]
    INT     21h
    MOV     [RecoverHandle],AX
 rnfDone:
    MOV DWORD [RecoverSize],0
    POP DX,AX
    RET
 rnfExists:
    JMP     rnfDone
RecoverNewFile  ENDP

RecoverWriteFile    PROC    rwfBuffer:DWORD,rwfNumBytes:WORD
    PUSH    AX,BX,ECX,DX,ESI
    TEST    BYTE [ScanMode],80h
    JZ      rwfDone
    PUSH    DS
    MOV     AH,40h
    MOV     BX,[RecoverHandle]
    MOVZX   ECX,WORD [rwfNumBytes]
    MOV ESI,ECX
    ADD ESI,[RecoverSize]
    CMP ESI,[CurFileSize]
    JBE rwfSizeOK
    MOV ECX,[CurFileSize]
    SUB ECX,[RecoverSize]
 rwfSizeOK:
    ADD [RecoverSize],ECX
    LDS     DX,[rwfBuffer]
    INT     21h
    POP     DS
 rwfDone:
    POP    ESI,DX,ECX,BX,AX
    RET
RecoverWriteFile    ENDP

RecoverFATError     PROC
    PUSH    AX,BX
    TEST    BYTE [ScanMode],80h
    JZ      rfeDone
    CMP WORD [RecoverHandle],0
    JZ  rwfDone
    MOV     AH,3Eh
    MOV     BX,[RecoverHandle]
    INT     21h
 rfeDone:
    MOV WORD [RecoverHandle],0
    POP BX,AX
    RET
RecoverFATError     ENDP

RecoverFileDone PROC
    PUSH    AX,BX
    TEST    BYTE [ScanMode],80h
    JZ      rfdDone
    CMP WORD [RecoverHandle],0
    JZ  rfdDone
    MOV     AH,3Eh
    MOV     BX,[RecoverHandle]
    INT     21h
 rfdDone:
    MOV WORD [RecoverHandle],0
    POP BX,AX
    RET
RecoverFileDone ENDP
