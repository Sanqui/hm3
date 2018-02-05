SECTION "dialogue handling", ROM0[$26AB]
DialogueNextChar::
    ld a, [$4000]
    push af
    ld a, [wDialogueBank]
    ld [$2000], a
    xor a
    ld [$3000], a
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hli]
    ld [wDialogueTextByte], a
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [wDialogueOffset2+1], a
    ld a, [wDialogueTextByte]
    and $f0
    cp $f0
    jr z, DialogueNextChar.control
.letter
    pop af
    ld [$2000], a
    xor a
    ld [$3000], a
    ret 
.control
    pop af
    ld [$c546], a
    ld a, [wDialogueTextByte]
    and $0f
    jumptable
ControlByteJumpTable::
    dw ControlCodeF0 ; $2707
    dw ControlCodeF1 ; $2707
    dw ControlCodeF2 ; $2707
    dw ControlCodeF3 ; $270c
    dw ControlCodeF4 ; $273c
    dw ControlCodeF5 ; $275a
    dw ControlCodeF6 ; $2791
    dw ControlCodeF7 ; $2834
    dw ControlCodeF8 ; $285b
    dw ControlCodeF9 ; $288a
    dw ControlCodeFA ; $28bb
    dw ControlCodeFB ; $28da
    dw ControlCodeFC ; $28df
    dw ControlCodeFD ; $28fe
    dw ControlCodeFE ; $2928
    dw ControlCodeFF ; $2966

ControlCodeF0:
ControlCodeF1:
ControlCodeF2:
    ld b, $00
    jp ControlCodeEnd

ControlCodeF3::
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld de, $c53f
    ld b, $04

.loop
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .loop

    ld a, [$c53b]
    ld hl, $c53f
    add l
    ld l, a
    jr nc, .nc
    inc h
.nc
    ld a, [hl]
    ld [$c527], a
    
    ld a, [$c535]
    ld e, a
    ld a, [$c536]
    ld d, a
    call $243b
    ld b, $00
    jp ControlCodeEnd


ControlCodeF4::
    ld de, $9c01
    ld hl, .table
    ld c, .table_end-.table
.loop
    ld b, [hl]
    call $1a3a
    inc de
    inc hl
    dec c
    jr nz, .loop

    ld b, $00
    jp ControlCodeEnd

.table
    db $d9, $d9, $d9, $d9, $d9, $d9, $d9, $d9
.table_end

ControlCodeF5: ; <ask> (yes/no)
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hli]
    ld [$c53f], a
    ld a, [hli]
    ld [$c540], a
    ld [$c53b], a
    ld a, [hli]
    ld [$c541], a
    ld a, [hli]
    ld [$c542], a
    ld a, [hli]
    ld [$c543], a
    ld a, [hli]
    ld [$c544], a
    ld a, [hli]
    ld [$c545], a
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [wDialogueOffset2+1], a
    ld b, $e2
    call $2a2d
    ld b, $08
    jp ControlCodeEnd


ControlCodeF6: ; <name>
    ld de, $8b60
rept CHARACTER_NAME_LENGTH
    call ClearTile
endr
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hli] ; name byte
    push af
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [wDialogueOffset2+1], a
    pop af
    ld [$c53f], a
    add a
    ld de, NameTable
    add e
    ld e, a
    jr nc, .nc
    inc d
.nc:
    ld a, [$d7d2]
    push af
    ld a, BANK(NameTable)
    ld [$d7d2], a
    ld l, e
    ld h, d
    call ReadBCFar
    pop af
    ld [$d7d2], a
    ld l, b
    ld h, c
    ld de, $8b60
    ld c, $10
    ld a, [$d7d2]
    push af

.charloop
    ld a, c
    and a
    jr z, .done

    ld a, BANK(NameTable)
    ld [$d7d2], a
    push bc
    push de
    push hl
    call ReadBCFar
    ld a, b
    pop hl
    pop de
    pop bc
    cp "@"
    jr z, .done

    push bc
    push hl
    push de
    swap a
    ld h, a
    and $f0
    ld l, a
    ld a, h
    and $0f
    ld h, a
    ld de, $2fd8 ; FontGfx????
    add hl, de
    pop de
    call CopyTile
    pop hl
    pop bc
    inc hl
    dec c
    jr .charloop

