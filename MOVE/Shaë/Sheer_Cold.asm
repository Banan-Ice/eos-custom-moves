; ------------------------------------------------------------------------------
; SHEER COLD
; ---
; [Action Bonus]
; Freeze an ally or enemy for 2 turns.
; ---
; Target : Everyone
; Range : Front
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
.definelabel TryInflictFrozenStatus, 0x2313658

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;
		
SheerCold:

		; Freeze target
        mov r0, r9
        mov r1, r4
        mov r2, #1
        bl TryInflictFrozenStatus

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