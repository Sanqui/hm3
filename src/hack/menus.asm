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

WriteTilemapByteToDE:
    push af
    di
.loop
    ld a, [$ff41]
    bit 1, a
    jr nz, .loop
    pop af
    ld [de], a
    ei
    inc de
    ret
    
WriteTilemapPatches:
.loop
    ld a, [hl]
    and a
    cp $ff
    ret z
    call WriteTilemapPatch
    jr .loop

WriteTilemapPatch:
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
.loop
    ld a, [hli]
    cp -1
    ret z
    call WriteTilemapByteToDE
    jr .loop

LoadMenuStrings:
    lda [wMenuBlankTileNum], $d7
    lda [wMenuWhichTilemap], [hli]
.loop
    ld a, [hl]
    cp $ff
    ret z
    call LoadMenuString
    jr .loop

LoadMenuString:
    lda [wMenuStringX], [hli]
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
    ret
    
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
    cp "<var>"
    jr nz, .notvar
    ld a, [hli]
    push hl
    ld h, [hl]
    ld l, a
    call PrintMenuStringVar
    pop hl
    inc hl
    jr .loop
.notvar
    push hl
    call VWFDrawChar
    pop hl
    jr .loop
.done
    push hl
    call VWFFinish
    pop hl
    ret

PrintMenuStringVar:
.loop
    ld a, [hli]
    cp "@"
    ret z
    push hl
    call VWFDrawChar
    pop hl
    jr .loop

MainMenuStringDefinitions:
    db 0
    db 7,  2, 5, $00, "Neues Spiel@"
    db 7,  4, 4,  -1, "Fortsetzen@"
    db 7,  6, 4, $13, "Kopieren@"
    db 7,  8, 5,  -1, "Löschen@"
    db 7, 10, 5, $54, "Tauschen@"
    db -1

PlayerSelectionScreenStringDefinitions:
    db 0
    db  2,  1,  7, $00, "Bist du ein Junge@"
    db  2,  3, 16,  -1, "oder ein Mädchen?@"
    db  4, $b,  3,  -1, "Junge@"
    db $d, $b,  4,  -1, "Mädchen@"
    db -1

NamingScreenStringDefinitions:
    db 0
    db  18-NAME_LENGTH-4,  3,  4,   0, "Name",$f5,"@"
    db $10,$10, 3,  -1, "Ende@"
    db -1

NamingScreenPlayerStringDefinition:
    db  4,  1, 11,  -1, "Wie heißt du?@"
NamingScreenPetStringDefinition:
    db  4,  1, 11,  -1, "Wie heißt dein Haustier?@"
NamingScreenHeStringDefinition:
    db  4,  1, 11,  -1, "Wie heißt er?@"
NamingScreenSheStringDefinition:
    db  4,  1, 11,  -1, "Wie heißt sie?@"
    
ColorScreenStringDefinitions:
    db 0
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
    db 0
    db   2,  1, 12, $30, "Wann hast du@"
    db   2,  3,  9,  -1, "Geburtstag?@"
    db   2,  7,  6,  -1, "Frühling@"
    db   2,  9,  6,  -1, "Sommer@"
    db   2, 11,  4,  -1, "Herbst@"
    db   2, 13,  6,  -1, "Winter@"
    db   3, 16,  4,  -1, "Ende@"
    db -1

BirthdayScreenTilemapPatches:
    dw $986a
    db $d7, $86, $87, $d7, $80, $81, $82, $83, $84, -1
    db -1

BloodTypeScreenStringDefinitions:
    db 0
    db   2,  1, 12, $00, "Welche Blutgruppe@"
    db   2,  3, 11,  -1, "hast du?@"
    db   8,  7,  6,  -1, "A@"
    db   8, 10,  6,  -1, "B@"
    db   8, 13,  6,  -1, "O@"
    db   8, 16,  6,  -1, "AB@"
    db -1

PetScreenStringDefinitions:
    db 0
    db   2,  1, 13, $00, "Wähle ein Haustier.@"
    db -1

ConfirmationScreenStringDefinitions:
    db 0
    db   5,  6,  8, $00, "Geschlecht",$f5,"@"
    db   5,  8,  5,  -1, "Name",$f5,"@"
    db   5, 10,  7,  -1, "Outfit",$f5,"@"
    db   5, 12,  6,  -1, "Geburtstag",$f5,"@"
    db   5, 14, 11,  -1, "Blutgruppe",$f5,"@"
    db   4, 18,  5,  -1, "Name",$f5,"@"
    db  $e, 18,  5,  -1, "Name",$f5,"@"
    db   5, 19,  5,  -1, -2
    dw wPartnerName
    db   9,  8,  4,  -1, -2
    dw wPlayerName
    db  $f, 19,  5,  -1, -2
    dw wPetName
    db -1

ConfirmationScreenTilemapPatches:
    dw $998c
    db $8a, $8b, $84, $85, $86, $87, $88, -1
    dw $99cd
    db $8c, $8d, $d7, $d7, $d7, $d7, -1
    dw $9a69
    db $df, $db, $d7, $d7, $d7, -1
    dw $9a73
    db $df, -1
    db -1

BoyStringDefinition:
    db  $d,  6,  3,  -1, "Junge@"
GirlStringDefinition:
    db  $d,  6,  4,  -1, "Mädchen@"

StartMenuStringDefinitions:
    db 1
    db   2,  7,  4, $b0, -2
    dw wPlayerName
    db -1

StatusScreenStringDefinitions:
    db 0
    db   5,  2,  0, $20, "Blutgruppe@"
    db   2,  8,  0,  -1, "Geld",$f5,"@"
    db  $c,  8,  0,  -1, "G@"
    db   5, $a,  0,  -1, "Werkzeug",$f5,"@"
    db   2, $e,  7,  -1, "Jahr@"
    db   5,  1,  4,  -1, -2
    dw wPlayerName
    db -1

StatusScreenTilemapPatches:
    ;dw $9832
    ;db $84, -1
    dw $99c5
    db $b0, $d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7, -1
    ;dw $9a02
    ;db $e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7,$e8,$e9,$ea,$eb,$ec,$ed,$ee,$ef, -1
    db -1

MarriedOnStringDefinition:
    db   5,  4, 11,  -1, "Hochzeitstag",$f5,"@"

filescreenstringdefinitions: MACRO
    db 0
    db   1,  1+(\1*6),  0, $00 + (\1 * $28), "Spielstand ", "1"+\1, "@"
    db   5,  2+(\1*6),  0,  -1, "Jahr <var>"
    dw wVarString
    db "@"
    
    db   5,  3+(\1*6),  0,  -1, ""
    db "<var>"
    dw wVarString+4
    db $f2, " Tag <var>"
    dw wVarString+$d
    db "  <var>"
    dw wVarString+$11
    db "@"
    
    db   5,  4+(\1*6),  0,  -1, ""
    db "<var>"
    dw wVarString+$15
    db $f5,"00"
    db "@"
    
    db   1,  5+(\1*6),  0,  -1, "<var>"
    dw wTmpSaveName
    db "@"
    
    db -1
ENDM

FileScreen0StringDefinitions:
    filescreenstringdefinitions 0

FileScreen1StringDefinitions:
    filescreenstringdefinitions 1

