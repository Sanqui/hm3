SECTION "String Handling", ROMX[$4187], BANK[$79]

PrepareStringDialogueBox:
    ; this is some initializing function which
    ; doesn't do much if skipped.
    ; Probably since dialogues do much of the same and
    ; stay in RAM.
    xor a
    ld [wDialogueState], a
    ;hack PrepareStringDialogueBox
    ld hl, wDialogueTilesPtr
    ld a, $00
    ld [hli], a
    ld a, $8e
    ld [hli], a
    ld a, $10
    ld [hli], a
    ld [hl], $02
    jp PrepareDialogueBox

    setup_start_dialogue_overflow_asm 79_44a0, $0e-3, 50_4b7e

PrintStringID:
    ld hl, wStringID
    ld a, [hli]
    ld d, a
    ld e, [hl]
    call StringIDInDToPointer
    call PrintString
    ret 

PrintStringIDX:
    ld hl, wStringID
    ld a, [hli]
    ld d, a
    ld e, [hl]
    call StringIDInDToPointer
    call PrintString
    ;call $4419
    ret 

PrintVarString:
    ld hl, wVarString
    call PrintString
    ret

; routines for formatting strings follow.
; I may disassemble them on a different day.

SECTION "String Handling 2", ROMX[$43b5], BANK[$79]
    
PrintString::
; string in hl
; b: tiles to clear (reserve)
    push hl
    nop
    hack PrintStringInit
    ;ld a, c
    ;call TileNumToPointer
    ld d, h
    ld e, l
    pop hl
    ld a, b
    or a
    nop
    nop
    ;jr z, .no_padding
.next
    ld a, [hli]
    cp $ed
    jr nz, .got_tile

    ld a, [hli]
    push de
    ld de, .high_tiles
    add e
    ld e, a
    jr nc, .nc
    inc d
.nc
    ld a, [de]
    pop de
    jr .got_tile

.high_tiles
    db $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8

.got_tile
    cp a, "@"
    jr z, .pad
    
    ld [H_TMP], a
    hack PrintStringWriteTile
    ;push hl
    ;call WriteFontTile
    ;pop hl
    dec b
    jr nz, .next
    ret 

.pad
    hack PrintStringEnd
    nop
    nop
    nop
    nop
    nop
    ;ld a, " "
    ;call WriteFontTile
    ;dec b
    ;jr nz, .pad

    ret 

; this is now dead code

.no_padding
.next_no_padding
    ld a, [hli]
    cp $ed
    jr nz, .got_tile2

    ld a, [hli]
    push de
    ld de, .high_tiles2
    add e
    ld e, a
    jr nc, .nc2
    inc d
.nc2
    ld a, [de]
    pop de
    jr .got_tile2

.high_tiles2
    db $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8

.got_tile2
    cp a, "@"
    ret z

    push hl
    call WriteFontTile
    pop hl
    jr .next_no_padding

Call_079_4419:
    push hl
    ld a, c
    call TileNumToPointer
    ld d, h
    ld e, l
    pop hl
    push hl
    ld c, $ff

jr_079_4424:
    inc c
    ld a, [hli]
    inc a
    jr nz, jr_079_4424

    pop hl
    ld a, b
    sub c
    jr c, jr_079_443b

    jr z, jr_079_443b

    push hl
    ld b, a

jr_079_4432:
    ld a, $ef
    call WriteFontTile
    dec b
    jr nz, jr_079_4432

    pop hl

jr_079_443b:
    ld a, [hli]
    cp $ed
    jr nz, @+$19

    ld a, [hli]
    push de
    ld de, $444e
    add e
    ld e, a
    jr nc, jr_079_444a

    inc d

jr_079_444a:
    ld a, [de]
    pop de
    jr @+$0b

    ld a, [$ff00+$f1]
    ld a, [$ff00+c]
    di 
    DB $f4
    push af
    or $f7
    ld hl, sp-$02
    rst $38
    ret z

    push hl
    call WriteFontTile
    pop hl
    jr jr_079_443b

WriteFontTile:
    push bc
    swap a
    ld b, a
    and $f0
    ld c, a
    ld a, b
    and $0f
    ld b, a
    ld hl, FontGfx
    add hl, bc
    ld b, $10
    call VCopy79
    pop bc
    ret 


StringIDInDToPointer:
    ld a, d
StringIDToPointer:
    ld hl, Metatable79_44a0
    call GetPointer
    ld a, e
    call GetPointer
    ret 


    ld hl, $c548
    ld a, b
    and $0f
    ld [hld], a
    ld a, b
    swap a
    and $0f
    ld [hl], a
    ld b, $02
    call PrintString
    ret 


Call_079_4496:
    ld de, $ff0a

jr_079_4499:
    inc d
    sub e
    jr nc, jr_079_4499

    add e
    ld e, a
    ret 

; metatable follows

 




