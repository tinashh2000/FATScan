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

ScanDisk:
;    INT 3
;    MOV BYTE [Drive],81h
;    CALL    ReadFSSector,DWORD (119940),DWORD (1)
;    MOV DWORD FS:[0].fatNumSectors32,3EEFF0h
;    CALL    WriteFSSector,DWORD (119940),DWORD (1)
;    INT 3
;    CALL    ReadFSSector,DWORD [StartSector],DWORD (1)

;    MOV SI,(MyDat)
;    XOR DI,DI
;    MOV AX,FS
;    MOV ES,AX

;    MOVSW
;    MOVSB
;    ADD SI,(5Ah)-3
;    ADD DI,(5Ah)-3
;    MOV ECX,512
;    REP MOVSB

;    CALL    WriteFSSector,DWORD [StartSector],DWORD (1)

;    INT 3
    CALL    PrintStr,DWORD (_TestingSystem)
    CALL    PrintLF
    MOV ECX,[StartSector]
 sdInitCursor:
    PUSH    ECX
    CALL    GetCursor
    MOVZX   AX,DH
    MOV DH,0
    MOV [CurX],DX
    MOV [CurY],AX
    POP ECX
 sdTestRoot:
    CALL    SetCursor,[CurX],[CurY]
    CALL    PrintInt,ECX
    PUSHAD
    CALL    TestFSSectors,ECX,DWORD (1) ;[SectorsPerCluster]
    POPAD
    JC  sdTestError
    ADD ECX,[SectorsPerCluster]
    CMP ECX,[DataSector]
    JBE sdTestRoot
    JMP sdTestRootOK
 sdTestError:
    CALL    PrintStr,DWORD (_Err)
    CALL    PrintLF
    ADD ECX,[SectorsPerCluster]
    CMP ECX,[DataSector]
    JBE sdTestRoot
 sdTestRootOK:

    CALL    PrintLF
    MOV DI,(CurPath)
    MOV AX,"DH"
    STOSW
    MOV AL,"("
    STOSB
    MOV AL,[Drive]
    AND AL,NOT 80h
    AAM
    XCHG    AL,AH
    OR  AX,"00"
    STOSW
    MOV AX,"\)"
    STOSW
    MOV EAX,"TRAP"
    STOSD
    MOV AL,"("
    STOSB
    MOV AL,[Partition]
    AAM
    XCHG    AL,AH
    OR  AX,"00"
    STOSW
    MOV AL,")"
    STOSB
    MOV BYTE [DI],0
    MOV WORD [PathLen],15

    CALL    RecoverNewDir,WORD (_RecDir)

    MOV AX,[ScanMode]
    TEST    AL,4
    JNZ sdScanFree
    TEST    AL,8
    JNZ sdScanAll
    TEST    AL,40h
    JNZ sdRetest
    TEST    AL,20h
    JNZ sdBackFAT
    TEST    AH,1
    JNZ sdTestX

 sdLoop:

    MOV EAX,[NextDirCluster]
    MOV [CurDirCluster],EAX

    CMP DWORD [DirNesting],0
    JZ  sdRoot
    PUSH    EAX
    CALL    ClusterToSector,EAX
    MOV [CurDirSector],EAX
    POP EAX
    CALL    ReadDirCluster,DWORD [FirstDirCluster],EAX
    JC  sdScanFree
    JMP sdDirOK
 sdRoot:
    PUSH    EAX
    CMP BYTE [FATType],FAT32
    JZ  sdRootFAT32
    TEST    EAX,EAX
    JNZ sdRootCurSectorOK
    MOV EAX,[RootSector]
    JMP sdRootCurSectorOK
 sdRootFAT32:
    TEST    EAX,EAX
    JNZ sdRootFAT32OK
    MOV EAX,[RootCluster]
 sdRootFAT32OK:
    CALL    ClusterToSector,EAX
 sdRootCurSectorOK:
    MOV [CurDirSector],EAX
    POP EAX
    CALL    ReadRootDirCluster,EAX
    JC  sdScanFree
 sdDirOK:
    MOV [NextDirCluster],EAX
    PUSH    FS
    POP ES
    MOV ESI,[CurDirPosition]
    MOV ECX,[DirBytes]
    CMP ESI,ECX
    JA  sdNextCluster
 sdProcessDir:
    MOV EAX,ES:[SI]

    TEST    BYTE ES:[SI].feAttr,FAT_FILE_VOLUME
    JNZ sdLFNEntry

    CMP AL,0
    JZ  sdPrevDirectory
    CMP AL,0E5h
    JZ  sdNextEntry
    CMP AX,202Eh        ;". "
    JZ  sdNextEntry
    AND EAX,0FF_FFFFh
    CMP EAX,00202E2Eh   ;".. "
    JZ  sdNextEntry

    TEST    BYTE [ScanMode],2
    JNZ sdFindPath

    TEST    BYTE ES:[SI].feAttr,FAT_FILE_DIRECTORY
    JNZ sdDirectory

    CMP DWORD ES:[SI].feSize,0
    JZ  sdNextEntry
    LEA EAX,[ESI][32]
    MOV [CurDirPosition],EAX

    MOV EAX,[CurDirCluster]
    MOV [NextDirCluster],EAX

    CALL    PathNext
    CALL    PrintPath

    MOV EAX,ES:[SI].feSize
    MOV [CurFileSize],EAX

    MOV AX,ES:[SI].feClusterH
    SHL EAX,16
    MOV AX,ES:[SI].feClusterL

    CALL    ProcessFile,EAX,DWORD [CurDirSector],ESI

    CALL    PathPrevious,0  ;0=File 1=Dir
    CALL    PrintPath

    JMP sdLoop

 sdLFNEntry:
    TEST    BYTE [LFNStatus],1
