HandleItemListSwapping::
	ld a, [wListMenuID]
	cp ITEMLISTMENU
	jp nz, DisplayListMenuIDLoop ; only rearrange item list menus
	push hl
	ld hl, wListPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl ; hl = beginning of list entries
	ld a, [wCurrentMenuItem]
	ld b, a
	ld a, [wListScrollOffset]
	add b
	add a
	ld c, a
	ld b, 0
	add hl, bc ; hl = address of currently selected item entry
	ld a, [hl]
	pop hl
	inc a
	jp z, DisplayListMenuIDLoop ; ignore attempts to swap the Cancel menu item
	ld a, [wMenuItemToSwap] ; ID of item chosen for swapping (counts from 1)
	and a ; has the first item to swap already been chosen?
	jr nz, .swapItems
; if not, set the currently selected item as the first item
	ld a, [wCurrentMenuItem]
	inc a
	ld b, a
	ld a, [wListScrollOffset] ; index of top (visible) menu item within the list
	add b
	ld [wMenuItemToSwap], a ; ID of item chosen for swapping (counts from 1)
	ld c, 20
	call DelayFrames
	jp DisplayListMenuIDLoop
.swapItems
	ld a, [wCurrentMenuItem]
	inc a
	ld b, a
	ld a, [wListScrollOffset]
	add b
	ld b, a
	ld a, [wMenuItemToSwap] ; ID of item chosen for swapping (counts from 1)
	cp b ; is the currently selected item the same as the first item to swap?
	jp z, DisplayListMenuIDLoop ; ignore attempts to swap an item with itself
	dec a
	ld [wMenuItemToSwap], a ; ID of item chosen for swapping (counts from 1)
	ld c, 20
	call DelayFrames
	push hl
	push de
	ld hl, wListPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl ; hl = beginning of list entries
	ld d, h
	ld e, l ; de = beginning of list entries
	ld a, [wCurrentMenuItem]
	ld b, a
	ld a, [wListScrollOffset]
	add b
	add a
	ld c, a
	ld b, 0
	add hl, bc ; hl = address of currently selected item entry
	ld a, [wMenuItemToSwap] ; ID of item chosen for swapping (counts from 1)
	add a
	add e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry ; de = address of first item to swap
	ld a, [de]
	ld b, a
	ld a, [hli]
	cp b
	jr z, .swapSameItemType
.swapDifferentItems
	ldh [hSwapItemID], a ; save second item ID
	ld a, [hld]
	ldh [hSwapItemQuantity], a ; save second item quantity
	ld a, [de]
	ld [hli], a ; put first item ID in second item slot
	inc de
	ld a, [de]
	ld [hl], a ; put first item quantity in second item slot
	ldh a, [hSwapItemQuantity]
	ld [de], a ; put second item quantity in first item slot
	dec de
	ldh a, [hSwapItemID]
	ld [de], a ; put second item ID in first item slot
	xor a
	ld [wMenuItemToSwap], a ; 0 means no item is currently being swapped
	pop de
	pop hl
	jp DisplayListMenuIDLoop
.swapSameItemType
	inc de
	ld a, [hl]
	ld b, a
	ld a, [de]
	add b ; a = sum of both item quantities
	cp 100 ; is the sum too big for one item slot?
	jr c, .combineItemSlots
; swap enough items from the first slot to max out the second slot if they can't be combined
	sub 99
	ld [de], a
	ld a, 99
	ld [hl], a
	jr .done
.combineItemSlots
	ld [hl], a ; put the sum in the second item slot
	ld hl, wListPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	dec [hl] ; decrease the number of items
	ld a, [hl]
	ld [wListCount], a ; update number of items variable
	cp 1
	jr nz, .skipSettingMaxMenuItemID
	ld [wMaxMenuItem], a ; if the number of items is only one now, update the max menu item ID
.skipSettingMaxMenuItemID
	dec de
	ld h, d
	ld l, e
	inc hl
	inc hl ; hl = address of item after first item to swap
.moveItemsUpLoop ; erase the first item slot and move up all the following item slots to fill the gap
	ld a, [hli]
	ld [de], a
	inc de
	inc a ; reached the $ff terminator?
	jr z, .afterMovingItemsUp
	ld a, [hli]
	ld [de], a
	inc de
	jr .moveItemsUpLoop
.afterMovingItemsUp
	xor a
	ld [wListScrollOffset], a
	ld [wCurrentMenuItem], a
.done
	xor a
	ld [wMenuItemToSwap], a ; 0 means no item is currently being swapped
	pop de
	pop hl
	jp DisplayListMenuIDLoop

SortItems::
	push hl
	push bc
	ld hl, SortItemsText ; Display the text to ask to sort
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp z, .beginSorting ; If yes
	jr .done
.finishedSwapping
	ld a, [hSwapTemp] ; If not 0, then a swap of items did occur
	cp 0
	jr z, .nothingSorted
	ld hl, SortComplete
	jr .printResultText
.nothingSorted
	ld hl, NothingToSort
.printResultText
	call PrintText
.done
	xor a ; Zeroes a
	pop bc
	pop hl
	ret
.beginSorting
	xor a
	ld [hSwapTemp], a ; 1 if something in the bag got sorted
	ld de, 0
	ld hl, ItemSortList
	ld b, [hl] ; This is the first item to check for
	ld hl, wBagItems
	ld c, 0 ; Relative to wBagItems, this is where we'd like to begin swapping
