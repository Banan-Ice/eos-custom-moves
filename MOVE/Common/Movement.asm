; ------------------------------------------------------------------------------
; MOVEMENT
; ---
; [Bonus Action]
; Move forward one tile.
; If it's occupied by an ally, swap places with them.
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

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area		

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

Movement:
		
        ; Check if user can move forward
        mov r0,r9
        bl CanMoveForward

        ; If blocked, try swapping with an ally
        cmp r0,#0
        beq @@try_swap

        ; Move forward with animation
        mov r0,r9
        bl MoveForwardOneTile

        b @@check_tile

    @@try_swap:

        ; Try switching places with an ally
        mov r0,r9
        bl TrySwapWithAlly

        ; Skip tile triggers if swap failed
        cmp r0,#0
        beq @@end_move

    @@check_tile:

        ; Check arrival tile effects
        mov r0,r9
        bl CheckTileTriggers

    @@end_move:

        ; BONUS ACTION: +1 Speed
        mov r0,r9
        bl BoostSpeedIfNeeded

        b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/BoostSpeedIfNeeded.asm"
.include "lib/CanMoveForward.asm"
.include "lib/MoveForwardOneTile.asm"
.include "lib/TrySwapWithAlly.asm"
.include "lib/CheckTileTriggers.asm"

		.pool
	.endarea
.close