;    JNZ sdLFNExists
    OR  [LFNStatus],0
    JMP sdNextEntry
 sdDirectory:
    INT 3
    MOV EAX,[DirNesting]
    IMUL    EDI,EAX,LINK_ENTRYSIZE
    ADD EDI,(PathBackLink)
    MOV EAX,[FirstDirCluster]
    MOV EDX,[CurDirCluster]
    MOV [EDI],EAX       ;FirstDirCluster
    MOV [EDI][4],EDX    ;CurDirCluster
    LEA EAX,[ESI][32]   ;Point CurDirPosition to next entry
    MOV [EDI][8],EAX    ;CurDirPosition
    INC DWORD [DirNesting]

    MOV AX,ES:[SI].feClusterH
    SHL EAX,16
    MOV AX,ES:[SI].feClusterL
    MOV [NextDirCluster],EAX
    MOV [FirstDirCluster],EAX
    XOR EAX,EAX
    MOV [CurDirPosition],EAX

    CALL    PathNext
    CALL    PrintPath
    JMP sdLoop
 sdNextEntry:
    ADD ESI,32
    CMP ESI,ECX
    JB  sdProcessDir
 sdLFNExists:
 sdNextCluster:
    XOR EAX,EAX
    MOV [CurDirPosition],EAX
    CMP DWORD [NextDirCluster],-1
    JB  sdLoop
 sdPrevDirectory:

    TEST    BYTE [ScanMode],2
    JNZ sdPathNotFound

    MOV EAX,[DirNesting]
    TEST    EAX,EAX
    JZ  sdScanFree
    DEC EAX
    MOV [DirNesting],EAX
    PUSH    ESI
    IMUL    ESI,EAX,LINK_ENTRYSIZE
    ADD ESI,(PathBackLink)
    LODSD
    MOV [FirstDirCluster],EAX
    LODSD
    MOV [CurDirCluster],EAX
    MOV [NextDirCluster],EAX
    LODSD
    MOV [CurDirPosition],EAX
    POP ESI
    MOV AL,2
    CALL    PathPrevious,1
    CALL    PrintPath
    JMP sdLoop

 sdPathNotFound:
    AND BYTE [ScanMode],NOT 2
    MOV AX,0E07h
    INT 10h
    XOR EAX,EAX
    MOV [CurDirPosition],EAX
    MOV EAX,[FirstDirCluster]
    MOV [NextDirCluster],EAX
    JMP sdLoop
 sdTestX:
    CALL    TestX
 sdBackFAT:
    MOV AH,3Ch
    MOV CX,0
    MOV DX,(_FATFile)
    INT 21h
    MOV BX,AX
    MOV ESI,[FATSector]
    MOV EDI,[FATSectors]
    ADD EDI,EDI
    ADD EDI,ESI
 sdBackFATWrite:
    CALL    ReadFSSector,ESI,DWORD (7Fh)
    PUSH    DS
    PUSH    FS
    POP DS
    MOV AH,40h
    MOV CX,7Fh*512
    XOR DX,DX
    INT 21h
    POP DS
    ADD ESI,7Fh
    CMP ESI,EDI
    JB  sdBackFATWrite
    MOV AH,4Ch
    INT 21h

 sdRetest:
 sdScanAll:
    CALL    ScanAllSpace
    RET

 sdScanFree:
    CALL    ScanFreeSpace
    MOV EAX,[DirNesting]
    MOV SI,(CurPath)
    RET

 sdFindPath:
    TEST    BYTE FS:[SI].feAttr,FAT_FILE_DIRECTORY
    JZ  sdNextEntry

    CALL    FormatPath,DWORD [PathPTR],DWORD (_TargetPath)    
    PUSH    ES
    PUSH    EAX,ECX
    MOV CX,8
    MOV DI,(_TargetPath)
    MOV BX,SI
    PUSH    DS
    POP ES
 sdCompareNames:
    REPZ    CMPS    BYTE FS:[SI],ES:[DI]
    JZ  sdCompareExt
    MOV AL,[DI][-1]
    CMP AL,"?"
    JZ  sdCompareNames
    MOV SI,BX
    POP ECX,EAX
    POP ES
    JMP sdNextEntry
 sdCompareExt:
    LEA SI,[BX][8]
    LEA DI,[_TargetPath][8]
    MOV CX,3
 sdExt:
    REPZ    CMPS    BYTE FS:[SI],ES:[DI]
    JZ  sdPathFound
    MOV AL,[DI][-1]
    CMP AL,"?"
    JZ  sdExt
    MOV SI,BX
    POP ECX,EAX
    POP ES
    JMP sdNextEntry
 sdPathFound:
    POP ECX,EDI
    POP ES
    MOV SI,BX
    MOV [PathPTR],EDI
    CMP BYTE [DI],0
    JNZ sdDirectory
    AND BYTE [ScanMode],NOT 2
    JMP sdDirectory

