INCLUDE "constants/registers.asm"
INCLUDE "build/charmap.asm"

A_ EQU $0
B_ EQU $1
SELECT EQU $2
START EQU $3
RIGHT EQU $4
LEFT EQU $5
UP EQU $6
DOWN EQU $7

H_TMP EQU $FFFE

CHARACTER_NAME_LENGTH   EQU 6
NAME_LENGTH             EQU 8
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

MACRO jumptable
    rst $0
ENDM

MACRO dwb
    dw \1
    db \2
ENDM

MACRO dbw
    db \1
    dw \2
ENDM

MACRO pwb
    dwb \1, BANK(\1)
ENDM

MACRO lda
    ld a, \2
    ld \1, a
    ENDM

MACRO farcall
    ld hl, \1
    ld a, BANK(\1)
    call FarCall
ENDM

MACRO addhla
    add l
    ld l, a
    jr nc, .nc\@
    inc h
.nc\@
ENDM

MACRO adddea
    add e
    ld e, a
    jr nc, .nc\@
    inc d
.nc\@
ENDM

pusha: MACRO
    push af
    push bc
    push de
    push hl
ENDM

popa: MACRO
    pop hl
    pop de
    pop bc
    pop af
ENDM

vtile EQUS "$8800 + $800 ^ $10 * "

; because I am particularly lazy
MACRO ORG
    SECTION "Lazy Section \@", ROMX[\2], BANK[\1]
ENDM


hack: MACRO
    ld a, (Hack\1Entry-HackPredefTable) / 2
    rst $10
ENDM
