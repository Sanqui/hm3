
INCLUDE "build/text/dummy.asm"

SECTION "Text pointer metatable at 17:400f", ROMX[$400f], BANK[$17]
; covers: strings/locations_island, strings/locations_mainland
    INCLUDE "build/text/17_400f_table.asm"
    INCLUDE "build/text/17_400f.asm"
TextSection17_400f_END

SECTION "Text pointer metatable at 18:400f", ROMX[$400f], BANK[$18]
; covers: dialogue/restaurant, dialogue/seed_shop, dialogue/book_shop, dialogue/mall, dialogue/theater
    INCLUDE "build/text/18_400f_table.asm"
    INCLUDE "build/text/18_400f.asm"
TextSection18_400f_END

SECTION "Text pointer metatable at 2e:400f", ROMX[$400f], BANK[$2e]
; covers: dialogue/town, dialogue/town2, dialogue/billy, dialogue/town3
    INCLUDE "build/text/2e_400f_table.asm"
    INCLUDE "build/text/2e_400f.asm"
TextSection2e_400f_END

SECTION "Text pointer metatable at 42:401f", ROMX[$401f], BANK[$42]
; covers: dialogue/player_found, dialogue/thanks, dialogue/partner_love, dialogue/ferry, fishing, dialogue/assorted
    INCLUDE "build/text/42_401f_table.asm"
    INCLUDE "build/text/42_401f.asm"
TextSection42_401f_END

SECTION "Text pointer metatable at 43:401f", ROMX[$401f], BANK[$43]
; covers: dialogue/house, dialogue/partner_assignments, strings/assignments, dialogue/caught, dialogue/house2, dialogue/weather, dialogue/partner, dialogue/partner_feelings
    INCLUDE "build/text/43_401f_table.asm"
    INCLUDE "build/text/43_401f.asm"
TextSection43_401f_END

SECTION "Text pointer table at 4a:4089", ROMX[$4089], BANK[$4a]
; is strings/names
    INCLUDE "build/text/4a_4089_table.asm"
    INCLUDE "build/text/4a_4089.asm"
TextSection4a_4089_END

SECTION "Text pointer metatable at 4b:400f", ROMX[$400f], BANK[$4b]
; covers: books, dialogue/lucas, dialogue/thanks2, dialogue/thanks3, dialogue/assorted3, dialogue/pak, dialogue/snowboarding, strings/buildings
    INCLUDE "build/text/4b_400f_table.asm"
    INCLUDE "build/text/4b_400f.asm"
TextSection4b_400f_END

SECTION "Text pointer metatable at 50:4b7e", ROMX[$4b7e], BANK[$50]
; covers: None, None, None, None, None, None, None, None, None, None, None, None, None, None, strings/main_menu, strings/partner_introductions, dialogue/wedding_boy, dialogue/wedding_girl, dialogue/evaluation
    INCLUDE "build/text/50_4b7e_table.asm"
    INCLUDE "build/text/50_4b7e.asm"
TextSection50_4b7e_END

SECTION "Text pointer metatable at 50:5804", ROMX[$5804], BANK[$50]
; covers: dialogue/farmers_union
    INCLUDE "build/text/50_5804_table.asm"
    INCLUDE "build/text/50_5804.asm"
TextSection50_5804_END

SECTION "Text pointer metatable at 50:6878", ROMX[$6878], BANK[$50]
; covers: None, None, None, None, None, None, dialogue/assorted2
    INCLUDE "build/text/50_6878_table.asm"
    INCLUDE "build/text/50_6878.asm"
TextSection50_6878_END

SECTION "Text pointer metatable at 79:44a0", ROMX[$44a0], BANK[$79]
; covers: strings/dummy, strings/items, strings/strings, strings/goods, strings/animals, dialogue/maomao, dialogue/girl_intro, dialogue/story, dialogue/record, dialogue/comedians, dialogue/boy_intro, dialogue/endings, strings/character_choice, strings/save
    INCLUDE "build/text/79_44a0_table.asm"
    INCLUDE "build/text/79_44a0.asm"
TextSection79_44a0_END

SECTION "Text pointer metatable at 7c:55f7", ROMX[$55f7], BANK[$7c]
; covers: None, None, None, None, None, None, None, None, dialogue/partner_events, dialogue/missing
    INCLUDE "build/text/7c_55f7_table.asm"
    INCLUDE "build/text/7c_55f7.asm"
TextSection7c_55f7_END

