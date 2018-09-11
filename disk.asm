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

CalcCHS PROC    ccSector:DWORD
LOCAL ccHead:WORD,ccCyl:WORD,cccSector:WORD
    PUSH    EBX,ESI,EDI

    PUSH    EDX
    MOV ESI,[ccSector]

    MOV EBX,[SectorsPerTrack]
    MOV ECX,[NumHeads]
    XOR EDX,EDX
    MOV EAX,ESI
    DIV EBX     ;Sec/SPT
    MOV [cccSector],DX
    XOR EDX,EDX
    DIV ECX     ;TotalHeads/Heads
    MOV [ccHead],DX

    MOV [ccCyl],AX
    MOV CX,AX

    MOV AL,[cccSector]
    AND AL,3Fh
    INC AL

    AND CX,11_00000000b
    SHR CX,2
    OR  CL,AL
    MOV CH,[ccCyl]

    POP EDX
    MOV DH,[ccHead]

    POP EDI,ESI,EBX
    RET
CalcCHS ENDP

ReadFSSector    PROC    rsSector:DWORD,rsNumSectors:DWORD
LOCAL   rfsRemain:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI
    MOV SI,(DiskPacket)
    MOV [SI],(SIZE DiskStruct)

    MOV EAX,[rsSector]
    MOV DWORD [SI].dpSector,EAX

    MOV WORD [SI].dpBuffer,0
    MOV WORD [SI][2].dpBuffer,FS

    MOV EAX,[rsNumSectors]
    MOV [rfsRemain],EAX

 rfsReadIt:
    CMP EAX,7Fh
    JBE rfsSectorOK
    MOV EAX,7Fh
 rfsSectorOK:
    MOV [SI].dpNumSectors,AX
    SUB [rfsRemain],AX

    MOV DL,[Drive]
    CALL    BIOSRead

    JC rfsError

    CMP [rfsRemain],0
    CLC
    JZ  rfsDone

    ADD [SI].dpSector,7Fh
    ADD [SI][2].dpBuffer,0FE0h  ;0FE00h bytes
    MOV EAX,[rfsRemain]
    JMP rfsReadIt

 rfsError:
    PUSH    EAX
    PUSHF
    CALL    ResetDisk
    POPF
    POP EAX

 rfsDone:

    POP EDI,ESI,EDX,ECX,EBX
    RET
ReadFSSector    ENDP

WriteFSSector    PROC    wsSector:DWORD,wsNumSectors:DWORD
LOCAL   wfsRemain:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI
    MOV SI,(DiskPacket)
    MOV [SI],(SIZE DiskStruct)

    MOV EAX,[wsSector]
    MOV DWORD [SI].dpSector,EAX       ;Read MBR

    MOV WORD [SI].dpBuffer,0
    MOV WORD [SI][2].dpBuffer,FS

    MOV EAX,[wsNumSectors]
    MOV [wfsRemain],EAX

 wfsReadIt:
    CMP EAX,7Fh
    JBE wfsSectorOK
    MOV EAX,7Fh
 wfsSectorOK:
    MOV [SI].dpNumSectors,AX
    SUB [wfsRemain],AX

    MOV DL,[Drive]
    CALL    BIOSWrite

    JC wfsError

    CMP [wfsRemain],0
    CLC
    JZ  wfsDone
    ADD [SI].dpSector,7Fh
    ADD [SI][2].dpBuffer,0FE0h  ;0FE00h bytes
    MOV EAX,[wfsRemain]
    JMP wfsReadIt

 wfsError:
    PUSH    EAX
    PUSHF
    CALL    ResetDisk
    POPF
    POP EAX

 wfsDone:

    POP EDI,ESI,EDX,ECX,EBX
    RET
WriteFSSector    ENDP

ReadGSSector    PROC    rsSector:DWORD,rsNumSectors:DWORD
LOCAL   rgsRemain:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI
    MOV SI,(DiskPacket)
    MOV [SI],(SIZE DiskStruct)

    MOV EAX,[rsSector]
    MOV DWORD [SI].dpSector,EAX

    MOV WORD [SI].dpBuffer,0
    MOV WORD [SI][2].dpBuffer,GS

    MOV EAX,[rsNumSectors]
    MOV [rgsRemain],EAX

 rgsReadIt:
    CMP EAX,7Fh
    JBE rgsSectorOK
    MOV EAX,7Fh
 rgsSectorOK:
    MOV [SI].dpNumSectors,AX
    SUB [rgsRemain],AX

    MOV DL,[Drive]
    CALL    BIOSRead

    JC rgsError

    CMP [rgsRemain],0
    CLC
    JZ  rgsDone
    ADD [SI].dpSector,7Fh
    ADD [SI][2].dpBuffer,0FE0h  ;0FE00h bytes
    MOV EAX,[rgsRemain]
    JMP rgsReadIt
 rgsError:
    PUSH    EAX
    PUSHF
    CALL    ResetDisk
    POPF
    POP EAX

 rgsDone:

    POP EDI,ESI,EDX,ECX,EBX
    RET
