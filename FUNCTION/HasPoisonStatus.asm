
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