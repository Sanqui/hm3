INCLUDE "build/charmap.asm"

CHARACTER_NAME_LENGTH   EQU 6
PLAYER_NAME_LENGTH      EQU 4

jumptable: MACRO
    rst $0
ENDM

dwb: MACRO
    dw \1
    db \2
ENDM

dbw: MACRO
    db \1
    dw \2
ENDM

pwb: MACRO
    dwb \1, BANK(\1)
ENDM
