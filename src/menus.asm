SECTION "Print Variable Name", ROMX[$428f], BANK[$79]
PrintVariableName:
    ld a, b
    ld hl, VariableNamePtrs
    call GetPointer
    ld b, NAME_LENGTH
    call PrintString
    ret

VariableNamePtrs: ; 79:429c
    dw wPlayerName
    dw wPartnerName
    dw wPetName
    dw $d74e ; $03
    dw $d753 ; $04
    dw $d758 ; $05
    dw $d75d ; $06
    dw $d762 ; $07
    dw $d767 ; $08
    dw $d76c ; $09
    dw $d771 ; $0a
    dw Ord1String ; $0b
    dw Ord2String ; $0c
    dw Ord3String ; $0d
    dw Ord4String ; $0e
    dw Ord5String ; $0f
    dw Ord6String ; $10
    dw Ord7String ; $11
    dw Ord8String ; $12
    dw $d726 ; $13
    dw $d72b ; $14
    dw $d730 ; $15
    dw $d735 ; $16
    dw $d73a ; $17
    dw $d73f ; $18
    dw $d744 ; $19
    dw $d749 ; $1a
    dw $d776 ; $1b
    dw $d77b ; $1c
    dw $d780 ; $1d
    dw $d785 ; $1e
    dw $d78a ; $1f
    dw $d78f ; $20
    dw $d794 ; $21
    dw $d799 ; $22
    
; unused?  TCRF
    
Ord1String:
    db "1st@"
Ord2String:
    db "2nd@"
Ord3String:
    db "3rd@"
Ord4String:
    db "4th@"
Ord5String:
    db "5th@"
Ord6String:
    db "6th@"
Ord7String:
    db "7th@"
Ord8String:
    db "8th@"

SECTION "Start Menu", ROMX[$4e68], BANK[$0b]

DrawStartMenu:
    ld de, $8c30
rept PLAYER_NAME_LENGTH_CODE
    call ClearTile
endr
    ld hl, wPlayerName
    ld de, $8c30
    ld c, PLAYER_NAME_LENGTH
    call $4f40
    ld hl, $9c00
    ld de, StartMenuTilemap
    ld bc, START_MENU_DIMENSIONS

.rowloop
    push hl
    push bc

.loop
    call WaitVBlank
    ld a, [de]
    ld [hli], a
    ei 
    inc de
    dec b
    jr nz, .loop

    pop bc
    pop hl
    ld a, $20
    add l
    ld l, a
    jr nc, .nc1
    inc h
.nc1
    dec c
    jr nz, .rowloop

    ld hl, $9c00
    ld bc, START_MENU_WIDTH << 8 | 18
    ld a, $01
    ld [REG_VBK], a

.rowloopattr
    push bc
    push hl

.loopattr
    call WaitVBlank
    ld a, $80
    ld [hli], a
    ei 
    dec b
    jr nz, .loopattr

    pop hl
    pop bc
    ld a, $20
    add l
    ld l, a
    jr nc, .nc
    inc h
.nc
    dec c
    jr nz, .rowloopattr

    xor a
    ld [REG_VBK], a
    ld a, $6f
    ld [$ff00+$9c], a
    xor a
    ld [$ff00+$9b], a
    ret 

StartMenuTilemap:
    db $d8, $d9, $d9, $d9, $d9, $d9, $da
    db $db, $d7, $bf, $ce, $ce, $cb, $df
    db $db, $d7, $d7, $d7, $d7, $d7, $df
    db $db, $d7, $be, $c7, $c7, $c2, $df
    db $db, $d7, $d7, $d7, $d7, $d7, $df
    db $db, $d7, $d1, $c1, $c8, $d7, $df
    db $db, $d7, $d7, $d7, $d7, $d7, $df
    db $db, $d7, $c3, $c4, $c5, $c6, $df
    db $db, $d7, $d7, $d7, $d7, $d7, $df
    db $db, $d7, $d0, $cd, $cc, $cb, $df
    db $db, $d7, $d7, $d7, $d7, $d7, $df
    db $db, $d7, $c0, $ce, $cf, $ca, $df
    db $db, $d7, $d7, $d7, $d7, $d7, $df
    db $db, $d7, $bd, $c9, $cb, $c7, $df
    db $db, $d7, $d7, $d7, $d7, $d7, $df
    db $dc, $dd, $dd, $dd, $dd, $dd, $de

 ORG $78, $41b2

StartMenuDoJoypad:
    call JumptableOnJoypad
    dw StartMenuA       ; A
    dw StartMenuExit    ; B
    dw StartMenuExit    ; SELECT
    dw StartMenuNop     ; START
    dw StartMenuNop     ; RIGHT
    dw StartMenuNop     ; LEFT
    dw StartMenuUp      ; UP
    dw StartMenuDown    ; DOWN
    dw StartMenuNop     ; none?
    

SECTION "Work Menu Related Stuff", ROMX[$4254], BANK[$78]

