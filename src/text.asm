SECTION "Dialogue handling", ROM0[$243b]

SetupDialogue:: ; $243b
; de: pointer table
    push de
    call PrepareDialogueBox
    ld hl, wDialogueTilesPtr
    ld de, wDialogueTileDestination
    ld b, $04
.loop
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .loop

    pop de
    push de
    ld a, e
    ld [$c535], a
    ld a, d
    ld [$c536], a
    pop de
    call GetDialogueAddress
    ld a, [wDialogueState]
    or $01
    ld [wDialogueState], a
    ret 

GetDialogueAddress:
    ld a, [$4000]
    ld [wDialogueBank], a
    ld a, [wStringID]
    ld l, a
    ld h, $00
    add hl, hl
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [wStringID2]
    ld l, a
    ld h, $00
    add hl, hl
    add hl, de
    ld a, [hli]
    ld e, a
    ld d, [hl]
    ld a, e
    ld [wDialogueOffset2], a
    ld a, d
    ld [wDialogueOffset2+1], a
    ret 

PrepareDialogueBox::
    ;ld hl, wDialogueTilesPtr
    ;ld a, [hli]
    ;ld e, a
    hack VWFInit
    nop
    nop
    
    ld d, [hl]
    push de
    ld hl, wDialogueBoxWidth
    ld a, [hli]
    ld c, [hl]
    call GetTilePtr
    ld c, l
    ld b, h
    pop de
.loop:
    ld hl, BlankTilesGFX
    push bc
    call CopyTile
    pop bc
    dec bc
    ld a, b
    or c
    jr nz, .loop

    ret 

BlankTilesGFX: ; $64a9
	INCBIN "gfx/blank_tiles.2bpp"

StartDialogue:
    ld a, [wDialogueState]
    or 1<<DIALOGUE_STATE_ONCE
    ld [wDialogueState], a
    ld a, $80
    ld [$c53d], a

DoDialogue:
    ld a, [wDialogueState]
    bit DIALOGUE_STATE_OFF, a
    ret z

    bit DIALOGUE_STATE_ONCE, a
    jr z, .handle_state
.loop:
    ld a, [wDialogueState]
    call .handle_state
    ld a, [wDialogueState]
    bit DIALOGUE_STATE_OFF, a
    jr nz, .loop
    ret 

.handle_state
    bit DIALOGUE_STATE_6, a
    jp nz, DialogueState6 ; $2564

    bit DIALOGUE_STATE_WAITA, a
    jp nz, DialogueState5 ; $2575

    bit DIALOGUE_STATE_4, a
    jp nz, DialogueState4 ; $2585

    bit DIALOGUE_STATE_3, a
    jp nz, DialogueState3 ; $25a9

    bit DIALOGUE_STATE_2, a
    jp nz, DialogueState2 ; $2647

    ld a, [$c53d]
    bit 7, a
    jr nz, .advance

    ld a, [$ff00+$8a]
    bit 6, a
    jr nz, .jr_2530
    bit 7, a
    jr nz, .jr_2530
    bit 4, a
    jr nz, .jr_2530
    bit 5, a
    jr nz, .jr_2530

    ld a, [$c53c]
    inc a
    ld [$c53c], a
    cp $04
    ret c

    xor a
    ld [$c53c], a
    jr .advance

.jr_2530:
    ld a, [$c53d]
    set 7, a
    ld [$c53d], a

.advance:
    ld a, [wDialogueState]
    bit DIALOGUE_STATE_1, a
    jp nz, Jump_266d

    call Call_29fd
    push de
    call DialogueNextChar
    pop de
    ld a, [wDialogueTextByte]
    and $f0
    cp $f0
    ret z ; command byte, already handled in DialogueNextChar

    call DrawChar
    ld a, [wDialogueTextByte]
    cp $ef
    ret nz

    ld a, $03
    ld [$c53c], a
    ld a, [wDialogueState]
    jp .handle_state


DialogueState6:
    xor a
    ld [$c538], a
    ld [wDialogueState], a
    ld [wDialogueTextByte], a
    ld [$c53c], a
    ld [$c53d], a
    ret 


DialogueState5:
    ld a, [$ff00+$8c]
    cp $01
    ret nz

    ld a, [wDialogueState]
    res 5, a
    ld [wDialogueState], a
    jp DoDialogue


