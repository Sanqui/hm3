INCLUDE "constants/registers.asm"
INCLUDE "build/charmap.asm"

CHARACTER_NAME_LENGTH   EQU 6
PLAYER_NAME_LENGTH      EQU 4

DIALOGUE_STATE_OFF    EQU 0
DIALOGUE_STATE_1      EQU 1
DIALOGUE_STATE_2      EQU 2
DIALOGUE_STATE_3      EQU 3
DIALOGUE_STATE_4      EQU 4
DIALOGUE_STATE_WAITA  EQU 5
DIALOGUE_STATE_6      EQU 6
DIALOGUE_STATE_ONCE   EQU 7

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

lda: MACRO
    ld a, \2
    ld \1, a
    ENDM


hack: MACRO
    ld a, (Hack\1Entry-HackPredefTable) / 2
    rst $10
ENDM
