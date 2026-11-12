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
.definelabel RestoreAllMovePP, 0x2318680
.definelabel TryThawTarget, 0x023086A4

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize

		;Thaw target
		mov r0,r9
		mov r1,r4
		bl TryThawTarget

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
		; Deal damage
		mov r0,r9
		mov r1,r4
		mov r2,r8
		mov r3,#0x100
		str r7,[r13]
		bl DealDamage
		b end_move
		
	ally_target:
		;Restore 50% max hp
		ldr r0,[r4,#+0xb4]
		ldrsh r1,[r0,#+0x12]
		ldrsh r0,[r0,#+0x16]
		add r0,r0,r1
		lsrs r2,r0,#1
		moveq r2,#1
		mov r0,r9
		mov r1,r4
		mov r3,#1
		str r3,[r13]
		mov r3,#0
		bl RaiseHP
		mov r0,#1
		
	end_move:
		mov r10,r0
		add r13,r13,#0x4

		; ACTION: Restore PP
        mov r0, r9
        mov r1, r9
        mov r2, #10
        mov r3, #0
        bl RestoreAllMovePP

		b MoveJumpAddress
		.pool
	.endarea
.close