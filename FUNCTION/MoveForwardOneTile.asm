
.ifndef MoveMonsterToPos
    .definelabel MoveMonsterToPos, 0x22F8FFC
.endif

.ifndef UpdateEntityPixelPos
    .definelabel UpdateEntityPixelPos, 0x22E2380
.endif

MoveForwardOneTile:
    ;-----------------------------------------------------------------
    ; Moves an entity one tile with walking animation.
    ; Updates logical and graphical positions.
    ;
    ; Does not check whether the destination is accessible. 
    ; (used with CanMoveForward.asm)
    ;
    ; r0: entity pointer
    ; r1: front tile X
    ; r2: front tile Y
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save arguments
        mov r4,r0              ; Entity
        mov r5,r1              ; front tile X
        mov r6,r2              ; front tile Y

        ; Animate walking forward
        mov r0,r4
        bl AnimateWalkOneTile

        ; Update logical tile position
        mov r0,r4
        mov r1,r5
        mov r2,r6
        mov r3,#0
        bl MoveMonsterToPos

        ; Synchronize graphical position
        mov r0,r4
        mov r1,#0
        bl UpdateEntityPixelPos

        pop {r4-r6,pc}

    ;-----------------------------------------------------------------
    ; CUSTOM DEPENDENCIES
    ;-----------------------------------------------------------------

.include "AnimateWalkOneTile.asm"
