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
.definelabel MakeTargetFaceUserAndIdle, 0x22F1008
.definelabel MoveMonsterToPos, 0x22F8FFC
.definelabel DIRECTIONS_XY, 0x2352328
.definelabel UpdateEntityPixelPos, 0x22E2380
.definelabel CanMonsterMoveInDirection, 0x23018A4
.definelabel ChangeMonsterAnimation, 0x23053D4
.definelabel IncrementEntityPixelPosXY, 0x22E23D0
.definelabel AdvanceFrame, 0x22EA990


; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area
		
		; stack space
		sub sp,sp,#16

		; Make target face user
		mov r0, r4
		mov r1, r9
		bl MakeTargetFaceUserAndIdle	

		; limit step: max 10 tiles
        mov r0,#10
        str r0,[sp,#8]

		; Start walking animation
        mov r0,r4
        mov r1,#0
        mov r2,r5
        bl ChangeMonsterAnimation

	movement_loop:

		; Get target's direction
		ldr r0,[r4,#0xB4]
        ldrb r1,[r0,#0x4C]

		; Check next tile availability
		mov r0,r4
        bl CanMonsterMoveInDirection
        cmp r0,#0
        beq movement_end

		; limit counter
        ldr r0,[sp,#8]
        cmp r0,#0
        beq movement_end
        sub r0,r0,#1
        str r0,[sp,#8]
		
		; one tile movement
		mov r0,r4
        bl AnimateWalkOneTile

		; Get target's direction
        ldr r0,[r4,#0xB4]
        ldrb r1,[r0,#0x4C]

		; Get X/Y direction offsets
        ldr r0,=DIRECTIONS_XY
        add r0,r0,r1,lsl #2
        ldrsh r1,[r0]       ; Movement X
        ldrsh r2,[r0,#2]    ; Movement Y

        ; Add movement to current position
        ldrh r3,[r4,#0x4]
        add r1,r1,r3        ; Destination X
        ldrh r3,[r4,#0x6]
        add r2,r2,r3        ; Destination Y

		; Update logical position
		mov r0,r4
        mov r3,#0
        bl MoveMonsterToPos

		; Update graphical position
        mov r0,r4
        mov r1,#0
        bl UpdateEntityPixelPos

		b movement_loop

	movement_end:

		; Return to idle animation
        mov r0,r4
        mov r1,#7
        mov r2,r5
        bl ChangeMonsterAnimation

        ; Check if target is ally or foe
		ldr r0,[r4,#0xB4]
        ldrb r1,[r0,#0x6]
        ldrb r2,[r0,#0x8]
        eor r0,r1,r2
        ldr r1,[r9,#0xB4]
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
		str r3,[sp]
        str r3,[sp,#4]
		bl DefenseStatDown
		mov r0,r9
		mov r1,r4
		mov r2,#1
		mov r3,#1
		str r3,[sp]
        str r3,[sp,#4]
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
		add sp,sp,#16

		; ACTION BONUS: +1 Speed
        mov r0, r9
        mov r1, r9
        mov r2, #1
        mov r3, #0
        bl BoostSpeedOneStage

		b MoveJumpAddress


AnimateWalkOneTile:
        push {r4-r8,lr}

        mov r4,r0

        ; Get direction
        ldr r0,[r4,#0xB4]
        ldrb r5,[r0,#0x4C]

        ; Calculate graphical X/Y offsets
        ldr r0,=DIRECTIONS_XY
        add r0,r0,r5,lsl #2
        ldrsh r7,[r0]		; Direction X: -1, 0, 1
        ldrsh r8,[r0,#2]	; Direction Y: -1, 0, 1

        ; Convert to graphical units (x 0x200)
        mov r7,r7,lsl #9
        mov r8,r8,lsl #9

        ; Animate movement over 12 frames
        mov r6,#12

    walk_loop:
        ; Increment graphical position
        mov r0,r4
        mov r1,r7
        mov r2,r8
        bl IncrementEntityPixelPosXY

        ; Advance one frame
        mov r0,#0
        bl AdvanceFrame

        ; Next step
        subs r6,r6,#1
        bne walk_loop

		; Restore registers and return
        pop {r4-r8,pc}

		.pool
	.endarea
.close