NamePointers::
; entries correspond to *_NAME constants
	dw MonsterNames
	dw MoveNames
	dw tmhmNames
	dw ItemNames
	dw wPartyMonOT ; player's OT names list
	dw wEnemyMonOT ; enemy's OT names list
	dw TrainerNames

GetName::
; arguments:
; [wd0b5] = which name
; [wNameListType] = which list
; [wPredefBank] = bank of list
;
; returns pointer to name in de
	ld a, [wd0b5]
	ld [wd11e], a

	; TM names are separate from item names.
	; BUG: This applies to all names instead of just items.
	;joenote - fixing the aforementioned bug
	push bc
	ld b, a
	ld a, [wNameListType]
	cp ITEM_NAME
	ld a, b
	pop bc
	jr nz, .notMachine	;if the list type is not items, then A cannot be referring to a machine
	;At this line, definitely working with an item list. So see if it's a machine or item
	cp HM01
	;jp nc, GetMachineName	;joenote - function removed. Handle list-based tm & hm names here.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;joenote - do some stuff if the item is a machine
	jr c, .notMachine
	sub (HM01 - 1)	;need to shift things because tm and hm constants are offset by +$C3 from the first item constant
	ld [wd0b5], a
	ld a, TMHM_NAME	
	ld [wNameListType], a
.notMachine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ldh a, [hLoadedROMBank]
	push af
	push hl
	push bc
	push de
	ld a, [wNameListType]
	dec a
	jr nz, .otherEntries
	; 1 = MONSTER_NAME
	call GetMonName
	ld hl, NAME_LENGTH
	add hl, de
	ld e, l
	ld d, h
	jr .gotPtr
.otherEntries
	; 2-7 = other names
	ld a, [wPredefBank]
	call BankswitchCommon
	ld a, [wNameListType]
	dec a
	add a
	ld d, 0
	ld e, a
	jr nc, .skip
	inc d
.skip
	ld hl, NamePointers
	add hl, de
	ld a, [hli]
	ldh [hSwapTemp + 1], a
	ld a, [hl]
	ldh [hSwapTemp], a
	ldh a, [hSwapTemp]
	ld h, a
	ldh a, [hSwapTemp + 1]
	ld l, a
	ld a, [wd0b5]
	ld b, a ; wanted entry
	ld c, 0 ; entry counter
.nextName
	ld d, h
	ld e, l
.nextChar
	ld a, [hli]
	cp "@"
	jr nz, .nextChar
	inc c
	ld a, b
	cp c
	jr nz, .nextName
	ld h, d
	ld l, e
	ld de, wcd6d
	ld bc, NAME_BUFFER_LENGTH
	call CopyData
.gotPtr
	; ld a, e
	; ld [wUnusedCF8D], a
	; ld a, d
	; ld [wUnusedCF8D + 1], a
	ld a, [wd11e]
	cp HM01
	jr c, .notMachine2
	ld a, ITEM_NAME	;this needs to be reset because machines can be in the same listings as items	
	ld [wNameListType], a
.notMachine2
	pop de
	pop bc
	pop hl
	pop af
	call BankswitchCommon
	ret
