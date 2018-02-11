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
    add l
    ld l, a
    jr nc, .nc
    inc h
.nc
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
    add l
    ld l, a
    jr nc, .nc2
    inc h
.nc2
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