DialogueState4:
    ld a, [$c539]
    ld b, a
    ld a, [$c538]
    inc a
    ld [$c538], a
    cp b
    ret c

    xor a
    ld [$c538], a
    ld a, [wDialogueState]
    res 4, a
    ld [wDialogueState], a
    ld a, [$c53d]
    res 7, a
    ld [$c53d], a
    jp DoDialogue


DialogueState3:
    ld a, [$ff00+$8c]
    cp $01
    jr z, jr_2601

    cp $40
    jr z, jr_25c5

    cp $80
    jr z, jr_25d4

    cp $10
    jr z, jr_25e3

    cp $20
    jr z, jr_25f2

    ld b, $e2
    call Call_2a2d
    ret 


jr_25c5:
    ld a, [$c545]
    bit 0, a
    jr z, jr_25d0

    call Call_2ac6
    ret 


jr_25d0:
    call Call_2a66
    ret 


jr_25d4:
    ld a, [$c545]
    bit 0, a
    jr z, jr_25df

    call Call_2b07
    ret 


jr_25df:
    call Call_2aa8
    ret 


jr_25e3:
    ld a, [$c545]
    bit 0, a
    jr z, jr_25ee

    call Call_2a66
    ret 


jr_25ee:
    call Call_2ac6
    ret 


jr_25f2:
    ld a, [$c545]
    bit 0, a
    jr z, jr_25fd

    call Call_2aa8
    ret 


jr_25fd:
    call Call_2b07
    ret 


jr_2601:
    ld a, [wDialogueState]
    res 3, a
    ld [wDialogueState], a
    ld b, $ef
    ld a, [$c541]
    ld c, a
    call Call_2a3b
    ld a, [wCurName]
    and a
    jp z, DoDialogue

    ld b, $ef
    ld a, [$c542]
    ld c, a
    call Call_2a3b
    ld a, [wCurName]
    cp $01
    jp z, DoDialogue

    ld b, $ef
    ld a, [$c543]
    ld c, a
    call Call_2a3b
    ld a, [wCurName]
    cp $02
    jp z, DoDialogue

    ld b, $ef
    ld a, [$c544]
    ld c, a
    call Call_2a3b
    jp DoDialogue


DialogueState2:
    ld a, [$ff00+$8c]
    cp $01
    jr z, jr_2656

    ld a, [$c539]
    ld b, a
    ld a, [$c538]
    cp b
    ret c

jr_2656:
    xor a
    ld [$c538], a
    ld a, [wDialogueState]
    res 2, a
    ld [wDialogueState], a
    ld a, [$c53d]
    res 7, a
    ld [$c53d], a
    jp DoDialogue


Jump_266d:
    ld hl, wDialogueOffset2
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hli]
    cp $ff
    jr z, jr_2692

    ld [wDialogueTextByte], a
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [wDialogueOffset2+1], a
    call DrawChar
    ld a, [wDialogueTextByte]
    cp $ef
    ret nz

    ld a, [wDialogueState]
    jp DoDialogue.handle_state


jr_2692:
    ld hl, $c533
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [wDialogueOffset2+1], a
    ld a, [wDialogueState]
    res 1, a
    ld [wDialogueState], a
    jp DoDialogue


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
    ld de, FontGfx
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

    ld b, 0
    jp ControlCodeEnd

.tiles
    db $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc
.tiles_end

ControlCodeF7: ; <var>
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
    ld [wDialogueOffset2+1], a
    ld b, 1<<DIALOGUE_STATE_1
    jp ControlCodeEnd


ControlCodeF8: ; <player>
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
    ld [wDialogueOffset2+1], a
    
    ld b, 1<<DIALOGUE_STATE_1
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
    
    ld b, 0
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
    ld [wDialogueOffset2+1], a
    ld a, [$c53d]
    set 7, a
    ld [$c53d], a
    
    ld b, 1<<DIALOGUE_STATE_2
    jp ControlCodeEnd


ControlCodeFB:: ; wait for A
    ld b, 1<<DIALOGUE_STATE_WAITA
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
    ld [wDialogueOffset2+1], a
    ld a, [$c53d]
    set 7, a
    ld [$c53d], a
    
    ld b, 1<<DIALOGUE_STATE_4
    jp ControlCodeEnd

ControlCodeFD: ; <clear> - reset dialogue state
    call PrepareDialogueBox
    xor a
    ld [$c53c], a
    ld [$c53d], a
    ld hl, wDialogueTilesPtr
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, l
    ld [wDialogueTileDestination], a
    ld a, h
    ld [wDialogueTileDestination+1], a
    ld hl, wDialogueBoxWidth
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, l
    ld [wRemainingCharacters], a
    ld a, h
    ld [wRemainingLines], a

    ld b, 0
    jr ControlCodeEnd

