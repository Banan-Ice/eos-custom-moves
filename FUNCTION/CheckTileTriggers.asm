
.ifndef CheckNonLeaderTile
    .definelabel CheckNonLeaderTile, 0x23060C0
.endif

.ifndef CheckLeaderTile
    .definelabel CheckLeaderTile, 0x22F3FEC
.endif

.ifndef GetLeader
    .definelabel GetLeader, 0x22E9F30
.endif

CheckTileTriggers:
    ;-----------------------------------------------------------------
    ; Checks tile-triggered effects at entity's position
    ;
    ; r0: entity pointer
    ;-----------------------------------------------------------------

        push {r4,lr}

        ; Save entity pointer
        mov r4,r0

        ; Check if entity is the leader
        bl GetLeader
        cmp r0,r4
        beq @@leader

        ; Non-leader tile effects
        mov r0,r4
        bl CheckNonLeaderTile

        b @@end

    @@leader:
        ; Leader tile effects
        bl CheckLeaderTile

    @@end:
        pop {r4,pc}