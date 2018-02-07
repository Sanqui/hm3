SECTION "Hack RAM", WRAM0[$c300]

wHackOldBank: ds 1
wTempH: ds 1
wTempL: ds 1
wTempA: ds 1

SECTION "Rst $10", ROM0[$0010]
    push af
    ld a, [$4000]
    ld [wHackOldBank], a
    ld a, BANK(HackPredef)
    ld [$2000], a
    pop af
    call HackPredef
    push af
    ld a, [wHackOldBank]
    ld [$2000], a
    pop af
    ret


SECTION "Hack ROM", ROMX[$4000], BANK[$4E]
HackPredef:
    ; save hl
    ld a, h
    ld [wTempH], a
    ld a, l
    ld [wTempL], a
    
    push bc
    ld hl, HackPredefTable
    ld b, 0
    ld a, [wTempA] ; old a
    ld c, a
    add hl, bc
    add hl, bc
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    push bc
    pop hl
    pop bc
    
    push hl
    ld a, [wTempH]
    ld h, a
    ld a, [wTempL]
    ld l, a
    ret ; jumps to hl

hack_entry: MACRO
Hack\1Entry:
    dw Hack\1
ENDM

hack: MACRO
    ld a, (Hack\1Entry-HackPredefTable) / 2
    rst $10
ENDM

HackPredefTable:
    hack_entry Nop

HackNop:
    ret
