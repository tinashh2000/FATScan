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

BIOSGetParam    PROC
    PUSH    ES,DI
    PUSH    EBX,ECX,EDX

    MOV AH,48h
    MOV [SI].dspSize,1Ah
    INT 13h
    JC  bgpError

    TEST    BYTE [SI].dspFlags,2
    CLC
    JNZ bgpDone

    MOV AH,8
    XOR DI,DI
    MOV ES,DI
    INT 13h
    JC  bgpError

    MOV BL,CL
    AND BL,3Fh
    SHR CL,6
    XCHG    CH,CL

    XOR EAX,EAX
    MOV AL,BL
    MOV [SI].dspSectorsPerTrack,EAX

    MOV AL,DH
    INC AX
    MOV [SI].dspHeads,EAX

    MOV AX,CX
    INC AX
    MOV [SI].dspCylinders,EAX
    JMP bgpDone

 bgpError:
    CMP AH,2        ;Func not supported
    STC
    JA bgpDone

    MOV AH,8
    XOR DI,DI
    MOV ES,DI
    INT 13h

    MOV BL,CL
    AND BL,3Fh
    SHR CL,6
    XCHG    CH,CL

    XOR EAX,EAX
    MOV AL,BL
    MOV [SI].dspSectorsPerTrack,EAX

    MOV AL,DH
    MOV [SI].dspHeads,EAX

    MOV AX,CX
    MOV [SI].dspCylinders,EAX

    MOVZX   AX,BL
    MUL [SI].dspHeads
    MUL [SI].dspCylinders
    MOV [SI].dspSectors,EAX
    CLC
 bgpDone:
    POP EDX,ECX,EBX
    POP DI,ES
    RET
BIOSGetParam    ENDP

BIOSRead    PROC
    PUSH    BX,CX,DX
    TEST    BYTE [ScanMode][1],CHSMODE
    JNZ brCHS
    MOV AH,41h
    MOV BX,55AAh
    INT 13h
    JC  brCHS
    CMP BX,0AA55h
    JNZ brCHS
    TEST    CL,1
;    JNZ brCHS
    MOV AH,42h
    INT 13h
    JMP brDone
 brCHS:
    PUSH    ES    
    MOV EAX,[SI].dpSector
    CALL    CalcCHS,EAX
    LES BX,[SI].dpBuffer
    MOV AH,2
    MOV AL,[SI].dpNumSectors
    INT 13h
    POP ES
 brDone:
    POP DX,CX,BX
    RET
BIOSRead    ENDP

BIOSWrite   PROC
    PUSH    BX,CX,DX
    TEST    BYTE [ScanMode][1],CHSMODE
    JNZ bwCHS
    MOV AH,41h
    MOV BX,55AAh
    INT 13h
    JC  bwCHS
    CMP BX,0AA55h
    JNZ bwCHS
    TEST    CL,1
    JNZ bwCHS
    MOV AH,43h
    INT 13h
    JMP bwDone
 bwCHS:
    PUSH    ES    
    MOV EAX,[SI].dpSector
    CALL    CalcCHS,EAX
    LES BX,[SI].dpBuffer
    MOV AH,3
    MOV AL,[SI].dpNumSectors
    INT 13h
    POP ES
 bwDone:
    POP DX,CX,BX
    RET
BIOSWrite   ENDP
