; ------------------------------------------------------------------------------
; ROLLCALL
; ---
; [Bonus Action]
; Draws all team members to the user.
; ---
; Target : Allies except user
; Range : Floor
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
.definelabel BoostSpeedOneStage, 0x231539C
;.definelabel PlayEffectAnimationEntity, 0x22E3F94
.definelabel DoMoveWildCall, 0x232D734


; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area
		
		; Rollcall
		mov r0,r9
		mov r1,r9
		mov r2,r8
		mov r3, #0
		bl DoMoveWildCall
		
		; ACTION BONUS: +1 Speed
        mov r0, r9
        mov r1, r9
        mov r2, #1
        mov r3, #0
        bl BoostSpeedOneStage

		b MoveJumpAddress
		.pool
	.endarea
.close