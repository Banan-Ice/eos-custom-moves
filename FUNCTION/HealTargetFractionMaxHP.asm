
HealTargetFractionMaxHP:
    ;-----------------------------------------------------------------
    ; Restores a fraction of the target's maximum HP.
    ; Minimum healing is 1 HP.
    ;
    ; r0: user entity pointer
    ; r1: target entity pointer
    ; r2: division exponent (0 = 100%, 1 = 50%, 2 = 25%, 3 = 12%
    ;                        4 = 6%, 5 = 3%, 6 = 1%)
    ; return: r0 = success
    ;-----------------------------------------------------------------

        push {r4-r6,lr}
        sub sp,sp,#8

        ; Save arguments
        mov r4,r0              ; User
        mov r5,r1              ; Target
        mov r6,r2              ; Division exponent

        ; Get target's monster structure
        ldr r0,[r5,#0xB4]

        ; Calculate actual maximum HP
        ldrsh r1,[r0,#0x12]    ; max_hp_stat
        ldrsh r2,[r0,#0x16]    ; max_hp_boost
        add r2,r2,r1

        ; Check maximum HP
        cmp r2,#0
        ble @@fail

        ; Divide maximum HP by 2^exponent
        mov r2,r2,lsr r6

        ; Ensure minimum healing of 1 HP
        cmp r2,#0
        moveq r2,#1

        ; Restore HP
        mov r0,r4
        mov r1,r5
        mov r3,#1
        str r3,[sp]
		mov r3,#0
        bl RaiseHP

        b @@end

    @@fail:
        mov r0,#0

    @@end:

        add sp,sp,#8
        pop {r4-r6,pc}