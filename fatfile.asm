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

ProcessFile PROC    pfCluster:DWORD,pfCurDirSector:DWORD,pfDirPosition:DWORD
LOCAL pfX:WORD,pfY:WORD,pfCurCluster:DWORD,pfNumErrors:DWORD,pfPrevCluster:DWORD,\
      pfErrorNext:DWORD,pfSize:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI
    XOR EAX,EAX
    MOV [pfSize],EAX
    MOV [pfNumErrors],EAX
    MOV [pfPrevCluster],EAX
    CALL    GetCursor
    MOVZX   AX,DH
    MOV DH,0
    MOV [pfX],DX
    MOV [pfY],AX
    MOV EAX,[pfCluster]
 pfLoop:
    MOV [pfCurCluster],EAX
    MOV EBX,EAX
    CALL    SetCursor,[pfX],[pfY]
    CALL    PrintCluster,EBX
    CALL    ClusterToSector,EBX
    CALL    TestGSSectors,EAX,DWORD [SectorsPerCluster]
    PUSHF

    CALL    PrintInt,EAX
    MOV AL,32
    CALL    PrintChar
    CALL    PrintChar
    CALL    PrintInt,ESP
    MOV AL,32
    CALL    PrintChar
    CALL    PrintInt,[pfSize]
    MOV EAX,[BytesPerCluster]
    ADD [pfSize],EAX
    POPF
    JC  pfError
    CALL    RecoverWriteFile,WORD (0),GS,WORD [BytesPerCluster]
    CALL    ReadNextCluster,EBX
    JC  pfBadFAT
    MOV [pfPrevCluster],EBX

    CMP EAX,-1
    JNZ pfLoop
    MOV EAX,[pfNumErrors]
    CLC
 pfDone:
    POP EDI,ESI,EDX,ECX,EBX
    RET

 pfError:
    CALL    ReadNextCluster,EBX
    JC  pfBadFAT
    MOV [pfErrorNext],EAX
    CALL    FindFreeCluster
    JC  pfDriveFull
    PUSH    EAX
    CALL    ClusterToSector,EAX
    CALL    TestGSSectors,EAX,DWORD [SectorsPerCluster]
    POP EAX
    JNC pfErrorFreeOK
    CALL    BadFreeCluster,EAX
    JMP pfError
 pfErrorFreeOK:
    MOV EDX,[pfPrevCluster]
    TEST    EDX,EDX
    JZ  pfFirstEntryBAD
    PUSH    EAX                         ;Save new free cluster
    CALL    WriteNextCluster,EDX,EAX    ;Put new free cluster in the link
    CALL    ReadNextCluster,EBX         ;Get next cluster of the bad one
    POP ECX
    CALL    WriteNextCluster,ECX,EAX    ;Put that next cluster after the new one
    CALL    RecoverCluster,EBX,ECX
    JMP pfPatchOK
 pfFirstEntryBAD:
    MOV ECX,EAX
    MOV ESI,[pfDirPosition]

    MOV EDX,ECX
    MOV FS:[SI].feClusterL,DX
    SHR EDX,16
    MOV FS:[SI].feClusterH,DX

    PUSH    EAX,EBX,ECX,ESI,EDI

    MOV EAX,ESI
    XOR EDX,EDX
    DIV [BytesPerSector]
    MOV ECX,EAX
    ADD ECX,[pfCurDirSector]
    MOV EAX,ESI
    SUB EAX,EDX

    PUSH    ES

    PUSH    DS
    POP ES

    PUSH    ECX,ESI
    MOV ESI,EAX
    MOV DI,(DiskBuffer)
    MOV CX,[BytesPerSector]
    REP MOVS BYTE [DI],FS:[SI]
    MOV DWORD [DSSectorCount],0

    POP ESI,ECX
    POP ES

    CALL    WriteDSSector,ECX,DWORD (1)
    POP EDI,ESI,ECX,EBX,EAX

    CALL    ReadNextCluster,EBX         ;Get next cluster of the bad one
    CALL    WriteNextCluster,EDX,EAX
    CALL    RecoverCluster,EBX,EDX
 pfPatchOK:
    INC [pfNumErrors]
    CALL    BadCluster,EBX
 pfResumeError:
    CALL    GetCursor
    MOVZX   AX,DH
    MOV DH,0
    MOV [pfX],DX
    MOV [pfY],AX

    MOV EAX,[pfErrorNext]
    MOV [pfPrevCluster],EBX
    CMP EAX,-1
    JNZ pfLoop
    MOV EAX,[pfNumErrors]
    CLC
    JMP pfDone

 pfDriveFull:
    CALL    PrintStr,DWORD (_DriveFull)
    MOV EAX,[pfNumErrors]
    STC
    JMP pfDone

 pfBadFAT:
    CALL    PrintStr,DWORD (_BadFAT)
    STC
    MOV AH,4Ch