ScanFreeSpace   PROC
LOCAL sfsX:WORD,sfsY:WORD,sfsCurSector:DWORD,sfsCurCluster:DWORD,\
      sfsClustersInBuffer:DWORD,sfsFreeClusters:DWORD,sfsError:WORD,\
      sfsFATSectors:DWORD

    MOV EAX,[FSSectors]
    MOV [sfsFATSectors],EAX

    CALL    PrintLF
    CALL    PrintStr,DWORD (_ScanningFree)
    CALL    GetCursor
    MOVZX   AX,DH
    MOV DH,0
    MOV [sfsX],DX
    MOV [sfsY],AX
    MOV EAX,[FATSector]
    MOV [sfsCurSector],EAX
    MOV EAX,[sfsFATSectors]
    MUL DWORD [BytesPerSector]
    CMP BYTE [FATType],FAT16
    JA  sfs32
    JZ  sfs16
    MOV ESI,3
    MUL ESI
    SHR EAX,1
    JMP sfsFATOK
 sfs16:
    SHR EAX,1
    JMP sfsFATOK
 sfs32:
    SHR EAX,2
 sfsFATOK:
    MOV [sfsClustersInBuffer],EAX
    XOR ESI,ESI
    MOV [sfsFreeClusters],ESI
    MOV [sfsError],0
 sfsLoop:
    CMP [sfsError],0
