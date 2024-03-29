
INCLUDE "build/text/dummy.asm"

MACRO setup_start_dialogue_asm
SetupDialogue\1:
    ld de, Metatable\1
    call SetupDialogue
    ret

StartDialogue\1:
    call SetupDialogue\1
    call StartDialogue
    ret
ENDM

MACRO setup_start_dialogue_overflow_asm
SetupDialogue\1:
    ld a, [wStringID]
    cp a, \2
    jr c, .here
    ld hl, SetupDialogue\3
    ld a, BANK(SetupDialogue\3)
    call FarCall
    ret
.here
    ld de, Metatable\1
    call SetupDialogue
    ret

StartDialogue\1:
    call SetupDialogue\1
    call StartDialogue
    ret
ENDM

SECTION "Text pointer metatable at 01:52f9", ROMX[$52eb], BANK[$01]
; covers: strings/test, strings/debug, strings/items_select
    setup_start_dialogue_asm 01_52f9
    INCLUDE "build/text/01_52f9_table.asm"
    INCLUDE "build/text/01_52f9.asm"
TextSection01_52f9_END:

SECTION "Text pointer metatable at 07:4001", ROMX[$4001], BANK[$07]
; covers: signs/farm, signs/garden, signs/barns, signs/backyard, signs/hot_spring, signs/outside
    setup_start_dialogue_asm 07_400f
    INCLUDE "build/text/07_400f_table.asm"
    INCLUDE "build/text/07_400f.asm"
TextSection07_400f_END:

; code follows, naturally

SECTION "Text bank at 17:4001", ROMX[$4001], BANK[$17]
; covers: strings/locations_island, strings/locations_mainland
    setup_start_dialogue_asm 17_400f
    INCLUDE "build/text/17_400f_table.asm"
    INCLUDE "build/text/17_400f.asm"
TextSection17_400f_END:

; code and other data follows

SECTION "Text pointer metatable at 18:4001", ROMX[$4001], BANK[$18]
; covers: dialogue/restaurant, dialogue/seed_shop, dialogue/book_shop, dialogue/mall, dialogue/theater
    setup_start_dialogue_asm 18_400f
    INCLUDE "build/text/18_400f_table.asm"
    INCLUDE "build/text/18_400f.asm"
TextSection18_400f_END:

; code follows

SECTION "Text pointer metatable at 20:4001", ROMX[$4001], BANK[$20]
; covers: dialogue/animals
    setup_start_dialogue_asm 20_400f
    INCLUDE "build/text/20_400f_table.asm"
    INCLUDE "build/text/20_400f.asm"
TextSection20_400f_END:

; code follows


SECTION "Text pointer metatable at 2e:4001", ROMX[$4001], BANK[$2e]
; covers: dialogue/town, dialogue/town2, dialogue/billy, dialogue/town3
    setup_start_dialogue_asm 2e_400f
    INCLUDE "build/text/2e_400f_table.asm"
    INCLUDE "build/text/2e_400f.asm"
TextSection2e_400f_END:

; code follows

SECTION "Text pointer metatable at 42:4001", ROMX[$4001], BANK[$42]
; covers: dialogue/player_found, dialogue/thanks, dialogue/partner_love, dialogue/ferry, fishing, dialogue/assorted
    setup_start_dialogue_overflow_asm 42_401f, 6, 50_6878
    INCLUDE "build/text/42_401f_table.asm"
    INCLUDE "build/text/42_401f.asm"
TextSection42_401f_END:

; data and code follows

SECTION "Text pointer metatable at 43:4001", ROMX[$4001], BANK[$43]
; covers: dialogue/house, dialogue/partner_assignments, strings/assignments, dialogue/caught, dialogue/house2, dialogue/weather, dialogue/partner, dialogue/partner_feelings
    setup_start_dialogue_overflow_asm 43_401f, 8, 7c_55f7
    INCLUDE "build/text/43_401f_table.asm"
    INCLUDE "build/text/43_401f.asm"
TextSection43_401f_END:

; rest of bank is free

SECTION "Text pointer table at 4a:4089", ROMX[$4089], BANK[$4a]
; is strings/names
    INCLUDE "build/text/4a_4089_table.asm"
    INCLUDE "build/text/4a_4089.asm"
TextSection4a_4089_END:

; rest of bank is free

SECTION "Text pointer metatable at 4b:4001", ROMX[$4001], BANK[$4b]
; covers: books, dialogue/lucas, dialogue/thanks2, dialogue/thanks3, dialogue/assorted3, dialogue/pak, dialogue/snowboarding, strings/buildings
    setup_start_dialogue_asm 4b_400f
    INCLUDE "build/text/4b_400f_table.asm"
    INCLUDE "build/text/4b_400f.asm"
TextSection4b_400f_END:

; covers: dialogue/naysaying
    setup_start_dialogue_asm 4b_6c1f
    INCLUDE "build/text/4b_6c1f_table.asm"
    INCLUDE "build/text/4b_6c1f.asm"
TextSection4b_6c1f_END:

; data and code follows

SECTION "Text pointer metatable at 50:4b70", ROMX[$4b70], BANK[$50]
; covers: None, None, None, None, None, None, None, None, None, None, None, None, None, None, strings/main_menu, strings/partner_introductions, dialogue/wedding_boy, dialogue/wedding_girl, dialogue/evaluation
    setup_start_dialogue_asm 50_4b7e
    INCLUDE "build/text/50_4b7e_table.asm"
    INCLUDE "build/text/50_4b7e.asm"
TextSection50_4b7e_END:

; covers: dialogue/farmers_union
    setup_start_dialogue_asm 50_5804
    INCLUDE "build/text/50_5804_table.asm"
    INCLUDE "build/text/50_5804.asm"
TextSection50_5804_END:

; covers: None, None, None, None, None, None, dialogue/assorted2
    setup_start_dialogue_asm 50_6878
    INCLUDE "build/text/50_6878_table.asm"
    INCLUDE "build/text/50_6878.asm"
TextSection50_6878_END:

; rest of the bank is empty

SECTION "Text pointer metatable at 79:44a0", ROMX[$44a0], BANK[$79]
; covers: strings/dummy, strings/items, strings/strings, strings/goods, strings/animals, dialogue/maomao, dialogue/girl_intro, dialogue/story, dialogue/record, dialogue/comedians, dialogue/boy_intro, dialogue/endings, strings/character_choice, strings/save
    ; the logic above this is a bit more complex and also
    ; covers the font, do it another time TODO
    INCLUDE "build/text/79_44a0_table.asm"
    INCLUDE "build/text/79_44a0.asm"
TextSection79_44a0_END:

; rest of the bank is empty

SECTION "Start/setup diloague for 7c:437a", ROMX[$4187], BANK[$7c]
    setup_start_dialogue_asm 7c_437a

    ; wtf is the following code?  I'm out.
    ; also I just realized I cared for bank 79 not this anyway.
    
    

SECTION "Text pointer metatable at 7c:437a", ROMX[$437a], BANK[$7c]
; covers: dialogue/snowboard, dialogue/market, dialogue/tutorial, text/credits, dialogue/sound_test
    ; the relevant code is at 7c:4187 (wth...)
    INCLUDE "build/text/7c_437a_table.asm"
    INCLUDE "build/text/7c_437a.asm"
TextSection7c_437a_END:

; covers: None, None, None, None, None, None, None, None, dialogue/partner_events, dialogue/missing
    setup_start_dialogue_asm 7c_55f7
    INCLUDE "build/text/7c_55f7_table.asm"
    INCLUDE "build/text/7c_55f7.asm"
TextSection7c_55f7_END:

; rest of the bank is empty
