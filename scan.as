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

_FATFile    DB  "FUJFAT32.DAT",0
_Cylinders  DB  " Cyl ",0
_Heads      DB  " Hds ",0
_SectorsPerTrack    DB  " SecPerTrack ",0
_Sectors    DB  " Secs ",0

_BytesPerSector DB  " bps ",0
_Bytes      DB  " Bytes",0
_MB         DB  " MB",0

_LF         DB  13,10,0

_FreeAsBad  DB  "A useable cluster was marked as bad. Free It. (Y)es/(N)o/Y(e)s Always,N(o) Always (Y/N/E/O/X): ",0

_Bad        DB  "Bad",0
_BadFAT     DB  "Bad FAT Table",13,10,0
_BadRootDir DB  "Bad Directory Sector",13,10,0

_FirstClusterBAD    DB  "First cluster bad."
_ErrorNotFixed      DB  "Error not fixed. Call me and get the updated program",13,10,0
_DriveFull  DB  "Your hard disk is full. Free some space then run this program again",13,10,0

BadMsgPTR   DD  (_MarkAsBad)

_FreeSpaceBad   DB  "Bad cluster while allocating another cluster for a bad cluster. "
_MarkAsBad      DB  "Mark cluster as bad? Yes/No/Yes Always/No Always/Exit (Y/N/E/O/X): ",0

_MarkChoices    DB  "YNEOX",0

_Yes        DB  "&Yes",0
_No         DB  "&No",0
_YesAll     DB  "Yes To All",0
_NoAll      DB  "No To All",0
_Exit       DB  "Exit",0

ButtonGroup:
            DD  5
            DD  _Yes
            DD  _No
            DD  _YesAll
            DD  _NoAll
            DD  _Exit

_ScanningFree   DB  "Scanning free clusters... ",0
_ScanningAll    DB  "Scanning all clusters... ",0

UCaseTbl:
        DB  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
        DB  21,22,23,24,25,26,27,28,29,30,31,32
        DB  "!",34,"#$%&'()*+,-./0123456789:;<=>?@"
        DB  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        DB  "[\]^_`"
        DB  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        DB  "z{|}~€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥¦§¨©ª«¬­®¯"
        DB  "°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞß"
        DB  "àáâãäåæçèéêëìíîïğñòóôõö÷øùúûüışÿ"

LCaseTable:
        DB  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
        DB  21,22,23,24,25,26,27,28,29,30,31,32
        DB  "!",34,"#$%&'()*+,-./0123456789:;<=>?@"
        DB  "abcdefghijklmnopqrstuvwxyz"
        DB  "[\]^_`"
        DB  "abcdefghijklmnopqrstuvwxyz"
        DB  "z{|}~€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥¦§¨©ª«¬­®¯"
        DB  "°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞß"
        DB  "àáâãäåæçèéêëìíîïğñòóôõö÷øùúûüışÿ"

RealCaseTable:
        DB  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
        DB  21,22,23,24,25,26,27,28,29,30,31,32
        DB  "!",34,"#$%&'()*+,-./0123456789:;<=>?@"
        DB  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        DB  "[\]^_`"
        DB  "abcdefghijklmnopqrstuvwxyz"
        DB  "z{|}~€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥¦§¨©ª«¬­®¯"
        DB  "°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞß"
        DB  "àáâãäåæçèéêëìíîïğñòóôõö÷øùúûüışÿ"

_Choices    DB  "1. ",0
            DB  "2. ",0
            DB  "3. ",0
            DB  "4. ",0
            DB  "5. ",0
            DB  "6. ",0
            DB  "7. ",0
            DB  "8. ",0
            DB  "9. ",0
            DB  "10.",0

ExtTrackPTR     DD  (ExtTrack)

_SelectDrive    DB  13,10,"Select Drive (ESC to Quit) :1",0
_sdrvEnd:
_NoFixedDrives  DB  "No Fixed Drives or AH=4x INT 13h compatible services",13,10,0
_NoPartitions   DB  "No defined or supported partions (FAT12,FAT16,FAT32)",13,10,0
_MemoryAllocationFail   DB  "Memory Allocation Failed. At least 256KB of DOS memory is needed",13,10,0
_Err            DB  "(err)",0
_TestingSystem  DB  "Testing System Areas...",0
_Bootable       DB  " (Bootable) ",0
_FAT12          DB  " FAT12 ",0
_FAT16          DB  " FAT16 ",0
_FAT32          DB  " FAT32 ",0

_Prog           DB  "MTScan (C) Tinashe Mutandagayi 2008",13,10,0

_Usage          DB  "MTScan [InitialPath] [Options]",13,10
                DB  "Valid options are:",13,10
                DB  "/C     -   Scan clusters sequencially without going through each file",13,10
                DB  "/R     -   Repair bad clusters (by marking them as bad)",13,10
                DB  "/F     -   Scan free sectors",13,10
                DB  0

_RecDir         DB  "MTSCRECV",0

_DotDot         DB  "..\",0

MyDat:
    INCLUDEBIN "BOOTSECT.DOS"
