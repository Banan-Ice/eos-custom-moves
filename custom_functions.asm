; ==============================================================================
; CUSTOM FUNCTIONS - POKEMON MYSTERY DUNGEON: EXPLORERS OF SKY (EU)
; ==============================================================================
; Consolidated from FUNCTION.zip (23 original .asm files).
;
; HOW TO USE:
;   Include this file ONCE in an ARMIPS custom move, after stdlib/dunlib,
;   inside the move's .area and after the move entry code.
;
;   .include "lib/custom_functions.asm"
;
; Do NOT include any of the individual function files in the same move.
; This is a code library, not a standalone ARMIPS patch: it does not have
; .create, .org, .area, or .close directives.
;
; IMPORTANT: Including ALL functions increases binary size. A custom move
; can exceed MaxSize (0x2598) if the whole library is included.
; Use the original individual .asm files for small moves when necessary.
;
; Original function logic and interfaces preserved.
; All inter-function .include directives removed; functions defined once.
; Native EU symbols centralized under guards below.
; Local literal pools follow each function to keep LDR references in range.
; ==============================================================================

; ------------------------------------------------------------------------------
; NATIVE DEPENDENCIES (EU)
; ------------------------------------------------------------------------------

.ifndef AdvanceFrame
    .definelabel AdvanceFrame, 0x22EA990
.endif

.ifndef ApplyAquaRingHealing
    .definelabel ApplyAquaRingHealing, 0x2318E48
.endif

.ifndef BoostSpeedOneStage
    .definelabel BoostSpeedOneStage, 0x231539C
.endif

.ifndef CanMonsterMoveInDirection
    .definelabel CanMonsterMoveInDirection, 0x23018A4
.endif

.ifndef CannotStandOnTileNoMonsterCheck
    .definelabel CannotStandOnTileNoMonsterCheck, 0x2300384
.endif

.ifndef ChangeMonsterAnimation
    .definelabel ChangeMonsterAnimation, 0x23053D4
.endif

.ifndef CheckLeaderTile
    .definelabel CheckLeaderTile, 0x22F3FEC
.endif

.ifndef CheckNonLeaderTile
    .definelabel CheckNonLeaderTile, 0x23060C0
.endif

.ifndef DIRECTIONS_XY
    .definelabel DIRECTIONS_XY, 0x2352328
.endif

.ifndef DealDamage
    .definelabel DealDamage, 0x2333560
.endif

.ifndef EvolveMonster
    .definelabel EvolveMonster, 0x23046A8
.endif

.ifndef GetLeader
    .definelabel GetLeader, 0x22E9F30
.endif

.ifndef GetMaxPpWrapper
    .definelabel GetMaxPpWrapper, 0x231F458
.endif

.ifndef GetTileSafe
    .definelabel GetTileSafe, 0x2336D34
.endif

.ifndef IncrementEntityPixelPosXY
    .definelabel IncrementEntityPixelPosXY, 0x22E23D0
.endif

.ifndef LoadMonsterSprite
    .definelabel LoadMonsterSprite, 0x22F800C
.endif

.ifndef MakeMonsterIdleInDirection
    .definelabel MakeMonsterIdleInDirection, 0x2305528
.endif

.ifndef MoveMonsterToPos
    .definelabel MoveMonsterToPos, 0x22F8FFC
.endif

.ifndef RestoreAllMovePP
    .definelabel RestoreAllMovePP, 0x2318680
.endif

.ifndef TryRestoreHp
    .definelabel TryRestoreHp, 0x2315CCC
.endif

.ifndef TrySwitchPlace
    .definelabel TrySwitchPlace, 0x22EBB28
.endif

.ifndef UpdateEntityPixelPos
    .definelabel UpdateEntityPixelPos, 0x22E2380
.endif


; ------------------------------------------------------------------------------
; CUSTOM FUNCTIONS
; ------------------------------------------------------------------------------


; ==============================================================================
; GetFrontTile (original: GetFrontTile.asm)
; ==============================================================================


