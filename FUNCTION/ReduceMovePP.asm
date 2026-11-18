 
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