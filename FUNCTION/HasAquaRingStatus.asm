
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