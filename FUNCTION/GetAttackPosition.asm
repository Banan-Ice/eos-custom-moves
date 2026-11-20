
.ifndef DIRECTIONS_XY
    .definelabel DIRECTIONS_XY, 0x2352328
.endif

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
