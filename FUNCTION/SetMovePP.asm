
.ifndef GetMaxPpWrapper
    .definelabel GetMaxPpWrapper, 0x231F458
.endif

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