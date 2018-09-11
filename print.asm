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

PrintInt    PROC    piNumber:DWORD
    PUSHAD
    PUSH    ES
    PUSH    DS
    POP ES
    MOV EAX,[piNumber]
    CALL    NumToStrD
    CALL    PrintStr,ESI
    POP ES
    POPAD
    RET
PrintInt    ENDP

PrintCommaInt   PROC    piNumber:DWORD
    PUSHAD
    PUSH    ES
    PUSH    DS
    POP ES
    MOV EAX,[piNumber]
    CALL    NumToStrD
    MOV EAX,3
    CALL    CommaNumber
    CALL    PrintStr,ESI
    POP ES
    POPAD
    RET
PrintCommaInt   ENDP

PrintInt64  PROC    pi64Pointer:DWORD
    PUSHAD
    PUSH    ES
    PUSH    DS
    POP ES
    MOV EDX,[pi64Pointer]
    MOV EAX,[EDX]
    MOV EDX,[EDX][4]
    CALL    NumToStrQ
    CALL    PrintStr,ESI
    POP ES
    POPAD
    RET
PrintInt64  ENDP

PrintCommaInt64  PROC    pi64Pointer:DWORD
    PUSHAD
    PUSH    ES
    PUSH    DS
    POP ES
    MOV EDX,[pi64Pointer]
    MOV EAX,[EDX]
    MOV EDX,[EDX][4]
    CALL    NumToStrQ
    MOV EAX,3
    CALL    CommaNumber
    CALL    PrintStr,ESI
    POP ES
    POPAD
    RET
PrintCommaInt64  ENDP

PrintHex:
    PUSHAD
    PUSH    ES
    PUSH    DS
    POP ES
    CALL    HexToStrD
    MOV AL,0
    STOSB
    CALL    PrintStr,(PrintBuffer)
    POP ES
    POPAD
    RET

PrintStr    PROC    psSource:DWORD
LOCAL   psNumBytes:DWORD
    PUSHAD
    PUSH    ES
    PUSH    DS
    POP ES
    MOV EDI,[psSource]
    MOV ECX,-1
    MOV AL,0
    REPNZ   SCASB
    NOT ECX
    DEC ECX

    MOV DX,[psSource]
    MOV DI,CX
    ADD DI,DX
    MOV AL,"$"
    XCHG    AL,[DI]
    PUSH    AX
    MOV AH,9
    INT 21h
    POP AX
    MOV [DI],AL
    POP ES    
    POPAD
    RET
PrintStr    ENDP

PrintLF:
    CALL    PrintStr,DWORD (_LF)
    RET

PrintDriveInfo:
;    CALL    PrintInt,[SI].dspCylinders
;    CALL    PrintStr,DWORD (_Cylinders)

;    CALL    PrintInt,[SI].dspHeads
;    CALL    PrintStr,DWORD (_Heads)

;    CALL    PrintInt,[SI].dspSectorsPerTrack
;    CALL    PrintStr,DWORD (_SectorsPerTrack)

    LEA EAX,[SI].dspSectors
    CALL    PrintInt64,EAX
    CALL    PrintStr,DWORD,(_Sectors)

    MOVZX   EAX,WORD [SI].dspBytesPerSector
    CALL    PrintInt,EAX
    CALL    PrintStr,DWORD (_BytesPerSector)

;    INT 3
;    NOP
;    MOV EAX,[SI].dspHeads
;    MUL [SI].dspSectorsPerTrack

;    CALL    Mul64,[SI].dspCylinders
;    CALL    Mul64,[SI].dspBytesPerSector

    MOV EAX,[SI].dspSectors
    MOV EDX,[SI][4].dspSectors
    MOVZX ECX,WORD [SI].dspBytesPerSector
    CALL    Mul64,ECX

    PUSH    EDX
    PUSH    EAX
    CALL    PrintCommaInt64,ESP
    CALL    PrintStr,DWORD (_Bytes)
    MOV AL,"("
    CALL    PrintChar
    POP EAX
    POP EDX
    CALL    Div64,DWORD (1048576)
    PUSH    EDX
    PUSH    EAX
    CALL    PrintCommaInt64,ESP
    ADD ESP,8
    CALL    PrintStr,DWORD (_MB)
    MOV AL,")"
    CALL    PrintChar
    CALL    PrintLF
    RET

PrintChar:
    MOV AH,0Eh
    INT 10h
    RET

GetCursor:
    PUSH    AX,BX
    MOV AH,3
    MOV BH,0
    INT 10h
    POP BX,AX
    RET

SetCursor   PROC    scX:WORD,scY:WORD
    PUSH    AX,BX,DX
    MOV DL,[scX]
    MOV DH,[scY]
    MOV AH,2
    MOV BH,0
    INT 10h
    POP DX,BX,AX
    RET
SetCursor   ENDP

PrintCluster    PROC    pcCluster:DWORD    
    MOV AL,20h
    CALL    PrintChar
    MOV AL,"("
    CALL    PrintChar
    CALL    PrintInt,[pcCluster]
    MOV AL,")"
    CALL    PrintChar
    RET
PrintCluster    ENDP

PrintBadCluster PROC    pbcCluster:DWORD
    CALL    PrintInt,[pbcCluster]
    CALL    PrintStr,DWORD (_Bad)
    CALL    PrintLF
    RET
PrintBadCluster ENDP


Choice   PROC   gccString:DWORD,gccOptions:DWORD
    PUSH    EBX,ESI,EDI
    CALL    PrintStr,[gccString]
    MOV EDI,[gccOptions]
    MOV AL,[DI]
    CALL    PrintChar
    MOV BL,1
 gcGetChoice:
;    MOV AH,0
;    INT 16h
    CALL    GetChar
    CMP AL,0Dh
    JZ  gcDone
    MOV BH,1
    MOV SI,DI
    AND AL,NOT 20h
    MOV AH,AL
 gcCompare:
    LODSB
    CMP AL,0
    JZ  gcError
    CMP AL,AH
    JZ  gcNewChoice
    INC BH
    JMP gcCompare
 gcError:
    MOV AX,0E07h
    INT 10h
    JMP gcGetChoice
 gcNewChoice:
    MOV AX,0E08h
    INT 10h
    MOV AL,[SI][-1]
    CALL    PrintChar
    MOV BL,BH
    JMP gcGetChoice
 gcDone:
    MOV AL,BL
    POP EDI,ESI,EBX
    RET
Choice   ENDP

GetChar:
    PUSH    DX
    MOV AH,7
    INT 21h
    POP DX
    RET
