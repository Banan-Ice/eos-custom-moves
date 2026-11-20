; ------------------------------------------------------------------------------
; ATTRACT
; ---
; [Bonus Action]
; Lures the target towards the user.
; Ally : Raises its Atk and Sp.Atk by one stage.
; Foe : lowers its Def and Sp.Def by one stage.
; ---
; Target : Everyone
; Range : Line
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
.definelabel DoMovePounce, 0x232D4BC
.definelabel MakeMonsterIdleInDirection2, 0x22FAD6C
; MakeTargetFaceUserAndIdle


; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area
		

		; Get user and target positions
		ldrh r0,[r9,#0x4] ; user X
		ldrh r1,[r9,#0x6] ; user Y

		ldrh r2,[r4,#0x4] ; target X
		ldrh r3,[r4,#0x6] ; target Y

		; Compare X coordinates
		cmp r0,r2
		blo turn_left
		bhi turn_right

		; Same X > compare Y coordinates
		cmp r1,r3
		blo turn_up
		bhi turn_down
		b turn_skip

	turn_left:
		cmp r1,r3
		blo turn_up_left
		bhi turn_down_left
		mov r12,#6 
		b turn_done

	turn_right:
		cmp r1,r3
		blo turn_up_right
		bhi turn_down_right
		mov r12,#2 
		b turn_done

	turn_up:
		mov r12,#4 
		b turn_done

	turn_down:
		mov r12,#0 
		b turn_done

	turn_up_left:
		mov r12,#5  
		b turn_done

	turn_up_right:
		mov r12,#3    
		b turn_done

	turn_down_left:
		mov r12,#7     
		b turn_done

	turn_down_right:
		mov r12,#1    
		b turn_done

	turn_done:
		; Turn target to face user.
		mov r0,r4
		mov r1,r12
		bl MakeMonsterIdleInDirection2

	turn_skip:
		; Make target pounce
		mov r0, r9
		mov r1, r4
		mov r2, r8
		mov r3, #0
		bl DoMovePounce
		
        ; ally_or_foe
		sub r13,r13,#0x4
		ldr r0,[r4,#+0xb4]
		ldrb r1,[r0,#0x6]
		ldrb r2,[r0,#0x8]
		eor r0,r1,r2
		ldr r1,[r9,#+0xb4]
		ldrb r2,[r1,#0x6]
		ldrb r3,[r1,#0x8]
		eor r1,r2,r3
		cmp r0,r1
		beq ally_target

	foe_target:
        ; -1 def & -1 Spe.Def
        mov r0,r9
		mov r1,r4
		mov r2,#0
		mov r3,#1
		str r3,[r13]
		str r3,[r13,#+0x4]
		bl DefenseStatDown
		mov r0,r9
		mov r1,r4
		mov r2,#1
		mov r3,#1
		str r3,[r13]
		str r3,[r13,#+0x4]
		bl DefenseStatDown
		b end_move

	ally_target:
        ; +1 atk & +1 Spe.Atk
		mov r0,r9
		mov r1,r4
		mov r2,#0
		mov r3,#1
		bl AttackStatUp
        mov r0,r9
		mov r1,r4
		mov r2,#1
		mov r3,#1
		bl AttackStatUp

	end_move:
		mov r10,r0
		add r13,r13,#0x4

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