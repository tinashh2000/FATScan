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

UCaseStr:
    TEST    ECX,ECX
    JZ  UCaseStrDone
    PUSH    EBX
    MOV EBX,OFFSET UCaseTbl
UCaseStrLoop:
    LODSB
    CS:
    XLAT
    STOSB
    DEC CX
    JNZ UCaseStrLoop
    POP EBX
UCaseStrDone:
    RET

NumToStrD:
    MOV EDI,OFFSET PrintBuffer+11
    MOV ECX,EDI
    MOV EBX,10
    MOV BYTE ES:[EDI],0
    JMP ntsdCheckNum
NumToStrDLoop:
    XOR EDX,EDX
    DIV EBX
    ADD DL,30h
    DEC EDI
    MOV ES:[EDI],DL
ntsdCheckNum:
    CMP EAX,9
    JA  NumToStrDLoop
    ADD AL,30h
    DEC EDI
    MOV ES:[EDI],AL
    MOV ESI,EDI
    SUB ECX,ESI
    RET

NumToStrQ:
    PUSH    EAX,EBX,EDX,EDI
    MOV EDI,(PrintBuffer+32)
    MOV EBX,10
    ADD EDI,26
    MOV ECX,EDI
    MOV BYTE ES:[EDI],0
    JMP ntsqCheckNum
ntsqLoop:
    PUSH    EAX
    MOV EAX,EDX
    XOR EDX,EDX
    DIV EBX
    MOV ESI,EAX
    POP EAX
    DIV EBX
    ADD DL,30h
    DEC EDI
    MOV ES:[EDI],DL
    MOV EDX,ESI
ntsqCheckNum:
    TEST    EDX,EDX
    JNZ ntsqLoop
    CMP EAX,9
    JA ntsqLoop
    ADD AL,30h
    DEC EDI
    MOV ES:[EDI],AL
    MOV ESI,EDI
    SUB ECX,ESI
    POP EDI,EDX,EBX,EAX
    RET

HexToStrD:
    MOV EDI,OFFSET PrintBuffer
HexToStrD2:
    PUSH    EBX
    MOV ESI,EDI
    MOV CL,4
    MOV CH,8
    MOV EBX,EAX
    MOV AL,'0'
    STOSB
HexToStrDLoop:
    ROL EBX,CL
    MOV AL,BL
    AND AL,0x0F     ;Get lower 4-Bits
    CMP AL,0x0A     ;Is AL < 10
    MOV AH,0xFF     ;Prepare mask
    ADC AH,0        ;AH=0 IF < 10 but 0xFF IF >=10
    AND AH,0x07     ;IF AH was 0, it remains. IF it was FF it becomes 0x07
    ADD AH,0x30     ;ADD 30.
    ADD AL,AH       ;Store it
    STOSB
    DEC CH
    JNZ HexToStrDLoop
    MOV ECX,EDI
    SUB ECX,ESI
    POP EBX
    RET

CommaNumber PROC
    PUSH    EAX,EDX,EDI,ES
    PUSHF
    CMP EAX,ECX
    JAE cnDone
    MOV EDI,EAX
    MOV EAX,ECX
    XOR EDX,EDX
    DIV EDI
    TEST    EAX,EAX
    JZ  cnDone
    
    MOV EDX,EDI
    LEA ESI,[ESI][ECX][-1]
    LEA EDI,[EAX][ESI]
    MOV BYTE [EDI][1],0
    PUSH    DS
    POP ES
    PUSH    EDI
    MOV AL,","
    STD
 cnLoop:
    PUSH    ECX
    MOV ECX,EDX
    REP MOVSB
    POP ECX
    STOSB
    SUB ECX,EDX
    CMP ECX,EDX
    JA  cnLoop
    REP MOVSB
    LEA ESI,[EDI][1]
    POP ECX
    SUB ECX,ESI
 cnDone:
    POPF
    POP ES,EDI,EDX,EAX
    RET
CommaNumber ENDP
