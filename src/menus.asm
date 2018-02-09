SECTION "Load Main Menu Screen", ROMX[$5d17], BANK[$78]
LoadMainMenuScreen:
    farcall LoadDialogueBoxTilemap
    ld hl, $4187
    ld a, $79
    call FarCall
    ld hl, MainMenuPalettes
    ld de, wPalettes
    ld b, $40
    call Copy
    ld hl, MainMenuGfxComp
    ld c, BANK(MainMenuGfxComp)
    ld de, $9000
    call Decompress
    ld b, $28
    farcall LoadTilemapNum
    ;ld hl, $4187
    hack LoadMainMenuScreen
    ld a, $7e
    call FarCall ; ?
    call $5df2
    ld a, $00
    call $2da7
    jp $5cdc

SECTION "Player Selection Screen", ROMX[$4408], BANK[$7a]
LoadPlayerSelectionScreen:
    ld [wMainMenuOption], a
    ld hl, $5503
    ld c, $7a
    ld de, $9000
    call Decompress
    ld hl, $4230
    ld a, $7b
    call FarCall
    ld hl, $9800
    ld de, $55d0
    ld bc, $1412
    call CopyTilemap7A
    ld a, $01
    ld [REG_VBK], a
    ;ld hl, $9800
    hack LoadPlayerSelectionScreen
    ld de, $5738
    ld bc, $1412
    call CopyTilemap7A
    xor a
    ld [REG_VBK], a
    ld hl, $4187
    ld a, $7e
    call FarCall
    ld b, $00
    ld de, $0500
    ld hl, $2b52
    call $4387
    ld b, $01
    ld de, $0504
    ld hl, $7352
    call $4387
    call $453e
    call $452a
    call $4516
    call $43a0
    ld a, $00
    call $2da7
    jp $4379

