; ------------------------------------------------------------------------------
; SHADOW SNEAK
; ---
; [Bonus Action]
; Teleports the user two tiles forward.
; If the destination is occupied by a Pokémon, teleports behind it instead.
; ---
; Target : User
; Range  : User
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

; Native dependencies
.definelabel GetTileSafe, 0x2336D34
.definelabel DIRECTIONS_XY, 0x2352328
.definelabel CannotStandOnTileNoMonsterCheck, 0x2300384
.definelabel MoveMonsterToPos, 0x22F8FFC
.definelabel UpdateEntityPixelPos, 0x22E2380
.definelabel PlayEffectAnimationEntityStandard, 0x22E4C98

; File creation
.create "./code_out.bin", 0x02330B74
.org MoveStartAddress
.area MaxSize

;-----------------------------------------------------------------;
;                          MOVE EFFECT                            ;
;-----------------------------------------------------------------;

ShadowSneak:

        push {r4-r8,lr}
        sub sp,sp,#8

        ; Teleport type
        mov r4,#0

    @@get_destination_2_tiles:

        ; Get first tile in front of user
        mov r0,r9
        bl GetFrontTile

        ; Save first tile coordinates for fallback
        strh r0,[sp,#4]       ; First tile X
        strh r1,[sp,#6]       ; First tile Y

        ; Get user's direction vector
        ldr r3,=DIRECTIONS_XY
        add r3,r3,r2,lsl #2

        ldrsh r4,[r3]         ; Direction X
        ldrsh r5,[r3,#2]      ; Direction Y

        ; Calculate second tile coordinates
        add r0,r0,r4
        add r1,r1,r5

        ; Save destination coordinates
        strh r0,[sp]
        strh r1,[sp,#2]

    @@check_initial_destination:

        ; Get destination tile
        bl GetTileSafe

        cmp r0,#0
        beq @@end_move

        ; Get monster occupying the destination
        ldr r5,[r0,#0xC]

        ; If empty, check the original destination
        cmp r5,#0
        beq @@check_direct_destination

    @@start_search:

        ; Get target's facing direction
        ldr r0,[r5,#0xB4]
        ldrb r8,[r0,#0x4C]

        ; Initialize priority index
        mov r7,#0

    @@search_loop:

        ; Get direction offset from priority table
        ldr r3,=teleport_priority
        ldrb r6,[r3,r7]

        ; Calculate absolute direction
        add r6,r6,r8
        and r6,r6,#7

        ; Get current direction vector
        ldr r3,=DIRECTIONS_XY
        add r3,r3,r6,lsl #2

        ldrsh r1,[r3]           ; Direction X
        ldrsh r2,[r3,#2]        ; Direction Y

        ; Calculate candidate X
        ldrh r0,[r5,#0x4]
        add r0,r0,r1
        strh r0,[sp]

        ; Calculate candidate Y
        ldrh r1,[r5,#0x6]
        add r1,r1,r2
        strh r1,[sp,#2]

        ; Get candidate tile
        bl GetTileSafe

        ; Skip invalid tiles
        cmp r0,#0
        beq @@next_direction

        ; Check tile occupancy
        ldr r1,[r0,#0xC]

        ; Skip occupied tiles
        cmp r1,#0
        bne @@next_direction

        ; Check terrain compatibility
        mov r0,r9
        mov r1,sp
        bl CannotStandOnTileNoMonsterCheck

        ; Skip inaccessible tiles
        cmp r0,#0
        bne @@next_direction

        ; Valid destination found
        b @@teleport

    @@next_direction:

        ; Move to next priority
        add r7,r7,#1

        ; Check up to 8 directions
        cmp r7,#8
        blt @@search_loop

        ; No valid destination found
        b @@end_move

    @@check_direct_destination:

        ; Check if user can stand on destination
        mov r0,r9
        mov r1,sp
        bl CannotStandOnTileNoMonsterCheck

        ; If destination is valid, teleport directly
        cmp r0,#0
        beq @@teleport

        ; Otherwise, try one tile forward
        b @@fallback_one_tile

    @@fallback_one_tile:

        ; Restore first tile as destination
        ldrh r0,[sp,#4]
        ldrh r1,[sp,#6]

        strh r0,[sp]
        strh r1,[sp,#2]

        ; Check destination tile
        bl GetTileSafe

        cmp r0,#0
        beq @@end_move

        ; Check tile occupancy
        ldr r1,[r0,#0xC]
        cmp r1,#0
        bne @@end_move

        ; Check terrain compatibility
        mov r0,r9
        mov r1,sp
        bl CannotStandOnTileNoMonsterCheck

        cmp r0,#0
        bne @@end_move

        ; Teleport one tile forward
        b @@teleport

    @@teleport:

        ; Update logical position
        mov r0,r9
        ldrh r1,[sp]
        ldrh r2,[sp,#2]
        mov r3,#0
        bl MoveMonsterToPos

        ; Synchronize graphical position instantly
        mov r0,r9
        mov r1,#0
        bl UpdateEntityPixelPos

        mov r0,r9
        ldr r1,=479
        bl PlayEffectAnimationEntityStandard

        ; Set [string:0] to user's name
        mov r0,#0
        mov r1,r9
        mov r2,#0
        bl ChangeString

        ; Empty destination message
        mov r0,r9
        ldr r1,=shadow_sneak_message
        bl SendMessageWithStringLog

        ; Check destination tile triggers
        mov r0,r9
        bl CheckTileTriggers

    @@end_move:

        ; Restore engine registers
        add sp,sp,#8
        pop {r4-r8,lr}

        ; BONUS ACTION: +1 Speed
        mov r0,r9
        bl BoostSpeedIfNeeded

        b MoveJumpAddress

;-----------------------------------------------------------------;
;                        PRIORITY TABLE                           ;
;-----------------------------------------------------------------;

; Relative to target's facing direction:
; Back, rear-right, rear-left, then remaining directions.
;
; Example for direction 0:
; 4 -> 3 -> 5 -> 2 -> 6 -> 1 -> 0 -> 7

teleport_priority:
    .db 4,3,5,2,6,1,0,7

.align 4
.pool

;-----------------------------------------------------------------;
;                           FUNCTIONS                             ;
;-----------------------------------------------------------------;

.include "lib/GetFrontTile.asm"
.include "lib/CheckTileTriggers.asm"
.include "lib/BoostSpeedIfNeeded.asm"

        .pool

;-----------------------------------------------------------------;
;                            STRINGS                              ;
;-----------------------------------------------------------------;

shadow_sneak_message:
    .asciiz "[string:0] slips into the shadows!"

    .endarea
.close