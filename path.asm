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

FormatPath  PROC    fpSource:DWORD,fpDest:DWORD
    PUSH    BX,CX,SI,DI
    PUSH    ES
    MOV SI,[fpSource]
    MOV DI,[fpDest]
    LEA BX,[DI][8]
    MOV CX,8
    PUSH    DS
    POP ES
 fpTestSlash:
    CMP BYTE [SI],"\"
    JNZ fpLoop
    INC SI
    JMP fpTestSlash
 fpLoop:
    LODSB
    CMP AL,20h
    JZ  fpEnd
    CMP AL,0
    JZ  fpEnd
    CMP AL,"*"
    JZ  fpAster
    CMP AL,"\"
    JZ  fpEnd
    STOSB
    DEC CX
    JNZ fpLoop
    JMP fpExt
 fpAster:
    MOV AL,"?"
    REP STOSB
 fpExt:
    MOV CX,BX
    SUB CX,DI
    MOV AL,20h
    REP STOSB
    MOV CX,3
 fpExtLoop:
    LODSB
    CMP AL,"*"
    JZ  fpExtAster
    CMP AL,0
    JZ  fpEnd
    CMP AL,"\"
    JZ  fpEnd
    CMP AL,20h
    JZ  fpEnd
    STOSB
    DEC CX
    JNZ fpExtLoop
    JMP fpEnd
 fpExtAster:
    MOV AL,"?"
    REP STOSB
 fpEnd:
    LEA CX,[BX][3]
    SUB CX,DI
    MOV AL,20h
    REP STOSB
    MOV AL,0
    STOSB
    POP ES
    XOR EAX,EAX
    DEC SI
 fpFindEnd:
    LODSB
    CMP AL,0
    JZ  fpEndOK
    CMP AL,"\"
    JZ  fpEndOK
    JMP fpFindEnd
 fpEndOK:
    XOR EAX,EAX
    LEA AX,[SI][-1]
    POP DI,SI,CX,BX
    RET
FormatPath  ENDP

PathPrevious    PROC    ppFlag:WORD
    PUSH    ES
    PUSH    ECX,EDI
    PUSH    DS
    POP ES
    MOV AL,"\"
    MOV ECX,[PathLen]
    MOV EDI,ECX
    ADD EDI,(CurPath-1)
    STD
    REPNZ   SCASB
    CLD
    MOV [PathLen],ECX
    MOV BYTE [EDI][1],0

    TEST    [ppFlag],1
    JNZ ppPrevDir
;     CALL    RecoverFileDone
    JMP ppDone
 ppPrevDir:
;    CALL    RecoverPrevDir
 ppDone:
    POP EDI,ECX
    POP ES
    RET
PathPrevious    ENDP

PathNext:
    PUSH    ES
    PUSH    DS
    POP ES
    PUSH    EBX,ECX,ESI,EDI
    MOV ECX,8
    MOV EDI,[PathLen]
    ADD EDI,(CurPath)
    MOV AL,"\"
    STOSB
    MOV BX,DI
    PUSH    WORD FS:[SI].feAttr
    PUSH    ESI
 pnProcess:
    LODS    BYTE FS:[SI]
    CMP AL,20h
    JZ  pnExt
    STOSB
    DEC CX
    JNZ pnProcess
 pnExt:
    POP ESI
    ADD ESI,8
    CMP BYTE FS:[SI],20h
    JZ  pnPathOK
    MOV AL,"."
    STOSB
    MOV CX,3
 pnExtLoop:
    LODS    BYTE FS:[SI]
    CMP AL,20h
    JZ  pnPathOK
    STOSB
    DEC CX
    JNZ pnExtLoop
 pnPathOK:
    MOV ECX,EDI
    SUB ECX,(CurPath)
    MOV [PathLen],ECX
    MOV AL,0
    STOSB
    POP AX
    TEST    AX,FAT_FILE_DIRECTORY
    JNZ pnNewDir
    CALL    RecoverNewFile,BX
    JMP pnDone
 pnNewDir:
    CALL    RecoverNewDir,BX
 pnDone:
    POP EDI,ESI,ECX,EBX
    POP ES
    RET

PrintPath:
    PUSHAD
    CALL    SetCursor,[CurX],[CurY]
    CALL    PrintStr,DWORD (CurPath)

    CALL    GetCursor
    MOV DH,0
    SUB DX,80*4
    NEG DX
    MOV AX,0920h
    MOV BX,7
    MOVZX   ECX,DX
    INT 10h
    POPAD
    RET