BackupMainMenuBeforeWork:
    ld de, $9da0
    ld hl, $9c10
    ld bc, START_MENU_WIDTH<<8 | 19-START_MENU_HEIGHT
    call $4114
    ld hl, $4187
    ld a, $79
    call FarCall
    ld a, [$d448]
    bit 4, a
    ld a, $07
    jr z, .jr_078_428e
    ld hl, $641b
    ld a, $21
    call FarCall
    ld a, [$d95e]
    ld b, a
    ld a, [$d95b]
    sub b
    ld b, a
    ld c, $10
    ld hl, $4218
    ld a, $79
    call FarCall
    ld a, $06
.jr_078_428e
    ld [wStringID2], a
    ld a, $0d
    ld [wStringID], a
    ld hl, $419c
    ld a, $79
    call FarCall
    ld hl, $c711
    ld a, [$c7bc]
    ld [hli], a
    ld a, [$c7bd]
    ld [hli], a
    ld a, [$c7be]
    ld [hli], a
    ld a, [$c0a2]
    ld [hli], a
.waitvblank1
    ld a, [REG_LY]
    cp $8c
    jr nz, .waitvblank1
    di 
.waitvblank2
    ld a, [REG_LY]
    cp $90
    jr nz, .waitvblank2

    ld a, $67
    ld [$c0a2], a
    ld a, $78
    ld de, $55f7
    call $065b
    ld hl, $4282
    ld a, $7b
    call FarCall
    ei 
    jp $419d

    call $24d6
    ld a, [wDialogueState]
    bit 0, a
    ret nz

    ld a, [$ff00+$8c]
    and $03
    ret z

    ld a, $5b
    call $0ee4
    jp $419d

RestoreMainMenuAfterWork:
jr_078_42ed:
    ld a, [REG_LY]
    cp $8c
    jr nz, jr_078_42ed
    di 
jr_078_42f4:
    ld a, [REG_LY]
    cp $90
    jr nz, jr_078_42f4

    ld hl, $c711
    ld a, [hli]
    ld [$c7bc], a
    ld a, [hli]
    ld [$c7bd], a
    ld a, [hli]
    ld [$c7be], a
    ld a, [hli]
    ld [$c0a2], a
    ld de, $9c10
    ld hl, $9da0
    ld bc, START_MENU_WIDTH << 8 | 19-START_MENU_HEIGHT
    call $4114
    ei 
    ld a, $01
    jp $41a2

    xor a
    ld [$c700], a
    ret 

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
    ld hl, $4187
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
    ld hl, $9800
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
    

SECTION "Player Selection Screen 2", ROMX[$44aa], BANK[$7a]
    
WritePartnerGenderInVar:
    ld hl, wVarString
    ld a, [wMainMenuOption]
    or a
    jr nz, .boy
.girl
    ld [hl], "G"
    inc hl
    ld [hl], "i"
    inc hl
    ld [hl], "r"
    inc hl
    ld [hl], "l"
    jr .got_name
.boy
    ld [hl], "B"
    inc hl
    ld [hl], "o"
    inc hl
    ld [hl], "y"
.got_name
    inc hl
    ld [hl], "@"
    ld a, $0c
    ld [wStringID], a
    ld a, $02
    ld [wStringID2], a
    farcall SetupDialogue79_44a0
    xor a
    ld [$c70e], a
    jp $4379

SECTION "Player Naming Screen", ROMX[$456e], BANK[$7a]

SetupPlayerNamingScreen:
    ld a, [$c70f]
    or a
    jr nz, .jr_07a_4587

    ld hl, $c711
    ld a, [hli]
    ld [$d9a9], a
    ld a, [hli]
    ld [$d9aa], a
    ld a, [hli]
    ld [$d9b1], a
    ld a, [hli]
    ld [$d9b2], a

.jr_07a_4587:
    ld hl, wPlayerName
    call $43d5
    ld a, [$c70e]
    ld [$c7b6], a
    ld bc, wPlayerName
    call SetupNamingScreen
    call $43a0
    ld a, $00
    call $2da7
    jp $4379


SECTION "Color Customization Screen", ROMX[$45f5], BANK[$7a]

SetupColorScreen:
    xor a
    ld [wMainMenuOption], a
    ld [$c71d], a
    call $4877
    ld hl, $58a0
    ld c, $7a
    ld de, $9000
    call $2e3b
    ld hl, $9800
    ld de, $5990
    ld bc, $1412
    call CopyTilemap7A
    ld a, $01
    ld [REG_VBK], a
    ld hl, $9800
    ld de, $5af8
    ld bc, $1412
    call CopyTilemap7A
    xor a
    ld [REG_VBK], a
    call $484d
    ld hl, $4187
    ld a, $7e
    call FarCall
    call $47ac
    call $47dc
    call $43a0
    ld a, $00
    call $2da7
    jp $4379

SECTION "Birthday Screen", ROMX[$48ba], BANK[$7a]

SetupBirthdayScreen:
    ld a, [$c70e]
    or a
    ld bc, $0000
    jr z, .jr_07a_48cb

    ld a, [$d40a]
    ld b, a
    ld a, [$d40b]
    ld c, a

.jr_07a_48cb
    ld a, b
    ld [wMainMenuOption], a
    ld a, c
    ld [$c704], a
    ld hl, $5c60
    ld c, $7a
    ld de, $9000
    call $2e3b
    ld hl, $9800
    ld de, $5d75
    ld bc, $1412
    call CopyTilemap7A
    ld a, $01
    ld [REG_VBK], a
    ld hl, $9800
    ld de, $5edd
    ld bc, $1412
    call CopyTilemap7A
    xor a
    ld [REG_VBK], a
    call $49ee
    ld hl, $4187
    ld a, $7e
    call FarCall
    call $4a0c
    call $43a0
    ld a, $00
    call $2da7
    jp $4379

