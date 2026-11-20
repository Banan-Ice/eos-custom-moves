
SendTargetMessage:
    ;-----------------------------------------------------------------
    ; Displays a custom message containing the target's name.
    ;
    ; r0: Target entity pointer
    ; r1: String pointer
    ;
    ; Replaces [string:0] with the target's name.
    ;-----------------------------------------------------------------

        push {r4,lr}

        ; Save string pointer
        mov r4,r1

        ; Set [string:0] to target's name
        mov r1,r0
        mov r0,#0
        mov r2,#0
        bl ChangeString

        ; Display custom message
        mov r0,r9
        mov r1,r4
        bl SendMessageWithStringLog

        pop {r4,pc}