ControlCodeFE:: ; \n
    ;ld a, [wRemainingLines]
    ;and a
    ;jr z, ControlCodeFF
    ;
    ;dec a
    ; 7
    hack Newline
    ld b, 0
    jr ControlCodeEnd
    
    ld [wRemainingLines], a
    ld a, [wDialogueBoxWidth]
    ld [wRemainingCharacters], a
    ld hl, wDialogueTileDestination
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [wDialogueTilesPtr+1]
    cp h
    jr z, .first_row

    ld a, l
    and a
    ; would overflow, so stop?
    jr z, .stop

.first_row
    ld a, [wDialogueTilesPtr]
    ld l, a
    ld a, [wDialogueBoxWidth]
    swap a
    ld d, a
    and $f0
    ld e, a
    ld a, d
    and $0f
    ld d, a
    add hl, de
    ld a, l
    ld [wDialogueTileDestination], a
    ld a, h
    ld [wDialogueTileDestination+1], a

.stop
    ld b, 0
    jr ControlCodeEnd

ControlCodeFF::
    ld b, $40
    ; TODO VWFFinish
; fallthru

ControlCodeEnd:
    ld a, [wDialogueState]
    or b
    ld [wDialogueState], a
    ld a, [$c546]
    ld [$2000], a
    xor a
    ld [$3000], a
    ret 

DrawChar:
    ld a, [wDialogueTextByte]
    cp $ed ; XXX replace with control code?
    jr nz, .visible
    
.extra_tile
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
    ld b, a
    ld a, l
    ld [wDialogueOffset2], a
    ld a, h
    ld [wDialogueOffset2+1], a
    ld hl, .extra_tiles
    ld a, b
    add l
    ld l, a
    jr nc, .nc
    inc h
.nc
    ld a, [hl]
    ld [wDialogueTextByte], a
    pop af
    ld [$2000], a
    xor a
    ld [$3000], a
    jr .visible

.extra_tiles
    ; $f0-$f7
    db $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7

.visible
    ;ld a, [wDialogueTextByte]
    ;swap a
    hack DrawChar
    ret
    nop
    
    ld h, a
    and $f0
    ld l, a
    ld a, h
    and $0f
    ld h, a
    ld de, FontGfx
    add hl, de
    ld a, [wDialogueTileDestination]
    ld e, a
    ld a, [wDialogueTileDestination+1]
    ld d, a
    call CopyTile
    ld a, e
    ld [wDialogueTileDestination], a
    ld a, d
    ld [wDialogueTileDestination+1], a
    
    ld a, [wRemainingCharacters]
    and a
    jr z, .no_remaining_characters
    
    dec a
    ld [wRemainingCharacters], a
    ret
    
.no_remaining_characters:
    ld a, [wRemainingLines]
    and a
    ret z

    dec a
    ld [wRemainingLines], a
    ld a, [wDialogueBoxWidth]
    ld [wRemainingCharacters], a
    ret 


Call_29fd:
    ld a, [wDialogueTextByte]
    cp "<arrow>"
    ret z

    ld a, [$c53a]
    bit 7, a
    ret z

    res 7, a
    ld [$c53a], a
    sla a
    push de
    ld hl, $2a25
    add l
    ld l, a
    jr nc, jr_2a19

    inc h

jr_2a19:
    ld e, [hl]
    inc hl
    ld d, [hl]
    call WaitVBlank
    ld a, $d7
    ld [de], a
    ei 
    pop de
    ret 


ArrowTilemapPointers:: ; TODO
    sub d
    sbc h
    ld [hl], d
    sbc h
    ld [de], a
    sbc d
    nop 
    sbc b


Call_2a2d:
    ld a, [$c53b]
    ld hl, $c541
    add l
    ld l, a
    jr nc, jr_2a38

    inc h

jr_2a38:
    ld a, [hl]
    jr jr_2a3c

Call_2a3b:
    ld a, c

jr_2a3c:
    swap a
    ld h, a
    and $f0
    ld l, a
    ld a, h
    and $0f
    ld h, a
    ld a, [wDialogueTilesPtr]
    ld e, a
    ld a, [wDialogueTilesPtr+1]
    ld d, a
    add hl, de
    ld e, l
    ld d, h
    push de
    ld a, b
    swap a
    ld h, a
    and $f0
    ld l, a
    ld a, h
    and $0f
    ld h, a
    ld de, $2fd8
    add hl, de
    pop de
    call CopyTile
    ret 


