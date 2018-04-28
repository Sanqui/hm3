
    ORG $78, $6149

LoadFileScreen:
    ld a, $ff 
    ld [$ff9c], a 
    xor a 
    ld [wFileScreenY], a
    ld hl, $4205
    ld a, $7b 
    call FarCall
    ld hl, $d9a5
    ld de, wPalettes + $58
    ld b, $10 
    call Copy 
    ld hl, $756d
    ld de, wPalettes + $68
    ld b, $08 
    call Copy 
    ld hl, $47fa
    ld c, $69 
    ld de, $9400
    call Decompress 
    ld hl, $754d
    ld de, $8400
    ld b, $20 
    call $4023
    ld hl, $9800
    ld de, FileScreenTilemap
    ld bc, $1412
    call CopyTilemap78
    ld a, $01 
    ld [REG_VBK], a
    ld hl, $9800
    ld de, FileScreenAttrmap
    ld bc, $1412
    call CopyTilemap78
    xor a 
    ld [REG_VBK], a
    ld hl, $4187
    ld a, $7e 
    call FarCall
    call FileScreenShowData
    ret 


Call_078_61b0:
    ld a, [$ff00+$8c]
    cp $01
    jr z, jr_078_61c5

    cp $02
    jr z, jr_078_61cc

    ld a, [$ff00+$8a]
    cp $40
    jr z, jr_078_61cd

    cp $80
    jr z, jr_078_61d0

    ret 


jr_078_61c5:
    ld a, [wFileScreenY]
    ld [wWhichSave], a
    ret 


jr_078_61cc:
    ret 


jr_078_61cd:
    xor a
    jr jr_078_61d2

jr_078_61d0:
    ld a, $01

jr_078_61d2:
    ld hl, wFileScreenY
    cp [hl]
    ret z

    ld [hl], a
    call Call_078_6209
    ld a, $59
    call $0ee4
    ret 


Call_078_61e1:
    ld hl, $c56b
    ld a, [hl+]
    ld [$d9a9], a
    ld a, [hl+]
    ld [$d9aa], a
    ld a, [hl+]
    ld [$d9b1], a
    ld a, [hl+]
    ld [$d9b2], a
    ret 


Call_078_61f5:
    ld hl, $c56b
    ld a, [hl+]
    ld [$d9c1], a
    ld a, [hl+]
    ld [$d9c2], a
    ld a, [hl+]
    ld [$d9c9], a
    ld a, [hl+]
    ld [$d9ca], a
    ret 


Call_078_6209:
    ld a, [wFileScreenY]
    or a
    ld l, $20
    jr z, jr_078_6213

    ld l, $50

jr_078_6213:
    ld b, $02
    ld a, $05
    ld [$ff00+$a8], a
    ld a, $13
    ld [$ff00+$a9], a
    ld a, $08
    ld [$ff00+$aa], a
    ld a, l
    ld [$ff00+$ab], a
    ld hl, $4196
    ld a, $7e
    call FarCall
    ret 


Call_078_622d:
    ld b, $02
    ld hl, $421b
    ld a, $7e
    call FarCall
    ret 


FileScreenShowData:
    ld a, $0d
    ld [wStringID], a
    ld a, $01
    ld [wStringID2], a
    xor a
    ld [wWhichSave], a
    farcall LoadSaveData
    inc c
    jr z, .no_file
    ld de, $9000
    hack FileScreenWriteLine0
    ;call FileScreenWriteLine
    ; the rest of this loads the player picture
    ld hl, $1828
    call Call_078_62d3
    call Call_078_61e1
    ld hl, $9840
    ld de, $72a5
    call Call_078_62fc
    jr .file2
.no_file
    ld b, $00
    ld hl, $421b
    ld a, $7e
    call FarCall
    ld hl, $9841
    call Call_078_62f4
    
.file2
    ld a, $01
    ld [wWhichSave], a
    farcall LoadSaveData
    inc c
    jr z, .no_file2

    ld de, $9200
    hack FileScreenWriteLine1
    ld hl, $1858
    call Call_078_62e3
    call Call_078_61f5
    ld hl, $9900
    ld de, $731d
    call Call_078_62fc
    jr .done
.no_file2
    ld b, $01
    ld hl, $421b
    ld a, $7e
    call FarCall
    ld hl, $9901
    call Call_078_62f4
.done
    farcall PrepareStringDialogueBox
    ret 

FileScreenWriteLine:
; writes the line with the name and date and time
    ld hl, wDialogueTilesPtr
    ld a, e
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, $15
    ld [hli], a
    ld [hl], $01
    farcall StartDialogue79_44a0
    ret 

Call_078_62d3:
    ld b, $00
    ld a, [$c56a]
    or a
    ld de, $0500
    jr z, jr_078_62f1

    ld de, $0504
    jr jr_078_62f1

Call_078_62e3:
    ld b, $01
    ld a, [$c56a]
    or a
    ld de, $0514
    jr z, jr_078_62f1

    ld de, $0515

jr_078_62f1:
    jp $445e


Call_078_62f4:
    ld bc, $1204
    ld a, $d7
    jp $4103


Call_078_62fc:
    ld bc, $1404
    ; what in the absolute fuck
    ret
    nop
    nop
    ;jp CopyTilemap78

    ORG $78, $727d

FileScreenTilemap:
    db $d8,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$da
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $4e,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$50
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $dc,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$de
    db $d8,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$da
    db $db,$d7,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7,$e8,$e9,$ea,$eb,$ec,$ed,$ee,$ef,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff,$d7,$df
    db $dc,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$de
; 78:73e5

FileScreenAttrmap:
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
; 78:754d

