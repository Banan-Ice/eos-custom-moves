.ifndef GetTileSafe
    .definelabel GetTileSafe, 0x2336D34
.endif

.ifndef CanMonsterMoveInDirection
    .definelabel CanMonsterMoveInDirection, 0x23018A4
.endif

.ifndef DIRECTIONS_XY
    .definelabel DIRECTIONS_XY, 0x2352328
.endif

.ifndef MakeMonsterIdleInDirection
    .definelabel MakeMonsterIdleInDirection, 0x2305528
.endif

.ifndef ChangeMonsterAnimation
    .definelabel ChangeMonsterAnimation, 0x23053D4
.endif

.ifndef IncrementEntityPixelPosXY
    .definelabel IncrementEntityPixelPosXY, 0x22E23D0
.endif

.ifndef AdvanceFrame
    .definelabel AdvanceFrame, 0x22EA990
.endif

.ifndef MoveMonsterToPos
    .definelabel MoveMonsterToPos, 0x22F8FFC
.endif

.ifndef UpdateEntityPixelPos
    .definelabel UpdateEntityPixelPos, 0x22E2380
.endif

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
    ; CUSTOM DEPENDENCIES
    ;-----------------------------------------------------------------

;.include "lib/GetFrontTile.asm"
;.include "lib/CheckTileTriggers.asm"