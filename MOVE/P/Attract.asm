; ------------------------------------------------------------------------------
; ATTRACT
; ---
; [Bonus Action]
; Lures the target towards the user (up to 10 tiles).
; Ally : Raises its Atk and Sp.Atk by one stage.
; Foe : lowers its Def and Sp.Def by one stage.
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
.definelabel MakeTargetFaceUserAndIdle, 0x22F1008
.definelabel ApplyAquaRingHealing, 0x2318E48
.definelabel TryInflictAquaRingStatus, 0x2318EBC

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the 
    
	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;
		
Attract:

        push {r11,lr}

        ; Make target face user
        mov r0,r4
        mov r1,r9
        bl MakeTargetFaceUserAndIdle

        ; Pull target towards user (up to 10 tiles)
        mov r0,r4
        mov r1,#10
        bl MoveForwardNTiles

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
            ; Check if target has Aqua Ring
            mov r0,r4
            bl HasAquaRingStatus
            cmp r0,#1
            beq @@has_aqua_ring

            ; Apply Aqua Ring status if not already active
            mov r0, r9
            mov r1, r4
            bl TryInflictAquaRingStatus
            b @@end_move

            @@has_aqua_ring:
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
        pop {r11,lr}

        ; BONUS ACTION: +1 Speed
        mov r0,r9
        bl BoostSpeedIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/MoveForwardNTiles.asm"
.include "lib/BoostSpeedIfNeeded.asm"
.include "lib/IsTargetAlly.asm"
.include "lib/HasAquaRingStatus.asm"

		.pool
	.endarea
.close