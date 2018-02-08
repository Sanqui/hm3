INCLUDE "constants.asm"

INCLUDE "src/text.asm"
INCLUDE "src/text_sections.asm"
INCLUDE "src/strings.asm"

INCLUDE "src/hack/hack.asm"

blankbank: MACRO
SECTION "Blank bank \1", ROMX[$4000], BANK[\1]
    db \1 ; BANK(@) doesn't work atm
    ds $3fff
ENDM


;    blankbank $4e
;    blankbank $4f
;    blankbank $51
;    blankbank $52
;    blankbank $53
    blankbank $54
    blankbank $55
    blankbank $56
    blankbank $57
    blankbank $58
    blankbank $59
    blankbank $5a
    blankbank $5b
    blankbank $5c
    blankbank $5d
    blankbank $5e
    blankbank $5f
    blankbank $62
    blankbank $63
    blankbank $64
    blankbank $65
