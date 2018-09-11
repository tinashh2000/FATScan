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

    CLI
    XOR EAX,EAX
    MOV FS,EAX

    MOV AX,CS
    SHL EAX,16
    PUSH    EAX
    MOV AX,(NewInt25)

    XCHG    EAX,FS:[25h*4]
    MOV CS:[OldInt25],EAX
    POP EAX
    PUSH    EAX
    MOV AX,(NewInt26)
    XCHG    EAX,FS:[26h*4]
    MOV CS:[OldInt26],EAX

    POP EAX
    MOV AX,(NewInt13)
    XCHG    EAX,FS:[13h*4]
    MOV CS:[OldInt13],EAX

    STI
    MOV DX,(ProgEnd+100h)
    INT 27h

NewInt13:
    PUSHF
    CALL    DWORD CS:[OldInt13]
    JNC  NewInt13OK
    INT 3

    PUSHF
    PUSHAD
    MOV AH,0
    PUSHF
    CALL    DWORD CS:[OldInt13]
    POPAD
    POPF

 NewInt13OK:
    PUSH    BP
    MOV BP,SP
    PUSHF
    POP WORD [BP][6]
    POP BP

    IRET

NewInt25:
    PUSHF
    CALL    DWORD CS:[OldInt25]
    LEA SP,[ESP][2]
    JC  NewIntError
 NewIntDone:
    PUSH    BP
    MOV BP,SP
    PUSHF
    POP WORD [BP][6]
    POP BP
    RETF
NewInt26:
    PUSHF
    CALL    DWORD CS:[OldInt26]
    LEA SP,[ESP][2]
    JNC NewIntDone
 NewIntError:
    PUSHF
    PUSHAD
    MOV AH,0
    MOV DL,81h
    PUSHF
    CALL    DWORD CS:[OldInt13]
    POPAD
    POPF

    PUSH    BP
    MOV BP,SP
    PUSHF
    POP WORD [BP][6]
    POP BP

    RETF

OldInt13    DD  ?
OldInt25    DD  ?
OldInt26    DD  ?
ProgEnd:
