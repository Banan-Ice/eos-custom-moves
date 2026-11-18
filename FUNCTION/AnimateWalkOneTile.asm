
.ifndef DIRECTIONS_XY
    .definelabel DIRECTIONS_XY, 0x2352328
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