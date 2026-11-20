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
.definelabel GetTileSafe, 0x2336D34

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

        ; If blocked, check entity on tile
        cmp r0,#0
        beq @@check_entity

        mov r0,r9
        bl GetFrontTile
        mov r2,r1              ; Destination Y
        mov r1,r0              ; Destination X
        mov r0,r9

        ; Move forward with animation
        ;mov r0,r9
        bl MoveForwardOneTile

        ; Check arrival tile effects
        mov r0,r9
        bl CheckTileTriggers

        b @@end_move

    @@check_entity:
        mov r0,r9
        bl GetFrontTile
        bl GetTileSafe

        cmp r0,#0
        beq @@end_move

        ; Get entity on tile
        ldr r1,[r0,#0xC]

        cmp r1,#0
        beq @@end_move

        mov r0,r9
        bl IsTargetAlly

        ; Ally: swap
        cmp r0,#1
        beq @@swap

        ; Enemy: push
        b @@push

    @@swap:
        ; Try switching places with an ally
        mov r0,r9
        bl SwapWithEntity

        ; Skip tile triggers if swap failed
        cmp r0,#0
        beq @@end_move

        mov r0,r9
        ldr r1,=swap_string
        bl SendTargetMessage

        b @@end_move

    @@push:
        mov r0,r9
        bl TryPushEntityForward

        ; Skip tile triggers if push failed
        cmp r0,#0
        beq @@end_move

        mov r0,r9
        ldr r1,=push_string
        bl SendTargetMessage

        b @@end_move

    @@end_move:
        ; BONUS ACTION: +1 Speed
        mov r0,r9
        bl BoostSpeedIfNeeded

        b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/CanMoveForward.asm"
.include "lib/MoveForwardOneTile.asm"
.include "lib/IsTargetAlly.asm"
.include "lib/SwapWithEntity.asm"
.include "lib/TryPushEntityForward.asm"
.include "lib/CheckTileTriggers.asm"
.include "lib/BoostSpeedIfNeeded.asm"
.include "lib/SendTargetMessage.asm"
.include "lib/GetFrontTile.asm"
.include "lib/AnimateWalkOneTile.asm"

		.pool

	;-----------------------------------------------------------------;
	;                            STRING                               ;
	;-----------------------------------------------------------------;

push_string:
    .asciiz "[string:0] pushes their opponent back!"

swap_string:
    .asciiz "[string:0] swaps places!"

	.endarea
.close