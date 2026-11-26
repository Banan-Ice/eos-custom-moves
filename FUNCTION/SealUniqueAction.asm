
SealUniqueAction:
    ;-----------------------------------------------------------------
    ; Seals a move, preventing it from being used.
    ;
    ; r0: move pointer
    ;-----------------------------------------------------------------

        ; Read move flags2
        ldrh r1,[r0,#0x2]

        ; Set f_sealed (bit 0)
        orr r1,r1,#0x1

        ; Write updated flags
        strh r1,[r0,#0x2]

        bx lr