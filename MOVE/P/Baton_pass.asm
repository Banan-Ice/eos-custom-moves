; ------------------------------------------------------------------------------
; BATON PASS
; ---
; [Bonus Action]
; Switches positions with a target.
; Ally : Raises its Atk and Sp.Atk by one stage.
; Foe : lowers its Def and Spe.Def by one stage.
; ---
; Target : Everyone
; Range : Line
; ------------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For EU
.include "lib/stdlib_eu.asm"
.include "lib/dunlib_eu.asm"
.definelabel MoveStartAddress, 0x02330B74
.definelabel MoveJumpAddress, 0x0233310C
.definelabel DungeonRandInt, 0x22EB448
.definelabel SwapEntity, 0x022EBB28
.definelabel GetTileAtEntity, 0x022E1F68
.definelabel BoostSpeedOneStage, 0x231539C
.definelabel ApplyAquaRingHealing, 0x2318E48

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

BatonPass:
	   
	    ; Switch position with target
		mov r0,r9
		bl GetTileAtEntity
		mov r10,r0
		mov r0,r9
		mov r1,r4
		mov r2,#0
		mov r2,#0
		bl SwapEntity 

		; Check if the swap occured
		mov r0,r9
		bl GetTileAtEntity
		cmp r0,r10
		moveq r10,#0
		beq MoveJumpAddress

		; Check if target is ally or foe
		mov r0,r9
		mov r1,r4
		bl IsTargetAlly
		mov r11,r0

		; Get user's species ID
		ldr r0,[r9,#0xB4]    ; Get monster structure
		ldrh r0,[r0,#0x2]    ; Get species I

		; Check current form
		ldr r1,=733
		cmp r0,r1
		beq @@is_eevee
		ldr r1,=734
		cmp r0,r1
		beq @@is_vaporeon
		ldr r1,=735
		cmp r0,r1
		beq @@is_jolteon
		ldr r1,=736
		cmp r0,r1
		beq @@is_flareon
		ldr r1,=796
		cmp r0,r1
		beq @@is_espeon
		ldr r1,=797
		cmp r0,r1
		beq @@is_umbreon
		ldr r1,=1070
		cmp r0,r1
		beq @@is_leafeon
		ldr r1,=1071
		cmp r0,r1
		beq @@is_glaceon

		b @@end_move

	@@is_eevee:
		cmp r11,#1
		beq @@ally_eevee

		@@foe_eevee:
			; -1 def & -1 Spe.Def
			sub sp,sp,#8
			mov r0,r9
			mov r1,r4
			mov r2,#0
			mov r3,#1
			str r3,[r13]
			str r3,[r13,#+0x4]
			bl DefenseStatDown
			mov r0,r9
			mov r1,r4
			mov r2,#1
			mov r3,#1
			str r3,[r13]
			str r3,[r13,#+0x4]
			bl DefenseStatDown
			add sp,sp,#8
			b @@end_move

		@@ally_eevee:
			; +1 Atk & +1 Spe.Atk
			sub sp,sp,#8
			mov r0,r9
			mov r1,r4
			mov r2,#0
			mov r3,#1
			str r3,[sp]
			str r3,[sp,#4]
			bl AttackStatUp
			mov r0,r9
			mov r1,r4
			mov r2,#1
			mov r3,#1
			str r3,[sp]
			str r3,[sp,#4]
			bl AttackStatUp
			add sp,sp,#8
			b @@end_move

	@@is_vaporeon:
		cmp r11,#1
		beq @@ally_vaporeon

		@@foe_vaporeon:
			;EFFECT HERE
			b @@end_move
		
		@@ally_vaporeon:
			mov r0,r4
			bl ApplyAquaRingHealing
			b @@end_move

	@@is_jolteon:
		cmp r11,#1
		beq @@ally_jolteon

		@@foe_jolteon:
			;EFFECT HERE
			b @@end_move
		
		@@ally_jolteon:
			;EFFECT HERE
			b @@end_move

	@@is_flareon:
		cmp r11,#1
		beq @@ally_flareon

		@@foe_flareon:
			;EFFECT HERE
			b @@end_move
		
		@@ally_flareon:
			;EFFECT HERE
			b @@end_move

	@@is_espeon:
		cmp r11,#1
		beq @@ally_espeon

		@@foe_espeon:
			;EFFECT HERE
			b @@end_move
		
		@@ally_espeon:
			;EFFECT HERE
			b @@end_move

	@@is_umbreon:
		cmp r11,#1
		beq @@ally_umbreon

		@@foe_umbreon:
			;EFFECT HERE
			b @@end_move
		
		@@ally_umbreon:
			;EFFECT HERE
			b @@end_move

	@@is_leafeon:
		cmp r11,#1
		beq @@ally_leafeon

		@@foe_leafeon:
			;EFFECT HERE
			b @@end_move
		
		@@ally_leafeon:
			;EFFECT HERE
			b @@end_move

	@@is_glaceon:
		cmp r11,#1
		beq @@ally_glaceon

		@@foe_glaceon:
			;EFFECT HERE
			b @@end_move
		
		@@ally_glaceon:
			;EFFECT HERE
			b @@end_move

	@@end_move:
        ; BONUS ACTION: +1 Speed
        mov r0,r9
        bl BoostSpeedIfNeeded

		b MoveJumpAddress


	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;


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


		.pool
	.endarea
.close