SECTION "Blood Type Screen", ROMX[$4a67], BANK[$7a]

SetupBloodTypeScreen:
    ld a, [$c70e]
    or a
    ld a, $00
    jr z, .jr_07a_4a72
    ld a, [$d409]
.jr_07a_4a72
    ld [wMainMenuOption], a
    ld hl, $6045
    ld c, $7a
    ld de, $9000
    call $2e3b
    ld hl, $9800
    ld de, $60f5
    ld bc, $1412
    call CopyTilemap7A
    ld a, $01
    ld [REG_VBK], a
    ld hl, $9800
    ld de, $625d
    ld bc, $1412
    call CopyTilemap7A
    xor a
    ld [REG_VBK], a
    ld hl, $4187
    ld a, $7e
    call FarCall
    call $4b0e
    call $43a0
    ld a, $00
    call $2da7
    jp $4379

SECTION "Pet Screen", ROMX[$4b3d], BANK[$7a]

SetupPetScreen:
    ld a, [$c70e]
    or a
    jr nz, .jr_07a_4b46
    xor a
    jr .jr_07a_4b49
.jr_07a_4b46
    call $4c23
.jr_07a_4b49
    ld [wMainMenuOption], a
    ld hl, $6a42
    ld de, $d975
    ld b, $30
    call Copy
    ld hl, $63c5
    ld c, $7a
    ld de, $9000
    call $2e3b
    ld hl, $9800
    ld de, $6772
    ld bc, $1412
    call CopyTilemap7A
    ld a, $01
    ld [REG_VBK], a
    ld hl, $9800
    ld de, $68da
    ld bc, $1412
    call CopyTilemap7A
    xor a
    ld [REG_VBK], a
    ld hl, $4187
    ld a, $7e
    call FarCall
    call $4c02
    call $43a0
    ld a, $00
    call $2da7
.jr_07a_4b94
    jp $4379

SECTION "Pet Naming Screen", ROMX[$4c4f], BANK[$7a]

SetupPetNamingScreen:
    ld hl, wPetName
    call $43d5
    ld a, [$c70e]
    ld [$c7b6], a
    ld bc, wPetName
    call SetupNamingScreen
    call $43ab
    call $4cb3
    ld hl, $4187
    ld a, $7d
    call FarCall
    call $43a0
    ld a, $00
    call $2da7
    jp $4379

SECTION "Partner Naming Screen", ROMX[$4cc8], BANK[$7a]

SetupPartnerNamingScreen:
    ld hl, wPartnerName
    call $43d5
    ld a, [$c70e]
    or a
    jr nz, .jr_07a_4ce8
    ld a, [wPlayerGender]
    or a
    ld hl, DefaultGirlName
    jr z, .girl
    ld hl, DefaultBoyName
.girl
    ld b, $05
    ld de, wPartnerName
    call Copy
.jr_07a_4ce8:
    ld a, $01
    ld [$c7b6], a
    ld bc, wPartnerName
    call SetupNamingScreen
    call $4d4f
    ld hl, $4187
    ld a, $7d
    call FarCall
    call $43a0
    ld a, $00
    call $2da7
    jp $4379

DefaultBoyName:
    db "Pete@"
DefaultGirlName:
    db "Sara@"

SECTION "Confirmation Screen", ROMX[$4d86], BANK[$7a]

SetupConfirmationScreen:
    ld [$c70f], a
    call $43ab
    ld hl, $6ae6
    ld c, $7a
    ld de, $9000
    call $2e3b
    ld hl, $9800
    ld de, $6baa
    ld bc, $1415
    call CopyTilemap7A
    ld a, $01
    ld [REG_VBK], a
    ld hl, $9800
    ld de, $6d4e
    ld bc, $1415
    call CopyTilemap7A
    xor a
    ld [REG_VBK], a
    ld a, [wPlayerGender]
    or a
    ld a, $16
    ld b, $03
    jr z, .jr_07a_4dc4

    ld a, $19
    ld b, $04

.jr_07a_4dc4:
    ld hl, $98cc
    ld c, $01
    call $4090
    ld b, $00
    ld c, $80
    ld hl, $428f
    ld a, $79
    call FarCall
    ld a, [$d40a]
    ld b, a
    ld c, $84
    ld hl, $4255
    ld a, $79
    call FarCall
    ld a, [$d40b]
    inc a
    ld b, a
    ld c, $8a
    ld hl, $43a5
    ld a, $79
    call FarCall
    ld a, [$d409]
    ld b, a
    ld c, $8c
    ld hl, $4302
    ld a, $79
    call FarCall
    ld b, $01
    ld c, $8e
    ld hl, $428f
    ld a, $79
    call FarCall
    ld b, $02
    ld c, $92
    ld hl, $428f
    ld a, $79
    call FarCall
    ld hl, $4187
    ld a, $7e
    call FarCall
    call $4f32
    call $2489
    ld a, $0f
    ld [$c0a2], a
    call $439c
    ld a, $00
    call $2da7
    jp $4379

