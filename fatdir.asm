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

ReadRootDirCluster  PROC    rrdSector:DWORD
    MOV AL,[FATType]
    CMP AL,FAT32
    JZ  rrd32
    MOV EAX,[RootSector]    ;Root sector start
    ADD EAX,[rrdSector]     ;+NextSector
    CMP EAX,[DataSector]    ;Is NextSector>DataSector
    JAE rrdEnd              ;If so we are past rootdir
    CALL    ReadFSSector,EAX,DWORD (2)
    JC  rrdExit

    MOV EAX,[BytesPerSector]
    SHL EAX,1
    MOV [DirBytes],EAX

    MOV EAX,[rrdSector]     ;NextSector=NextSector+2 because we read 2 sectors
    ADD EAX,2
    CMP EAX,[DataSector]    ;Does NextSector point after DataSector,if so
    JB  rrdDone             ;We have read an extra sector
    MOV EAX,-1              ;If NextSector>=DataSector zero
    JZ  rrdDone

    SHR DWORD [DirBytes],1
    MOV BX,[BytesPerSector]
    MOV BYTE FS:[BX],0      ;Invalidate so that the extra sector terminates
    JMP rrdDone
 rrd32:
    CALL    ReadDirCluster,DWORD [RootCluster],[rrdSector]
    RET
 rrdEnd:
    XOR EAX,EAX
    MOV BYTE FS:[0],0
 rrdDone:
    CLC
    RET
 rrdExit:
    STC
    RET
ReadRootDirCluster  ENDP

ReadDirCluster  PROC    rdcFirstCluster:DWORD,rdcCurCluster:DWORD
LOCAL   rdcRetry:DWORD
    MOV [rdcRetry],5
    MOV EAX,[rdcFirstCluster]
    MOV EDX,[rdcCurCluster]
    TEST    EDX,EDX
    JZ  rdc32Read
    MOV EAX,EDX
 rdc32Read:
    MOV EBX,EAX             ;Save current cluster
    CALL    ClusterToSector,EAX
 rdc32Retry:
    CALL    ReadFSSector,EAX,DWORD [SectorsPerCluster]
    JNC rdcOK
    JMP rdcExit
    MOV EAX,EBX
    DEC [rdcRetry]
    JNZ rdc32Read
 rdcOK:
    MOV EAX,[SectorsPerCluster]
    MUL [BytesPerSector]
    MOV [DirBytes],EAX

    CALL    ReadNextCluster,EBX
    CMP BYTE [FATType],FAT16
    JZ  rdc16
    JB  rdc12
    CMP EAX,0FFF_FFF8h
    JMP rdcCommonText
 rdc16:
    CMP EAX,0FFF8h
    JMP rdcCommonText
 rdc12:
    CMP EAX,0FF8h
 rdcCommonText:
    JB  rdcDone
    MOV EAX,-1
 rdcDone:
    CLC
    RET

 rdcExit:
    STC
    RET
ReadDirCluster  ENDP