;    JNZ sfsReset
    MOV [sfsCurCluster],ESI
    MOV EAX,[sfsCurSector]
    CMP EAX,[AfterFAT]
    JAE sfsDone
    CALL    ReadFSSector,[sfsCurSector],DWORD [sfsFATSectors]
    PUSHF
    CALL    PrintInt,EAX
    POPF
    JC  sfsFATError
    MOV EAX,[sfsFATSectors]
    ADD EAX,[sfsCurSector]
    CMP EAX,[AfterFAT]
    JBE sfsSectorsOK
    MOV EAX,[AfterFAT]
 sfsSectorsOK:
    MOV EDI,EAX
    XCHG    [sfsCurSector],EDI
    SUB EAX,EDI
    JZ  sfsDone
    MUL DWORD [BytesPerSector]
    MOV BX,AX
    MOV ESI,[sfsCurCluster]
    XOR EDI,EDI
 sfsScan:
    CALL    ReadCluster,DWORD (0),EDI
    TEST    EAX,EAX
    JZ  sfsScanIt
 sfsScanOK:
    INC EDI
    INC ESI
    CMP ESI,[NumClusters]
    JAE sfsLoop
    CMP EDI,[sfsClustersInBuffer]
    JAE sfsLoop
    JMP sfsScan
 sfsScanIt:
    CMP ESI,2
    JB  sfsScanOK

    CMP ESI,RSTART
    JB  sfsScanOK

    INC [sfsFreeClusters]
    CALL    SetCursor,[sfsX],[sfsY]
    CALL    PrintCluster,ESI
    CALL    ClusterToSector,ESI

    CALL    TestGSSectors,EAX,DWORD [SectorsPerCluster]
    PUSHF
    CALL    PrintInt,EAX
    POPF
    JNC sfsScanOK
 sfsBadCluster:
    CALL    BadCluster,ESI
    CALL    GetCursor
    MOVZX   AX,DH
    MOV DH,0
    MOV [sfsX],DX
    MOV [sfsY],AX

    CALL    WriteCluster,DWORD (0),EDI,DWORD (0FFF_FFF7h)
    OR  [sfsError],1

    SUB EDI,BACK_TRACK
    JC  sfsReset
    SUB ESI,BACK_TRACK
;    CALL    ResetDisk
;    CALL    Delay,ERRORDEL
    JMP sfsScanOK

 sfsReset:
    MOV [sfsError],0
    XOR EDI,EDI
    MOV ESI,[sfsCurCluster]
    JMP sfsScanOK
 sfsFATError:
 sfsDone:
    MOV EAX,[sfsFreeClusters]
    RET
ScanFreeSpace   ENDP

ScanAllSpace    PROC
LOCAL sasX:WORD,sasY:WORD,sasCurSector:DWORD,sasCurCluster:DWORD,\
      sasClustersInBuffer:DWORD,sasFreeClusters:DWORD,sasFlags:DWORD,\
      sasFATSectors:DWORD,sasBadClusters:DWORD,sasBadAdvance:DWORD

    XOR EAX,EAX
    MOV [sasBadAdvance],EAX

    MOV EAX,[FSSectors]
    MOV [sasFATSectors],EAX

    CALL    PrintLF
    CALL    PrintStr,DWORD (_ScanningAll)
    CALL    GetCursor
    MOVZX   AX,DH
    MOV DH,0
    MOV [sasX],DX
    MOV [sasY],AX
    MOV EAX,[FATSector]
    MOV [sasCurSector],EAX
    MOV EAX,[sasFATSectors]
    MUL DWORD [BytesPerSector]
    CMP BYTE [FATType],FAT16
    JA  sas32
    JZ  sas16
    MOV ESI,3
    MUL ESI
    SHR EAX,1
    JMP sasFATOK
 sas16:
    SHR EAX,1
    JMP sasFATOK
 sas32:
    SHR EAX,2
 sasFATOK:
    MOV [sasClustersInBuffer],EAX
    XOR ESI,ESI
    MOV [sasFreeClusters],ESI
 sasLoop:
    MOV [sasCurCluster],ESI
    MOV EAX,[sasCurSector]
    CMP EAX,[AfterFAT]
    JAE sasDone
    CALL    ReadFSSector,[sasCurSector],DWORD [sasFATSectors]
    JC  sasFATError
    MOV EAX,[sasFATSectors]
    ADD EAX,[sasCurSector]
    CMP EAX,[AfterFAT]
    JBE sasSectorsOK
    MOV EAX,[AfterFAT]
 sasSectorsOK:
    MOV EDI,EAX
    XCHG    [sasCurSector],EDI
    SUB EAX,EDI
    JZ  sasDone
    MUL DWORD [BytesPerSector]
    MOV BX,AX
    MOV ESI,[sasCurCluster]
    XOR EDI,EDI
 sasScan:
    CALL    ReadCluster,DWORD (0),EDI
    MOV DL,[FATType]

    CMP DL,FAT12
    JZ  sasF12

    CMP DL,FAT16
    JZ  sasF16

