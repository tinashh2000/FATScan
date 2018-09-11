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

DiskParam   STRUC
    dspSize             DW  ?
    dspFlags            DW  ?
    dspCylinders        DD  ?
    dspHeads            DD  ?
    dspSectorsPerTrack  DD  ?
    dspSectors          DQ  ?
    dspBytesPerSector   DW  ?
    dspConfig           DD  ?
    dspSignature        DW  ?
    dspSizeDevPath      DB  ?
    dspRes0             DB  3   DUP(?)
    dspAscHostBus       DB  4   DUP(?)
    dspAscInterface     DB  8   DUP(?)
    dspBufInterfacePath DB  8   DUP(?)
    dspBufDevicePath    DB  8   DUP(?)
    dspRes1             DB  ?
    dspCheckSum         DB  ?
DiskParam   ENDS

DiskStruct  STRUC
    dpSize              DB  ?
    dpRes0              DB  ?
    dpNumSectors        DW  ?
    dpBuffer            DD  ?
    dpSector            DQ  ?
    dpBuffer64          DQ  ?
DiskStruct  ENDS