Call_2a66:
    ld a, [wCurName]
    cp $02
    ret c

    jr nz, jr_2a89

    ld a, [$c53b]
    bit 0, a
    jr z, jr_2a89

    ret 




jr_2a76:
    ld a, [$c53b]
    set 1, a
    ld [$c53b], a
    ld b, $e2
    call Call_2a2d
    ld a, $59
    call $0ee4
    ret 


jr_2a89:
    ld b, $ef
    call Call_2a2d
    ld a, [$c53b]
    bit 1, a
    jr z, jr_2a76

jr_2a95:
    ld a, [$c53b]
    res 1, a
    ld [$c53b], a
    ld b, $e2
    call Call_2a2d
    ld a, $59
    call $0ee4
    ret 


Call_2aa8:
    ld a, [wCurName]
    cp $02
    ret c

    jr nz, jr_2ab8

    ld a, [$c53b]
    bit 0, a
    jr z, jr_2ab8

    ret 


jr_2ab8:
    ld b, $ef
    call Call_2a2d
    ld a, [$c53b]
    bit 1, a
    jr z, jr_2a76

    jr jr_2a95

Call_2ac6:
    ld a, [wCurName]
    and a
    ret z

    cp $02
    jr nz, jr_2ad5

    ld a, [$c53b]
    bit 1, a
    ret nz

jr_2ad5:
    ld b, $ef
    call Call_2a2d
    ld a, [$c53b]
    bit 0, a
    jr z, jr_2af4

jr_2ae1:
    ld a, [$c53b]
    res 0, a
    ld [$c53b], a
    ld b, $e2
    call Call_2a2d
    ld a, $59
    call $0ee4
    ret 


jr_2af4:
    ld a, [$c53b]
    set 0, a
    ld [$c53b], a
    ld b, $e2
    call Call_2a2d
    ld a, $59
    call $0ee4
    ret 


Call_2b07:
    ld a, [wCurName]
    and a
    ret z

    cp $02
    jr nz, jr_2b16

    ld a, [$c53b]
    bit 1, a
    ret nz

jr_2b16:
    ld b, $ef
    call Call_2a2d
    ld a, [$c53b]
    bit 0, a
    jr nz, jr_2ae1

    jr jr_2af4

    ld b, d
    sbc h
    ld c, d
    sbc h
    add d
    sbc h
    adc d
    sbc h

Call_2b2c:
Jump_2b2c:
    xor a
    ld [$d963], a
    ld [$d964], a

Jump_2b33:
    ld a, [$d964]
    cp $03
    jp z, Jump_2bf9

    ld hl, $ff47
    ld bc, $c0a4
    push af
    add l
    ld l, a
    jr nc, jr_2b47

    inc h

jr_2b47:
    pop af
    add c
    ld c, a
    jr nc, jr_2b4d

    inc b

Jump_2b4d:
jr_2b4d:
    call Call_2d41
    ld a, [$d963]
    and a
    jp z, Jump_2b84

    cp $01
    jp z, Jump_2baf

    cp $02
    jp z, Jump_2bd2

    ld a, [bc]
    and $03
    ld e, a
    ld a, [hl]
    and $03
    cp e
    jr c, jr_2b6d

    jr jr_2b76

jr_2b6d:
    inc a
    and $03
    ld e, a
    ld a, [hl]
    and $fc
    or e
    ld [hl], a

jr_2b76:
    xor a
    ld [$d963], a
    ld a, [$d964]
    inc a
    ld [$d964], a
    jp Jump_2b33


Jump_2b84:
    ld a, [bc]
    and $c0
    ld e, a
    ld a, [hl]
    and $c0
    cp e
    jr c, jr_2b90

    jr jr_2ba5

jr_2b90:
    swap a
    srl a
    srl a
    inc a
    and $03
    swap a
    sla a
    sla a
    ld e, a
    ld a, [hl]
    and $3f
    or e
    ld [hl], a

jr_2ba5:
    ld a, [$d963]
    inc a
    ld [$d963], a
    jp Jump_2b4d


Jump_2baf:
    ld a, [bc]
    and $30
    ld e, a
    ld a, [hl]
    and $30
    cp e
    jr c, jr_2bbb

    jr jr_2bc8

