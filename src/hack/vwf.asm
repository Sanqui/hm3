CopyColumn:
    ; b = source column
    ; c = dest column
    ; de = source number
    ; hl = dest number
    push hl
    push de
    ld a, $08
.Copy
    push af
    ld a, [de]
    and a, b
    jr nz, .CopyOne
.CopyZero
    ld a, %11111111
    xor c
    and [hl]
    jp .Next
.CopyOne
    ld a, c
    or [hl]
.Next
    ld [hli],a
    inc de
    pop af
    dec a
    jp nz, .Copy
    pop de
    pop hl
    ret

VWFInit:
    xor a
    ld [wVWFCurTileCol], a
    ld [wVWFCurTileNum], a
    ld hl, wVWFBuildArea2
    ld b, 16
    xor a
    call MyFillMemory
    ret

VWFDrawChar:
    push de
    push hl
    ld [wVWFChar], a
    
    ; Store the character tile in BuildArea0.
    ld hl, VWFFont
    ld b, 0
    ld c, a
    ld a, $8
    call MyMultiply
    ld bc, $0008
    ld de, wVWFBuildArea0
    call MyCopyData ; copy bc source bytes from hl to de
    
    ld a, $1
    ld [wVWFNumTilesUsed], a
    
    ; Get the character length from the width table.
    ld a, [wVWFChar]
    ld c, a
    ld b, $00
    ld hl, VWFTable
    add hl, bc
    ld a, [hl]
    ld [wVWFCharWidth], a
.WidthWritten
    ; Set up some things for building the tile.
    ; Special cased to fix column $0, which is invalid (not a power of 2)
    ld de, wVWFBuildArea0
    ld hl, wVWFBuildArea2
    ;ld b, a
    ld b, %10000000
    ld a, [wVWFCurTileCol]
    and a
    jr nz, .ColumnIsFine
    ld a, $80
.ColumnIsFine
    ld c, a ; a
.DoColumn
    ; Copy the column.
    call CopyColumn
    rr c
    jr c, .TileOverflow
    rrc b
    ld a, [wVWFCharWidth]
    dec a
    ld [wVWFCharWidth], a
    jr nz, .DoColumn
    jr .Done
.TileOverflow
    ld c, $80
    ld a, $2
    ld [wVWFNumTilesUsed], a
    ld hl, wVWFBuildArea3
    jr .ShiftB
.DoColumnTile2
    call CopyColumn
    rr c
.ShiftB
    rrc b
    ld a, [wVWFCharWidth]
    dec a
    ld [wVWFCharWidth], a
    jr nz, .DoColumnTile2
.Done
    ld a, c
    ld [wVWFCurTileCol], a
    
    ; 1bpp -> 2bpp
    ld b, $10
    ld de, wVWFBuildArea2
    ld hl, wVWFCopyArea
    
.doubleloop
    ld a, $ff
    ld [hli], a
    ld a, [de]
    inc de
    ld [hli], a
    dec b
    jr nz, .doubleloop

    ; Get the tileset offset.
    ;ld hl, $8800
    lda l, [wDialogueTilesPtr]
    lda h, [wDialogueTilesPtr+1]
    ld a, [wVWFCurTileNum]
    ld b, $0
    ld c, a
    ld a, 16
    call MyMultiply
    
    push hl
    pop de
    ld hl, wVWFCopyArea
    
    ; Write the new tile(s)
    
    call CopyTile

    ld a, [wVWFNumTilesUsed]
    dec a
    jr z, .copied
    
    call CopyTile

.copied

    ld a, [wVWFNumTilesUsed]
    dec a
    dec a
    jr nz, .SecondAreaUnused
    
    ; If we went over one tile, make sure we start with it next time.
    ; also move through the tilemap.
    ld a, [wVWFCurTileNum]
    inc a
    ld [wVWFCurTileNum], a
    
    ld hl, wVWFBuildArea3
    ld de, wVWFBuildArea2
    ld bc, 8
    call MyCopyData
    
    ld hl, wVWFBuildArea3
    ld b, 8
    xor a
    call MyFillMemory
    
    ;ld hl, wVWFCopyArea
    ;ld b, 16
    ;xor a
    ;call MyFillMemory

.SecondAreaUnused
    
.AlmostDone
    pop hl
    pop de
    ret
    
VWFTable:
    db 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
    db 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
    db 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 6, 5, 3, 4, 5, 3
    db 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 5, 5, 0, 0
    
    db 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
    db 6, 6, 6, 6, 6, 6, 6, 8, 8, 8, 8, 8, 8, 8, 8, 8

    db 6, 5, 4, 5, 5, 6, 5, 4, 5, 5, 6, 5, 4, 5, 5, 6
    db 5, 4, 5, 5, 5, 5, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8
    
    db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
    db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
    db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
    db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
    db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
    db 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
    db 8, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 3, 8, 4 ; <- space
    db 4, 8, 4, 7, 5, 3, 8, 8, 8, 3, 3, 7, 2, 8, 8, 8

VWFFont:
    INCBIN "gfx/font_vwf.1bpp"
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
