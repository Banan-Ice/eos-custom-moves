
.ifndef EvolveMonster
    .definelabel EvolveMonster, 0x23046A8
.endif

.ifndef LoadMonsterSprite
    .definelabel LoadMonsterSprite, 0x22F800C
.endif

ChangeMonsterForm:
    ;-----------------------------------------------------------------
    ; Changes a monster into the specified species if it doesn't
    ; already have that species ID.
    ; Loads the required sprite before calling EvolveMonster.
    ;
    ; r0: monster entity pointer
    ; r1: desired monster species ID
    ;-----------------------------------------------------------------

        push {r4-r6,lr}

        ; Save arguments
        mov r4,r0              ; Monster entity
        mov r5,r1              ; Desired species ID

        ; Get current species ID
        ldr r0,[r4,#0xB4]
        ldrh r0,[r0,#0x2]

        ; Check if already in desired form
        cmp r0,r5
        beq @@end

        ; Load new form's sprite
        mov r0,r5
        mov r1,#0
        bl LoadMonsterSprite

        ; Evolve monster
        mov r0,r4
        mov r1,r4
        mov r2,r5
        bl EvolveMonster

    @@end:
        pop {r4-r6,pc}