jr_2bbb:
    swap a
    inc a
    and $03
    swap a
    ld e, a
    ld a, [hl]
    and $cf
    or e
    ld [hl], a

jr_2bc8:
    ld a, [$d963]
    inc a
    ld [$d963], a
    jp Jump_2b4d

Jump_2bd2:
    ld a, [bc]
    and $0c
    ld e, a
    ld a, [hl]
    and $0c
    cp e
    jr c, jr_2bde

    jr jr_2bef

jr_2bde:
    srl a
    srl a
    inc a
    and $03
    sla a
    sla a
    ld e, a
    ld a, [hl]
    and $f3
    or e
    ld [hl], a

jr_2bef:
    ld a, [$d963]
    inc a
    ld [$d963], a
    jp Jump_2b4d


Jump_2bf9:
    ld bc, $c0a4
    ld hl, $ff47
    ld e, $00

jr_2c01:
    ld a, [hl]
    ld d, a
    ld a, [bc]
    cp d
    jp nz, Jump_2b2c

    inc hl
    inc bc
    inc e
    ld a, e
    cp $03
    jr nz, jr_2c01

    ret 


Call_2c11:
    ld a, [$da2d]
    ld [REG_BGP], a
    ld a, [$da2e]
    ld [REG_OBP0], a
    ld a, [$da2f]
    ld [REG_OBP1], a
    ret 


Call_2c21:
Jump_2c21:
    ld a, [$dcf0]
    and a
    jr z, jr_2c42

jr_2c27:
    ld hl, $66a5
    ld a, $01
    call FarCall
    call Call_2d41
    xor a
    ld [$d962], a
    call Call_2e19
    cp $ff
    jr nz, jr_2c27

    xor a
    ld [$c50d], a
    ret 


jr_2c42:
    xor a
    ld [$d963], a
    ld [$d964], a
    ld hl, $ff47

Jump_2c4c:
    ld a, [$d964]
    cp $03
    jp z, Jump_2d0d

    and a
    jr z, jr_2c5f

    ld c, $00
    ld a, l
    inc a
    ld l, a
    ld a, h
    adc c
    ld h, a

Jump_2c5f:
jr_2c5f:
    push hl
    ld hl, $66a5
    ld a, $01
    call FarCall
    call Call_2d41
    pop hl
    ld a, [$d963]
    and a
    jp z, Jump_2c9e

    cp $01
    jp z, Jump_2cc7

    cp $02
    jp z, Jump_2ce8

    ld a, [hl]
    and $03
    dec a
    cp $ff
    jr z, jr_2c87

    jr jr_2c88

jr_2c87:
    xor a

jr_2c88:
    and $03
    ld c, a
    ld a, [hl]
    and $fc
    or c
    ld [hl], a
    xor a
    ld [$d963], a
    ld a, [$d964]
    inc a
    ld [$d964], a
    jp Jump_2c4c


Jump_2c9e:
    ld a, [hl]
    and $c0
    swap a
    srl a
    srl a
    dec a
    cp $ff
    jr z, jr_2cae

    jr jr_2caf

jr_2cae:
    xor a

jr_2caf:
    and $03
    swap a
    sla a
    sla a
    ld c, a
    ld a, [hl]
    and $3f
    or c
    ld [hl], a
    ld a, [$d963]
    inc a
    ld [$d963], a
    jp Jump_2c5f


Jump_2cc7:
    ld a, [hl]
    and $30
    swap a
    dec a
    cp $ff
    jr z, jr_2cd3

    jr jr_2cd4

jr_2cd3:
    xor a

jr_2cd4:
    and $03
    swap a
    ld c, a
    ld a, [hl]
    and $cf
    or c
    ld [hl], a
    ld a, [$d963]
    inc a
    ld [$d963], a
    jp Jump_2c5f


Jump_2ce8:
    ld a, [hl]
    and $0c
    srl a
    srl a
    dec a
    cp $ff
    jr z, jr_2cf6

    jr jr_2cf7

jr_2cf6:
    xor a

jr_2cf7:
    and $03
    sla a
    sla a
    ld c, a
    ld a, [hl]
    and $f3
    or c
    ld [hl], a
    ld a, [$d963]
    inc a
    ld [$d963], a
    jp Jump_2c5f


Jump_2d0d:
    ld a, [REG_BGP]
    and a
    jp nz, Jump_2c21

    ld a, [REG_OBP0]
    and a
    jp nz, Jump_2c21

    ld a, [REG_OBP1]
    and a
    jp nz, Jump_2c21

    xor a
    ld [$d963], a
    ld [$d964], a
    ld [$c50d], a
    ret 


