
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