SECTION "Naming screen", ROMX[$5022], BANK[$7a]
SetupNamingScreen:
    ld hl, wNamingScreenDestination
    ld a, c
    ld [hli], a
    ld [hl], b
    ld h, b
    ld l, c
    ld a, [$c7b6]
    or a
    jr nz, .jr_07a_5037

    ld a, $ff
rept NAME_LENGTH
    ld [hli], a
endr
    ld [hl], a
.jr_07a_5037:
    ld h, b
    ld l, c
    ld c, $ff

.jr_07a_503b:
    inc c
    ld a, [hli]
    cp $ff
    jr nz, .jr_07a_503b

    ld a, c
    ld [wNamingScreenCursor], a
    xor a
    ld [wNamingScreenX], a
    ld [wNamingScreenY], a
    ld [$c7b7], a
    dec a
    ld [$c7b6], a
    call $40b1
    ld hl, $54b3
    ld de, wPalettes
    ld b, $08
    call Copy
    ld hl, $6f02
    ld de, $d9cd
    ld b, $08
    call Copy
    ld hl, $6ef2 ; right arrow tile?
    ld de, $8320
    ld b, $10
    call $4023
    ld hl, $6f0a
    ld c, $7a
    ld de, $9000
    call Decompress
    ld hl, $4230
    ld a, $7b
    call FarCall
    ld a, $01
    ld [REG_VBK], a
    ld hl, $2fd8
    ld de, $9000
    ld bc, $0800
    call $4032
    ld hl, $37d8
    ld de, $8800
    ld bc, $0800
    call $4032
    xor a
    ld [REG_VBK], a
    ld hl, $9800
    ld de, EnterNameTilemap
    ld bc, $1405
    call CopyTilemap7A
    ld a, $01
    ld [REG_VBK], a
    ld hl, $9800
    ld de, EnterNameAttributemap
    ld bc, $1405
    call CopyTilemap7A
    xor a
    ld [REG_VBK], a
    ld a, $02
    call LoadKeyboard ; $5341
    ld hl, $4187
    ld a, $7e
    call FarCall
    call $51db
    ld hl, $4187
    ld a, $7d
    call FarCall
    call NamingScreenWriteName
    ret 

DoNamingScreen:
    ld a, $ff
    ld [$c7b6], a
    ld a, [$c7b7]
    rst $00
    dw NamingScreenState0 ; $50f3
    dw NamingScreenState1 ; $5195
    dw NamingScreenState2 ; $51cc

NamingScreenState0:
    ld a, [wNamingScreenX]
    ld d, a
    ld a, [wNamingScreenY]
    ld e, a
    call $40d8 ; ??????

    dw NamingScreenSubState0 ; $5110
    dw NamingScreenSubState1 ; $512e
    dw NamingScreenSubState2 ; $5186
    dw NamingScreenSubState3 ; $5143
    dw NamingScreenSubState4 ; $5155
    dw NamingScreenSubState5 ; $514a
    dw NamingScreenSubState6 ; $5161
    dw NamingScreenSubState7 ; $516c
    dw NamingScreenSubState8 ; $5186

NamingScreenSubState0:
    call NamingScreenWriteLetter
    jr nc, jr_07a_511d
    
    ld a, $5a
    call $0ee4
    jp Jump_07a_5186


jr_07a_511d:
    call Call_07a_520f
    jr nc, jr_07a_5129

    xor a
    ld [$c7b6], a
    jp Jump_07a_5186


jr_07a_5129:
    ld hl, $c7b7
    inc [hl]
    ret 

NamingScreenSubState1:
    call $52eb
    jr nc, jr_07a_513b

    ld a, $5b
    call $0ee4
    jp Jump_07a_5186


jr_07a_513b:
    ld a, $01
    ld [$c7b6], a
    jp Jump_07a_5186

NamingScreenSubState3:
    ld c, $00
    ld de, $070a
    jr jr_07a_5176
    
NamingScreenSubState5:
    ld c, $02
    dec d
    bit 7, d
    jr z, jr_07a_5176

    ld d, $08
    jr jr_07a_5176

NamingScreenSubState4:
    ld c, $03
    inc d
    ld a, d
    cp $09
    jr c, jr_07a_5176

    ld d, $00
    jr jr_07a_5176

NamingScreenSubState6:
    ld c, $00
    dec e
    bit 7, e
    jr z, jr_07a_5176

    ld e, $0a
    jr jr_07a_5176

NamingScreenSubState7:
    ld c, $01
    inc e
    ld a, e
    cp $0b
    jr c, jr_07a_5176

    ld e, $00

jr_07a_5176:
    ld a, d
    ld [wNamingScreenX], a
    ld a, e
    ld [wNamingScreenY], a
    call NamingScreenSkipHoles
    ld a, $59
    call $0ee4

NamingScreenSubState2:
NamingScreenSubState8:
Jump_07a_5186:
    call Call_07a_51db
    call NamingScreenWriteName

    ld hl, $4187
    ld a, $7d
    call FarCall
    ret 

