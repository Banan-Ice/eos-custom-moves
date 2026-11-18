
.ifndef TryRestoreHp
    .definelabel TryRestoreHp, 0x2315CCC
.endif

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
        bl TryRestoreHp

        b @@end

    @@fail:
        mov r0,#0

    @@end:
        pop {r4-r6,pc}