Call_2d2a:
    ld a, [REG_BGP]
    ld [$da2d], a
    ld a, [REG_OBP0]
    ld [$da2e], a
    ld a, [REG_OBP1]
    ld [$da2f], a
    xor a
    ld [REG_BGP], a
    ld [REG_OBP0], a
    ld [REG_OBP1], a
    ret 


Call_2d41:
    ld de, $01b5

jr_2d44:
    nop 
    nop 
    nop 
    dec de
    ld a, d
    or e
    jr nz, jr_2d44

    ret 


Call_2d4d:
    ld a, [$dcf0]
    and a
    jr nz, jr_2d5f

    call Call_2d2a
    ld a, [$c0a3]
    ld [REG_LCDC], a
    call Call_2b2c
    ret 


jr_2d5f:
    ld a, [$c0a3]
    ld [REG_LCDC], a
    call Call_2d41
    ret 


Call_2d68:
    ld a, [$d962]
    bit 7, a
    and a
    ret z

    bit 6, a
    jr nz, jr_2d8d

    bit 5, a
    jr nz, jr_2d82

    call Call_2df4
    cp $ff
    ret nz

    xor a
    ld [$d962], a
    ret 


jr_2d82:
    call Call_2e19
    cp $ff
    ret nz

    xor a
    ld [$d962], a
    ret 


jr_2d8d:
    bit 5, a
    jr nz, jr_2d9c

    call Call_2dad
    cp $ff
    ret nz

    xor a
    ld [$d962], a
    ret 


jr_2d9c:
    call Call_2dd2
    cp $ff
    ret nz

    xor a
    ld [$d962], a
    ret 


    or $80
    ld [$d962], a
    ret 


Call_2dad:
    ld a, [$dcf0]
    and a
    jr z, jr_2dc5

    ld hl, $5d94
    ld a, $01
    call FarCall
    ld a, c
    cp $ff
    jr nz, jr_2dc3

    ld a, $ff
    ret 


jr_2dc3:
    xor a
    ret 


jr_2dc5:
    ld a, $e4
    ld [REG_BGP], a
    ld a, $d2
    ld [REG_OBP0], a
    ld [REG_OBP1], a
    ld a, $ff
    ret 


Call_2dd2:
    ld a, [$dcf0]
    and a
    jr z, jr_2dea

    ld hl, $5cb4
    ld a, $01
    call FarCall
    ld a, c
    cp $ff
    jr nz, jr_2de8

    ld a, $ff
    ret 


jr_2de8:
    xor a
    ret 


jr_2dea:
    xor a
    ld [REG_BGP], a
    ld [REG_OBP0], a
    ld [REG_OBP1], a
    ld a, $ff
    ret 


Call_2df4:
    ld a, [$dcf0]
    and a
    jr z, jr_2e0c

    ld hl, $5ee3
    ld a, $01
    call FarCall
    ld a, c
    cp $ff
    jr nz, jr_2e0a

    ld a, $ff
    ret 


jr_2e0a:
    xor a
    ret 


jr_2e0c:
    ld a, $e4
    ld [REG_BGP], a
    ld a, $d2
    ld [REG_OBP0], a
    ld [REG_OBP1], a
    ld a, $ff
    ret 


Call_2e19:
    ld a, [$dcf0]
    and a
    jr z, jr_2e31

    ld hl, $5bd3
    ld a, $01
    call FarCall
    ld a, c
    cp $ff
    jr nz, jr_2e2f

    ld a, $ff
    ret 


jr_2e2f:
    xor a
    ret 


jr_2e31:
    xor a
    ld [REG_BGP], a
    ld [REG_OBP0], a
    ld [REG_OBP1], a
    ld a, $ff
    ret 

SECTION "Font GFX", ROM0[$2fd8]
FontGfx:
	INCBIN "gfx/font.2bpp"

SECTION "Pointers to PrintDialogue functions in different banks", ROMX[$44be], BANK[$2f]
PrintDialoguePointers:
    pwb PrintDialogue0 ; $4001, $2e
    pwb PrintDialogue1 ; $4001, $43
    pwb PrintDialogue2 ; $4001, $18
    pwb PrintDialogue3 ; $57f6, $50
    pwb PrintDialogue4 ; $4001, $42
    pwb PrintDialogue5 ; $4001, $4b
