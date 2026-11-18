
.ifndef GetTileSafe
    .definelabel GetTileSafe, 0x2336D34
.endif


.ifndef TrySwitchPlace
    .definelabel TrySwitchPlace, 0x22EBB28
.endif

TrySwapWithAlly:
    ;-----------------------------------------------------------------
    ; Attempts to swap positions with an ally on a target tile.
    ;
    ; r0: user entity pointer
    ; r1: destination X
    ; r2: destination Y
    ;
    ; return: r0 = 1 if swap succeeded, 0 otherwise
    ;-----------------------------------------------------------------

        push {r4-r8,lr}

        ; Save arguments
        mov r4,r0              ; User
        mov r5,r1              ; Destination X
        mov r6,r2              ; Destination Y

        ; Get destination tile
        mov r0,r5
        mov r1,r6
        bl GetTileSafe

        ; Get monster entity on tile
        ldr r7,[r0,#0xC]

        ; Check if tile contains a monster
        cmp r7,#0
        beq @@fail

        ; Check if target is an ally
        mov r0,r4
        mov r1,r7
        bl IsTargetAlly

        cmp r0,#1
        bne @@fail

        ; Try switching places
        mov r0,r4
        mov r1,r7
        bl TrySwitchPlace

        ; Verify user's new position
        ldrh r0,[r4,#0x4]
        cmp r0,r5
        bne @@fail

        ldrh r0,[r4,#0x6]
        cmp r0,r6
        bne @@fail

        ; Swap succeeded
        mov r0,#1
        b @@end

    @@fail:
        mov r0,#0

    @@end:
        pop {r4-r8,pc}

    ;-----------------------------------------------------------------
    ; CUSTOM DEPENDENCIES
    ;-----------------------------------------------------------------

.include "IsTargetAlly.asm"
