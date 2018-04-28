SECTION "Hack RAM", WRAM0[$c300]

wHackOldBank: ds 1
wTempH: ds 1
wTempL: ds 1
wTempA: ds 1

wVWFLetterNum:
    ds 1
wVWFChar:
    ds 1
wVWFTileLoc:
    ds 2
wVWFFirstTileNum:
    ds 1
wVWFCurTileNum:
    ds 1
wVWFCurTileCol:
    ds 1
wVWFNumTilesUsed:
    ds 1
wVWFCharWidth:
    ds 1
wVWFFast: ds 1
wVWFHangingTile: ds 1
wVWFTilesPtr: ds 2

wVWFBuildArea0:
    ds 8
wVWFBuildArea1:
    ds 8
wVWFBuildArea2:
    ds 8
wVWFBuildArea3:
    ds 8
    
wVWFCopyArea:
    ds $40

wMenuStringX: ds 1
wMenuStringY: ds 1
wMenuStringPad: ds 1
wMenuTileNum: ds 1
wMenuBlankTileNum: ds 1
wMenuWhichTilemap: ds 1

wStringBuildArea: ds $20

SECTION "Rst $10", ROM0[$0010]
    push af
    ld a, [$4000]
    ld [wHackOldBank], a
    ld a, BANK(HackPredef)
    ld [$2000], a
    pop af
    call HackPredef
    push af
    ld a, [wHackOldBank]
    ld [$2000], a
    pop af
    ret


SECTION "Hack ROM", ROMX[$4000], BANK[$4E]
db $4e

MyCopyData:
; copy bc bytes of data from hl to de
.loop
	ld a, [hli]
	ld [de],a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, .loop
	ret

MyCopyDataFF:
; copy bytes from hl to de until ff
.loop
	ld a, [hli]
	ld [de],a
	inc de
	inc a
	jr nz, .loop
	ret

MyFillMemory:
; write a in hl b times
.loop
    ld [hli], a
    dec b
    jr nz, .loop
    ret

MyMultiply:
; Add bc * a to hl.
	and a
	ret z
.loop
	add hl, bc
	dec a
	jr nz, .loop
	ret
    
HackPredef:
    ld [wTempA], a
    ; save hl
    ld a, h
    ld [wTempH], a
    ld a, l
    ld [wTempL], a
    
    push bc
    ld hl, HackPredefTable
    ld b, 0
    ld a, [wTempA] ; old a
    ld c, a
    add hl, bc
    add hl, bc
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    push bc
    pop hl
    pop bc
    
    push hl
    ld a, [wTempH]
    ld h, a
    ld a, [wTempL]
    ld l, a
    ret ; jumps to hl

hack_entry: MACRO
Hack\1Entry:
    dw Hack\1
ENDM

HackPredefTable:
    hack_entry Nop
    hack_entry VWFInit
    hack_entry DrawChar
    hack_entry Newline
    hack_entry DialogueStateEnd
    hack_entry ControlCodeF5
    hack_entry ControlCodeFB
    hack_entry PrepareStringDialogueBox
    hack_entry PrintStringWriteTile
    hack_entry PrintStringInit
    hack_entry PrintStringEnd
    hack_entry NameWriteTile
    hack_entry NameSetupVWF
    hack_entry NameEnd
    hack_entry LoadMainMenuScreen
    hack_entry LoadPlayerSelectionScreen
    hack_entry SetupNamingScreen
    hack_entry SetupNamingScreen2
    hack_entry SetupColorScreen
    hack_entry SetupBirthdayScreen
    hack_entry SetupBloodTypeScreen
    hack_entry SetupPetScreen
    hack_entry SetupConfirmationScreen
    hack_entry WritePartnerGenderInVar
    hack_entry DrawStartMenu
    hack_entry LoadCompressedGfxAtDE
    hack_entry ControlCodeF1
    hack_entry HUDWriteStringInit
    hack_entry HUDWriteStringDrawChar
    hack_entry HUDWriteStringEnd
    hack_entry UnkMapLoad
    hack_entry StatusScreenLoad
    hack_entry FileScreenWriteLine0
    hack_entry FileScreenWriteLine1

HackNop:
    ret

HackVWFInit:
    call VWFInit
    ld hl, wDialogueTilesPtr
    ld a, [hli]
    ld e, a
    ret

HackDrawChar:
    ld a, [wDialogueDelayEnabled]
    ld [wVWFFast], a
    
    lda [wVWFTilesPtr], [wDialogueTilesPtr]
    lda [wVWFTilesPtr+1], [wDialogueTilesPtr+1]
    
    ld a, [wDialogueTextByte]
    call VWFDrawChar
    ret

HackNewline:
    call VWFFinish
    call VWFInit
    ld a, [wDialogueBoxWidth]
    ld [wVWFCurTileNum], a
    ret

