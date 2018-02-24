SECTION "HUD", ROMX[$4ab8], BANK[$0b]

InitHUD:
    ld hl, $9c00
    ld de, HUDTilemap
    ld bc, HUD_DIMENSIONS
    call $4d5f
    ld hl, $9c00
    ld de, HUDAttrmap
    ld bc, HUD_DIMENSIONS
    ld a, $01
    ld [REG_VBK], a
    call $4d5f
    xor a
    ld [REG_VBK], a
    ld hl, vtile $e0
    ld a, l
    ld [wDialogueTilesPtr], a
    ld a, h
    ld [wDialogueTilesPtrHi], a
    ld hl, $0210
    ld a, l
    ld [wDialogueBoxWidth], a
    ld a, h
    ld [wDialogueBoxHeight], a
    call PrepareDialogueBox
    ld a, [wSeason]
    add a
    ld b, a
    add a
    add a
    sub b
    ld hl, HUDSeasonNames
    add l
    ld l, a
    jr nc, .nc
    inc h
.nc
    ld de, vtile $e0
    ld c, $06
    call HUDWriteString
    ld a, [$d473]
    inc a
    ld l, a
    ld h, $00
    call FormatNumber
    ld a, [$c509]
    and a
    jr nz, .jr_00b_4b1d
    ld a, $ef
    ld [$c509], a
.jr_00b_4b1d
    ld hl, $c509
    ld de, vtile $e6
    ld c, $02
    call HUDWriteString
    ld a, [wDay]
    ld b, a
    add a
    add b
    ld hl, HUDDayNames
    add l
    ld l, a
    jr nc, .nc2
    inc h
.nc2
    ld de, vtile $e8
    ld c, $03
    call HUDWriteString
    ld a, [wHour]
    cp 12
    jr c, .jr_00b_4b49
    ld a, $02
    jr .jr_00b_4b4a
.jr_00b_4b49
    xor a
.jr_00b_4b4a
    ld hl, HUDAMPM
    add l
    ld l, a
    jr nc, .nc3
    inc h
.nc3
    ld c, $02
    ld de, vtile $eb
    call HUDWriteString
    ld a, [wHour]
    cp 12
    jr c, .c
    sub 12
.c
    ld l, a
    ld h, $00
    call FormatNumber
    ld a, [$c509]
    and a
    jr nz, .jr_00b_4b74
    ld a, $ef
    ld [$c509], a
.jr_00b_4b74
    ld hl, $c509
    ld c, $02
    ld de, vtile $d2
    call HUDWriteString
    ld hl, wStringID
    ld a, [hli]
    ld h, [hl]
    ld l, a
    push hl
    ld a, [wPlayerGender]
    and a
    jr nz, .jr_00b_4bb6

    ld a, [wTool]
    ld b, $01
    ld c, $06
    cp c
    jr nc, .jr_00b_4b98
    cp b
    ccf 
.jr_00b_4b98
    jr c, .jr_00b_4b9c
    jr .jr_00b_4bb6
.jr_00b_4b9c
    ld a, [wTool]
    sub $01
    ld b, a
    ld hl, $d55f
    add l
    ld l, a
    jr nc, .jr_00b_4baa
    inc h
.jr_00b_4baa
    ld a, [hl]
    ld c, a
    add a
    add a
    add c
    ld c, a
    ld a, b
    add c
    add $31
    jr .jr_00b_4bb9
.jr_00b_4bb6
    ld a, [wTool]
.jr_00b_4bb9
    ld [wStringID2], a
    ld a, $02
    ld [wStringID], a
    ld hl, vtile $ed
    ld a, l
    ld [wDialogueTilesPtr], a
    ld a, h
    ld [wDialogueTilesPtrHi], a
    ld hl, $0110
    ld a, l
    ld [wDialogueBoxWidth], a
    ld a, h
    ld [wDialogueBoxHeight], a
    farcall StartDialogue01_52f9
    pop hl
    ld a, l
    ld [wStringID], a
    ld a, h
    ld [wStringID2], a
    ld a, [wTool]
    ld b, $01
    ld c, $06
    cp c
    jr nc, .jr_00b_4bf4
    cp b
    ccf
.jr_00b_4bf4
    jr c, .jr_00b_4c0b
    ld b, a
    add a
    add b
    ld de, $4cab
    add e
    ld e, a
    jr nc, .jr_00b_4c01
    inc d
.jr_00b_4c01
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    inc de
    ld a, [de]
    ld b, a
    jr .jr_00b_4c37
.jr_00b_4c0b
    ld a, [wTool]
    dec a
    ld c, a
    ld b, a
    add a
    add a
    add a
    add b
    ld de, $4d32
    add e
    ld e, a
    jr nc, .jr_00b_4c1d
    inc d
.jr_00b_4c1d
    ld a, c
    ld hl, $d55f
    add l
    ld l, a
    jr nc, .jr_00b_4c26
    inc h
.jr_00b_4c26
    ld a, [hl]
    ld c, a
    add a
    add c
    add e
    ld e, a
    jr nc, .jr_00b_4c2f
    inc d
.jr_00b_4c2f
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    inc de
    ld a, [de]
    ld b, a
.jr_00b_4c37
    ld de, vtile $fc
    call CopyTileFar
    call CopyTileFar
    call CopyTileFar
    call CopyTileFar
    ld a, [$d4b5]
    set 7, a
    set 6, a
    ld [$d4b5], a
    ld a, $90 - HUD_HEIGHT * $8
    ld [$ff00+$9b], a
    ld [REG_WY], a
    ld a, $07
    ld [$ff00+$9c], a
    ld [REG_WX], a
    ret 

HUDSeasonNames: ; 4c5d
    db "Spring"
    db "Summer"
    db "Fall  "
    db "Winter"

HUDDayNames: ; 4c75
    db "Mon"
    db "Tue"
    db "Wed"
    db "Thu"
    db "Fri"
    db "Sat"
    db "Sun"

HUDAMPM: ; 4c8a
    db "AM"
    db "PM"

HUDWriteString: ; 4c8e
; length in c
.loop
    push hl
    push bc
    ld a, [hl]
    swap a
    ld b, a
    and $f0
    ld c, a
    ld a, b
    and $0f
    ld b, a
    ld hl, FontGfx
    add hl, bc
    pop bc
    push bc
    call CopyTile
    pop bc
    pop hl
    inc hl
    dec c
    jr nz, .loop
    ret 

SECTION "HUD data", ROMX[$4d78], BANK[$0b]

HUDTilemap: ; 4d78
    db $d8,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$da
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7,$d7,$e8,$e9,$ea,$d7,$d2,$d3,$d7,$eb,$ec,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$fc,$fd,$df
    db $db,$d7,$ed,$ee,$ef,$f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fe,$ff,$df
    db $dc,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$de

HUDAttrmap: ; 4df0
    db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
    db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
    db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
    db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
    db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
    db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
; 0b:4e68

SECTION "HUD free space", ROMX[$601c], BANK[$0b]
    ds $1000
