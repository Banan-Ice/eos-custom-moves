
.ifndef CanMonsterMoveInDirection
    .definelabel CanMonsterMoveInDirection, 0x23018A4
.endif

CanMoveForward:
    ;-----------------------------------------------------------------
    ; Checks if an entity can move one tile forward.
    ;
    ; r0: entity pointer
    ;
    ; return:
    ; r0: 1 if movement is possible, 0 otherwise
    ; r1: front tile X
    ; r2: front tile Y
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save entity pointer
        mov r4,r0

        ; Get forward destination and direction
        bl GetFrontTile

        ; Save front tile coordinates
        mov r5,r0              ; front tile X
        mov r6,r1              ; front tile Y

        ; Check movement availability
        mov r1,r2              ; Direction
        mov r0,r4              ; Entity
        bl CanMonsterMoveInDirection

        ; Restore destination coordinates as return values
        mov r1,r5
        mov r2,r6

        pop {r4-r6,pc}

    ;-----------------------------------------------------------------
    ; CUSTOM DEPENDENCIES
    ;-----------------------------------------------------------------

;.include "lib/GetFrontTile.asm"

