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
    db 7,  2, 5, $00, "Neues Spiel@"
    db 7,  4, 4,  -1, "Fortsetzen@"
    db 7,  6, 4, $13, "Kopieren@"
    db 7,  8, 5,  -1, "Löschen@"
    db 7, 10, 5, $54, "Tauschen@"
    db -1

PlayerSelectionScreenStringDefinitions:
    db $d7
    db  2,  1,  7, $00, "Bist du ein Junge@"
    db  2,  3, 16,  -1, "oder ein Mädchen?@"
    db  4, $b,  3,  -1, "Junge@"
    db $d, $b,  4,  -1, "Mädchen@"
    db -1

NamingScreenStringDefinitions:
    db $d7
    db  4,  1, 11, $00, "Wie heißt du?@"
    db  6,  3,  4,  -1, "Name…@"
    db $10,$10, 3,  -1, "Ende@"
    db -1
    
ColorScreenStringDefinitions:
    db $d7
    db   2,  1, 16, $00, "Wähle die Farbe@"
    db   2,  3, 15,  -1, "deines Outfits!@"
    db   2,  6,  7,  -1, "Kleidung@"
    db  $a,  6,  8,  -1, "Halstuch@"
    db   2,  8,  8,  -1, "Standard@"
    db  $f,  8,  3,  -1, "Ok!@"
    db   2, $b,  6,  -1, "Vorschau@"
    db  $b, $b,  3,  -1, "Rot@"
    db  $b, $d,  5,  -1, "Grün@"
    db  $b, $f,  4,  -1, "Blau@"
    db -1

BirthdayScreenStringDefinitions:
    db $d7
    db   2,  1, 12, $30, "Wann hast du@"
    db   2,  3,  9,  -1, "Geburtstag?@"
    db   2,  7,  6,  -1, "Frühling@"
    db   2,  9,  6,  -1, "Sommer@"
    db   2, 11,  4,  -1, "Herbst@"
    db   2, 13,  6,  -1, "Winter@"
    db   3, 16,  4,  -1, "Ende@"
    db -1

BloodTypeScreenStringDefinitions:
    db $d7
    db   2,  1, 12, $00, "Welche Blutgruppe@"
    db   2,  3, 11,  -1, "hast du?@"
    db   8,  7,  6,  -1, "A@"
    db   8, 10,  6,  -1, "B@"
    db   8, 13,  6,  -1, "O@"
    db   8, 16,  6,  -1, "AB@"
    db -1

PetScreenStringDefinitions:
    db $d7
    db   2,  1, 13, $00, "Wähle ein Haustier.@"
    db -1

ConfirmationScreenStringDefinitions:
    db $d7
    db   5,  6,  7, $00, "Geschlecht…@"
    db   5,  8,  5,  -1, "Name…@"
    db   5, 10,  7,  -1, "Outfit…@"
    db   5, 12,  6,  -1, "Geburtstag…@"
    db   5, 14, 11,  -1, "Blutgruppe…@"
    db   4, 18,  5,  -1, "Name…@"
    db  $e, 18,  5,  -1, "Name…@"
    db -1

BoyStringDefinition:
    db  $c,  6,  3,  -1, "Boy@"
    db -1
GirlStringDefinition:
    db  $c,  6,  4,  -1, "Girl@"
    db -1

