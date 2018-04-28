SECTION "Save Bank Begin", ROMX[$4001], BANK[$41]

    ld a, $0a
    ld [$0100], a
    ld a, $01
    ld [$4100], a
    ld de, $4053
    ld bc, $1000
    call Call_041_4041
    ld a, $02
    ld [$4100], a
    ld de, $4057
    ld bc, $0800
    call Call_041_4041
    ld de, $405b
    ld bc, $0800
    call Call_041_4041
    ld a, $03
    ld [$4100], a
    ld de, $405f
    ld bc, $1000
    call Call_041_4041
    xor a
    ld [$0100], a
    ld [$4100], a
    ret 


Call_041_4041:
    ld a, [wWhichSave]
    add a
    add e
    ld e, a
    jr nc, jr_041_404a

    inc d

jr_041_404a:
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    call $0ab4
    ret 


SECTION "Write Save", ROMX[$49da], BANK[$41]

WriteSavePlayerSection:
    ld a, $0a
    ld [$0100], a
    ld a, BANK(sSave1)
    ld [$4100], a
    ld a, [wWhichSave]
    add a
    ld hl, SaveTargets
    addhla
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [REG_SVBK], a
    ld hl, wPlayerDataStart
    ld bc, wPlayerDataEnd-wPlayerDataStart
    ld a, $88
    ld [de], a
    inc de
    xor a
    ld [de], a
    inc de
    xor a
    ld [de], a
    inc de
    xor a
    ld [de], a
    inc de
    ld a, [$c70c]
    ld [$db75], a
    ld a, [wSelectedLocation]
    ld [$db76], a
    ld a, [$c0ab]
    ld [$db77], a
    ld a, [$c0ac]
    ld [$db78], a
    ld a, [$c709]
    ld [$db71], a
    ld a, [$ff00+$98]
    ld [$db72], a
    ld a, [$c708]
    ld [$db73], a
    ld a, [$ff00+$9a]
    ld [$db74], a
    push hl
    push de
    push bc
    ld hl, $c600
    ld de, $da71
    ld bc, $0100
    call CopyLong
    pop bc
    pop de
    pop hl
    ld a, $ff
    ld [$d4ae], a
    ld a, $ff
    ld [$da37], a
    ld a, $ff
    ld [$da48], a
    ld a, $00
    ld [$c50f], a
    ld a, [$d4b5]
    bit 6, a
    jr z, .jr_041_4a71
    res 6, a
    set 7, a
    ld [$d4b5], a
    ld a, $01
    ld [$c50f], a
.jr_041_4a71
    ld a, [$d4b6]
    res 6, a
    res 5, a
    ld [$d4b6], a
    xor a
    ld [REG_SVBK], a
    call CopyLong
    xor a
    ld [REG_SVBK], a
    ld [$0100], a
    ld [$4100], a
    call $504a
    ld a, $0a
    ld [$0100], a
    ld a, BANK(sSave1)
    ld [$4100], a
    ld a, [wWhichSave]
    add a
    ld hl, SaveTargets
    addhla
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc de
    ld a, [$c503]
    ld [de], a
    inc de
    ld a, [$c504]
    ld [de], a
    inc de
    ld a, [$c505]
    ld [de], a
    xor a
    ld [$0100], a
    ld [$4100], a
    ld a, [$c50f]
    and a
    ret z

    ld a, [$d4b5]
    res 7, a
    set 6, a
    ld [$d4b5], a
    ret 

SaveTargets:
    dw sSave1
    dw sSave2

 ORG $41, $4113

LoadSaveData:
    ld a, $0a
    ld [$0100], a
    ld a, $03
    ld [$4100], a
    ld a, [wWhichSave]
    add a
    ld de, $4257
    add e
    ld e, a
    jr nc, .nc
    inc d
.nc
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    ld a, [hl]
    cp $88
    jr z, .save
.no_save
    xor a
    ld [$0100], a
    ld [$4100], a
    ld c, $ff
    ret 
.save
    xor a
    ld [$0100], a
    ld [$4100], a
    push hl
    call $504a
    pop hl
    ld a, $0a
    ld [$0100], a
    ld a, $03
    ld [$4100], a
    inc hl
    ld a, [$c503]
    ld b, a
    ld a, [hl]
    cp b
    jp nz, .no_save
    inc hl
    ld a, [$c504]
    ld b, a
    ld a, [hl]
    cp b
    jp nz, .no_save
    inc hl
    ld a, [$c505]
    ld b, a
    ld a, [hl]
    cp b
    jp nz, .no_save
    inc hl
    call SaveWriteStrings
    xor a
    ld [$0100], a
    ld [$4100], a
    ld c, $00
    ret 

