WriteTilemapByteClone:
    push af
    di
.loop
    ld a, [$ff41]
    bit 1, a
    jr nz, .loop
    pop af
    ld [hli], a
    ei
    ret

LoadMenuStrings:
    lda [wMenuBlankTileNum], [hli]
LoadMenuString:
    lda [wMenuStringX], [hli]
    cp $ff
    ret z
    lda [wMenuStringY], [hli]
    lda [wMenuStringPad], [hli]
    ld a, [hli]
    cp $ff
    jr z, .uselasttile
    ld [wMenuTileNum], a
.uselasttile
    ;ld a, [hli]
    ;push hl
    ;ld h, [hl]
    ;ld l, a
    call PrintMenuString
    
    push hl
    ld hl, $9800
    ld bc, $0020
    ld a, [wMenuStringY]
    call MyMultiply
    
    ld a, [wMenuStringX]
    add l
    ld l, a
    jr nc, .nc
    inc h
.nc
    ld a, [wMenuTileNum]
    ld b, a
    ld a, [wVWFCurTileNum]
    inc a
    sub b
    ; number of tiles used by vwf
    ld b, a
    ld c, a
    ld a, [wMenuTileNum]
.loop
    call WriteTilemapByteClone
    inc a
    dec b
    jr nz, .loop
    
    ld a, [wMenuStringPad]
    sub c
    jr c, .done
    jr z, .done
    ld b, a
.padloop
    ld a, [wMenuBlankTileNum]
    call WriteTilemapByteClone
    dec b
    jr nz, .padloop
.done
    ld a, [wVWFCurTileNum]
    inc a
    ld [wMenuTileNum], a
    
    pop hl
    jr LoadMenuString
    
PrintMenuString:
    push hl
    call VWFInit
    lda [wVWFCurTileNum], [wMenuTileNum]
    lda [wVWFTilesPtr], $00
    lda [wVWFTilesPtr+1], $90
    pop hl
.loop
    ld a, [hli]
    cp "@"
    jr z, .done
    push hl
    call VWFDrawChar
    pop hl
    jr .loop
.done
    push hl
    call VWFFinish
    pop hl
    ret

MainMenuStringDefinitions:
    db $ff
    db 7,  2, 5, $00, "Start@"
    db 7,  4, 4,  -1, "Load@"
    db 7,  6, 4,  -1, "Copy@"
    db 7,  8, 5,  -1, "Erase@"
    db 7, 10, 5,  -1, "Trade@"
    db -1

