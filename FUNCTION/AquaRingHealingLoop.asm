
.ifndef ApplyAquaRingHealing
	.definelabel ApplyAquaRingHealing, 0x2318E48
.endif

AquaRingHealingLoop:
	;-----------------------------------------------------------------
	; Applies Aqua Ring healing to the target once, plus one
	; additional time for every N levels of the user.
	;
	; r0: user entity pointer
	; r1: target entity pointer
	; r2: number of levels required per additional heal (must be > 0)
	;-----------------------------------------------------------------

		push {r4-r6,lr}

		; Save arguments
		mov r4,r1              ; Target
		mov r6,r2              ; Levels per additional heal

		; Get user's level
		ldr r0,[r0,#0xB4]      ; Monster structure
		ldrb r5,[r0,#0xA]      ; User's level

		; Apply initial healing
		mov r0,r4
		bl ApplyAquaRingHealing

		; Prevent infinite loop if LevelsPerHeal = 0
		cmp r6,#0
		beq @@end

	@@loop:
		; Check if enough levels remain
		cmp r5,r6
		blo @@end

		; Subtract required levels
		sub r5,r5,r6

		; Apply additional healing
		mov r0,r4
		bl ApplyAquaRingHealing

		b @@loop

	@@end:
    	pop {r4-r6,pc}