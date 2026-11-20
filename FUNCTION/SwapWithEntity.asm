; Native dependencies
.ifndef GetTileSafe
    .definelabel GetTileSafe, 0x2336D34
.endif

.ifndef TrySwitchPlace
    .definelabel TrySwitchPlace, 0x22EBB28
.endif

.ifndef DIRECTIONS_XY
    .definelabel DIRECTIONS_XY, 0x2352328
.endif

.ifndef UpdateEntityPixelPos
    .definelabel UpdateEntityPixelPos, 0x22E2380
.endif

.ifndef IncrementEntityPixelPosXY
    .definelabel IncrementEntityPixelPosXY, 0x22E23D0
.endif

.ifndef ChangeMonsterAnimation
    .definelabel ChangeMonsterAnimation, 0x23053D4
.endif

.ifndef AdvanceFrame
    .definelabel AdvanceFrame, 0x22EA990
.endif

.ifndef CannotStandOnTileNoMonsterCheck
    .definelabel CannotStandOnTileNoMonsterCheck, 0x2300384
.endif


SwapWithEntity:
    ;-----------------------------------------------------------------
    ; Swaps the user with the entity directly in front of it.
    ; Both entities walk simultaneously over 12 frames.
    ;
    ; r0: user entity pointer
    ;
    ; return:
    ; r0 = 1 if swap succeeded, 0 otherwise
    ;-----------------------------------------------------------------

        push {r4-r8,r10-r11,lr}
        sub sp,sp,#8

        ; Save user
        mov r4,r0

        ; Get front tile coordinates
        bl GetFrontTile

        ; Save destination
        str r0,[sp]           ; Destination X
        str r1,[sp,#4]        ; Destination Y

        ; Get destination tile
        bl GetTileSafe

        cmp r0,#0
        beq @@fail

        ; Get entity on destination tile
        ldr r5,[r0,#0xC]

        cmp r5,#0
        beq @@fail

        ;---------------------------------------------------------------
        ; CHECK TERRAIN COMPATIBILITY
        ;---------------------------------------------------------------

        ; Check if target can stand on user's current tile
        mov r0,r5
        add r1,r4,#0x4
        bl CannotStandOnTileNoMonsterCheck

        cmp r0,#0
        bne @@fail

        ; Check if user can stand on target's current tile
        mov r0,r4
        add r1,r5,#0x4
        bl CannotStandOnTileNoMonsterCheck

        cmp r0,#0
        bne @@fail

        ;---------------------------------------------------------------
        ; PREPARE MOVEMENT DIRECTION
        ;---------------------------------------------------------------

        ; Get user's direction
        ldr r0,[r4,#0xB4]
        ldrb r8,[r0,#0x4C]

        ; Get direction vector
        ldr r0,=DIRECTIONS_XY
        add r0,r0,r8,lsl #2

        ldrsh r6,[r0]          ; X direction
        ldrsh r7,[r0,#2]       ; Y direction

        ; Convert to graphical units per frame
        mov r6,r6,lsl #9
        mov r7,r7,lsl #9

        ;---------------------------------------------------------------
        ; PERFORM LOGICAL SWAP
        ;---------------------------------------------------------------

        ; Attempt swap with saved ally pointer
        mov r0,r4
        mov r1,r5
        bl TrySwitchPlace

        ; Verify user's new X position
        ldrh r0,[r4,#0x4]
        ldr r1,[sp]
        cmp r0,r1
        bne @@fail

        ; Verify user's new Y position
        ldrh r0,[r4,#0x6]
        ldr r1,[sp,#4]
        cmp r0,r1
        bne @@fail

        ;---------------------------------------------------------------
        ; RESTORE ORIGINAL GRAPHICAL POSITIONS
        ;---------------------------------------------------------------

        ; Synchronize sprites to new logical positions
        mov r0,r4
        mov r1,#0
        bl UpdateEntityPixelPos

        mov r0,r5
        mov r1,#0
        bl UpdateEntityPixelPos

        ; Total displacement = 12 frames * step

        ; X total
        add r1,r6,r6,lsl #1   ; Step * 3
        mov r1,r1,lsl #2      ; Step * 12

        ; Y total
        add r2,r7,r7,lsl #1
        mov r2,r2,lsl #2

        ; Put user's sprite back at original position
        rsb r1,r1,#0
        rsb r2,r2,#0

        mov r0,r4
        bl IncrementEntityPixelPosXY

        ; Put ally's sprite back at original position
        add r1,r6,r6,lsl #1
        mov r1,r1,lsl #2

        add r2,r7,r7,lsl #1
        mov r2,r2,lsl #2

        mov r0,r5
        bl IncrementEntityPixelPosXY

        ;---------------------------------------------------------------
        ; START WALKING ANIMATIONS
        ;---------------------------------------------------------------

        ; User walks forward
        mov r0,r4
        mov r1,#0
        mov r2,r8
        bl ChangeMonsterAnimation

        ; Ally walks in opposite direction
        mov r0,r5
        mov r1,#0
        add r2,r8,#4
        and r2,r2,#7
        bl ChangeMonsterAnimation

        ;---------------------------------------------------------------
        ; ANIMATE BOTH ENTITIES
        ;---------------------------------------------------------------

        mov r10,#12

    @@walk_loop:

        ; Move user forward
        mov r0,r4
        mov r1,r6
        mov r2,r7
        bl IncrementEntityPixelPosXY

        ; Move ally in opposite direction
        mov r0,r5
        rsb r1,r6,#0
        rsb r2,r7,#0
        bl IncrementEntityPixelPosXY

        ; Advance one frame
        mov r0,#0
        bl AdvanceFrame

        ; Next frame
        subs r10,r10,#1
        bne @@walk_loop

        ;---------------------------------------------------------------
        ; FINALIZE POSITIONS AND ANIMATIONS
        ;---------------------------------------------------------------

        ; Synchronize user's sprite
        mov r0,r4
        mov r1,#0
        bl UpdateEntityPixelPos

        ; Synchronize ally's sprite
        mov r0,r5
        mov r1,#0
        bl UpdateEntityPixelPos

        ; User idle
        mov r0,r4
        mov r1,#7
        mov r2,r8
        bl ChangeMonsterAnimation

        ; Ally idle
        mov r0,r5
        mov r1,#7
        add r2,r8,#4
        and r2,r2,#7
        bl ChangeMonsterAnimation

        ; Check target's arrival tile
        mov r0,r5
        bl CheckTileTriggers

        ; Check user's arrival tile
        mov r0,r4
        bl CheckTileTriggers

        ; Success
        mov r0,#1
        b @@end

    @@fail:
        mov r0,#0

    @@end:
        add sp,sp,#8
        pop {r4-r8,r10-r11,pc}


    ;-----------------------------------------------------------------
    ; CUSTOM DEPENDENCIES
    ;-----------------------------------------------------------------

;.include "lib/GetFrontTile.asm"
;.include "lib/CheckTileTriggers.asm"