NamingScreenState1:
    ld a, $5c
    call $0ee4
    call $4135
    ld hl, $4cb3
    ld a, $07
    call FarCall
    ld a, $07
    ld [$ff00+$9c], a
    ld a, $60
    ld [$ff00+$9b], a
    ld hl, $4187
    ld a, $79
    call FarCall
    ld a, $02
    ld [wStringID], a
    ld a, $14
    ld [wStringID2], a
    ld hl, $419c
    ld a, $79
    call FarCall
    ld hl, $c7b7
    inc [hl]
    ret 

NamingScreenState2:
    ld a, [wDialogueState]
    bit 0, a
    ret nz

    call $4145
    ld hl, $c7b7
    dec [hl]
    dec [hl]
    ret 


Call_07a_51db:
    ld a, [wNamingScreenX]
    swap a
    add $08
    ld h, a
    ld a, [wNamingScreenY]
    add a
    add a
    add a
    add $38
    ld l, a
    ld b, $00
    ld de, $0509
    jp $4387


NamingScreen_GetCharFromCoords:
    ld a, [wNamingScreenY]
    swap a
    ld l, a
    ld h, $00
    add hl, hl
    ld a, [wNamingScreenX]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld de, $98c2
    add hl, de
    ld d, h
    ld e, l
    call $4001
    ret 


Call_07a_520f:
    ld hl, wNamingScreenDestination
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld b, NAME_LENGTH

jr_07a_5217:
    ld a, [hli]
    cp $ff
    jr z, jr_07a_5223

    cp $ef
    jr nz, jr_07a_5225

    dec b
    jr nz, jr_07a_5217

jr_07a_5223:
    or a
    ret 


jr_07a_5225:
    ld a, [wNamingScreenDestination]
    ld e, a
    ld a, [wNamingScreenDestinationHi]
    ld d, a
    ld hl, $5252

jr_07a_5230:
    ld a, [hli]
    cp $fe
    jr z, jr_07a_5240

    ld b, a
    ld a, [de]
    cp b
    jr z, jr_07a_5242

jr_07a_523a:
    ld a, [hli]
    inc a
    jr nz, jr_07a_523a

    jr jr_07a_5230

jr_07a_5240:
    scf 
    ret 


jr_07a_5242:
    push de

jr_07a_5243:
    inc de
    ld a, [de]
    cp [hl]
    jr nz, jr_07a_524f

    inc hl
    inc a
    jr nz, jr_07a_5243

    pop de
    jr jr_07a_5223

jr_07a_524f:
    pop de
    jr jr_07a_523a

    ld c, $2f
    daa 
    jr z, jr_07a_528c

    rst $38
    dec bc
    inc l
    cpl 
    cpl 
    inc a
    rst $38
    inc de
    ld [hld], a
    jr z, @+$01

    inc c
    dec hl
    cpl 
    ld [hld], a
    jr z, @+$01

    ld c, $2f
    dec a
    inc h
    rst $38
    dec bc
    inc l
    ld a, [hli]
    dec h
    jr z, jr_07a_529b

    rst $38
    inc d
    inc l
    dec [hl]
    ld l, $ff
    inc d
    inc h
    scf 
    jr z, @+$01

    ld d, $24
    dec [hl]
    cpl 
    inc h
    rst $38
    dec d
    jr c, @+$30

    inc l
    inc h
    rst $38
    dec d
    inc a

jr_07a_528c:
    cpl 
    inc h
    rst $38
    dec d
    jr c, jr_07a_52b8

    jr c, @+$38

    rst $38
    inc c
    ld [hld], a
    dec a
    inc a
    rst $38
    dec de

jr_07a_529b:
    ld [hld], a
    ld [hl], $2c
    jr z, @+$01

    inc c
    dec hl
    ld [hld], a
    ld h, $32
    rst $38
    dec c
    inc h
    inc l
    ld [hl], $3c
    rst $38
    inc c
    dec hl
    jr z, @+$39

    rst $38
    inc c
    inc h
    inc l
    ld sp, $20ff
    inc l

jr_07a_52b8:
    cpl 
    cpl 
    rst $38
    dec bc
    inc l
    cpl 
    cpl 
    rst $38
    ld d, $24
    dec [hl]
    inc a
    rst $38
    ld de, $2c28
    ld sp, $ff3d
    ld de, $3524
    dec [hl]
    inc a
    rst $38
    ld de, $3124
    ld [hl], $ff
    dec d
    inc l
    ld [hl], $24
    rst $38
    DB $10
    jr z, NamingScreenWriteLetter.jr_07a_530f

    rst $38
    ld [de], a
    ld [hl], $2b
    inc h
    rst $38
    rla 
    inc h
    ld sp, $3c26
    rst $38
    cp $fa
    or h
    rst $00
    or a
    ret z

    dec a
    ld [wNamingScreenCursor], a
    ld c, a
    ld b, $00
    ld hl, wNamingScreenDestination
    ld a, [hli]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld [hl], $ff
    scf 
    ret 


NamingScreenWriteLetter:
    call PackNamingScreenXY
    ld hl, TargetKeyboards
    cp $78
    jr z, .switch_keyboard
    ld hl, $533e
.jr_07a_530f: ; XXX
    cp $79
    jr z, .switch_keyboard
    cp $7a
    ret z

    ld hl, wNamingScreenCursor
    ld a, [hl]
    cp NAME_LENGTH
    jr z, .name_limit

    ld c, a
    inc [hl]
    call NamingScreen_GetCharFromCoords
    ld d, a
    ld hl, wNamingScreenDestination
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld b, $00
    add hl, bc
    ld [hl], d

