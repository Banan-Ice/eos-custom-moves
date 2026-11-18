; ------------------------------------------------------------------------------
; WHIRLPOOL
; ---
; [Action - Vaporeon]
; Ally: Grants Aqua Ring. Apply its healing once, plus once more for every 5 
;       levels of the user.
; Foe : Deals damage and may inflict the Wrapped status (10%).
; ---
; Target : Everyone
; Range : 8 tiles around user
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
.definelabel TryInflictAquaRingStatus, 0x2318EBC
.definelabel DoMoveWhirlpool, 0x23271B8


; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;
	
Whirlpool:

		; Try evolve into Vaporeon_F
		mov r0, r9
		ldr r1, =734
		bl ChangeMonsterForm

		; Check if target is ally or foe
		mov r0, r9
		mov r1, r4
		bl IsTargetAlly
		cmp r0,#1
		beq @@ally_target

	@@foe_target:
		; Use Whirlpool on target
		mov r0, r9
		mov r1, r4
		mov r2, r8
		mov r3, #0
		bl DoMoveWhirlpool

		b @@end_move

	@@ally_target:
		; Check if target already has Aqua-Ring
		mov r0, r4
		bl HasAquaRingStatus
		cmp r0, #1
		beq @@has_aqua_ring
		
		@@has_not_aqua_ring:
			; Apply Aqua_Ring status
			mov r0, r9
			mov r1, r4
			bl TryInflictAquaRingStatus

			b @@end_move

		@@has_aqua_ring:
			; Restore 6% HP 2 times
			mov r0,r9
			mov r1,r4
			mov r2, #4
			bl HealTargetFractionMaxHP
            mov r0,r9
			mov r1,r4
			mov r2, #4
			bl HealTargetFractionMaxHP

	@@end_move:
		; ACTION: Restore PP
        mov r0,r9
		bl RestoreAllPPIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/IsTargetAlly.asm"
.include "lib/ChangeMonsterForm.asm"
.include "lib/HealTargetFractionMaxHP.asm"
.include "lib/HasAquaRingStatus.asm"
.include "lib/RestoreAllPPIfNeeded.asm"

		.pool
	.endarea
.close