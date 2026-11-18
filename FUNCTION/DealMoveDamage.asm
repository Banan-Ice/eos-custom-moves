
.ifndef DealDamage
    .definelabel DealDamage, 0x2333560
.endif

DealMoveDamage:
    ;-----------------------------------------------------------------
    ; Deals move damage to a target with a configurable multiplier.
    ; Item ID is always set to 0 (regular move).
    ;
    ; r0: user entity pointer
    ; r1: target entity pointer
    ; r2: move pointer
    ; r3: damage multiplier (0x100 = 100% / 0xC0 = 75% / 0x80 = 50%
    ;     0x40 = 25% / 0x180 = 150% / 0x200 = 200% / 0x300 = 300%)
    ; return: r0 = amount of damage dealt
    ;-----------------------------------------------------------------

        push {r4,lr}

        ; Set item ID to 0
        mov r12,#0
        sub sp,sp,#8
        str r12,[sp]

        bl DealDamage

        add sp,sp,#8
        pop {r4,pc}