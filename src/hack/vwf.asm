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
    ld [wVWFHangingTile], a
    
    ld a, 1
    ld [wVWFFast], a
    ld hl, wVWFBuildArea2
    ld b, 16
    xor a
    call MyFillMemory
    
    ld b, $10
    ld hl, wVWFCopyArea
.loop
    ld a, $ff
    ld [hli], a
    xor a
    ld [hli], a
    dec b
    jr nz, .loop
    ret


VWFCopyTiles:
    ; a takes number of tiles to copy
    ; 1bpp -> 2bpp
    sla a
    sla a
    sla a
    ld b, a
    ld de, wVWFBuildArea2
    ld hl, wVWFCopyArea
    
.doubleloop
    inc hl
    ld a, [de]
    inc de
    ld [hli], a
    dec b
    jr nz, .doubleloop

    ; Get the tileset offset.
    ;ld hl, $8800
    lda l, [wVWFTilesPtr]
    lda h, [wVWFTilesPtr+1]
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
    ret z
    
    call CopyTile
    ret

VWFShiftTile:
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
    ret

VWFDrawChar:
    push de
    push hl
    ld [wVWFChar], a
    
    
    ld a, [wVWFChar]
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
    cp $80
    jr nz, .dontshift
    push bc
    push de
    push hl
    call VWFShiftTile
    ld a, $1
    ld [wVWFNumTilesUsed], a
    pop hl
    pop de
    pop bc
.dontshift
    ld a, [wVWFCurTileCol]
    and a
    jr nz, .ColumnIsFine
    ld a, $80
.ColumnIsFine
    ld c, a ; a
.DoColumn
    ; Copy the column.
    call CopyColumn
    rrc b
    ld a, [wVWFCharWidth]
    dec a
    ld [wVWFCharWidth], a
    jr z, .Done
    rrc c
    jr c, .TileOverflow
    jr .DoColumn
.TileOverflow
    ld c, $80
    ld a, $2
    ld [wVWFNumTilesUsed], a
    ld hl, wVWFBuildArea3
    ;jr .ShiftB
.DoColumnTile2
    call CopyColumn
    rrc b
    ld a, [wVWFCharWidth]
    dec a
    ld [wVWFCharWidth], a
    jr z, .Done
    rrc c
    jr .DoColumnTile2
.Done
    rrc c
    ld a, c
    ld [wVWFCurTileCol], a
    
    ld a, [wVWFFast]
    and a
    jr z, .draw
    ld a, [wVWFNumTilesUsed]
    dec a
    ; only one tile is used --
    ; wait for the second one
    ; (or have it be copied when text is done)
    ; to be fast.
    jr nz, .drawtwofast
    ld a, [wVWFCurTileCol]
    cp $80
    jr z, .draw
    lda [wVWFHangingTile], 1
    jr .copied
.drawtwofast
    ld a, 1
    call VWFCopyTiles
    lda [wVWFHangingTile], 2
    jr .copied
.draw
    ld a, [wVWFNumTilesUsed]
    call VWFCopyTiles

.copied
    
    ld a, [wVWFNumTilesUsed]
    cp $2
    jr z, .forcenewtile
    ;ld a, [wVWFCurTileCol]
    ;cp $80
    ;jr z, .forcenewtile
    jr .SecondAreaUnused
.forcenewtile
    ; If we went over one tile, make sure we start with it next time.
    ; also move through the tilemap.
    call VWFShiftTile
    
    ;ld hl, wVWFCopyArea
    ;ld b, 16
    ;xor a
    ;call MyFillMemory

.SecondAreaUnused
    
.AlmostDone
    pop hl
    pop de
    ret

VWFFinish:
    ld a, [wVWFFast]
    and a
    ret z
    ld a, [wVWFHangingTile]
    and a
    ret z
    jp VWFCopyTiles

VWFTable:
    INCLUDE "src/hack/vwftable.asm"

VWFFont:
    INCBIN "gfx/font_vwf.1bpp"
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