.name_limit:
    scf 
    ret 

.switch_keyboard:
    ld a, [wKeyboard]
    call $4043
    call $5341
    scf 
    ret 

TargetKeyboards: ; 533b
    db 1, 0, 0
    db 2, 2, 1


LoadKeyboard:
    ld [wKeyboard], a
    ld a, [wKeyboard]
    ld hl, $5370
    call $4063
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    push hl
    ld hl, $98a0
    ld bc, $140d
    call CopyTilemap7A
    pop hl
    ld a, [hli]
    ld e, a
    ld d, [hl]
    ld a, $01
    ld [REG_VBK], a
    ld hl, $98a0
    ld bc, $140d
    call CopyTilemap7A
    xor a
    ld [REG_VBK], a
    ret 

KeyboardsTable:
    dw KeyboardLayout0Tilemap      ; $704c
    dw KeyboardLayout0Attributemap ; $7150
    dw KeyboardLayout1Tilemap      ; $7254
    dw KeyboardLayout1Attributemap ; $7358
    dw KeyboardLayout2Tilemap      ; $745c
    dw KeyboardLayout2Attributemap ; $7560


NamingScreenWriteName: ; $537c
; runs framely
; first, draw the name (every frame?!) and blink the cursor
    ld hl, $9872 - NAME_LENGTH
    ld a, [wNamingScreenDestination]
    ld e, a
    ld a, [wNamingScreenDestination+1]
    ld d, a
    ld b, NAME_LENGTH

.drawnameloop:
    ld a, [de]
    inc de
    cp $ff
    jr z, .blink

    call WriteTilemapByte7A
    dec b
    jr nz, .drawnameloop

    ret 

.blink
    ; the name isn't complete - blink the cursor
    ld a, [wFrameCounter]
    bit 5, a
    ld a, "_"
    jr z, .gotchar
    ld a, " "
.gotchar
    call WriteTilemapByte7A
    dec b
    ret z
    ld a, "_"
.padloop
    call WriteTilemapByte7A
    dec b
    jr nz, .padloop

    ret 


NamingScreenSkipHoles:
    ld a, c
    ld [$ff00+$a8], a
    ld a, [wKeyboard]
    cp $02
    ld hl, KeyboardTableKanaHoles
    ld de, KeyboardTableKanaTargets
    jr nz, .gottable
    ld hl, KeyboardTableHoles ; $5434
    ld de, KeyboardTableTargets ; $544c
.gottable
    call PackNamingScreenXY
    ld b, a
    ld c, $ff
.loop:
    ld a, [hli]
    cp $ff
    ret z
    inc c
    cp b
    jr nz, .loop

    ; get the new destination
    ld l, c
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, de
    ld a, [$ff00+$a8]
    call $4043
    ld b, a
    swap a
    and $0f
    ld [wNamingScreenX], a
    ld a, b
    and $0f
    ld [wNamingScreenY], a
    ret 

KeyboardTableKanaHoles:
    db $85, $86, $87, $88
    db $89, $8a, $05, $15
    db $25, $35, $45, $55
    db $65, $75, $ff

KeyboardTableKanaTargets:
    db $ff, $76, $ff, $ff
    db $ff, $ff, $76, $06
    db $ff, $ff, $77, $07
    db $ff, $ff, $78, $08
    db $ff, $ff, $79, $09
    db $7a, $ff, $7a, $0a
    db $04, $06, $ff, $ff
    db $14, $16, $ff, $ff
    db $24, $26, $ff, $ff
    db $34, $36, $ff, $ff
    db $44, $46, $ff, $ff
    db $54, $56, $ff, $ff
    db $64, $66, $ff, $ff
    db $74, $76, $ff, $ff

KeyboardTableHoles:
    db $82, $85, $87, $88
    db $89, $8a, $06, $16
    db $26, $36, $46, $56
    db $66, $76, $0a, $1a
    db $2a, $3a, $4a, $5a
    db $6a, $78, $79, $ff
    
KeyboardTableTargets:
    db $81, $83, $72, $02
    db $ff, $77, $75, $05
    db $ff, $ff, $77, $07
    db $ff, $ff, $68, $08
    db $ff, $ff, $69, $09
    db $7a, $ff, $7a, $09
    db $05, $07, $ff, $ff
    db $15, $17, $ff, $ff
    db $25, $27, $ff, $ff
    db $35, $37, $ff, $ff
    db $45, $47, $ff, $ff
    db $55, $57, $ff, $ff
    db $65, $67, $ff, $ff
    db $75, $77, $ff, $ff
    db $09, $00, $ff, $ff
    db $19, $10, $ff, $ff
    db $29, $20, $ff, $ff
    db $39, $30, $ff, $ff
    db $49, $40, $ff, $ff
    db $59, $50, $ff, $ff
    db $69, $60, $69, $ff
    db $ff, $7a, $ff, $08
    db $77, $ff, $ff, $09

PackNamingScreenXY: ; 54a8
    ld a, [wNamingScreenY]
    ld b, a
    ld a, [wNamingScreenX]
    swap a
    or b
    ret
    