HackDialogueStateEnd:
    call VWFFinish
    xor a
    ld [$c538], a
    ret

HackControlCodeF5:
    call VWFFinish
    ld hl, wDialogueOffset2
    ret
    
HackControlCodeFB:
    call VWFFinish
    ld b, 1<<DIALOGUE_STATE_WAITA
    ret
    
HackPrepareStringDialogueBox: ; XXX unused
    push bc
    push de
    
    ;call VWFInit
    ld a, 1
    ld [wVWFFast], a
    
    pop de
    pop bc
    ;o
    xor a
    ld [wDialogueState], a
    ret
    
HackPrintStringWriteTile:
    push hl
    ld a, [H_TMP]
    call VWFDrawChar
    pop hl
    ret

TileNumToPointerClone:
    ld h, $08
    ld l, a
    bit 7, a
    jr nc, .nc
    inc h
.nc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ret

HackPrintStringInit:
    push bc
    push de
    push hl
    call VWFInit
    pop hl
    pop de
    pop bc
    ; o, cloned
    ld a, c
    call TileNumToPointerClone
    
    lda [wVWFTilesPtr], l
    lda [wVWFTilesPtr+1], h
    
    ld a, b
    and a ; do we need to pad?
    ret z ; no we don't
    
    push bc
    push de
    push hl
    
    ; instead of padding, erase the tiles...
    ; could be faster ofc by padding but
    ld d, h
    ld e, l
.eraseloop
    ld hl, wVWFCopyArea
    call CopyTile
    dec b
    jr nz, .eraseloop
    
    pop hl
    pop de
    pop bc
    ld b,0
    ret

HackPrintStringEnd:
    jp VWFFinish

HackNameSetupVWF:
    push bc
    push de
    push hl
    call VWFInit
    pop hl
    pop de
    pop bc
    ld de, $8b60 ; o
    lda [wVWFTilesPtr], e
    lda [wVWFTilesPtr+1], d
    ret

HackNameWriteTile:
    ld a, [H_TMP]
    call VWFDrawChar
    ret
    
HackNameEnd:
    call VWFFinish
    call VWFInit
    ld hl, NameLeftTileGfx
    ld de, $8b50
    call CopyTile
    ld hl, NameRightTileGfx
    ld de, $8bc0
    call CopyTile
    ; o
    ld de, $9c01
    ret

NameLeftTileGfx:
    INCBIN "gfx/nameleft.2bpp"
NameRightTileGfx:
    INCBIN "gfx/nameright.2bpp"

HackLoadMainMenuScreen:
    ld hl, MainMenuStringDefinitions
    call LoadMenuStrings
    ; o
    ld hl, $4187
    ret

HackLoadPlayerSelectionScreen:
    ld a, $00
    ld [REG_VBK], a
    
    ld hl, PlayerSelectionScreenStringDefinitions
    call LoadMenuStrings
    
    ld a, $01
    ld [REG_VBK], a
    ; o
    ld hl, $9800
    ret

HackSetupNamingScreen:
    ld a, $ff
rept NAME_LENGTH
    ld [hli], a
endr
    ld [hl], a
    ret

HackSetupNamingScreen2:
    ld hl, NamingScreenStringDefinitions
    call LoadMenuStrings
    
    lda e, [wNamingScreenDestination]
    lda d, [wNamingScreenDestinationHi]
    
    ld a, e
    cp wPlayerName & $ff
    jr nz, .notplayername
    ld a, d
    cp wPlayerName >> 8
    jr z, .playername
.notplayername
    cp wPartnerName & $ff
    jr nz, .notpartnername
    ld a, d
    cp wPartnerName >> 8
    jr z, .partnername
.notpartnername
    cp wPetName & $ff
    jr nz, .notpetname
    ld a, d
    cp wPetName >> 8
    jr z, .petname
.notpetname
    ld b, b
    jr .done
.playername
    ld hl, NamingScreenPlayerStringDefinition
    call LoadMenuString
    jr .done
.petname
    ld hl, NamingScreenPetStringDefinition
    call LoadMenuString
    jr .done
.partnername
    ld a, [wPlayerGender]
    and a
    jr nz, .girl
    ld hl, NamingScreenSheStringDefinition
    call LoadMenuString
    jr .done
.girl
    ld hl, NamingScreenHeStringDefinition
    call LoadMenuString
.done
    
    ld hl, $4187
    ret

HackSetupColorScreen:
    ld hl, ColorScreenStringDefinitions
    call LoadMenuStrings
    ;o
    ld hl, $4187
    ret

HackSetupBirthdayScreen:
    ld hl, BirthdayScreenStringDefinitions
    call LoadMenuStrings
    
    ld hl, BirthdayScreenTilemapPatches
    call WriteTilemapPatches
    ;o
    ld hl, $4187
    ret