;    CMP DL,FAT32
;    JZ  sasF32
    CMP EAX,0FFF_FFF7h
    JNZ sasScanIt
    JMP sasBad

 sasScanOK:
    INC EDI
    INC ESI
    CMP ESI,[NumClusters]
    JAE sasDone
    CMP ESI,REND
    JAE sasDone
    CMP EDI,[sasClustersInBuffer]
    JAE sasLoop
    JMP sasScan

 sasF12:
    CMP EAX,0FF7h
    JNZ sasScanIt
    JMP sasBad

 sasF16:
    CMP AX,0FFF7h
    JNZ sasScanIt
    JMP sasBad

 sasBad:
    TEST    BYTE [ScanMode],40h
    JZ  sasScanOK

    CMP [sasBadAdvance],0
    JZ  sasBadAdvOK
    DEC [sasBadAdvance]
 sasBadAdvOK:

    CMP ESI,2
    JB  sasScanOK

    CMP ESI,RSTART
    JB  sasScanOK

    INC [sasBadClusters]
    CALL    SetCursor,[sasX],[sasY]
    CALL    PrintCluster,ESI
    CALL    ClusterToSector,ESI

    CALL    TestGSSectors,EAX,DWORD [SectorsPerCluster]
    PUSHF
    CALL    PrintInt,EAX
    POPF
    JC  sasScanOK
    CALL    FreeCluster,ESI
    CALL    GetCursor
    MOVZX   AX,DH
    MOV DH,0
    MOV [sasX],DX
    MOV [sasY],AX
    JMP sasScanOK

 sasScanIt:
    TEST    BYTE [ScanMode],40h
    JNZ sasScanOK

    CMP ESI,2
    JB  sasScanOK

    CMP ESI,RSTART
    JB  sasScanOK

    INC [sasFreeClusters]
    CALL    SetCursor,[sasX],[sasY]
    CALL    PrintCluster,ESI

    CMP [sasBadAdvance],0
    JZ  sasAdvOK
    DEC [sasBadAdvance]
;    JNZ sasBadCluster
;    JMP sasBadDone
 sasAdvOK:

    CALL    ClusterToSector,ESI

    CALL    TestGSSectors,EAX,DWORD [SectorsPerCluster]
    PUSHF
    CALL    PrintInt,EAX
    POPF
    JNC sasScanOK
 sasBadCluster:
    CALL    BadCluster,ESI
    CALL    GetCursor
    MOVZX   AX,DH
    MOV DH,0
    MOV [sasX],DX
    MOV [sasY],AX
    CALL    WriteCluster,DWORD (0),EDI,DWORD (0FFF_FFF7h)
    OR  [sasFlags],1
    CMP [sasBadAdvance],0
    JNZ sasScanOK
;    MOV EAX,ESI
;    ADD EAX,BAD_ADVANCE
;    CMP EAX,[NumClusters]
;    JAE sasScanOK

