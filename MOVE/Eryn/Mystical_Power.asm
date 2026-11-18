; ------------------------------------------------------------------------------
; MYSTICAL POWER
; ---
; [Action]
; Ally : Heals its status conditions and apply Safeguard.
; Foe : deal damage. 
; ---
; Target : Everyone
; Range : 2 tiles away
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
.definelabel DoMoveHealStatus, 0x2326BF0
.definelabel TryInflictSafeguardStatus, 0x23198D0

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

MysticalPower:

		; Check if target is ally or foe
		mov r0, r9
		mov r1, r4
		bl IsTargetAlly
		cmp r0,#1
		beq @@ally_target

	@@foe_target:
		; Deal damage
		mov r0,r9
		mov r1,r4
		mov r2,r8
		mov r3,#0x100
		bl DealMoveDamage

		b @@end_move

	@@ally_target:
		; Heal status
        mov r0, r9
        mov r1, r4
        mov r2, r8
        mov r3, #0
        bl DoMoveHealStatus
		; Apply Safeguard
		mov r0, r9
		mov r1, r4
		bl TryInflictSafeguardStatus

	@@end_move:
		; ACTION: Restore PP
        mov r0,r9
		bl RestoreAllPPIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/RestoreAllPPIfNeeded.asm"
.include "lib/IsTargetAlly.asm"
.include "lib/DealMoveDamage.asm"

		.pool
	.endarea
.close