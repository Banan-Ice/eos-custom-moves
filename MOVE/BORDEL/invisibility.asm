.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For EU
.include "lib/stdlib_eu.asm"
.include "lib/dunlib_eu.asm"
.definelabel MoveStartAddress, 0x02330B74
.definelabel MoveJumpAddress, 0x0233310C
.definelabel TryInflictInvisibleStatus, 0x2316FDC
.definelabel BoostSpeedOneStage, 0x231539C


; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area
		; Usable Variables: 
		; r6 = Move ID
		; r9 = User Monster Structure Pointer
		; r4 = Target Monster Structure Pointer
		; r8 = Move Data Structure Pointer (8 bytes: flags [4 bytes], move_id [2 bytes], pp_left [1 byte], boosts [1 byte])
		; r7 = ID of the item that called this move (0 if the move effect isn't from an item)
		; Returns: 
		; r10 (bool) = ???
		; Registers r4 to r9, r11 and r13 must remain unchanged after the execution of that code
		

        ;deal_damage
        mov r0, r9
        mov r1, r4
        mov r2, r8
        mov r3, #255
        str r7,[sp, #0]
        bl DealDamage

        ;invis_user
        mov r0, r9
        mov r1, r9
        bl TryInflictInvisibleStatus

        ;Speed_up
        mov r0, r9
        mov r1, r9
        mov r2, #1
        mov r3, #0
        bl BoostSpeedOneStage
		
	
		b MoveJumpAddress
		.pool
	.endarea
.close