.ifndef GenerateAndSpawnItem
    .definelabel GenerateAndSpawnItem, 0x2345014
.endif

.ifndef TryLeaderItemPickUp
    .definelabel TryLeaderItemPickUp, 0x2345C40
.endif

.ifndef TryNonLeaderItemPickUp
    .definelabel TryNonLeaderItemPickUp, 0x230FBD8
.endif

.ifndef GetLeader
    .definelabel GetLeader, 0x22E9F30
.endif

.ifndef GetTileAtEntity
    .definelabel GetTileAtEntity, 0x22E1F68
.endif


SpawnAndPickUpItem:
    ;-----------------------------------------------------------------
    ; Spawns an item under the user and attempts to pick it up.
    ; Supports both leader and non-leader entities.
    ;
    ; r0: User entity pointer
    ; r1: Item ID
    ;
    ; return:
    ; r0 = 1 if item was spawned and pickup was attempted
    ; r0 = 0 otherwise
    ;-----------------------------------------------------------------

    push {r4-r6,lr}
    sub sp,sp,#8

    ; Save arguments
    mov r4,r0              ; User
    mov r5,r1              ; Item ID

    ;---------------------------------------------------------------
    ; CHECK CURRENT TILE
    ;---------------------------------------------------------------

    ; Get tile under user
    mov r0,r4
    bl GetTileAtEntity

    cmp r0,#0
    beq @@fail

    ; Check if an item or trap already occupies the tile
    ldr r1,[r0,#0x10]
    cmp r1,#0
    bne @@fail

    ;---------------------------------------------------------------
    ; GENERATE AND SPAWN ITEM
    ;---------------------------------------------------------------

    ; Stack arguments
    mov r0,#0
    str r0,[sp]            ; Sticky flag = false
    str r0,[sp,#4]         ; Check-in-bag flag = false

    ; Item ID
    mov r0,r5

    ; User's coordinates
    ldrh r1,[r4,#0x4]      ; X
    ldrh r2,[r4,#0x6]      ; Y

    ; Quantity = 0
    mov r3,#0

    bl GenerateAndSpawnItem

    ;---------------------------------------------------------------
    ; VERIFY ITEM APPEARED
    ;---------------------------------------------------------------

    ; Get user's tile again
    mov r0,r4
    bl GetTileAtEntity

    cmp r0,#0
    beq @@fail

    ; Check for newly spawned object
    ldr r0,[r0,#0x10]
    cmp r0,#0
    beq @@fail

    ;---------------------------------------------------------------
    ; SELECT PICKUP FUNCTION
    ;---------------------------------------------------------------

    ; Check whether user is leader
    bl GetLeader

    cmp r0,r4
    beq @@leader_pickup

    ; Non-leader pickup
    mov r0,r4
    bl TryNonLeaderItemPickUp

    b @@success

@@leader_pickup:

    ; Position pointer
    add r0,r4,#0x4

    ; Log pickup failure
    mov r1,#1
    bl TryLeaderItemPickUp

@@success:
    mov r0,#1
    b @@end

@@fail:
    mov r0,#0

@@end:
    add sp,sp,#8
    pop {r4-r6,pc}
