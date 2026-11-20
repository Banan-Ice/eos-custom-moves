.ifndef GetTileSafe
    .definelabel GetTileSafe, 0x2336D34
.endif

.ifndef DIRECTIONS_XY
    .definelabel DIRECTIONS_XY, 0x2352328
.endif


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