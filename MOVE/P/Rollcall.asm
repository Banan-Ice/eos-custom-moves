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
.definelabel DoMoveWildCall, 0x232D734


; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

RollCall:
		
		; Rollcall
		mov r0,r9
		mov r1,r9
		mov r2,r8
		mov r3, #0
		bl DoMoveWildCall
		
        ; BONUS ACTION: +1 Speed
        mov r0,r9
        bl BoostSpeedIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/BoostSpeedIfNeeded.asm"

		.pool
	.endarea
.close