;    INT 21h
    JMP pfDone
 pfBadRoot:
    CALL    PrintStr,DWORD (_BadRootDir)
    STC
    MOV AH,4Ch
;    INT 21h
    JMP pfDone
ProcessFile ENDP

BadFreeCluster  PROC bfcCluster:DWORD
    MOV [BadMsgPTR],(_FreeSpaceBad)
    CALL    BadCluster,[bfcCluster]
    MOV [BadMsgPTR],(_MarkAsBad)
    RET
BadFreeCluster  ENDP

BadCluster  PROC    bcCluster:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI

    CALL    PrintStr,DWORD (_Bad)
;    CALL    PrintLF
    MOV AL,[CorrectOption]
    CMP AL,1
    JZ  bcMark
    CMP AL,2
    JZ  bcErrorResume
    CALL    PrintLF
    CALL    Choice,DWORD [BadMsgPTR],DWORD (_MarkChoices)
    CMP AL,1
    JZ  bcMark
    CMP AL,2
    JZ  bcErrorResume
    CMP AL,5
    JZ  bcErrorResume
    SUB AL,2
    MOV [CorrectOption],AL
    CMP AL,2
    JZ  bcErrorResume
 bcMark:
    MOV EAX,[bcCluster]
    CMP BYTE [FATType],FAT16
    JA  bc32
    JZ  bc16
    CALL    PrintStr,DWORD (_ErrorNotFixed)
    JMP bcErrorResume
 bc16:
    SHL EAX,1           ;Mul by 4
    MOVZX   ECX,WORD [BytesPerSector]   ;(Clust*2)/BytesPerSector
    XOR EDX,EDX
    DIV ECX
    MOV ESI,EDX
    ADD EAX,[FATSector]
    PUSH    EAX
    CALL    ReadDSSector,EAX,DWORD (2)
    POP EAX
    JC  bcBadFAT
    MOV WORD [ESI][DiskBuffer],0_FFF7h
    CALL    WriteDSSector,EAX,DWORD (1)
    JC  bcBadFAT

    ADD EBX,[FATSector]
    ADD EBX,[FATSectors]

    CALL    ReadDSSector,EBX,DWORD (2)
    MOV WORD [ESI][DiskBuffer],0_FFF7h
    CALL    WriteDSSector,EBX,DWORD (1)
    JMP bcErrorResume
 bc32:
    SHL EAX,2           ;Mul by 4
    MOVZX   ECX,WORD [BytesPerSector]   ;(Clust*4)/BytesPerSector
    XOR EDX,EDX
    DIV ECX
    MOV ESI,EDX
    MOV EBX,EAX
    ADD EAX,[FATSector]
    MOV EDI,EAX
    CALL    ReadDSSector,EAX,DWORD (2)
    JC  bcBadFAT
    AND DWORD [ESI][DiskBuffer],0F000_0000h     ;Preserve high nibble
    OR  DWORD [ESI][DiskBuffer],0FFF_FFF7h
    CALL    WriteDSSector,EDI,DWORD (1)
    JC  bcBadFAT

    ADD EBX,[FATSector]
    ADD EBX,[FATSectors]
    CALL    ReadDSSector,EBX,DWORD (2)
    AND DWORD [ESI][DiskBuffer],0F000_0000h     ;Preserve high nibble
    OR  DWORD [ESI][DiskBuffer],0FFF_FFF7h
    CALL    WriteDSSector,EBX,DWORD (1)
    JMP bcErrorResume
 bcBadFAT:
    CALL    PrintStr,DWORD (_BadFAT)
    MOV AH,4Ch
    INT 21h

 bcErrorResume:
    CALL    PrintLF
    POP EDI,ESI,EDX,ECX,EBX
    RET
BadCluster  ENDP