ReadGSSector    ENDP

WriteGSSector    PROC    wsSector:DWORD,wsNumSectors:DWORD
LOCAL   wgsRemain:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI
    MOV SI,(DiskPacket)
    MOV [SI],(SIZE DiskStruct)

    MOV EAX,[wsSector]
    MOV DWORD [SI].dpSector,EAX

    MOV WORD [SI].dpBuffer,0
    MOV WORD [SI][2].dpBuffer,FS

    MOV EAX,[wsNumSectors]
    MOV [wgsRemain],EAX

 wgsReadIt:
    CMP EAX,7Fh
    JBE wgsSectorOK
    MOV EAX,7Fh
 wgsSectorOK:
    MOV [SI].dpNumSectors,AX
    SUB [wgsRemain],AX

    MOV DL,[Drive]
    CALL    BIOSWrite

    JC wgsError

    CMP [wgsRemain],0
    CLC
    JZ  wgsDone
    ADD [SI].dpSector,7Fh
    ADD [SI][2].dpBuffer,0FE0h  ;0FE00h bytes
    MOV EAX,[wgsRemain]
    JMP wgsReadIt
 wgsError:
    PUSH    EAX
    PUSHF
    CALL    ResetDisk
    POPF
    POP EAX

 wgsDone:

    POP EDI,ESI,EDX,ECX,EBX
    RET
WriteGSSector    ENDP

ReadDSSector    PROC    rsSector:DWORD,rsNumSectors:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI
    PUSH    ES

    PUSH    DS
    POP ES
    MOV SI,(DiskPacket)
    MOV WORD [SI],(SIZE DiskStruct)

    MOV WORD [SI].dpBuffer,(DiskBuffer)
    MOV WORD [SI][2].dpBuffer,DS

    MOV ECX,[DSSector]
    ADD ECX,[DSSectorCount]
    JZ  rdsNoCache

    MOV EBX,[rsSector]
    ADD EBX,[rsNumSectors]

    MOV EAX,[rsSector]

    CMP EAX,[DSSector]
    JB  rdsCacheAhead
    JZ  rdsCacheHit

    SUB EAX,ECX
    JAE rdsNoCache

 rdsCacheBehind:
    NEG EAX                 ;Sectors B4 rqsted sector
    MOV ECX,[DSSectorCount]
    SUB ECX,EAX             ;Sectors left in cache
    JBE rdsNoCache

    PUSH    ESI
    MOV EBX,[BytesPerSector]    ;Hw many bytes to throw away
    MUL EBX
    MOV EDI,(DiskBuffer)
    LEA ESI,[EAX][EDI]          ;ESI=First byte of new cache

    PUSH    ECX
    MOV EAX,[BytesPerSector]    ;Copy first byte to start of cache buffer
    MUL ECX
    MOV ECX,EAX
    SHR ECX,2
    REP MOVSD
    POP EAX                     ;Restore number of sectors in cache
    POP ESI

    MOV EDX,[rsSector]
    MOV [DSSectorCount],EAX     ;Update sector count of cache
    MOV ECX,[rsNumSectors]
    MOV [DSSector],EDX          ;CacheSector=rqsted sector

    SUB ECX,EAX
    JBE rdsReadOK               ;If more sectors in cache than needed, dont read

    ADD [DSSectorCount],ECX

    MOV [SI].dpNumSectors,CX
    ADD EAX,EDX
    MOV [SI].dpSector,EAX
    MOV [SI].dpBuffer,DI
    MOV [SI][2].dpBuffer,DS

    MOV DL,[Drive]
    CALL    BIOSRead
    JMP rdsDone

 rdsCacheAhead:
    CMP EAX,ECX
    JBE rdsNoCache

 rdsNoCache:
    MOV EAX,[rsNumSectors]
    MOV [SI].dpNumSectors,AX
    MOV [DSSectorCount],EAX

    MOV WORD [SI].dpBuffer,(DiskBuffer)
    MOV WORD [SI][2].dpBuffer,DS

    MOV EAX,[rsSector]
    MOV DWORD [SI].dpSector,EAX       ;Read MBR
    MOV [DSSector],EAX

    MOV DL,[Drive]
    CALL    BIOSRead
    JMP rdsDone

 rdsCacheHit:
    SUB EBX,ECX             ;NumSectors to read.
    JBE rdsReadOK
    MOV [SI].dpNumSectors,BX

    MOV EDX,[DSSectorCount]
    MOV EAX,[rsSector]
    ADD EAX,EDX
    MOV DWORD [SI].dpSector,EAX

    MOV EAX,[BytesPerSector]
    MUL EDX
    ADD EAX,(DiskBuffer)
    MOV [SI].dpBuffer,AX

    MOV EAX,[rsNumSectors]
    MOV [DSSectorCount],EAX

    MOV DL,[Drive]
    CALL    BIOSRead
 rdsDone:
    JNC rdsDone2

    PUSH    EAX
    PUSHF
    CALL    ResetDisk
    POPF
    POP EAX

 rdsDone2:

    POP ES
    POP EDI,ESI,EDX,ECX,EBX
    RET
 rdsReadOK:
    CLC
    JMP rdsDone
