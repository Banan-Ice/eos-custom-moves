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
.definelabel BoostSpeedOneStage, 0x231539C
.definelabel MoveMonsterToPos, 0x22F8FFC
.definelabel DIRECTIONS_XY, 0x2352328
.definelabel UpdateEntityPixelPos, 0x22E2380
.definelabel CanMonsterMoveInDirection, 0x23018A4
.definelabel CheckNonLeaderTile, 0x23060C0
.definelabel CheckLeaderTile, 0x22F3FEC
.definelabel GetLeader, 0x22E9F30
.definelabel TrySwitchPlace, 0x22EBB28
.definelabel GetTileSafe, 0x2336D34
.definelabel ChangeMonsterAnimation, 0x23053D4
.definelabel IncrementEntityPixelPosXY, 0x22E23D0
.definelabel AdvanceFrame, 0x22EA990

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize ; Define the size of the area		
		
		; Get user's direction
        ldr r0, [r9,#0xB4]
        ldrb r12,[r0,#0x4C]

        ; Get X/Y direction
        ldr r1,=DIRECTIONS_XY
        mov r2,r12,lsl #0x2
        add r3,r1,r2
        ldrsh r0,[r3]       ; Movement X
        ldrsh r1,[r3,#0x2]  ; Movement Y

        ; Add movement to position
        ldrh r2,[r9,#0x4]   ; Position X
        ldrh r3,[r9,#0x6]   ; Position Y
        add r0,r0,r2        ; Destination X
        add r1,r1,r3        ; Destination Y

        ; Stack destination coordinates
        sub sp,sp,#8
        str r0,[sp]         ; Save X
        str r1,[sp,#4]      ; Save Y

        ; Check tile's availability
        mov r0,r9
        mov r1,r12
        bl CanMonsterMoveInDirection
        cmp r0,#0
        beq try_switch

        ; Movement animation
        mov r0,r9
        bl AnimateWalkOneTile       

        ; Unstack destination coordinates
        ldr r1,[sp]         ; Destination X
        ldr r2,[sp,#4]      ; Destination Y
        add sp,sp,#8

        ; Update logical position
        mov r0,r9
        mov r3,#0
        bl MoveMonsterToPos

        ; Update sprite position
        mov r0,r9
        mov r1,#0
        bl UpdateEntityPixelPos
        b Check_proc_on_tile

    try_switch:

        ; Restore destination coordinates
        ldr r0,[sp]
        ldr r1,[sp,#4]
        add sp,sp,#8
        bl GetTileSafe

        ldr r1,[r0,#0xC]    ; tile-> entity* monster
        cmp r1, #0
        beq end_move        ; no_monster

        ; ally_or_foe
        ldr r12,[r1,#0xB4]  ; entity -> monster
        ldrb r0,[r12,#0x6]  ; monster -> is_not_team_member
        ldrb r2,[r12,#0x8]  ; monster -> is_ally
        eor r3,r0,r2        ; 1 = foe, 0 = ally
        ldr r12,[r9,#0xB4]  ; entity -> monster
        ldrb r0,[r12,#0x6]  ; monster -> is_not_team_member
        ldrb r2,[r12,#0x8]  ; monster -> is_ally
        eor r12,r0,r2       ; 1 = foe, 0 = ally
        cmp r12,r3
        bne end_move        ; not on same team

        ; Switch places
        mov r0,r9
        bl TrySwitchPlace
        
    Check_proc_on_tile:
        bl GetLeader
        cmp r0, r9
        beq is_leader
        mov r0, r9
        bl CheckNonLeaderTile
        b end_move
    is_leader:
        bl CheckLeaderTile
        ; TryLeaderItemPickUp

    end_move:
        ; ACTION BONUS: +1 Speed
        mov r0, r9
        mov r1, r9
        mov r2, #1
        mov r3, #0
        bl BoostSpeedOneStage

		; Always branch at the end
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
        ldrsh r7,[r0]       ; Direction X: -1, 0, 1
        ldrsh r8,[r0,#2]    ; Direction Y: -1, 0, 1

        ; Convert to graphical units (x 0x200)
        mov r7,r7,lsl #9
        mov r8,r8,lsl #9

        ; Start walking animation
        mov r0,r4
        mov r1,#0           ; Animation ID: 0 (walk)
        mov r2,r5           ; Direction
        bl ChangeMonsterAnimation

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

        ; Return to idle animation
        mov r0,r4
        mov r1,#7           ; Animation ID: 7 (idle)
        mov r2,r5           ; Direction
        bl ChangeMonsterAnimation

        ; Restore registers and return
        pop {r4-r8,pc}

		.pool
	.endarea
.close