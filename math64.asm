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

Mul64   PROC    m64Multiplier:DWORD
    PUSH    EBX
    PUSH    EAX
    MOV EAX,EDX
    MUL [m64Multiplier]
    MOV EBX,EAX
    POP EAX
    MUL [m64Multiplier]
    ADD EDX,EBX
    POP EBX
    RET
Mul64   ENDP

Div64   PROC    d64Divisor:DWORD
    PUSH    EBX
    PUSH    EAX
    MOV EAX,EDX
    XOR EDX,EDX
    DIV [d64Divisor]
    MOV EBX,EAX
    POP EAX
    DIV [d64Divisor]
    MOV EDX,EBX
    POP EBX
    RET
Div64   ENDP
