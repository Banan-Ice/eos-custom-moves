; ------------------------------------------------------------------------------
; PURSUIT
; ---
; [Action]
; Deals damage based on the user's position relative to the target.
; Frontal attacks deal half damage.
; Attacks from behind deal double damage.
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
.definelabel PlayEffectAnimationEntityStandard, 0x22E4C98

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize
		
	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

Pursuit:

        ; Determine attack position
        mov r0,r9
        mov r1,r4
        bl GetAttackPosition

        cmp r0,#2
        beq @@back_attack

        cmp r0,#1
        beq @@side_attack

        cmp r0,#0
        beq @@front_attack

        b @@end_move

	@@back_attack:

		mov r0,r4
		ldr r1,=429
		bl PlayEffectAnimationEntityStandard

		; Display surprise message
        mov r0,r4
        ldr r1,=pursuit_back_message
        bl SendTargetMessage
        
        ; Deal 200% damage
		mov r0,r9
		mov r1,r4
		mov r2,r8
		mov r3,#0x200
		bl DealMoveDamage

		b @@end_move

	@@front_attack:

		mov r0,r4
		ldr r1,=47
		bl PlayEffectAnimationEntityStandard

        ; Display anticipation message
        mov r0,r4
        ldr r1,=pursuit_front_message
        bl SendTargetMessage

		; Deal 50% damage
		mov r0,r9
		mov r1,r4
		mov r2,r8
		mov r3,#0x80
		bl DealMoveDamage

        b @@end_move

	@@side_attack:

		; Deal 100% damage
		mov r0,r9
		mov r1,r4
		mov r2,r8
		mov r3,#0x100
		bl DealMoveDamage

        b @@end_move

	@@end_move:

		; ACTION: Restore PP
        mov r0,r9
		bl RestoreAllPPIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;
		
.include "lib/GetAttackPosition.asm"
.include "lib/DealMoveDamage.asm"
.include "lib/RestoreAllPPIfNeeded.asm"
.include "lib/SendTargetMessage.asm"

		.pool
	;-----------------------------------------------------------------;
	;                            STRING                               ;
	;-----------------------------------------------------------------;

pursuit_front_message:
    .asciiz "[string:0] saw the attack coming!"

pursuit_back_message:
    .asciiz "[string:0] was caught off guard!"

	.endarea
.close

	;-----------------------------------------------------------------;
	;                        ANIMATION TABLE                          ;
	;-----------------------------------------------------------------;

; animation_id_1 = 284
; animation_base = 8
; point = Aucun