; 54b3
    db $ff, $7f, $ff, $7f
    db $d3, $19, $42, $08
    db $ff, $7f, $ff, $7f
    db $d3, $19, $42, $08
    db $e0, $7f, $7f, $47
    db $72, $25, $84, $00
    db $e0, $7f, $7f, $47
    db $72, $25, $84, $00
    db $e0, $7f, $7f, $47
    db $72, $25, $84, $00
    db $e0, $7f, $7f, $47
    db $9f, $7a, $84, $00
    db $e0, $7f, $7f, $47
    db $8b, $31, $84, $00
    db $e0, $7f, $7f, $47
    db $90, $19, $84, $00
    db $e0, $7f, $7f, $47
    db $77, $31, $84, $00
    db $e0, $7f, $7f, $47
    db $73, $09, $84, $00
    db $50, $01, $ef, $ff
    db $10, $ff, $28, $20
    db $00, $44, $ff, $7c
    db $eb, $ff, $82, $20
    db $00, $00, $22, $00
    db $4e, $ff, $50, $cf
    db $ff, $60, $ff, $40
    db $20, $00, $03, $01
    db $3c, $ff, $57, $42
    db $ff, $7e, $00, $01
    db $3e, $04, $02, $42
    db $22, $00, $07, $3e
    db $ff, $02, $a0, $01
    db $05, $02, $41, $01
    db $e3, $00, $05, $02
    db $2a, $07, $01, $3c
    db $a0, $02, $3e, $40
    db $04, $3f, $00, $06
    db $61, $05, $e9, $40
    db $e0, $06, $41, $04
    db $7c, $0f, $07, $ff
    db $04, $ff, $9f, $38
    db $ff, $48, $ff, $30
    db $42, $07, $e3, $05
    db $08, $70, $42, $00
    db $23, $00, $a7, $00
    db $05, $01, $3c, $ff
    db $66, $20, $00, $e7
    db $0c, $ff, $18, $c0
    db $04, $41, $00, $f8
    db $ff, $84, $ea, $20
    db $00, $fc, $e2, $0c
    db $fc, $c4, $0b, $80
    db $ff, $9e, $7c, $e0
    db $0d, $03, $0a, $24
    db $ff, $fa, $ff, $22
    db $e0, $0e, $55, $a2
    db $20, $00, $64, $00
    db $08, $10, $20, $10
    db $20, $00, $07, $df
    db $68, $ff, $4a, $ff
    db $8c, $00, $09, $4c
    db $ff, $fd, $e2, $00
    db $08, $44, $ff, $9c
    db $ff, $a4, $ff, $7d
    db $9a, $02, $0a, $38
    db $ff, $54, $ff, $92
    db $20, $00, $12, $03
    db $03, $40, $e0, $10
    db $21, $09, $80, $00
    db $13, $01, $0c, $0c
    db $08, $d8, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $da, $db, $d7, $00
    db $01, $02, $d7, $03
    db $04, $05, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $df, $db, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $df, $db, $d7, $06
    db $d7, $07, $04, $03
    db $d7, $04, $01, $d7
    db $06, $d7, $09, $0a
    db $01, $0b, $0c, $d7
    db $df, $dc, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $de, $d8, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $da, $db, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $df, $db, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $df, $db, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $df, $db, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $df, $db, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $df, $db, $d7, $d7
    db $d7, $0d, $04, $03
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $0e, $0a
    db $01, $0b, $d7, $d7
    db $df, $dc, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $de, $d8, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $d9, $d9, $d9, $d9
    db $da, $db, $d7, $e0
    db $e1, $e2, $e3, $e4
    db $e5, $e6, $e7, $e8
    db $e9, $ea, $eb, $ec
    db $ed, $ee, $ef, $d7
    db $df, $db, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $d7, $d7, $d7, $d7
    db $df, $db, $d7, $f0
    db $f1, $f2, $f3, $f4
    db $f5, $f6, $f7, $f8
    db $f9, $fa, $fb, $fc
    db $fd, $fe, $ff, $d7
    db $df, $dc, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $dd, $dd, $dd, $dd
    db $dd, $dd, $dd, $dd

SECTION "Name Tilemaps", ROMX[$6f84], BANK[$7a]

EnterNameTilemap:
    db $d8,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$da
    db $db,$d7,$d7,$d7,$00,$01,$02,$03,$04,$d7,$05,$06,$07,$03,$08,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$09,$06,$07,$03,$0a,$ec,$ec,$ec,$ec,$d7,$df
    db $dc,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$de