FindFreeCluster PROC
LOCAL ffcCurCluster:DWORD,ffcCurSector:DWORD,ffcClustersInBuffer:DWORD
    PUSH    FS
    PUSH    EBX,ECX,EDX,ESI,EDI
    PUSH    GS
    POP FS
    MOV EAX,[FATSector]
    MOV [ffcCurSector],EAX
    MOV EAX,[FSSectors]
    MUL DWORD [BytesPerSector]
    CMP BYTE [FATType],FAT16
    JA  ffc32
    JZ  ffc16
    MOV ESI,3
    MUL ESI
    SHR EAX,1
    JMP ffcFATOK
 ffc16:
    SHR EAX,1
    JMP ffcFATOK
 ffc32:
    SHR EAX,2
 ffcFATOK:
    MOV [ffcClustersInBuffer],EAX
    XOR ESI,ESI
 ffcLoop:
    MOV [ffcCurCluster],ESI
    MOV EAX,[ffcCurSector]
    CMP EAX,[AfterFAT]
    JAE ffcDoneF
    CALL    ReadGSSector,[ffcCurSector],DWORD [FSSectors]
    JC  ffcFATError
    MOV EAX,[FSSectors]
    ADD EAX,[ffcCurSector]
    MOV [ffcCurSector],EAX
    MOV ESI,[ffcCurCluster]
    XOR EDI,EDI
 ffcScan:
    CALL    ReadCluster,DWORD (0),EDI
    TEST    EAX,EAX
    JZ  ffcFound
 ffcScanOK:
    INC EDI
    INC ESI
    CMP ESI,[NumClusters]
    JAE ffcDoneF
    CMP EDI,[ffcClustersInBuffer]
    JAE ffcLoop
    JMP ffcScan
 ffcFATError:
    CALL    PrintStr,DWORD (_BadFAT)
    STC
    MOV AH,4Ch
    INT 21h
    RET
 ffcDoneF:
    STC
    JMP ffcDone
 ffcFound:
    MOV EAX,ESI
    CLC
 ffcDone:
    POP EDI,ESI,EDX,ECX,EBX
    POP FS
    RET
FindFreeCluster ENDP

WriteNextCluster    PROC wncCluster:DWORD,wncLinkCluster:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI

    MOV EAX,[wncCluster]
    CMP BYTE [FATType],FAT16
    JZ  wnc16
    JB  wnc12
    SHL EAX,2           ;Mul by 4
    MOVZX   ECX,WORD [BytesPerSector]   ;(Clust*4)/BytesPerSector
    XOR EDX,EDX
    DIV ECX
    MOV ESI,EDX
    MOV EBX,EAX
    ADD EAX,[FATSector]
    MOV EDI,EAX
    CALL    ReadDSSector,EAX,DWORD (2)
    JC  wncBadFAT
    MOV EAX,[wncLinkCluster]
    MOV DWORD [ESI][DiskBuffer],EAX
    CALL    WriteDSSector,EDI,DWORD (1)
    JC  wncBadFAT

    ADD EBX,[FATSector]
    ADD EBX,[FATSectors]
    CALL    ReadDSSector,EBX,DWORD (2)
    MOV EAX,[wncLinkCluster]
    MOV DWORD [ESI][DiskBuffer],EAX
    CALL    WriteDSSector,EBX,DWORD (1)

 wncDoneOK:
    CLC
 wncDone:
    POP EDI,ESI,EDX,ECX,EBX
    RET
 wnc16:
    SHL EAX,1           ;Mul by 2
    MOVZX   ECX,WORD [BytesPerSector]   ;(Clust*2)/BytesPerSector
    XOR EDX,EDX
    DIV ECX
    MOV ESI,EDX
    MOV EBX,EAX
    ADD EAX,[FATSector]
    MOV EDI,EAX
    CALL    ReadDSSector,EAX,DWORD (2)
    JC  wncBadFAT
    MOV EAX,[wncLinkCluster]
    MOV WORD [ESI][DiskBuffer],AX
    CALL    WriteDSSector,EDI,DWORD (1)
    JC  wncBadFAT

    ADD EBX,[FATSector]
    ADD EBX,[FATSectors]
    CALL    ReadDSSector,EBX,DWORD (2)
    JC  wncBadFAT
    MOV AX,[wncLinkCluster]
    MOV WORD [ESI][DiskBuffer],AX
    CALL    WriteDSSector,EBX,DWORD (1)
    JC  wncBadFAT
    JMP wncDoneOK
 wnc12:
    CALL    PrintStr,DWORD (_ErrorNotFixed)
    JMP wncDoneOK
 wncBadFAT:
    CALL    PrintStr,DWORD (_ErrorNotFixed)
    MOV AH,4Ch
    INT 21h
