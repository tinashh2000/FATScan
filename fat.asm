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

DetectFAT   PROC    dfStartSector:DWORD,dfEndSector:DWORD
    MOVZX   EAX,WORD [EBX].fatBytesPerSector
    TEST    EAX,EAX
    JZ  dfExit

    MOV [BytesPerSector],EAX

    PUSH    EAX
    MOV ECX,EAX
    MOV EAX,0_FFFFh
    XOR EDX,EDX
    DIV ECX
    MOV [FSSectors],EAX    
    POP EAX

    MOV EDX,EAX

    MOVZX   EAX,BYTE [EBX].fatSectorsPerCluster
    TEST    EAX,EAX
    JZ  dfExit
    MOV [SectorsPerCluster],EAX

    MUL EDX
    MOV [BytesPerCluster],EAX

    MOVZX EAX,BYTE [EBX].fatNumFATs
    TEST    EAX,EAX
    JZ  dfExit
    MOV [NumFATs],EAX

    MOVZX   EDX,WORD [EBX].fatFATSectors
    TEST    EDX,EDX
    JNZ dfNumFATsOK
    MOV EDX,[EBX].f32FATSectors
    TEST    EDX,EDX
    JZ  dfExit
 dfNumFATsOK:
    MOV [FATSectors],EDX
    MUL EDX

    MOV DX,[EBX].fatReservedSectors
    MOV ECX,EDX
    LEA ESI,[EAX][EDX]          ;FAT Table+Reserved

    MOV EAX,[dfStartSector]
    MOV [StartSector],EAX
    ADD ECX,EAX                 ;FAT starts after reserved
    MOV [FATSector],ECX
    ADD ECX,[FATSectors]
    MOV [FAT2Sector],ECX

    MOV DX,[EBX].fatRootEntries
    TEST    EDX,EDX
    JZ  dfRootOK
    PUSH    EAX
    ADD EAX,ESI
    MOV [RootSector],EAX
    MOV EAX,32
    MUL EDX
    XOR EDX,EDX
    MOV ECX,[BytesPerSector]
    LEA EAX,[EAX][ECX][-1]
    DIV ECX
;    MOV [RootEntries],EAX
    ADD ESI,EAX
    POP EAX
 dfRootOK:
    ADD EAX,ESI
    MOV [DataSector],EAX             ;FAT Table+Reserved+RootDir=DataArea
    MOVZX EAX,WORD [EBX].fatNumSectors
    TEST    EAX,EAX
    JNZ dfNumSectorsOK
    MOV EAX,[EBX].fatNumSectors32
    TEST    EAX,EAX
    JZ  dfExit
 dfNumSectorsOK:
    SUB EAX,ESI
    JBE dfExit
    MOVZX   ECX,BYTE [EBX].fatSectorsPerCluster
    XOR EDX,EDX
    DIV ECX
    MOV [NumClusters],EAX
    CMP EAX,4085
    JB  dfFAT12
    CMP EAX,65525
    JB  dfFAT16
    MOV EDX,[EBX].f32RootCluster
    MOV [RootCluster],EDX
    MOV EAX,[DataSector]
    MOV [AfterFAT],EAX
    MOV BYTE [FatType],FAT32
    CLC
 dfDone:
    RET
 dfExit:
    STC
    JMP dfDone

 dfFAT12:
    MOV BYTE [FatType],FAT12
    MOV EAX,[RootSector]
    MOV [AfterFAT],EAX
    CLC
    JMP dfDone

 dfFAT16:
    MOV BYTE [FatType],FAT16
    MOV EAX,[RootSector]
    MOV [AfterFAT],EAX
    CLC
    JMP dfDone
DetectFAT   ENDP

ClusterToSector PROC    ctsCluster:DWORD
    PUSH    EDX
    MOV EAX,[ctsCluster]
    SUB EAX,2
    MUL DWORD CS:[SectorsPerCluster]
    ADD EAX,CS:[DataSector]
    POP EDX
    RET
ClusterToSector ENDP

SectorToCluster PROC    stcSector:DWORD
    PUSH    EDX
    MOV EAX,[stcSector]
    SUB EAX,CS:[DataSector]
    XOR EDX,EDX
    DIV DWORD CS:[SectorsPerCluster]
    ADD EAX,2
    POP EDX
    RET
SectorToCluster ENDP

ReadNextCluster PROC    rncCluster:DWORD
    PUSH    EBX,ECX,EDX,ESI,EDI
    MOV EAX,[rncCluster]
    CMP BYTE [FATType],FAT16
    JZ  rnc16
    JB  rnc12
    SHL EAX,2           ;Mul by 4
    MOVZX   ECX,WORD [BytesPerSector]   ;(Clust*4)/BytesPerSector
    XOR EDX,EDX
    DIV ECX
    MOV ESI,EDX
    ADD EAX,[FATSector]
    CALL    ReadDSSector,EAX,DWORD (2)
    JC  rncDone
    MOV EAX,[ESI][DiskBuffer]
    CMP EAX,0FFF_FFF7h
    JB  rncDoneOK
    MOV EAX,-1
 rncDoneOK:
    CLC
 rncDone:
    POP EDI,ESI,EDX,ECX,EBX
    RET
 rnc16:
    SHL EAX,1           ;Mul by 2
    MOVZX   ECX,WORD [BytesPerSector]   ;(Clust*2)/BytesPerSector
    XOR EDX,EDX
    DIV ECX
    MOV ESI,EDX
    ADD EAX,[FATSector]
    CALL    ReadDSSector,EAX,DWORD (2)
    JC  rncDone
    MOVZX   EAX,WORD [ESI][DiskBuffer]
    CMP AX,0FFF7h
    JB  rncDoneOK
    MOV EAX,-1
    JMP rncDone
 rnc12:
    IMUL    EAX,EAX,3       ;(Cluster*3)/2 same as Cluster* 1.5
    SHR EAX,1
    MOV BL,0
    ADC BL,BL               ;Store CF in BL
    MOVZX   ECX,WORD [BytesPerSector]   ;(Clust*1.5)/BytesPerSector
    XOR EDX,EDX
    DIV ECX
    MOV ESI,EDX
    ADD EAX,[FATSector]
    CALL    ReadDSSector,EAX,DWORD (2)
    JC  rncDone
    MOV AX,[ESI][DiskBuffer]
    CMP BL,1
    JNC rnc12Shift
    SHR AX,4
    MOVZX   EAX,AX
    CLC
    JMP rncDone
 rnc12Shift:
    AND AH,0Fh
    MOVZX   EAX,AX
    CMP AX,0FF7h
    JB  rncDoneOK
    MOV EAX,-1
    JMP rncDone
ReadNextCluster ENDP
