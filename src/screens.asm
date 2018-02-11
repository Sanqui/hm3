SECTION "Screens", ROMX[$445a], BANK[$7f]
LoadCompressedGfxAtDE:
    call LdBCAtDE
    call LoadHLAAtDE
    ld [H_TMP], a
    hack LoadCompressedGfxAtDE
    ret
    nop
    ;push de
    ;ld d, b
    ;ld e, c
    ;ld c, a
    ;call Decompress
    pop de
    xor a
    ld [REG_VBK], a
    ret

