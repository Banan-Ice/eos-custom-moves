
.ifndef MakeMonsterIdleInDirection
    .definelabel MakeMonsterIdleInDirection, 0x2305528
.endif

.ifndef AdvanceFrame
    .definelabel AdvanceFrame, 0x22EA990
.endif

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