EnterNameAttributemap:
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$08,$08,$08,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; hiragana
KeyboardLayout0Tilemap:
    db $d8,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$da
    db $db,$d7,$3e,$d7,$43,$d7,$48,$d7,$4d,$d7,$52,$d7,$57,$d7,$5c,$d7,$61,$d7,$64,$df
    db $db,$d7,$3f,$d7,$44,$d7,$49,$d7,$4e,$d7,$53,$d7,$58,$d7,$5d,$d7,$62,$d7,$65,$df
    db $db,$d7,$40,$d7,$45,$d7,$4a,$d7,$4f,$d7,$54,$d7,$59,$d7,$5e,$d7,$63,$d7,$66,$df
    db $db,$d7,$41,$d7,$46,$d7,$4b,$d7,$50,$d7,$55,$d7,$5a,$d7,$5f,$d7,$69,$d7,$67,$df
    db $db,$d7,$42,$d7,$47,$d7,$4c,$d7,$51,$d7,$56,$d7,$5b,$d7,$60,$d7,$6a,$d7,$68,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$6c,$d7,$71,$d7,$76,$d7,$7b,$d7,$80,$d7,$85,$d7,$8a,$d7,$e7,$d7,$d7,$df
    db $db,$d7,$6d,$d7,$72,$d7,$77,$d7,$7c,$d7,$81,$d7,$86,$d7,$8b,$d7,$ef,$d7,$d7,$df
    db $db,$d7,$6e,$d7,$73,$d7,$78,$d7,$7d,$d7,$82,$d7,$87,$d7,$8c,$d7,$0f,$10,$d7,$df
    db $db,$d7,$6f,$d7,$74,$d7,$79,$d7,$7e,$d7,$83,$d7,$88,$d7,$8d,$d7,$11,$12,$13,$df
    db $db,$d7,$70,$d7,$75,$d7,$7a,$d7,$7f,$d7,$84,$d7,$89,$d7,$6b,$d7,$14,$15,$16,$df
    db $dc,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$de

KeyboardLayout0Attributemap:
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; katakana
KeyboardLayout1Tilemap:
    db $d8,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$da
    db $db,$d7,$8e,$d7,$93,$d7,$98,$d7,$9d,$d7,$a2,$d7,$a7,$d7,$ac,$d7,$b1,$d7,$b4,$df
    db $db,$d7,$8f,$d7,$94,$d7,$99,$d7,$9e,$d7,$a3,$d7,$a8,$d7,$ad,$d7,$b2,$d7,$b5,$df
    db $db,$d7,$90,$d7,$95,$d7,$9a,$d7,$9f,$d7,$a4,$d7,$a9,$d7,$ae,$d7,$b3,$d7,$b6,$df
    db $db,$d7,$91,$d7,$96,$d7,$9b,$d7,$a0,$d7,$a5,$d7,$aa,$d7,$af,$d7,$b9,$d7,$b7,$df
    db $db,$d7,$92,$d7,$97,$d7,$9c,$d7,$a1,$d7,$a6,$d7,$ab,$d7,$b0,$d7,$ba,$d7,$b8,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,$bc,$d7,$c1,$d7,$c6,$d7,$cb,$d7,$d0,$d7,$d5,$d7,$da,$d7,$de,$d7,$d7,$df
    db $db,$d7,$bd,$d7,$c2,$d7,$c7,$d7,$cc,$d7,$d1,$d7,$d6,$d7,$db,$d7,$ef,$d7,$d7,$df
    db $db,$d7,$be,$d7,$c3,$d7,$c8,$d7,$cd,$d7,$d2,$d7,$d7,$d7,$dc,$d7,$0d,$0e,$d7,$df
    db $db,$d7,$bf,$d7,$c4,$d7,$c9,$d7,$ce,$d7,$d3,$d7,$d8,$d7,$dd,$d7,$11,$12,$13,$df
    db $db,$d7,$c0,$d7,$c5,$d7,$ca,$d7,$cf,$d7,$d4,$d7,$d9,$d7,$bb,$d7,$14,$15,$16,$df
    db $dc,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$de

KeyboardLayout1Attributemap:
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; latin alphabet
KeyboardLayout2Tilemap:
    db $d8,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$d9,$da
    db $db,$d7,"A",$d7,"B",$d7,"C",$d7,"D",$d7,"E",$d7,"F",$d7,"G",$d7,"H",$d7,"I",$df
    db $db,$d7,"J",$d7,"K",$d7,"L",$d7,"M",$d7,"N",$d7,"O",$d7,"P",$d7,"Q",$d7,"R",$df
    db $db,$d7,"S",$d7,"T",$d7,"U",$d7,"V",$d7,"W",$d7,"X",$d7,"Y",$d7,"Z",$d7,$d7,$df
    db $db,$d7,"a",$d7,"b",$d7,"c",$d7,"d",$d7,"e",$d7,"f",$d7,"g",$d7,"h",$d7,"i",$df
    db $db,$d7,"j",$d7,"k",$d7,"l",$d7,"m",$d7,"n",$d7,"o",$d7,"p",$d7,"q",$d7,"r",$df
    db $db,$d7,"s",$d7,"t",$d7,"u",$d7,"v",$d7,"w",$d7,"x",$d7,"y",$d7,"z",$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$df
    db $db,$d7,"0",$d7,"1",$d7,"2",$d7,"3",$d7,"4",$d7,"5",$d7,"6",$d7," ",$d7,$d7,$df
    db $db,$d7,"7",$d7,"8",$d7,"9",$d7,"!",$d7,"?",$d7,"&",$d7,"〜",$d7,$d7,$d7,$d7,$df
    db $db,$d7,"…",$d7,"_",$d7,"「",$d7,"」",$d7,$e2,$d7,"♥",$d7,"♪",$d7,$d7,$d7,$d7,$df
    db $db,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$00,$09,$0b,$df
    db $dc,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$de

KeyboardLayout2Attributemap:
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00,$00,$00
    db $00,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$08,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

