; ------------------------------------------------------------------------------
; BATON PASS
; ---
; [Bonus Action]
; Switches positions with a target.
; Ally : Raises its Atk and Sp.Atk by one stage.
; Foe : lowers its Def and Spe.Def by one stage.
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
.definelabel DungeonRandInt, 0x22EB448
.definelabel SwapEntity, 0x022EBB28
.definelabel GetTileAtEntity, 0x022E1F68
.definelabel BoostSpeedOneStage, 0x231539C

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize
		
        ; Switch position with target
		mov r0,r9
		bl GetTileAtEntity
		mov r10,r0
		mov r0,r9
		mov r1,r4
		mov r2,#0
		mov r2,#0
		bl SwapEntity 

		; Check if the swap occured
		mov r0,r9
		bl GetTileAtEntity
		cmp r0,r10
		moveq r10,#0
		beq MoveJumpAddress

        ; Check if target is ally or foe
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
        ; +1 Atk & +1 Spe.Atk
		mov r0,r9
		mov r1,r4
		mov r2,#0
		mov r3,#1
		str r3,[sp]
        str r3,[sp,#4]
		bl AttackStatUp
        mov r0,r9
		mov r1,r4
		mov r2,#1
		mov r3,#1
		str r3,[sp]
        str r3,[sp,#4]
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