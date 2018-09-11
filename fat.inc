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

fatBootRec  STRUC
    fatJmpCode              DB  3   DUP(?)
    fatSysID                DB  8   DUP(?)
    fatBytesPerSector       DW  ?
    fatSectorsPerCluster    DB  ?
    fatReservedSectors      DW  ?
    fatNumFATs              DB  ?
    fatRootEntries          DW  ?
    fatNumSectors           DW  ?
    fatMediaID              DB  ?
    fatFATSectors           DW  ?
    fatSectorsPerTrack      DW  ?
    fatNumHeads             DW  ?
    fatHiddenSectors        DD  ?
    fatNumSectors32         DD  ?
fatBootRec  ENDS

fat16BootRec    STRUC
                            DB  (SIZE fatBootRec) DUP(?)
    f16DriveNumber          DB  ?
    f16Reserved             DB  ?
    f16BootSignature        DB  ?
    f16SerialNumber         DD  ?
    f16VolumeLabel          DB  11  DUP(?)
    f16fatID                DB  8   DUP(?)
fat16BootRec    ENDS

fat32BootRec    STRUC
                            DB  (SIZE fatBootRec) DUP(?)
    f32FATSectors           DD  ?
    f32Flags                DW  ?
    f32Version              DW  ?
    f32RootCluster          DD  ?
    f32InfoSector           DW  ?
    f32BackUpSector         DW  ?
    f32Reserved             DB  12  DUP(?)
    f32DriveNumber          DB  ?
    f32BootSignature        DB  ?
    f32SerialNumber         DD  ?
    f32VolumeLabel          DB  11  DUP(?)
    f32fatID                DB  8   DUP(?)
fat32BootRec    ENDS

fatFileEntry   STRUC
    feName      DB  8   DUP(?)
    feExt       DB  3   DUP(?)
    feAttr      DB  ?
    feIsUCaseName   DB  ?
    feCreateTime    DB  3   DUP(?)
    feCreateDate    DW  ?
    feAccessDate    DW  ?
    feClusterH  DW  ?
    feTime      DW  ?
    feDate      DW  ?
    feClusterL  DW  ?
    feSize      DD  ?
fatFileEntry   ENDS

fatDriveEntry   STRUC
                            DB  (SIZE DiskStruct)   DUP(?)
    fdeDriveNumber          DD  ?
    fdeRootArea             DD  ?
    fdeFATArea              DD  ?
    fdeDataArea             DD  ?
    fdeDirCluster           DD  ?   ;Cluster of current directory
    fdeNumClusters          DD  ?   ;Number of clusters IN file system
    fdeSectorsPerCluster    DW  ?   ;Sectors IN one cluster
    fdeClusterSize          DW  ?   ;SIZE of one cluster IN bytes
    fdeRootEntries          DW  ?
    fdeDriveFS              DB  ?   ;File system
;    fdeCurPath              DB  1024 DUP(?)
fatDriveEntry   ENDS

fatHandleEntry  STRUC
    fheDriveNumber          DD  ?
    fheFirstCluster         DD  ?
    fheCurrentCluster       DD  ?
    fheCurrentClusterOffset DD  ?
    fheFileSize             DD  ?
fatHandleEntry  ENDS

fatLongFile STRUC
    flfSig      DB  ?
    flfName     DB  10  DUP(?)
    flfAttr     DB  ?
    flfFlags    DB  ?
    flfChksum   DB  ?
    flfName2    DB  12  DUP(?)
    flfCluster  DW  ?
    flfName3    DB  4   DUP(?)
fatLongFile ENDS

FAT_FILE_READONLY   =   01h
FAT_FILE_HIDDEN     =   02h
FAT_FILE_SYSTEM     =   04h
FAT_FILE_VOLUME     =   08h
FAT_FILE_DIRECTORY  =   10h
FAT_FILE_ARCHIVE    =   20h
FAT_FILE_NORMAL     =   80h

FAT12               =   12
FAT16               =   16
FAT32               =   32
