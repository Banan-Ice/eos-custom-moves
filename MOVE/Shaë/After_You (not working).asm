; ------------------------------------------------------------------------------
; MYSTICAL FIRE
; ---
; [Action]
; Ally : restore up to 50% of its max HP.
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
.definelabel BoostSpeed, 0x2315270

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

AfterYou:

		; Current move slot (1-4)
        mov r5,#1              

    @@pp_loop:
        mov r0,r4             
        mov r1,r5              
        mov r2,#1              
        mov r3,#0             
        bl SetMovePP

        ; Move to next slot
        add r5,r5,#1
        cmp r5,#4
        ble @@pp_loop

        ; +2 Speed to target
        sub sp,sp,#8
        mov r0,r9
        mov r1,r4
        mov r2,#1
        mov r3,#2
        mov r12,#1
        str r12,[sp]
        bl BoostSpeed
        add sp,sp,#8

        ; ACTION: Restore PP
        mov r0,r9
		bl RestoreAllPPIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/SetMovePP.asm"
.include "lib/RestoreAllPPIfNeeded.asm"

		.pool
	.endarea
.close
