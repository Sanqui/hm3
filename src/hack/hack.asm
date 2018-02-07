SECTION "Hack RAM", WRAM0[$c300]

wHackOldBank: ds 1
wTempH: ds 1
wTempL: ds 1
wTempA: ds 1

wVWFLetterNum:
    ds 1
wVWFChar:
    ds 1
wVWFTileLoc:
    ds 2
wVWFFirstTileNum:
    ds 1
wVWFCurTileNum:
    ds 1
wVWFCurTileCol:
    ds 1
wVWFNumTilesUsed:
    ds 1
wVWFCharWidth:
    ds 1

wVWFBuildArea0:
    ds 8
wVWFBuildArea1:
    ds 8
wVWFBuildArea2:
    ds 8
wVWFBuildArea3:
    ds 8
    
wVWFCopyArea:
    ds $40

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
db $4e

MyCopyData:
; copy bc bytes of data from hl to de
.loop
	ld a, [hli]
	ld [de],a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, .loop
	ret

MyFillMemory:
; write a in hl b times
.loop
    ld [hli], a
    dec b
    jr nz, .loop
    ret

MyMultiply:
; Add bc * a to hl.
	and a
	ret z
.loop
	add hl, bc
	dec a
	jr nz, .loop
	ret
    
HackPredef:
    ld [wTempA], a
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

HackPredefTable:
    hack_entry Nop
    hack_entry VWFInit
    hack_entry DrawChar
    hack_entry Newline

HackNop:
    ret

HackVWFInit:
    call VWFInit
    ld hl, wDialogueTilesPtr
    ld a, [hli]
    ld e, a
    ret

HackDrawChar:
    ld a, [wDialogueTextByte]
    call VWFDrawChar
    ret

HackNewline:
    call VWFInit
    ld a, [wDialogueBoxWidth]
    ld [wVWFCurTileNum], a
    ret

INCLUDE "src/hack/vwf.asm"









