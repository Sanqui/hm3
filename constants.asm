INCLUDE "constants/registers.asm"
INCLUDE "build/charmap.asm"

H_TMP EQU $FFFE

CHARACTER_NAME_LENGTH   EQU 6
NAME_LENGTH             EQU 4
PLAYER_NAME_LENGTH      EQU NAME_LENGTH
PLAYER_NAME_LENGTH_CODE EQU 4

START_MENU_WIDTH  EQU 8
START_MENU_HEIGHT EQU 16
START_MENU_DIMENSIONS EQU START_MENU_WIDTH << 8 | START_MENU_HEIGHT

HUD_HEIGHT      EQU 2
HUD_WIDTH       EQU 20
HUD_DIMENSIONS  EQU HUD_WIDTH << 8 | HUD_HEIGHT

DIALOGUE_STATE_OFF    EQU 0
DIALOGUE_STATE_1      EQU 1
DIALOGUE_STATE_2      EQU 2
DIALOGUE_STATE_3      EQU 3
DIALOGUE_STATE_4      EQU 4
DIALOGUE_STATE_WAITA  EQU 5
DIALOGUE_STATE_END    EQU 6
DIALOGUE_STATE_ONCE   EQU 7

DIALOGUE_DELAY_BIT    EQU 7
DIALOGUE_DELAY_FRAMES EQU 0

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

farcall: MACRO
    ld hl, \1
    ld a, BANK(\1)
    call FarCall
ENDM

addhla: MACRO
    add l
    ld l, a
    jr nc, .nc\@
    inc h
.nc\@
ENDM

adddea: MACRO
    add e
    ld e, a
    jr nc, .nc\@
    inc d
.nc\@
ENDM

vtile EQUS "$8800 + $800 ^ $10 * "

; because I am particularly lazy
ORG: MACRO
    SECTION "Lazy Section \@", ROMX[\2], BANK[\1]
ENDM


hack: MACRO
    ld a, (Hack\1Entry-HackPredefTable) / 2
    rst $10
ENDM