GetFrontTile:
    ;-----------------------------------------------------------------
    ; Calculates the tile directly in front of an entity.
    ;
    ; r0: entity pointer
    ;
    ; return:
    ; r0: front tile X
    ; r1: front tile Y
    ; r2: facing direction
    ;-----------------------------------------------------------------

        ; Get facing direction
        ldr r3,[r0,#0xB4]
        ldrb r2,[r3,#0x4C]

        ; Get X/Y direction offsets
        ldr r3,=DIRECTIONS_XY
        add r3,r3,r2,lsl #2

        ldrsh r12,[r3]       ; Direction X
        ldrsh r3,[r3,#0x2]   ; Direction Y

        ; Calculate destination
        ldrh r1,[r0,#0x6]    ; Current Y
        add r1,r1,r3         ; front tile Y

        ldrh r0,[r0,#0x4]    ; Current X
        add r0,r0,r12        ; front tile X

        bx lr

.pool


; ==============================================================================
; CanMoveForward (original: CanMoveForward.asm)
; ==============================================================================


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

.pool


; ==============================================================================
; AnimateWalkOneTile (original: AnimateWalkOneTile.asm)
; ==============================================================================


AnimateWalkOneTile:
    ;-----------------------------------------------------------------
    ; Animates an entity walking one tile forward over 12 frames.
    ; Does not update logical tile coordinates.
    ;
    ; r0: entity pointer
    ;-----------------------------------------------------------------

        push {r4-r8,lr}
        mov r4,r0

        ; Get facing direction
        ldr r0,[r4,#0xB4]
        ldrb r5,[r0,#0x4C]

        ; Get graphical X/Y offsets
        ldr r0,=DIRECTIONS_XY
        add r0,r0,r5,lsl #2

        ldrsh r7,[r0]
        ldrsh r8,[r0,#0x2]

        ; Convert to graphical units
        mov r7,r7,lsl #9
        mov r8,r8,lsl #9

        ; Start walking animation
        mov r0,r4
        mov r1,#0
        mov r2,r5
        bl ChangeMonsterAnimation

        ; Animate over 12 frames
        mov r6,#12

    @@walk_loop:
        ; Increment graphical position
        mov r0,r4
        mov r1,r7
        mov r2,r8
        bl IncrementEntityPixelPosXY

        ; Advance one frame
        mov r0,#0
        bl AdvanceFrame

        ; Next frame
        subs r6,r6,#1
        bne @@walk_loop

        ; Return to idle animation
        mov r0,r4
        mov r1,#7
        mov r2,r5
        bl ChangeMonsterAnimation

        pop {r4-r8,pc}

.pool


; ==============================================================================
; MoveForwardOneTile (original: MoveForwardOneTile.asm)
; ==============================================================================


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

.pool


; ==============================================================================
; MoveForwardNTiles (original: MoveForwardNTiles.asm)
; ==============================================================================


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

.pool


; ==============================================================================
; CheckTileTriggers (original: CheckTileTriggers.asm)
; ==============================================================================


CheckTileTriggers:
    ;-----------------------------------------------------------------
    ; Checks tile-triggered effects at entity's position
    ;
    ; r0: entity pointer
    ;-----------------------------------------------------------------

        push {r4,lr}

        ; Save entity pointer
        mov r4,r0

        ; Check if entity is the leader
        bl GetLeader
        cmp r0,r4
        beq @@leader

        ; Non-leader tile effects
        mov r0,r4
        bl CheckNonLeaderTile

        b @@end

    @@leader:
        ; Leader tile effects
        bl CheckLeaderTile

    @@end:
        pop {r4,pc}

.pool


; ==============================================================================
; IsTargetAlly (original: IsTargetAlly.asm)
; ==============================================================================


IsTargetAlly:
    ;-----------------------------------------------------------------
    ; Checks whether the user and target belong to the same side
    ; by comparing their monster affiliation flags.
    ;
    ; r0: user entity pointer
    ; r1: target entity pointer
    ; return: r0 = 1 if same side, 0 otherwise
    ;-----------------------------------------------------------------

        ; Get target affiliation flags
        ldr r2,[r1,#0xB4]
        ldrb r3,[r2,#0x6]
        ldrb r12,[r2,#0x8]
        eor r3,r3,r12

        ; Get user affiliation flags
        ldr r2,[r0,#0xB4]
        ldrb r0,[r2,#0x6]
        ldrb r12,[r2,#0x8]
        eor r0,r0,r12

        ; Compare affiliations
        cmp r0,r3

        ; Return 1 if equal, otherwise 0
        moveq r0,#1
        movne r0,#0

        bx lr

.pool


; ==============================================================================
; GetAttackPosition (original: GetAttackPosition.asm)
; ==============================================================================


GetAttackPosition:
    ;-----------------------------------------------------------------
    ; Determines the attacker's position relative to the target's
    ; facing direction, regardless of the attacker's orientation.
    ;
    ; r0: attacker entity pointer
    ; r1: target entity pointer
    ;
    ; return:
    ; r0 = 0 : Front
    ; r0 = 1 : Side
    ; r0 = 2 : Back
    ; r0 = 3 : Same tile (undefined position)
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Calculate delta X (attacker X - target X)
        ldrh r2,[r0,#0x4]
        ldrh r3,[r1,#0x4]
        sub r4,r2,r3

        ; Calculate delta Y (attacker Y - target Y)
        ldrh r2,[r0,#0x6]
        ldrh r3,[r1,#0x6]
        sub r5,r2,r3

        ; Check if attacker and target share the same tile
        orrs r2,r4,r5
        beq @@same_tile

        ; Get target's direction
        ldr r2,[r1,#0xB4]
        ldrb r3,[r2,#0x4C]

        ; Get direction vector from DIRECTIONS_XY
        ldr r2,=DIRECTIONS_XY
        add r2,r2,r3,lsl #2

        ldrsh r3,[r2]         ; Direction X
        ldrsh r6,[r2,#0x2]    ; Direction Y

        ; Delta X * Direction X
        mul r2,r3,r4

        ; Delta Y * Direction Y
        mul r3,r6,r5

        ; Dot product
        add r2,r2,r3
        cmp r2,#0

        ; Positive: attacker is in front
        movgt r0,#0

        ; Zero: attacker is on the side
        moveq r0,#1

        ; Negative: attacker is behind
        movlt r0,#2

        b @@end

    @@same_tile:
        mov r0,#3

    @@end:
        pop {r4-r6,pc}

.pool


; ==============================================================================
; FindNextAdjacentEntity (original: FindNextAdjacentEntity.asm)
; ==============================================================================


FindNextAdjacentEntity:
    ;-----------------------------------------------------------------
    ; Finds the first adjacent monster, searching clockwise
    ; starting from the center entity's facing direction.
    ;
    ; r0: Center entity pointer
    ; r1: First excluded entity pointer (or 0)
    ; r2: Second excluded entity pointer (or 0)
    ;
    ; return:
    ; r0 = Adjacent entity pointer, or 0 if none
    ;-----------------------------------------------------------------

        push {r4-r8,lr}

        ; Save parameters
        mov r4,r0                 ; Center entity
        mov r5,r1                 ; First exclusion
        mov r6,r2                 ; Second exclusion

        ; Get center entity's facing direction
        ldr r0,[r4,#0xB4]
        ldrb r7,[r0,#0x4C]

        ; Number of directions to check
        mov r8,#8

    @@check_direction:

        ; Get direction vector
        ldr r0,=DIRECTIONS_XY
        add r0,r0,r7,lsl #2

        ldrsh r1,[r0]             ; X offset
        ldrsh r2,[r0,#2]          ; Y offset

        ; Calculate adjacent coordinates
        ldrh r0,[r4,#0x4]
        add r0,r0,r1

        ldrh r1,[r4,#0x6]
        add r1,r1,r2

        ; Get adjacent tile
        bl GetTileSafe

        ; Check tile pointer
        cmp r0,#0
        beq @@next_direction

        ; Get monster on tile
        ldr r0,[r0,#0xC]

        ; Skip empty tiles
        cmp r0,#0
        beq @@next_direction

        ; Skip first excluded entity
        cmp r0,r5
        beq @@next_direction

        ; Skip second excluded entity
        cmp r0,r6
        beq @@next_direction

        ; Valid entity found
        b @@end

    @@next_direction:

        ; Rotate clockwise
        sub r7,r7,#1
        and r7,r7,#7

        ; Check next direction
        subs r8,r8,#1
        bne @@check_direction

        ; No valid entity found
        mov r0,#0

    @@end:
        pop {r4-r8,pc}

.pool


; ==============================================================================
; SwapWithEntity (original: SwapWithEntity.asm)
; ==============================================================================


; Native dependencies
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

.pool


; ==============================================================================
; TryPushEntityForward (original: TryPushEntityForward.asm)
; ==============================================================================


TryPushEntityForward:
    ;-----------------------------------------------------------------
    ; Pushes the entity directly in front of the user one tile
    ; forward, then moves the user into its original tile.
    ;
    ; Both entities walk simultaneously over 12 frames.
    ;
    ; r0: user entity pointer
    ;
    ; return:
    ; r0 = 1 if push succeeded, 0 otherwise
    ;-----------------------------------------------------------------

        push {r4-r8,r10-r11,lr}
        sub sp,sp,#16

        ; Save user entity
        mov r4,r0

        ; Calculate front tile coordinates
        bl GetFrontTile

        ; Save front tile position
        str r0,[sp,#8]         ; Front tile X
        str r1,[sp,#12]        ; Front tile Y

        ; GetFrontTile already returns X in r0 and Y in r1
        bl GetTileSafe

        ; Check tile pointer
        cmp r0,#0
        beq @@fail

        ; Get entity occupying the tile
        ldr r5,[r0,#0xC]

        ; Check if an entity is present
        cmp r5,#0
        beq @@fail

        ;---------------------------------------------------------------
        ; GET MOVEMENT DIRECTION
        ;---------------------------------------------------------------

        ; Get user's facing direction
        ldr r0,[r4,#0xB4]
        ldrb r8,[r0,#0x4C]

        ;---------------------------------------------------------------
        ; CHECK DESTINATION
        ;---------------------------------------------------------------

        ; Check whether the pushed entity can move forward
        mov r0,r5
        mov r1,r8
        bl CanMonsterMoveInDirection

        cmp r0,#0
        beq @@fail

        ; Get direction vector
        ldr r0,=DIRECTIONS_XY
        add r0,r0,r8,lsl #2

        ldrsh r6,[r0]          ; Direction X
        ldrsh r7,[r0,#2]       ; Direction Y

        ; Calculate pushed entity's destination
        ldrh r0,[r5,#0x4]
        add r0,r0,r6
        str r0,[sp]            ; Destination X

        ldrh r0,[r5,#0x6]
        add r0,r0,r7
        str r0,[sp,#4]         ; Destination Y

        ; Convert tile movement into graphical step
        mov r6,r6,lsl #9
        mov r7,r7,lsl #9

        ;---------------------------------------------------------------
        ; PREPARE WALKING ANIMATIONS
        ;---------------------------------------------------------------

        ; Turn pushed entity towards destination
        mov r0,r5
        mov r1,r8
        bl MakeMonsterIdleInDirection

        ; Start user's walking animation
        mov r0,r4
        mov r1,#0
        mov r2,r8
        bl ChangeMonsterAnimation

        ; Start pushed entity's hurting animation
        mov r0,r5
        mov r1,#6
        mov r2,r8
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

        ; Move pushed entity forward
        mov r0,r5
        mov r1,r6
        mov r2,r7
        bl IncrementEntityPixelPosXY

        ; Advance one frame
        mov r0,#0
        bl AdvanceFrame

        subs r10,r10,#1
        bne @@walk_loop

        ;---------------------------------------------------------------
        ; UPDATE LOGICAL POSITIONS
        ;---------------------------------------------------------------

        ; Move pushed entity first
        mov r0,r5
        ldr r1,[sp]
        ldr r2,[sp,#4]
        mov r3,#0
        bl MoveMonsterToPos

        ; Move user into the freed tile
        mov r0,r4
        ldr r1,[sp,#8]
        ldr r2,[sp,#12]
        mov r3,#0
        bl MoveMonsterToPos

        ;---------------------------------------------------------------
        ; SYNCHRONIZE GRAPHICAL POSITIONS
        ;---------------------------------------------------------------

        ; Update user's sprite position
        mov r0,r4
        mov r1,#0
        bl UpdateEntityPixelPos

        ; Update pushed entity's sprite position
        mov r0,r5
        mov r1,#0
        bl UpdateEntityPixelPos

        ;---------------------------------------------------------------
        ; RESTORE IDLE ANIMATIONS
        ;---------------------------------------------------------------

        ; User idle
        mov r0,r4
        mov r1,#7
        mov r2,r8
        bl ChangeMonsterAnimation

        ; Pushed entity idle
        mov r0,r5
        mov r1,#7
        mov r2,r8
        bl ChangeMonsterAnimation

        ; Check pushed entity's arrival tile
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
        add sp,sp,#16
        pop {r4-r8,r10-r11,pc}

    ;-----------------------------------------------------------------

.pool


; ==============================================================================
; TurnMonsterAround (original: TurnMonsterAround.asm)
; ==============================================================================


TurnMonsterAround:
    ;-----------------------------------------------------------------
    ; Turns a monster around (180 degrees).
    ; Rotates through 4 consecutive directions.
    ;
    ; r0: entity pointer
    ;-----------------------------------------------------------------

        push {r4-r8,lr}

        ; Save entity pointer
        mov r4,r0

        ; Get current direction
        ldr r0,[r4,#0xB4]
        ldrb r5,[r0,#0x4C]

        ; Number of rotations (4 x 45 degrees)
        mov r6,#4

    @@rotation_loop:

        ; Rotate 45 degrees
        add r5,r5,#1
        and r5,r5,#7

        ; Update monster direction and animation
        mov r0,r4
        mov r1,r5
        bl MakeMonsterIdleInDirection

        ; Wait 3 frames before next rotation
        mov r7,#3

    @@frame_loop:

        mov r0,#0
        bl AdvanceFrame

        subs r7,r7,#1
        bne @@frame_loop

        ; Next rotation
        subs r6,r6,#1
        bne @@rotation_loop

        ; Restore registers
        pop {r4-r8,pc}

.pool


; ==============================================================================
; BoostSpeedIfNeeded (original: BoostSpeedIfNeeded.asm)
; ==============================================================================


BoostSpeedIfNeeded:
    ;-----------------------------------------------------------------
    ; Boosts the user's speed by one stage only if no speed-up
    ; counter is currently active.
    ;
    ; r0: user entity pointer
    ; return: r0 = 1 if boost was attempted, 0 otherwise
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save user entity
        mov r4,r0

        ; Get monster structure
        ldr r5,[r4,#0xB4]

        ; Get first speed-up counter (offset 0x114)
        add r5,r5,#0x100
        add r5,r5,#0x14

        ; Initialize counter
        mov r6,#5

    @@loop:
        ; Check if a speed boost is active
        ldrb r0,[r5]
        cmp r0,#0
        bne @@already_boosted

        ; Check next speed-up counter
        add r5,r5,#1
        subs r6,r6,#1
        bne @@loop

        ; No active speed boost found
        mov r0,r4
        mov r1,r4
        mov r2,#1
        mov r3,#0
        bl BoostSpeedOneStage

        ; Boost was attempted
        mov r0,#1
        b @@end

    @@already_boosted:
        mov r0,#0

    @@end:
        pop {r4-r6,pc}

.pool


; ==============================================================================
; ChangeMonsterForm (original: ChangeMonsterForm.asm)
; ==============================================================================


ChangeMonsterForm:
    ;-----------------------------------------------------------------
    ; Changes a monster into the specified species if it doesn't
    ; already have that species ID.
    ; Loads the required sprite before calling EvolveMonster.
    ;
    ; r0: monster entity pointer
    ; r1: desired monster species ID
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save arguments
        mov r4,r0              ; Monster entity
        mov r5,r1              ; Desired species ID

        ; Get current species ID
        ldr r0,[r4,#0xB4]
        ldrh r0,[r0,#0x2]

        ; Check if already in desired form
        cmp r0,r5
        beq @@end

        ; Load new form's sprite
        mov r0,r5
        mov r1,#0
        bl LoadMonsterSprite

        ; Evolve monster
        mov r0,r4
        mov r1,r4
        mov r2,r5
        bl EvolveMonster

    @@end:
        pop {r4-r6,pc}

.pool


; ==============================================================================
; DealMoveDamage (original: DealMoveDamage.asm)
; ==============================================================================


DealMoveDamage:
    ;-----------------------------------------------------------------
    ; Deals move damage to a target with a configurable multiplier.
    ; Item ID is always set to 0 (regular move).
    ;
    ; r0: user entity pointer
    ; r1: target entity pointer
    ; r2: move pointer
    ; r3: damage multiplier (0x100 = 100% / 0xC0 = 75% / 0x80 = 50%
    ;     0x40 = 25% / 0x180 = 150% / 0x200 = 200% / 0x300 = 300%)
    ; return: r0 = amount of damage dealt
    ;-----------------------------------------------------------------

        push {r4,lr}

        ; Set item ID to 0
        mov r12,#0
        sub sp,sp,#8
        str r12,[sp]

        bl DealDamage

        add sp,sp,#8
        pop {r4,pc}

.pool


; ==============================================================================
; HealTargetFractionMaxHP (original: HealTargetFractionMaxHP.asm)
; ==============================================================================


HealTargetFractionMaxHP:
    ;-----------------------------------------------------------------
    ; Restores a fraction of the target's maximum HP.
    ; Minimum healing is 1 HP.
    ;
    ; r0: user entity pointer
    ; r1: target entity pointer
    ; r2: division exponent (0 = 100%, 1 = 50%, 2 = 25%, 3 = 12%
    ;                        4 = 6%, 5 = 3%, 6 = 1%)
    ; return: r0 = success
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save arguments
        mov r4,r0              ; User
        mov r5,r1              ; Target
        mov r6,r2              ; Division exponent

        ; Get target's monster structure
        ldr r0,[r5,#0xB4]

        ; Calculate actual maximum HP
        ldrsh r1,[r0,#0x12]    ; max_hp_stat
        ldrsh r2,[r0,#0x16]    ; max_hp_boost
        add r2,r2,r1

        ; Check maximum HP
        cmp r2,#0
        ble @@fail

        ; Divide maximum HP by 2^exponent
        mov r2,r2,lsr r6

        ; Ensure minimum healing of 1 HP
        cmp r2,#0
        moveq r2,#1

        ; Restore HP
        mov r0,r4
        mov r1,r5
        bl TryRestoreHp

        b @@end

    @@fail:
        mov r0,#0

    @@end:
        pop {r4-r6,pc}

.pool


; ==============================================================================
; HasAquaRingStatus (original: HasAquaRingStatus.asm)
; ==============================================================================


HasAquaRingStatus:
    ;-----------------------------------------------------------------
    ; Checks whether a monster has the Aqua Ring status.
    ;
    ; r0: monster entity pointer
    ; return: r0 = 1 if Aqua Ring is active, 0 otherwise
    ;-----------------------------------------------------------------

    ; Get monster structure
    ldr r0,[r0,#0xB4]

    ; Get reflect-class status
    ldrb r0,[r0,#0xD5]

    ; Check Aqua Ring
    cmp r0,#16
    moveq r0,#1
    movne r0,#0

    bx lr

.pool


; ==============================================================================
; HasPoisonStatus (original: HasPoisonStatus.asm)
; ==============================================================================


HasPoisonStatus:
    ;-----------------------------------------------------------------
    ; Checks whether a monster is poisoned or badly poisoned.
    ;
    ; r0: monster entity pointer
    ; return: r0 = 1 if poisoned, 0 otherwise
    ;-----------------------------------------------------------------

    ; Get monster structure
    ldr r0,[r0,#0xB4]

    ; Get burn-class status
    ldrb r0,[r0,#0xBF]

    ; Check Poison or Badly Poisoned
    cmp r0,#2
    moveq r0,#1
    bxeq lr

    cmp r0,#3
    moveq r0,#1
    movne r0,#0

    bx lr

.pool


; ==============================================================================
; AquaRingHealingLoop (original: AquaRingHealingLoop.asm)
; ==============================================================================


AquaRingHealingLoop:
	;-----------------------------------------------------------------
	; Applies Aqua Ring healing to the target once, plus one
	; additional time for every N levels of the user.
	;
	; r0: user entity pointer
	; r1: target entity pointer
	; r2: number of levels required per additional heal (must be > 0)
	;-----------------------------------------------------------------

		push {r4-r6,lr}

		; Save arguments
		mov r4,r1              ; Target
		mov r6,r2              ; Levels per additional heal

		; Get user's level
		ldr r0,[r0,#0xB4]      ; Monster structure
		ldrb r5,[r0,#0xA]      ; User's level

		; Apply initial healing
		mov r0,r4
		bl ApplyAquaRingHealing

		; Prevent infinite loop if LevelsPerHeal = 0
		cmp r6,#0
		beq @@end

	@@loop:
		; Check if enough levels remain
		cmp r5,r6
		blo @@end

		; Subtract required levels
		sub r5,r5,r6

		; Apply additional healing
		mov r0,r4
		bl ApplyAquaRingHealing

		b @@loop

	@@end:
    	pop {r4-r6,pc}

.pool


; ==============================================================================
; ReduceMovePP (original: ReduceMovePP.asm)
; ==============================================================================


 
ReduceMovePP:
    ;-----------------------------------------------------------------
    ; Reduces the PP of one of the target's moves.
    ; PP cannot drop below zero.
    ;
    ; r0: target entity pointer
    ; r1: move slot (1-4, ignored if r3 = 1)
    ; r2: PP amount to remove
    ; r3: last_used (0 = selected slot, 1 = last used move)
    ;
    ; return: r0 = 1 if PP were reduced, 0 otherwise
    ;-----------------------------------------------------------------

        ; Check amount
        cmp r2,#0
        beq @@fail

        ; Get target's monster structure
        ldr r0,[r0,#0xB4]

        ; Select search mode
        cmp r3,#0
        bne @@last_used

    @@by_move_slot
        ; Validate slot (1-4)
        cmp r1,#1
        blt @@fail
        cmp r1,#4
        bgt @@fail

        ; Convert 1-based slot to 0-based index
        sub r1,r1,#1

        ; Calculate move pointer: monster + 0x124 + index * 8
        add r0,r0,#0x100
        add r0,r0,#0x24
        add r0,r0,r1,lsl #3

        b @@move_found

    @@last_used:

        ; Point to first move
        add r0,r0,#0x100
        add r0,r0,#0x24

        ; Four move slots
        mov r1,#4

        @@loop:

            ; Read move flags
            ldrb r12,[r0]

            ; Check last-used flag
            tst r12,#0x10
            bne @@move_found

            ; Next move
            add r0,r0,#8

            subs r1,r1,#1
            bne @@loop

            b @@fail

    @@move_found:

        ; Check move exists
        ldrb r12,[r0]
        tst r12,#0x1
        beq @@fail

        ; Read current PP
        ldrb r1,[r0,#0x6]

        ; Skip if no PP remaining
        cmp r1,#0
        beq @@fail

        ; Subtract amount, clamp to zero
        cmp r1,r2
        subhi r1,r1,r2
        movls r1,#0

        ; Save updated PP
        strb r1,[r0,#0x6]

        ; Success
        mov r0,#1
        bx lr

    @@fail:
        mov r0,#0
        bx lr

.pool


; ==============================================================================
; RestoreAllPPIfNeeded (original: RestoreAllPPIfNeeded.asm)
; ==============================================================================


RestoreAllPPIfNeeded:
    ;-----------------------------------------------------------------
    ; Fully restores all moves' PP if at least one move is not at
    ; its maximum PP. Empty move slots are ignored.
    ;
    ; r0: monster entity pointer
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save monster entity
        mov r4,r0

        ; Get monster structure
        ldr r5,[r4,#0xB4]

        ; Get pointer to first move (offset 0x124)
        add r5,r5,#0x100
        add r5,r5,#0x24

        ; Initialize move counter
        mov r6,#4

    @@loop:
        ; Check if move slot is occupied
        ldrb r0,[r5]
        tst r0,#1
        beq @@next_move

        ; Get maximum PP
        mov r0,r5
        bl GetMaxPpWrapper

        ; Get current PP
        ldrb r1,[r5,#0x6]

        ; Compare current PP with maximum PP
        cmp r1,r0
        bne @@restore_pp

    @@next_move:
        ; Move to next slot (8 bytes)
        add r5,r5,#8

        ; Decrement counter
        subs r6,r6,#1
        bne @@loop

        ; All moves have full PP
        b @@end

    @@restore_pp:
        ; Fully restore all moves' PP
        mov r0,r4
        mov r1,r4
        mov r2,#99
        mov r3,#0
        bl RestoreAllMovePP

    @@end:
        pop {r4-r6,pc}

.pool


; ==============================================================================
; SetMovePP (original: SetMovePP.asm)
; ==============================================================================


SetMovePP:
    ;-----------------------------------------------------------------
    ; Sets the PP of one of the target's moves.
    ; The requested PP value is capped at the move's maximum PP.
    ;
    ; r0: target entity pointer
    ; r1: move slot (1-4, ignored if r3 = 1)
    ; r2: new PP value (0-99)
    ; r3: last_used (0 = selected slot, 1 = last used move)
    ;
    ; return: r0 = 1 if PP changed, 0 otherwise
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save arguments
        mov r5,r2              ; Requested PP
        mov r6,r3              ; Selection mode

        ; Validate PP value (0-99)
        cmp r5,#99
        bhi @@fail

        ; Get target's monster structure
        ldr r4,[r0,#0xB4]

        ; Select search mode
        cmp r6,#0
        bne @@last_used

    @@by_move_slot:

        ; Convert 1-based slot to 0-based index
        sub r1,r1,#1

        ; Validate slot index (0-3)
        cmp r1,#3
        bhi @@fail

        ; Calculate move pointer: monster + 0x124 + index * 8
        add r4,r4,#0x100
        add r4,r4,#0x24
        add r4,r4,r1,lsl #3

        b @@move_found

    @@last_used:

        ; Point to first move
        add r4,r4,#0x100
        add r4,r4,#0x24

        ; Four move slots
        mov r1,#4

        @@loop:

            ; Read move flags
            ldrb r2,[r4]

            ; Check last-used flag
            tst r2,#0x10
            bne @@move_found

            ; Next move
            add r4,r4,#8

            subs r1,r1,#1
            bne @@loop

            b @@fail

    @@move_found:

        ; Check move exists
        ldrb r2,[r4]
        tst r2,#0x1
        beq @@fail

        ; Get maximum PP
        mov r0,r4
        bl GetMaxPpWrapper

        ; Clamp requested PP to maximum
        cmp r5,r0
        movhi r5,r0

        ; Compare current PP with requested PP
        ldrb r2,[r4,#0x6]
        cmp r2,r5
        beq @@fail

        ; Set new PP value
        strb r5,[r4,#0x6]

        ; Success
        mov r0,#1
        b @@end

    @@fail:
        mov r0,#0

    @@end:
        pop {r4-r6,pc}

.pool


; ==============================================================================
; SendTargetMessage (original: SendTargetMessage.asm)
; ==============================================================================


SendTargetMessage:
    ;-----------------------------------------------------------------
    ; Displays a custom message containing the target's name.
    ;
    ; r0: Target entity pointer
    ; r1: String pointer
    ;
    ; Replaces [string:0] with the target's name.
    ;-----------------------------------------------------------------

        push {r4,lr}

        ; Save string pointer
        mov r4,r1

        ; Set [string:0] to target's name
        mov r1,r0
        mov r0,#0
        mov r2,#0
        bl ChangeString

        ; Display custom message
        mov r0,r9
        mov r1,r4
        bl SendMessageWithStringLog

        pop {r4,pc}

.pool
