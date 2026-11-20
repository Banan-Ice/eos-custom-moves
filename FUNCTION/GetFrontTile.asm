
.ifndef DIRECTIONS_XY
    .definelabel DIRECTIONS_XY, 0x2352328
.endif

GetFrontTile:
    ;-----------------------------------------------------------------
    ; Calculates the tile directly in front of an entity.
    ;
    ; r0: entity pointer
    ;
    ; return:
    ; r0: front tile X
    ; r1: front tile Y
    ; r2: facing direction
    ;-----------------------------------------------------------------

        ; Get facing direction
        ldr r3,[r0,#0xB4]
        ldrb r2,[r3,#0x4C]

        ; Get X/Y direction offsets
        ldr r3,=DIRECTIONS_XY
        add r3,r3,r2,lsl #2

        ldrsh r12,[r3]       ; Direction X
        ldrsh r3,[r3,#0x2]   ; Direction Y

        ; Calculate destination
        ldrh r1,[r0,#0x6]    ; Current Y
        add r1,r1,r3         ; front tile Y

        ldrh r0,[r0,#0x4]    ; Current X
        add r0,r0,r12        ; front tile X

        bx lr