.done
    pop af
    ld [$d7d2], a
    ld de, $9c01
    ld hl, .tiles
    ld c, .tiles_end-.tiles
.loop
    ld b, [hl]
    call $1a3a
    inc hl
    inc de
    dec c
    jr nz, .loop

    ld b, $00
    jp ControlCodeEnd

.tiles
    db $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc
.tiles_end

ControlCodeF7::
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hl]
    push af
    inc hl
    ld a, l
    ld [$c533], a
    ld a, h
    ld [$c534], a
    pop af
    ld hl, $c547
    add l
    ld l, a
    jr nc, .nc
    inc h
.nc
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [$c52e], a
    ld b, $02
    jp ControlCodeEnd


ControlCodeF8::
    ld hl, wPlayerName
    ld de, $c55f
    ld b, PLAYER_NAME_LENGTH

.loop:
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .loop

    ld a, "@"
    ld [de], a
    
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, l
    ld [$c533], a
    ld a, h
    ld [$c534], a
    ld hl, $c55f
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [$c52e], a
    
    ld b, $02
    jp ControlCodeEnd


ControlCodeF9:: ; arrow
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hli]
    push af
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [wDialogueOffset2+1], a
    pop af
    push af ; nice, victor
    or $80
    ld [$c53a], a
    pop af
    sla a
    ld hl, ArrowTilemapPointers
    add l
    ld l, a
    jr nc, .nc
    inc h
.nc
    ld e, [hl]
    inc hl
    ld d, [hl]
    call WaitVBlank
    ld a, $d4 ; down arrow tile
    ld [de], a
    ei
    ld b, $00
    jp ControlCodeEnd


ControlCodeFA:
; only used once:
; "This is how <player>'s new Harvest Moon adventure began…<fa>y@"
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hli]
    ld [$c539], a
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [$c52e], a
    ld a, [$c53d]
    set 7, a
    ld [$c53d], a
    ld b, $04
    jp ControlCodeEnd


ControlCodeFB:: ; wait for A
    ld b, $20
    jp ControlCodeEnd


ControlCodeFC::
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hli]
    ld [$c539], a
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [$c52e], a
    ld a, [$c53d]
    set 7, a
    ld [$c53d], a
    ld b, $10
    jp ControlCodeEnd

ControlCodeFD: ; <clear> - reset dialogue state
    call ClearDialogueBox
    xor a
    ld [$c53c], a
    ld [$c53d], a
    ld hl, $c529
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, l
    ld [$c52f], a
    ld a, h
    ld [$c530], a
    ld hl, wDialogueBoxWidth
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, l
    ld [wRemainingCharacters], a
    ld a, h
    ld [wRemainingLines], a
    ld b, $00
    jr ControlCodeEnd

ControlCodeFE::
    ld a, [wRemainingLines]
    and a
    jr z, ControlCodeFF

    dec a
    ld [wRemainingLines], a
    ld a, [wDialogueBoxWidth]
    ld [wRemainingCharacters], a
    ld hl, $c52f
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [$c52a]
    cp h
    jr z, .jr_000_2948

    ld a, l
    and a
    jr z, .jr_000_2962

.jr_000_2948:
    ld a, [$c529]
    ld l, a
    ld a, [$c52b]
    swap a
    ld d, a
    and $f0
    ld e, a
    ld a, d
    and $0f
    ld d, a
    add hl, de
    ld a, l
    ld [$c52f], a
    ld a, h
    ld [$c530], a

.jr_000_2962:
    ld b, $00
    jr ControlCodeEnd

ControlCodeFF::
    ld b, $40
; fallthru

ControlCodeEnd:
    ld a, [$c537]
    or b
    ld [$c537], a
    ld a, [$c546]
    ld [$2000], a
    xor a
    ld [$3000], a
    ret 

