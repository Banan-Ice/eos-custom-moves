; ------------------------------------------------------------------------------
; FLAME BURST
; ---
; [Action]
; Damages enemies or heals allies.
; The effect chains to up to 2 additional targets, adjacent to the last.
; Damages and healing double with each successive target.
; Each entity can only be targeted once.
; ---
; ROTATION : starting from each target's facing direction and searching 
;            clockwise.
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
.definelabel TryThawTarget, 0x023086A4
.definelabel PlayEffectAnimationEntityStandard, 0x22E4C98

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

FlameBurst:

        ; Initialize additional targets
        push {r5,r6}
        mov r5,#0
        mov r6,#0

        ; Find 2nd target
        mov r0,r4
        mov r1,r4
        mov r2,#0
        bl FindNextAdjacentEntity

        mov r5,r0

        cmp r5,#0
        beq @@apply_effects

        ; Find 3rd target
        mov r0,r5
        mov r1,r4
        mov r2,r5
        bl FindNextAdjacentEntity

        mov r6,r0

    @@apply_effects:

        ; Try to thaw first target
        mov r0,r9
        mov r1,r4
        bl TryThawTarget

        ; FIRST TARGET
        mov r0,r9
        mov r1,r4
        bl IsTargetAlly

        cmp r0,#1
        bne @@damage_1st_target

    @@heal_1st_target:
        ; Heal 12.5% max HP
        mov r0,r9
        mov r1,r4
        mov r2,#3
        bl HealTargetFractionMaxHP

        b @@start_2nd_target

    @@damage_1st_target:
        ; Deal 50% damage
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x80
        bl DealMoveDamage

        b @@start_2nd_target

    @@start_2nd_target:
        cmp r5,#0
        beq @@end_move

		mov r0,r5
		mov r1,#57
		bl PlayEffectAnimationEntityStandard

        mov r0,r9
        mov r1,r5
        bl TryThawTarget

        mov r0,r9
        mov r1,r5
        bl IsTargetAlly

        cmp r0,#1
        bne @@damage_2nd_target

    @@heal_2nd_target:
        ; Heal 25% max HP
        mov r0,r9
        mov r1,r5
        mov r2,#2
        bl HealTargetFractionMaxHP

        b @@start_3rd_target

    @@damage_2nd_target:
        ; Deal 100% damage
        mov r0,r9
        mov r1,r5
        mov r2,r8
        mov r3,#0x100
        bl DealMoveDamage

        b @@start_3rd_target

    @@start_3rd_target:
        cmp r6,#0
        beq @@end_move

		mov r0,r6
		mov r1,#57
		bl PlayEffectAnimationEntityStandard

        mov r0,r9
        mov r1,r6
        bl TryThawTarget

        mov r0,r9
        mov r1,r6
        bl IsTargetAlly

        cmp r0,#1
        bne @@damage_3rd_target

    @@heal_3rd_target:
        ; Heal 50% max HP
        mov r0,r9
        mov r1,r6
        mov r2,#1
        bl HealTargetFractionMaxHP
        b @@end_move

    @@damage_3rd_target:
        ; Deal 200% damage
        mov r0,r9
        mov r1,r6
        mov r2,r8
        mov r3,#0x200
        bl DealMoveDamage

	@@end_move:
        pop {r5,r6}

		; ACTION: Restore PP
        mov r0,r9
		bl RestoreAllPPIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/DealMoveDamage.asm"
.include "lib/RestoreAllPPIfNeeded.asm"
.include "lib/IsTargetAlly.asm"
.include "lib/HealTargetFractionMaxHP.asm"
.include "lib/FindNextAdjacentEntity.asm"

		.pool
	.endarea
.close

	;-----------------------------------------------------------------;
	;                        ANIMATION TABLE                          ;
	;-----------------------------------------------------------------;

; animation_id_2 = 78
; animation_id_3 = 57