WriteNextCluster    ENDP

RecoverCluster  PROC    rcBadCluster:DWORD,rcNewCluster:DWORD
LOCAL   rccError:DWORD
    PUSH    EBX,ECX,EDX,ESI
    XOR EAX,EAX
    MOV [rccError],EAX

    CALL    ClusterToSector,[rcBadCluster]
    MOV EBX,EAX

    CALL    ClusterToSector,[rcNewCluster]
    MOV ECX,EAX

    MOV EDX,[SectorsPerCluster]

    CALL    ReadDSSector,EBX,EDX
    JC  rccLoop
    CALL    WriteDSSector,ECX,EDX
 rccDone:
    POP ESI,EDX,ECX,EBX
    RET
 rccLoop:
    CALL    ReadDSSector,EBX,DWORD (1)
    JNC rccSectorOK
 rccSectorOK:
    CALL    WriteDSSector,ECX,DWORD (1)
    ADC [rccError],0    ;If we quit without writing the sectors, i dont know
    INC EBX,ECX         ;what happens. <-- Increase sector of source and dest
    DEC EDX
    JNZ rccLoop
    CMP [rccError],1    ;Is Error < 1, if CF no error
    CMC                 ;Twist so that CF=Error
    JMP rccDone
RecoverCluster  ENDP


FreeCluster  PROC    fcCluster:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI
    CALL    PrintStr,DWORD (_Bad)
    CALL    PrintLF
    MOV AL,[CorrectOption]
    CMP AL,1
    JZ  fcMark
    CMP AL,2
    JZ  fcErrorResume
    CALL    Choice,DWORD (_FreeAsBad),DWORD (_MarkChoices)
    CMP AL,1
    JZ  fcMark
    CMP AL,2
    JZ  fcErrorResume
    CMP AL,5
    JZ  fcErrorResume
    SUB AL,2
    MOV [CorrectOption],AL
    CMP AL,2
    JZ  fcErrorResume
 fcMark:
    MOV EAX,[fcCluster]
    CMP BYTE [FATType],FAT16
    JA  fc32
    JZ  fc16
    CALL    PrintStr,DWORD (_ErrorNotFixed)
    JMP fcErrorResume
 fc16:
    SHL EAX,1           ;Mul by 4
    MOVZX   ECX,WORD [BytesPerSector]   ;(Clust*2)/BytesPerSector
    XOR EDX,EDX
    DIV ECX
    MOV ESI,EDX
    MOV EBX,EAX
    ADD EAX,[FATSector]
    PUSH    EAX
    CALL    ReadDSSector,EAX,DWORD (2)
    POP EAX
    JC  fcBadFAT
    MOV WORD [ESI][DiskBuffer],0
    CALL    WriteDSSector,EAX,DWORD (1)
    JC  fcBadFAT

    ADD EBX,[FATSector]
    ADD EBX,[FATSectors]

    CALL    ReadDSSector,EBX,DWORD (2)
    MOV WORD [ESI][DiskBuffer],0
    CALL    WriteDSSector,EBX,DWORD (1)
    JC  fcBadFAT

    JMP fcErrorResume
 fc32:
    SHL EAX,2           ;Mul by 4
    MOVZX   ECX,WORD [BytesPerSector]   ;(Clust*4)/BytesPerSector
    XOR EDX,EDX
    DIV ECX
    MOV ESI,EDX
    MOV EBX,EAX
    ADD EAX,[FATSector]
    MOV EDI,EAX
    CALL    ReadDSSector,EAX,DWORD (2)
    JC  fcBadFAT
    AND DWORD [ESI][DiskBuffer],0F000_0000h     ;Preserve high nibble
    CALL    WriteDSSector,EDI,DWORD (1)
    JC  fcBadFAT

    ADD EBX,[FATSector]
    ADD EBX,[FATSectors]
    CALL    ReadDSSector,EBX,DWORD (2)
    AND DWORD [ESI][DiskBuffer],0F000_0000h     ;Preserve high nibble
    CALL    WriteDSSector,EBX,DWORD (1)
    JMP fcErrorResume
 fcBadFAT:
    CALL    PrintStr,DWORD (_BadFAT)
    MOV AH,4Ch
    INT 21h

 fcErrorResume:
    CALL    PrintLF
    POP EDI,ESI,EDX,ECX,EBX
    RET
FreeCluster  ENDP