HackSetupBloodTypeScreen:
    ld hl, BloodTypeScreenStringDefinitions
    call LoadMenuStrings
    ;o
    ld hl, $4187
    ret

HackSetupPetScreen:
    ld hl, PetScreenStringDefinitions
    call LoadMenuStrings
    ;o
    ld hl, $4187
    ret

HackSetupConfirmationScreen:
    ld hl, ConfirmationScreenStringDefinitions
    call LoadMenuStrings
    
    ld a, [wPlayerGender]
    and a
    jr nz, .girl
    ld hl, BoyStringDefinition
    jr .gotgenderdef
.girl
    ld hl, GirlStringDefinition
.gotgenderdef
    call LoadMenuString
    
    ld hl, ConfirmationScreenTilemapPatches
    call WriteTilemapPatches
    
    ld a, $0f
    ld [$c0a2], a
    ret

HackWritePartnerGenderInVar:
    ld de, wVarString
    ld a, [wMainMenuOption]
    or a
    jr nz, .boy
.girl
    ld hl, GirlDialogueString
    call MyCopyDataFF
    ret
.boy
    ld hl, BoyDialogueString
    call MyCopyDataFF
    ret

BoyDialogueString:
    db "Der Junge@"
GirlDialogueString:
    db "Das Mädchen@"

HackDrawStartMenu:
    ld hl, StartMenuStringDefinitions
    call LoadMenuStrings
    ld hl, MenuItemGfx
    ld de, $8b90
    ld b, $1b
.tilecopyloop
    push bc
    call CopyTile
    pop bc
    dec b
    jr nz, .tilecopyloop
    
    
    ; o
    xor a
    ld [$ff00+$9b], a
    ret

MenuItemGfx:
    INCBIN "gfx/menu_items.2bpp"

CopyTiles:
.tilecopyloop
    push bc
    call CopyTile
    pop bc
    dec b
    jr nz, .tilecopyloop
    ret

HackLoadCompressedGfxAtDE:
    ld a, [H_TMP]
    
    push de
    
    push hl
    push bc
    ld b, a
    ld e, l
    ld d, h
    ld hl, ReplacementCompressedGraphics
.loop
    ld a, [hli]
    cp $ff
    jr z, .not_found
    cp b
    jr nz, .not2
    ld a, [hli]
    cp e
    jr nz, .not1
    ld a, [hli]
    cp d
    jr nz, .not_found
    lda e, [hli]
    lda d, [hli]
    ld b, [hl]
    jr .load_replacement
.not2
    inc hl
.not1
    inc hl
.not
    inc hl
    inc hl
    inc hl
    jr .loop
    
.not_found
    ld a, b
    pop bc
    pop hl
    ld d, b
    ld e, c
    ld c, a
    call Decompress
    
jr .o

.load_replacement
    ld l, e
    ld h, d
    pop de
    call CopyTiles
    pop hl ; trash

.o
    pop de
    xor a
    ld [REG_VBK], a
    ret

comp_replacement_entry: MACRO
    dbw BANK(\1), \1
    dwb \2, (\2End - \2) / 16
ENDM

ReplacementCompressedGraphics:
    comp_replacement_entry PressStartGfxComp, PressStartGfxNew
    db -1

PressStartGfxNew:
    INCBIN "gfx/press_start.2bpp"
PressStartGfxNewEnd

HackControlCodeF1:
    call VWFFinish
    call VWFInit
    lda [wVWFCurTileNum], $19
    
    ld b, $00
    ret

HackHUDWriteStringInit:
    jp VWFInit
HackHUDWriteStringDrawChar:
    ld a, [H_TMP]
    jp VWFDrawChar
HackHUDWriteStringEnd:
    jp VWFFinish

HackUnkMapLoad:
    ld a, [$ff9b]
    cp $60
    jr nz, .nothud
    ld a, $90 - HUD_HEIGHT * $8
    ld [$ff9b], a
.nothud
    ld a, [$d4b6]
    ret

HackStatusScreenLoad:
    ld hl, StatusScreenStringDefinitions
    call LoadMenuStrings
    
    ld a, [$d453]
    bit 2, a
    jr z, .not_married
.married
    ld hl, MarriedOnStringDefinition
    call LoadMenuString
    
.not_married
    
    ld hl, StatusScreenTilemapPatches
    call WriteTilemapPatches
    
    ld a, [wHackOldBank]
    push af
    farcall HUDWriteFullDate
    pop af
    ld [wHackOldBank], a
    
    ;o
    ld a, $00
    call $2da7
    
    ret

HackFileScreenWriteLine0:
    ld hl, FileScreen0StringDefinitions
    call LoadMenuStrings
    ret

HackFileScreenWriteLine1:
    ld hl, FileScreen1StringDefinitions
    call LoadMenuStrings
    ret

INCLUDE "src/hack/vwf.asm"
INCLUDE "src/hack/menus.asm"