;    PUSH    EAX
;    CALL    ClusterToSector,EAX
;    CALL    TestGSSectors,EAX,DWORD [SectorsPerCluster]
;    POP EAX

;    PUSHF
;    CALL    PrintInt,EAX
;    POPF

;    JNC sasBadDone

;    MOV [sasBadAdvance],BAD_ADVANCE
;    JMP sasScanOK

 sasBadDone:
    SUB EDI,BACK_TRACK
    JC  sasReset
    SUB ESI,BACK_TRACK
    JMP sasScanOK

 sasReset:
    AND [sasFlags],NOT 1
    XOR EDI,EDI
    MOV ESI,[sasCurCluster]
    JMP sasScanOK

 sasFATError:
 sasDone:
    MOV EAX,[sasFreeClusters]
    RET
ScanAllSpace   ENDP

ReadCluster PROC    rcBuffer:DWORD,rcClusterOffset:DWORD
    MOV EAX,[rcClusterOffset]
    MOV EDX,[rcBuffer]
    CMP BYTE [FATType],FAT16
    JZ  rc16
    JB  rc12
    SHL EAX,2           ;Mul by 4
    MOV EAX,FS:[EAX][EDX]
    AND EAX,0FFF_FFFFh
    RET
 rc16:
    SHL EAX,1
    MOVZX EAX,WORD FS:[EAX][EDX]
    RET
 rc12:
    RET
ReadCluster ENDP

WriteCluster PROC    wcBuffer:DWORD,wcClusterOffset:DWORD,wcValue:DWORD
    PUSH    EAX,ECX,EDX
    MOV EAX,[wcClusterOffset]
    MOV EDX,[wcBuffer]
    CMP BYTE [FATType],FAT16
    JZ  wc16
    JB  wc12
    SHL EAX,2           ;Mul by 4
    MOV ECX,[wcValue]
    MOV FS:[EAX][EDX],ECX
    AND EAX,0FFF_FFFFh
    POP EDX,ECX,EAX
    RET
 wc16:
    SHL EAX,1
    MOV CX,[wcValue]
    MOV WORD FS:[EAX][EDX],CX
    POP EDX,ECX,EAX
    RET
 wc12:
    POP EDX,ECX,EAX
    RET
WriteCluster ENDP

GetTicks:
    PUSH    ES
    XOR EAX,EAX
    MOV ES,AX
    MOV EAX,ES:[46Ch]
    POP ES
    RET

Delay   PROC    dTime:WORD
    PUSH    ES
    PUSH    EAX,ECX,EDX
    XOR ECX,ECX
    MOV ES,CX
    MOV EAX,ES:[46Ch]
    MOV CX,[dTime]
 dLoop:
    MOV EDX,ES:[46Ch]
    SUB EDX,EAX
    CMP EDX,ECX
    JB  dLoop
    POP EDX,ECX,EAX
    POP ES    
    RET
Delay   ENDP

TestX   PROC
LOCAL   txX:WORD,txY:WORD
    CALL    GetCursor
    MOVZX   AX,DH
    MOV DH,0
    MOV [txX],DX
    MOV [txY],AX

    CALL    GetTicks
    PUSH    ES
    PUSH    FS
    POP ES
    MOV ECX,512/4
    XOR EBX,EBX
    MOV EBX,1000
 txMessUp:
    STOSD
    INC EAX
    ROR EAX,1
    DEC ECX
    JNZ txMessUp
 txWriteTest:
    CALL    SetCursor,[txX],[txY]
    CALL    PrintInt,EBX
    CALL    WriteFSSector,EBX,DWORD (1)
    CALL    ReadGSSector,EBX,DWORD (1)
    INC EBX
    XOR ESI,ESI
    MOV EDI,ESI
    PUSH    DS
    PUSH    GS
    POP DS
    MOV ECX,512/4
    REPZ    SCASD
    POP DS
    JZ  txNext
    INC [txY]
    JMP txWriteTest
 txNext:
    INC EBX
    JMP txWriteTest
TestX   ENDP
