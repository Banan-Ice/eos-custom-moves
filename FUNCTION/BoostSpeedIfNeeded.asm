
.ifndef BoostSpeedOneStage
    .definelabel BoostSpeedOneStage, 0x231539C
.endif

BoostSpeedIfNeeded:
    ;-----------------------------------------------------------------
    ; Boosts the user's speed by one stage only if no speed-up
    ; counter is currently active.
    ;
    ; r0: user entity pointer
    ; return: r0 = 1 if boost was attempted, 0 otherwise
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save user entity
        mov r4,r0

        ; Get monster structure
        ldr r5,[r4,#0xB4]

        ; Get first speed-up counter (offset 0x114)
        add r5,r5,#0x100
        add r5,r5,#0x14

        ; Initialize counter
        mov r6,#5

    @@loop:
        ; Check if a speed boost is active
        ldrb r0,[r5]
        cmp r0,#0
        bne @@already_boosted

        ; Check next speed-up counter
        add r5,r5,#1
        subs r6,r6,#1
        bne @@loop

        ; No active speed boost found
        mov r0,r4
        mov r1,r4
        mov r2,#1
        mov r3,#0
        bl BoostSpeedOneStage

        ; Boost was attempted
        mov r0,#1
        b @@end

    @@already_boosted:
        mov r0,#0

    @@end:
        pop {r4-r6,pc}
