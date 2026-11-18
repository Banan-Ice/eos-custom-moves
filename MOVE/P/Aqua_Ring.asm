; ------------------------------------------------------------------------------
; AQUA RING
; ---
; [Bonus Action - Vaporeon]
; Grants Aqua Ring. Apply its healing once (6% max HP) 
; ---
; Target : Ally
; Range : Room
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



; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;
	
AquaRing:

		; Try evolve into Vaporeon_F
		mov r0, r9
		ldr r1, =734
		bl ChangeMonsterForm

        ; Apply Aqua_Ring status
        mov r0, r9
        mov r1, r4
        bl TryInflictAquaRingStatus

        ; Restore 6% max HP
        mov r0,r9
        mov r1,r4
        mov r2, #4
        bl HealTargetFractionMaxHP

        ; BONUS ACTION: +1 Speed
        mov r0,r9
        bl BoostSpeedIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/HealTargetFractionMaxHP.asm"
.include "lib/ChangeMonsterForm.asm"
.include "lib/BoostSpeedIfNeeded.asm"

		.pool
	.endarea
.close