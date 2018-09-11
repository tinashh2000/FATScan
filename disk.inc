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

TICK_LIMIT  =   3
BACK_TRACK  =   200
ERRORDEL    =   0

BAD_ADVANCE =   25
RSTART      =   0
REND        =   -1

MBR STRUC
                DB  1BEh    dup(?)
    mbrBootFlag         DB  ?
    mbrBeginHead        DB  ?
    mbrBeginSecCyl      DW  ?
    mbrFileSysCode      DB  ?
    mbrEndHead          DB  ?
    mbrSecCyl           DW  ?
    mbrBeginAbsSector   DD  ?
    mbrTotalAbsSector   DD  ?
                        DB  16*3    dup(?)
    mbrSig              DW  ?
MBR ENDS
