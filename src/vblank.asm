SECTION "Vblank", ROM0[$04a0]

VBlank::
    push af
    push bc
    push de
    push hl
    ld a, [$ff96]
    and a
    jr z, .input
    jr .no_input
.input:
    ld a, [$c731]
    or a
    jp nz, $05ec

    ld a, [$ff93]
    and a
    jr z, .jr_000_04c8

.no_input
    ld a, [$d4b3]
    cp $01
    jr nz, .jr_000_04c1

    call $081e

.jr_000_04c1
    call $0f80
    ei 
    jp .end

.jr_000_04c8
    inc a
    ld [$ff00+$93], a
    call $081e
    ld a, [$c0a3]
    ld [REG_LCDC], a
    ld a, [$c0a2]
    ld [REG_LYC], a
    call $ff80
    ei 
    xor a
    ld [$dcee], a
    ld a, [$dcfa]
    and a
    call nz, $0f80
    ld a, [$dcfa]
    and a
    jr nz, .jr_000_04f6

    call $0a37
    call $1af8
    call $0f80

.jr_000_04f6
    xor a
    ld [$ff00+$9d], a
    ld a, [wFrameCounter]
    add $01
    ld [wFrameCounter], a
    jr nc, .jr_000_050a

    ld a, [$c0ae]
    inc a
    ld [$c0ae], a

.jr_000_050a
    call $0853
    ld a, [$dcfa]
    and a
    call z, $2d68
    xor a
    ld [$dcca], a
    ld [$dce7], a
    call $0539
    call $1e0d
    ld a, [$ff00+$9d]
    ld [$ff00+$9e], a
    call $066e
    ld a, [$ff00+$8a]
    and $0f
    cp $0f
    jp z, $0249

    xor a
    ld [$ff00+$93], a

.end
    pop hl
    pop de
    pop bc
    pop af
    ret 
