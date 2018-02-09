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
