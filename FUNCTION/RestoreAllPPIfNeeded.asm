
.ifndef GetMaxPpWrapper
    .definelabel GetMaxPpWrapper, 0x231F458
.endif

.ifndef RestoreAllMovePP
    .definelabel RestoreAllMovePP, 0x2318680
.endif

RestoreAllPPIfNeeded:
    ;-----------------------------------------------------------------
    ; Fully restores all moves' PP if at least one move is not at
    ; its maximum PP. Empty move slots are ignored.
    ;
    ; r0: monster entity pointer
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save monster entity
        mov r4,r0

        ; Get monster structure
        ldr r5,[r4,#0xB4]

        ; Get pointer to first move (offset 0x124)
        add r5,r5,#0x100
        add r5,r5,#0x24

        ; Initialize move counter
        mov r6,#4

    @@loop:
        ; Check if move slot is occupied
        ldrb r0,[r5]
        tst r0,#1
        beq @@next_move

        ; Get maximum PP
        mov r0,r5
        bl GetMaxPpWrapper

        ; Get current PP
        ldrb r1,[r5,#0x6]

        ; Compare current PP with maximum PP
        cmp r1,r0
        bne @@restore_pp

    @@next_move:
        ; Move to next slot (8 bytes)
        add r5,r5,#8

        ; Decrement counter
        subs r6,r6,#1
        bne @@loop

        ; All moves have full PP
        b @@end

    @@restore_pp:
        ; Fully restore all moves' PP
        mov r0,r4
        mov r1,r4
        mov r2,#99
        mov r3,#0
        bl RestoreAllMovePP

    @@end:
        pop {r4-r6,pc}