.loopCurrItemInBag
	ld a, [hl] ; Load the value of hl to a (which is an item number) and Increments to the quantity
	cp -1 ; See if the item number is $ff, which is 'cancel'
	jr z, .findNextItem ; If it is cancel, then move onto the next item
	cp b
	jr z, .hasItem ; If it's not b, then go to the next item in the bag
	inc hl ; increments past the quantity to the next item to check
	inc hl
	jr .loopCurrItemInBag
.findNextItem
	ld d, 0
	inc e
	ld hl, ItemSortList
	add hl, de
	ld b, [hl]
	ld hl, wBagItems ; Resets hl to start at the beginning of the bag
	ld a, b
	cp -1 ; Check if we got through all of the items, to the last one
	jr z, .finishedSwapping
	jr .loopCurrItemInBag
.hasItem ; c contains where to swap to relative to the start of wBagItems
		 ; hl contains where the item to swap is absolute.
		 ; b contains the item ID
	push de
	ld d, h
	ld e, l
	ld hl, wBagItems
	ld a, b
	ld b, 0
	add hl, bc ; hl now holds where we'd like to swap to
	ld b, a
	ld a, [de]
	cp [hl]
	jr z, .cont ; If they're the same item
	ld a, 1
	ld [hSwapTemp], a
	ld a, [hl]
	ld [hSwapItemID],a ; [hSwapItemID] = second item ID
	inc hl
	ld a,[hld]
	ld [hSwapItemQuantity],a ; [hSwapItemQuantity] = second item quantity
	ld a,[de]
	ld [hli],a ; put first item ID in second item slot
	inc de
	ld a,[de]
	ld [hl],a ; put first item quantity in second item slot
	ld a,[hSwapItemQuantity]
	ld [de],a ; put second item quantity in first item slot
	dec de
	ld a,[hSwapItemID]
	ld [de],a ; put second item ID in first item slot
.cont
	inc c
	inc c
	ld h, d
	ld l, e
	pop de
	jr .findNextItem

SortItemsText::
	text_far _SortItemsText
	db "@"

SortComplete::
	text_far _SortComplete
	db "@"

NothingToSort::
	text_far _NothingToSort
	db "@"

ItemSortList::
	; Used Key Items
	db BICYCLE
	db ITEMFINDER
	db EXP_ALL
	db TOWN_MAP
	; Rods
	db OLD_ROD
	db GOOD_ROD
	db SUPER_ROD
	; Balls
	db POKE_BALL
	db GREAT_BALL
	db ULTRA_BALL
	db SAFARI_BALL
	db MASTER_BALL
	; Common Items
	db REPEL
	db SUPER_REPEL
	db MAX_REPEL
	db ESCAPE_ROPE
	db POKE_DOLL
	; Health
	db POTION
	db SUPER_POTION
	db HYPER_POTION
	db MAX_POTION
	db FULL_RESTORE
	db FRESH_WATER
	db SODA_POP
	db LEMONADE
	; Revival
	db REVIVE
	db MAX_REVIVE
	; Status
	db ANTIDOTE
	db BURN_HEAL
	db ICE_HEAL
	db AWAKENING
	db PARLYZ_HEAL
	db FULL_HEAL
	db POKE_FLUTE
	; PP
	db ETHER
	db MAX_ETHER
	db ELIXER
	db MAX_ELIXER
	; Battle Raises
	db X_ACCURACY
	db X_ATTACK
	db X_DEFEND
	db X_SPEED
	db X_SPECIAL
	db GUARD_SPEC
	db DIRE_HIT	
	; Permanent Raises
	db RARE_CANDY
	db HP_UP
	db PROTEIN
	db IRON
	db CARBOS
	db CALCIUM
	db PP_UP
	; Stones
	db LEAF_STONE
	db FIRE_STONE
	db THUNDER_STONE
	db WATER_STONE
	db MOON_STONE
	; Money
	db COIN_CASE
	db COIN
	db NUGGET
	; Fossils
	db DOME_FOSSIL
	db HELIX_FOSSIL
	db OLD_AMBER
	; Maps and Items with No Use
	db SAFARI_BAIT
	db SAFARI_ROCK
	db S_S_TICKET
	; Key Items With No Use
	db SECRET_KEY
	db BIKE_VOUCHER
	db CARD_KEY
	db GOLD_TEETH
	db OAKS_PARCEL
	db LIFT_KEY
	db SILPH_SCOPE
	; TMs
	db TM01
	db TM01 + 1
	db TM01 + 2
	db TM01 + 3
	db TM01 + 4
	db TM01 + 5
	db TM01 + 6
	db TM01 + 7
	db TM01 + 8
	db TM01 + 9
	db TM01 + 10
	db TM01 + 11
	db TM01 + 12
	db TM01 + 13
	db TM01 + 14
	db TM01 + 15
	db TM01 + 16
	db TM01 + 17
	db TM01 + 18
	db TM01 + 19
	db TM01 + 20
	db TM01 + 21
	db TM01 + 22
	db TM01 + 23
	db TM01 + 24
	db TM01 + 25
	db TM01 + 26
	db TM01 + 27
	db TM01 + 28
	db TM01 + 29
	db TM01 + 30
	db TM01 + 31
	db TM01 + 32
	db TM01 + 33
	db TM01 + 34
	db TM01 + 35
	db TM01 + 36
	db TM01 + 37
	db TM01 + 38
	db TM01 + 39
	db TM01 + 40
	db TM01 + 41
	db TM01 + 42
	db TM01 + 43
	db TM01 + 44
	db TM01 + 45
	db TM01 + 46
	db TM01 + 47
	db TM01 + 48
	db TM01 + 49
	; HMs
	db HM01
	db HM01 + 1
	db HM01 + 2
	db HM01 + 3
	db HM01 + 4
	db -1 ; end