SaveWriteStrings:
    ld de, $0071
    add hl, de
    ld a, [hli]
    inc a
    ld de, wVarString
    push hl
    call WriteFormattedNumber
    pop hl
    ld a, [hli]
    push hl
    add a
    ld de, $425b
    add e
    ld e, a
    jr nc, .nc
    inc d
.nc
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    ld de, wVarString+4
    call SaveWriteString
    pop hl
    ld a, [hli]
    push hl
    inc a
    ld de, wVarString+$c
    call WriteFormattedNumber
    pop hl
    ld a, [hli]
    push hl
    add a
    add a
    ld hl, $4277
    addhla
    ld de, wVarString+$10
    call SaveWriteString
    pop hl
    ld a, [hl]
    cp 12
    jr c, .am
.pm
    ld a, "P"
    ld [$c55f], a
    ld a, "@"
    ld [$c560], a
    jr .ampmwritten
.am
    ld a, "A"
    ld [$c55f], a
    ld a, "@"
    ld [$c560], a
.ampmwritten
    ld a, [hl]
    cp 12
    jr c, .under12
    nop
    nop
.under12
    push hl
    ld de, wVarString+$14
    call WriteFormattedNumber
    pop hl
    push hl
    ld de, $ff8b
    add hl, de
    ld de, wVarString+$1c
    ld b, PLAYER_NAME_LENGTH
.loop
    ld a, [hl]
    cp "@"
    jr z, .donecopying
    ld [de], a
    inc de
    inc hl
    dec b
    jr nz, .loop
.donecopying
    ld a, b
    and a
    jr z, .donepadding
.padloop
    ld a, " "
    ld [de], a
    inc de
    dec b
    jr nz, .padloop
.donepadding
    ld a, $ff
    ld [de], a
    pop hl
    ld de, $ff93
    add hl, de
    ld a, [hl]
    ld [$c56a], a
    inc hl
    inc hl
    inc hl
    inc hl
    ld de, wVarString+$24
    ld a, [hli]
    ld [de], a
    inc de
    ld a, [hli]
    ld [de], a
    inc de
    ld a, [hli]
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    ret 

SaveWriteString:
.loop
    ld a, [hl]
    cp "@"
    jr z, .end
    ld [de], a
    inc de
    inc hl
    jr .loop
.end
    ld [de], a
    ret 


WriteFormattedNumber:
    push de
    ld l, a
    ld h, $00
    call FormatNumber
    ld a, [$c509]
    and a
    jr nz, .nz
    ld a, " "
    ld [$c509], a
.nz
    pop de
    ld a, [$c509]
    ld [de], a
    inc de
    ld a, [$c50a]
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    ret 

; 4257 ?


SECTION "Load Save", ROMX[$4d0c], BANK[$41]

Call_041_4d0c: ; some other section
    ld a, [wWhichSave]
    add a
    ld de, SaveXSources
    add e
    ld e, a
    jr nc, .nc
    inc d
.nc
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    ld de, $c800
    ld bc, $0800
    ld a, $0a
    ld [$0100], a
    ld a, $02
    ld [$4100], a
    call $0ac3
    xor a
    ld [$0100], a
    ld [$4100], a
    ret 

SaveXSources: ; 4d38
    dw $b000
    dw $b800


LoadSavePlayerSection:
    ld a, [wWhichSave]
    add a
    ld de, .sources
    add e
    ld e, a
    jr nc, .nc
    inc d
.nc
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    ld de, wPlayerName
    ld bc, $07c6
    ld a, $0a
    ld [$0100], a
    ld a, $03
    ld [$4100], a
    ld a, $00
    ld [REG_SVBK], a
    call $0ac3
    xor a
    ld [REG_SVBK], a
    ld [$0100], a
    ld [$4100], a
    ld a, $01
    ld [$dbc6], a
    ld a, $01
    ld [$dbc7], a
    ret 

.sources
    dw sSave1 + 4
    dw sSave2 + 4

SECTION "SomethingSave", ROMX[$5005], BANK[$41]

SomethingSave:
    ld a, [$d42b]
    set 7, a
    ld [$d42b], a
    ld a, $0a
    ld [$0100], a
    xor a
    ld [$4100], a
    ld a, $04
    ld [REG_SVBK], a
    ld hl, $a000
    ld de, $d000
    ld bc, $1000

jr_041_5023:
    ld a, [hli]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, jr_041_5023

    ld a, $05
    ld [REG_SVBK], a
    ld hl, $b000
    ld de, $d000
    ld bc, $1000

jr_041_5038:
    ld a, [hli]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, jr_041_5038

    xor a
    ld [REG_SVBK], a
    ld [$0100], a
    ld [$4100], a
    ret 

