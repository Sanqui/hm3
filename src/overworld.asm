 ORG $02, $4136

    ld a, [$ff8c]
    cp 1<<SELECT
    jp z, OverworldHandleSelect

    cp 1<<START
    jp z, OverworldHandleStart
