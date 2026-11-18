; ------------------------------------------------------------------------------
; MOTIVATION
; ---
; [Bonus Action]
; Fully restore the PP of the user's first move.
; ---
; Target : User
; Range : User
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
.definelabel RestoreOneMovePP, 0x23187B8


; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

Motivation:
		
		; Restore PP first atk
        mov r0, r9
        mov r1, r9
        mov r2, #0
        mov r3, #99
        sub sp, sp, #8
        mov r12, #1
        str r12, [sp]
        bl RestoreOneMovePP
        add sp, sp, #8

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