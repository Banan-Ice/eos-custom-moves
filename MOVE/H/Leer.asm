; ------------------------------------------------------------------------------
; LEER
; ---
; [Bonus Action]
; Lowers the target's Def and Sp.Def by one stage.
; Front : turns the target around.
; Back  : grants Focus Energy to the user.
; ---
; Target : Foe
; Range : Front
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
.definelabel TryInflictFocusEnergyStatus, 0x23167E4
.definelabel PlayEffectAnimationEntityStandard, 0x22E4C98

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize
		
	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

Leer:

		; -1 def & -1 Spe.Def
		sub sp,sp,#8
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
		add sp,sp,#8

        ; Determine attack position
        mov r0,r9
        mov r1,r4
        bl GetAttackPosition

        cmp r0,#2
        beq @@back_attack

        cmp r0,#0
        beq @@front_attack

        b @@end_move

	@@back_attack:
		mov r0,r9
		mov r1,r9
		bl TryInflictFocusEnergyStatus

		b @@end_move

	@@front_attack:
		mov r0,r4
		mov r1, #62
		bl PlayEffectAnimationEntityStandard

		mov r0,r4
		bl TurnMonsterAround

		mov r0,r4
		ldr r1,=leer_turn_message
		bl SendTargetMessage

    @@end_move:
        ; BONUS ACTION: +1 Speed
        mov r0,r9
        bl BoostSpeedIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;
		
.include "lib/GetAttackPosition.asm"
.include "lib/TurnMonsterAround.asm"
.include "lib/BoostSpeedIfNeeded.asm"
.include "lib/SendTargetMessage.asm"

		.pool
		
	;-----------------------------------------------------------------;
	;                            STRING                               ;
	;-----------------------------------------------------------------;

leer_turn_message:
    .asciiz "[string:0] looks away!"

	.endarea
.close