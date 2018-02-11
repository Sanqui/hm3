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
    lda [wMenuBlankTileNum], $d7
    lda [wMenuWhichTilemap], [hli]
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
    ld a, [hl]
    cp -2
    jr z, .redirectedstring
    call PrintMenuString
    jr .printedstring
.redirectedstring
    inc hl
    ld a, [hli]
    push hl
    ld h, [hl]
    ld l, a
    call PrintMenuString
    pop hl
    inc hl
.printedstring
    
    push hl
    ld a, [wMenuWhichTilemap]
    and a
    ld hl, $9800
    jr z, .gottilemap
    ld hl, $9c00
.gottilemap
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
    db 0
    db 7,  2, 5, $00, "Start@"
    db 7,  4, 4,  -1, "Load@"
    db 7,  6, 4,  -1, "Copy@"
    db 7,  8, 5,  -1, "Erase@"
    db 7, 10, 5,  -1, "Trade@"
    db -1

PlayerSelectionScreenStringDefinitions:
    db 0
    db  2,  1,  7, $00, "Are you@"
    db  2,  3, 16,  -1, "a boy or a girl?@"
    db  4, $b,  3,  -1, "Boy@"
    db $d, $b,  4,  -1, "Girl@"
    db -1

NamingScreenStringDefinitions:
    db 0
    db  4,  1, 11, $00, "Enter name!@"
    db  6,  3,  4,  -1, "Name…@"
    db $10,$10, 3,  -1, "END@"
    db -1
    
ColorScreenStringDefinitions:
    db 0
    db   2,  1, 16, $00, "Decide the Color@"
    db   2,  3, 15,  -1, "of your outfit!@"
    db   2,  6,  7,  -1, "Clothes@"
    db  $a,  6,  8,  -1, "Bandana@"
    db   2,  8,  8,  -1, "Standard@"
    db  $f,  8,  3,  -1, "Ok!@"
    db   2, $b,  6,  -1, "Sample@"
    db  $b, $b,  3,  -1, "Red@"
    db  $b, $d,  5,  -1, "Green@"
    db  $b, $f,  4,  -1, "Blue@"
    db -1

BirthdayScreenStringDefinitions:
    db 0
    db   2,  1, 12, $30, "When is your@"
    db   2,  3,  9,  -1, "Birthday?@"
    db   2,  7,  6,  -1, "Spring@"
    db   2,  9,  6,  -1, "Summer@"
    db   2, 11,  4,  -1, "Fall@"
    db   2, 13,  6,  -1, "Winter@"
    db   3, 16,  4,  -1, "End!@"
    db -1

BloodTypeScreenStringDefinitions:
    db 0
    db   2,  1, 12, $00, "What is your@"
    db   2,  3, 11,  -1, "blood type?@"
    db   8,  7,  6,  -1, "A@"
    db   8, 10,  6,  -1, "B@"
    db   8, 13,  6,  -1, "O@"
    db   8, 16,  6,  -1, "AB@"
    db -1

PetScreenStringDefinitions:
    db 0
    db   2,  1, 13, $00, "Choose a pet.@"
    db -1

ConfirmationScreenStringDefinitions:
    db 0
    db   5,  6,  7, $00, "Gender…@"
    db   5,  8,  5,  -1, "Name…@"
    db   5, 10,  7,  -1, "Outfit…@"
    db   5, 12,  6,  -1, "Birth…@"
    db   5, 14, 11,  -1, "Blood Type…@"
    db   4, 18,  5,  -1, "Name…@"
    db  $e, 18,  5,  -1, "Name…@"
    db -1

BoyStringDefinition:
    db  $c,  6,  3,  -1, "Boy@"
    db -1
GirlStringDefinition:
    db  $c,  6,  4,  -1, "Girl@"
    db -1

StartMenuStringDefinitions:
    db 1
    db   2,  1,  4, $80, "Tool@"
    db   2,  3,  4,  -1, "Seed@"
    db   2,  5,  3,  -1, "Bag@"
    db   2,  9,  4,  -1, "Animal@"
    db   2, 11,  4,  -1, "Work@"
    db   2, 13,  4,  -1, "File@"
    db   2,  7,  4,  -1, -2
    dw wPlayerName
    db -1