ReadDSSector    ENDP

WriteDSSector   PROC    wsSector:DWORD,wsNumSectors:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI
    MOV SI,(DiskPacket)
    MOV [SI],(SIZE DiskStruct)

    MOV EAX,[wsNumSectors]
    MOV [SI].dpNumSectors,AX

    MOV WORD [SI].dpBuffer,(DiskBuffer)
    MOV WORD [SI][2].dpBuffer,DS

    MOV EAX,[wsSector]
    MOV DWORD [SI].dpSector,EAX       ;Read MBR

    MOV DL,[Drive]
    CALL    BIOSWrite

    JNC wdsDone

    PUSH    EAX
    PUSHF
    CALL    ResetDisk
    POPF
    POP EAX

 wdsDone:
    POP EDI,ESI,EDX,ECX,EBX
    RET
WriteDSSector   ENDP

ResetDisk   PROC
    MOV AH,0
    MOV DL,[Drive]
    INT 13h
    RET
ResetDisk   ENDP

TestFSSectors PROC    tsSector:DWORD,tsNumSectors:DWORD
    PUSH    EDX
    CALL    GetTicks
    PUSH    EAX
    CALL    ReadFSSector,[tsSector],[tsNumSectors]
    POP EDX
    JC  tfsDone
    CALL    GetTicks
    SUB EAX,EDX
    CMP EAX,TICK_LIMIT  ;If CF then OK
    CMC         ;Complement so that NOT CF becomes CF which means is error
    JNC tfsTestWrite
    INC DWORD [TimeOut]
    STC
    JMP tfsDone
 tfsTestWrite:
    TEST    BYTE [ScanMode],10h
    CLC
    JZ  tgsDone

    CALL    GetTicks
    PUSH    EAX
    CALL    WriteFSSector,[tsSector],[tsNumSectors]
    POP EDX
    JC  tfsDone
    CALL    GetTicks
    SUB EAX,EDX
    CMP EAX,TICK_LIMIT  ;If CF then OK
    CMC         ;Complement so that NOT CF becomes CF which means is error
    JNC tfsVerify
    INC DWORD [TimeOut]
    STC
    JMP tfsDone
 tfsVerify:

    CALL    GetTicks
    PUSH    EAX
    CALL    ReadFSSector,[tsSector],[tsNumSectors]
    POP EDX
    JC  tfsDone
    CALL    GetTicks
    SUB EAX,EDX
    CMP EAX,TICK_LIMIT  ;If CF then OK
    CMC         ;Complement so that NOT CF becomes CF which means is error
    JNC tfsDone
    INC DWORD [TimeOut]
    STC
    JMP tfsDone
    
 tfsDone:
    JNC tfsNoReset
    PUSHF
    PUSH    EAX
    CALL    ResetDisk
    POP EAX
    POPF
 tfsNoReset:
    POP EDX
    RET
TestFSSectors ENDP

TestGSSectors PROC    tsSector:DWORD,tsNumSectors:DWORD
    PUSH    EDX
    CALL    GetTicks
    PUSH    EAX
    CALL    ReadGSSector,[tsSector],[tsNumSectors]
    POP EDX
    JC  tgsDone
    CALL    GetTicks
    SUB EAX,EDX
    CMP EAX,TICK_LIMIT  ;If CF then OK
    CMC         ;Complement so that NOT CF becomes CF which means is error
    JNC tgsTestWrite
    INC DWORD [TimeOut]
    STC
    JMP tgsDone
 tgsTestWrite:
    TEST    BYTE [ScanMode],10h
    CLC
    JZ  tgsDone

    CALL    GetTicks
    PUSH    EAX
    CALL    WriteGSSector,[tsSector],[tsNumSectors]
    POP EDX
    JC  tgsDone
    CALL    GetTicks
    SUB EAX,EDX
    CMP EAX,TICK_LIMIT  ;If CF then OK
    CMC         ;Complement so that NOT CF becomes CF which means is error
    JNC tgsVerify
    INC DWORD [TimeOut]
    STC
    JMP tgsDone
 tgsVerify:

;    CALL    GetTicks
;    PUSH    EAX
;    CALL    ReadGSSector,[tsSector],[tsNumSectors]
;    POP EDX
;    JC  tfsDone
;    CALL    GetTicks
;    SUB EAX,EDX
;    CMP EAX,TICK_LIMIT  ;If CF then OK
;    CMC         ;Complement so that NOT CF becomes CF which means is error
;    JNC tfsDone
;    INC DWORD [TimeOut]
;    STC
;    JMP tgsDone
    
 tgsDone:
    JNC tgsNoResett
    PUSH    EAX
    CALL    ResetDisk
    POP EAX
    STC
    JMP tgsNoReset
 tgsNoResett:
;    CALL    ReadGSSector,DWORD (0),DWORD (8)
 tgsNoReset:
    POP EDX
    RET
TestGSSectors ENDP
