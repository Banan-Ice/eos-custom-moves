
MoveForwardNTiles:
    ;-----------------------------------------------------------------
    ; Moves an entity forward by up to N tiles.
    ; Stops when movement is blocked or the limit is reached.
    ;
    ; r0: entity pointer
    ; r1: maximum number of tiles
    ;
    ; return: r0 = number of tiles actually moved
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save arguments
        mov r4,r0              ; Entity
        mov r5,r1              ; Remaining tiles

        ; Initialize movement counter
        mov r6,#0              ; Tiles moved

    @@movement_loop:

        ; Check remaining movement distance
        cmp r5,#0
        ble @@end

        ; Check if entity can move forward
        mov r0,r4
        bl CanMoveForward

        ; Stop if next tile is blocked
        cmp r0,#0
        beq @@end

        ; Move one tile with animation
        mov r0,r4
        bl MoveForwardOneTile

        ; Update counters
        add r6,r6,#1           ; Tiles moved +1
        sub r5,r5,#1           ; Remaining tiles -1

        b @@movement_loop

    @@end:

        ; Return number of tiles moved
        mov r0,r6

        pop {r4-r6,pc}

    ;-----------------------------------------------------------------
    ; CUSTOM DEPENDENCIES
    ;-----------------------------------------------------------------

.include "CanMoveForward.asm"
.include "MoveForwardOneTile.asm"