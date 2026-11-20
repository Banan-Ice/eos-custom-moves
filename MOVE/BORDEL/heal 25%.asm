; Heal target by 25% HP
		sub r13,r13,#0x4
		ldr r0,[r4,#+0xb4]
		ldrsh r1,[r0,#+0x12]
		ldrsh r2,[r0,#+0x16]
		add r2,r2,r1
		lsrs r2,r2,#2
		addeq r2,r2,#1
		mov r0,r9
		mov r1,r4
		mov r3,#1
		str r3,[r13]
		mov r3,#0
		bl RaiseHP
		mov r10,r0
		add r13,r13,#0x4