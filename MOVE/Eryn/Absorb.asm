; ------------------------------------------------------------------------------
; ABSORB
; ---
; [Action]
; Foe : Deals damage and restores HP up to 50% of the damage dealt.
; Ally : Reduces the target's HP to 1 and inflicts Heal Block.
;		 Restores HP up to 50% of the HP lost by the target.
; 
; If an enemy faints or an ally is targeted, generates and picks up
; a Reviver Seed, then seals this move.
; ---
; Target : Everyone
; Range  : Front
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
.definelabel GetMoveCategory, 0x02015270
.definelabel GetMoveType, 0x0201390C
.definelabel CalcDamageFixedWrapper, 0x0230DE68
.definelabel GetFaintReasonWrapper, 0x023258AC
.definelabel TryInflictHealBlockStatus, 0x02319008
.definelabel PlayEffectAnimationEntityStandard, 0x22E4C98

; File creation
.create "./code_out.bin", 0x02330B74
	.org MoveStartAddress
	.area MaxSize

	;-----------------------------------------------------------------;
	;                          MOVE EFFECT                            ;
	;-----------------------------------------------------------------;

Absorb:

		; Check if target is ally or foe
		mov r0, r9
		mov r1, r4
		bl IsTargetAlly
		cmp r0,#1
		beq @@ally_target

@@foe_target:

		; Deal damage
		mov r0,r9
		mov r1,r4
		mov r2,r8
		mov r3,#0x100
		bl DealMoveDamage

		; No damage dealt
		cmp r0,#0
		ble @@end_move

		sub sp,sp,#8

		; Heal user for half the damage dealt
		mov r2,r0,lsr #1
		mov r0,r9
		mov r1,r9
		mov r3,#1
        str r3,[sp]
		mov r3,#0
		bl RaiseHP

		; Check if user and target are still alive
		mov r0,r9
		mov r1,r4
		mov r2,#100
		bl RandomChanceUT

		; No faint detected
		cmp r0,#0
		bne @@foe_cleanup

		bl Animation_SpawnPickUpReviverSeed_SealMove

		b @@foe_cleanup

@@ally_target:

        ldr r0,[r4,#+0xb4]  
        ldrsh r0,[r0,#+0x10]	; r0 = target's current HP
        subs r10,r0,#1			; r10 = current HP - 1
        ble @@already_one_hp

		push {r5,r6}
        sub sp,sp,#0x20

        mov r0,#0
        strb r0,[sp,#+0x1c]

        mov r0,r8
        bl GetMoveType
        mov r6,r0

        ldrh r0,[r8,#+0x4]
        bl GetMoveCategory
        mov r5,r0

        mov r0,r8
        mov r1,r7
        bl GetFaintReasonWrapper

        add r3,sp,#0x1C
        stmia sp,{r3,r6}
        str r5,[sp,#+0x8]		; MoveCategory
        str r0,[sp,#+0xc]		; FaintReasonWrapper

        mov r2,#0
        str r2,[sp,#+0x10]

        mov r3,#0x1
        str r3,[sp,#+0x14]
        str r2,[sp,#+0x18]

		; Save target's HP before damage
		ldr r0,[r4,#0xB4]
		ldrsh r5,[r0,#0x10]

        ; Deal fixed damage to target
        mov r2,r10			; ; r10 = current HP - 1
        mov r1,r4       
        mov r0,r9      
        bl CalcDamageFixedWrapper

		; Check if target lost HP
		ldr r0,[r4,#0xB4]
		ldrsh r0,[r0,#0x10]
		cmp r0,r5
		bge @@ally_cleanup 

		; Heal user for half the damage dealt
		sub r2,r5,r0          ; r2 = HP before - HP after
		mov r2,r2,lsr #1      ; r2 = HP lost / 2
		mov r0,r9
		mov r1,r9
		mov r3,#1
        str r3,[sp]			  ; FailMessage
		mov r3,#0			  ; MaxHPRaise
		bl RaiseHP

		; Inflict heal block
		mov r0,r9
		mov r1,r4
		mov r2,#1               
		mov r3,#0     
		bl TryInflictHealBlockStatus

		bl Animation_SpawnPickUpReviverSeed_SealMove

		b @@ally_cleanup

@@already_one_hp:

		; Set string:0 to target's name
		mov r0,#0
		mov r1,r4
		mov r2,#0
		bl ChangeString

		mov r0,r9
		ldr r1,=one_hp_msg
		bl SendMessageWithStringLog

		b @@end_move

@@foe_cleanup:

		add sp,sp,#8

		b @@end_move
	
@@ally_cleanup:

		add sp,sp,#0x20
		pop {r5,r6}

		b @@end_move

@@end_move:

		; ACTION: Restore PP
        mov r0,r9
		bl RestoreAllPPIfNeeded

		b MoveJumpAddress

	;-----------------------------------------------------------------;
	;                           FUNCTIONS                             ;
	;-----------------------------------------------------------------;

.include "lib/SpawnAndPickUpItem.asm"
.include "lib/RestoreAllPPIfNeeded.asm"
.include "lib/IsTargetAlly.asm"
.include "lib/DealMoveDamage.asm"
.include "lib/SealUniqueAction.asm"

Animation_SpawnPickUpReviverSeed_SealMove:

		push {r4,lr}

		; Play animation
		mov r0,r9
		ldr r1,=186
		bl PlayEffectAnimationEntityStandard

		mov r0,r9
		ldr r1,=reviver_seed_msg
		bl SendMessageWithStringLog

		; Spawn and pick up Reviver Seed
		mov r0,r9
		mov r1,0x49		; Reviver Seed
		bl SpawnAndPickUpItem

		; Seal move
		mov r0,r8
		bl SealUniqueAction

		mov r0,r9
		ldr r1,=move_sealed_msg
		bl SendMessageWithStringLog

		pop {r4,pc}

		.pool

	;-----------------------------------------------------------------;
	;                            STRING                               ;
	;-----------------------------------------------------------------;

reviver_seed_msg:
    .asciiz "A Reviver Seed was harvested!"

one_hp_msg:
    .asciiz "[string:0] couldn't lose any more HP!"

move_sealed_msg:
    .asciiz "Absorb was sealed!"

	.endarea
.close
