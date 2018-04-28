SECTION "Status Screen", ROMX[$520f], BANK[$78]

HandleStatusScreen:
    call DoStatusScreen
    farcall DrawPlayerSpriteInCorner
    ret

DoStatusScreen:
    ld a, [wStatusScreenState]
    jumptable

    dw StatusScreenLoad ; $5225
    dw StatusScreenKeep ; $5379
    dw StatusScreenQuit ; $5386

StatusScreenLoad:
    ld a, $ff
    ld [$ff00+$9c], a
    ld hl, $4205
    ld a, $7b
    call FarCall
    ld hl, $421c
    ld a, $7b
    call FarCall
    ld a, [wTool]
    ld b, a
    ld c, $01
    ld hl, $4190
    ld a, $7b
    call FarCall ; prepare tool palette???
    ld hl, StatusScreenGfxCompr
    ld c, BANK(StatusScreenGfxCompr)
    ld de, vtile $00
    call Decompress
    ld hl, $9800
    ld de, StatusScreenTilemap
    ld bc, $1412
    call CopyTilemap78
    ld a, $01
    ld [REG_VBK], a
    ld hl, $9800
    ld de, StatusScreenAttrmap
    ld bc, $1412
    call CopyTilemap78
    xor a
    ld [REG_VBK], a
    ld b, 0
    ld c, $80
    farcall PrintVariableName
    ld a, [wPlayerBloodType]
    ld b, a
    ld c, $84
    ld hl, $4302
    ld a, $79
    call FarCall
    ld a, [wPlayerBirthdaySeason]
    ld b, a
    ld c, $86
    ld hl, $4255
    ld a, $79
    call FarCall
    ld a, [wPlayerBirthdayDay]
    inc a
    ld b, a
    ld c, $8c
    ld hl, $43a5
    ld a, $79
    call FarCall
    ld a, [$d453]
    bit 2, a
    jr z, .not_married
.married
    ld a, [wMarriageSeason]
    ld b, a
    ld c, $8e
    ld hl, $4255
    ld a, $79
    call FarCall
    ld a, [wMarriageDay]
    inc a
    ld b, a
    ld c, $94
    ld hl, $43a5
    ld a, $79
    call FarCall
    jr .marriage_done
.not_married
    ; merely clears the "Married on" string
    ld hl, $9885
    ld a, $d7
    ld bc, $0e02
    call $4103
.marriage_done
    ld c, $96
    farcall PrintMoney
    ld a, [wTool]
    ld b, a
    ld c, $9b
    farcall LoadToolGfx
    ld a, [wTool]
    ld b, a
    farcall LoadToolPal
    ld a, [wPlayerGender]
    or a
    jr z, .boy
.girl
    ld a, b
    sub $28
    jr c, .c
    add $37
    ld b, a
.c
.boy
    ld hl, wStringID2
    ld a, b
    ld [hld], a
    ld [hl], $01
    ld b, $10
    ld c, $a0
    farcall PrintStringIDX
    ld a, [wYear]
    inc a
    ld b, a
    ld c, $b0
    ld hl, $43a5
    ld a, $79
    call FarCall
    ld a, [wSeason]
    ld b, a
    ld c, $b2
    ld hl, $4255
    ld a, $79
    call FarCall
    ld a, [wDay]
    inc a
    ld b, a
    ld c, $b8
    ld hl, $43a5
    ld a, $79
    call FarCall
    ld a, [wWeekday]
    ld b, a
    ld c, $ba
    ld hl, $4264
    ld a, $79
    call FarCall
    ld a, [wHour]
    ld b, a
    ld c, $d0
    ld hl, $4273
    ld a, $79
    call FarCall
    ld hl, $4187
    ld a, $7e
    call FarCall
    call Call_078_538b
    hack StatusScreenLoad
    nop
    nop
    ;ld a, $00
    ;call $2da7
    jp IncStatusScreenState

StatusScreenKeep:
    ld a, [$ff00+$8c]
    and $03
    ret z

    ld a, $5b
    call $0ee4
    jp IncStatusScreenState

StatusScreenQuit:
    xor a
    ld [wStatusScreenState], a
    ret


Call_078_538b:
        ld a, [wPlayerGender]                     
        or a                                      
        ld de, $0500                              
        jr z, jr_078_5397                         

        ld de, $0504                              

jr_078_5397:
        ld b, $00                                 
        ld hl, $1828                              
        jp $445e   

SECTION "Status Screen Tilemap", ROMX[$6c13], BANK[$78]

StatusScreenTilemap:
    db $d8,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$da
    db $db,$d7,$d7,$d7,$d7,$80,$81,$82,$83,$d7,$d7,$84,$85,$00,$01,$02,$03,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$86,$87,$88,$89,$8a,$8b,$d7,$8c,$8d,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$04,$11,$10,$10,$0d,$03,$15,$d7,$05,$06,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$8e,$8f,$90,$91,$92,$93,$d7,$94,$95,$df
    db $dc,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$de
    db $d8,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$da
    db $db,$d7,$04,$05,$06,$03,$01,$08,$96,$97,$98,$99,$9a,$09,$d7,$12,$13,$13,$12,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$14,$9b,$9c,$14,$df
    db $db,$d7,$0a,$0b,$0c,$0d,$0e,$03,$06,$07,$d7,$08,$08,$08,$d7,$14,$9d,$9e,$14,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$12,$13,$13,$12,$df
    db $db,$d7,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9,$aa,$ab,$ac,$ad,$ae,$af,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$b0,$b1,$d7,$0f,$03,$11,$10,$d7,$b2,$b3,$b4,$b5,$d7,$b8,$b9,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$ba,$bb,$bc,$d7,$d7,$d7,$d2,$d3,$d7,$d0,$d1,$d7,$d7,$df
    db $dc,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$de
; 78:6d7b

StatusScreenAttrmap:
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$40,$40,$60,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
; 78:6ee3

