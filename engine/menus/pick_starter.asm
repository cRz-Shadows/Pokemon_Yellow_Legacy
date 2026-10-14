; Pick Starter mode: a scrollable list of all 151 Pokémon (in Pokédex order)
; with a preview of the highlighted one. The player can't back out; they
; must choose a starter.
; Output: a = [wPlayerStarter] = chosen species (internal index)

DEF PICK_STARTER_LIST_ROWS EQU 7
DEF PICK_STARTER_MAX_TOP   EQU NUM_POKEMON - PICK_STARTER_LIST_ROWS
; Decompressing a front pic takes 40+ frames and input is ignored meanwhile,
; so it's only loaded once the d-pad has been released for this many frames.
; Until then the list stays responsive.
DEF PICK_STARTER_PIC_DELAY EQU 12

; The list's state lives in the usual menu variables:
; [wListScrollOffset] = Pokédex index (0-based) of the top row
; [wCurrentMenuItem]  = highlighted row, 0 to PICK_STARTER_LIST_ROWS - 1

PickStarterMenu::
	ld a, [wUpdateSpritesEnabled]
	push af
	ldh a, [hTileAnimations]
	push af
	ld a, [wListScrollOffset]
	push af
	xor a
	ld [wUpdateSpritesEnabled], a
	ldh [hTileAnimations], a ; tile animations would overwrite the front pic in VRAM
	call SaveScreenTilesToBuffer2
	call GBPalWhiteOut
	call ClearSprites
	callfar LoadPokedexTilePatterns
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ldh [hJoy7], a ; repeat the d-pad while it's held
	xor a
	ld [wListScrollOffset], a
	ld [wCurrentMenuItem], a
	call ClearScreen
	call PickStarter_Redraw
	call PickStarter_DrawPic
	call GBPalNormal

.loop
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, .confirm
	bit BIT_D_UP, a
	jr nz, .up
	bit BIT_D_DOWN, a
	jr nz, .down
	bit BIT_D_LEFT, a
	jr nz, .pageUp
	bit BIT_D_RIGHT, a
	jp nz, .pageDown
	; no input: count down to loading the highlighted mon's picture,
	; but not while the d-pad is held, since auto-repeat is coming
	ldh a, [hJoyHeld]
	and D_UP | D_DOWN | D_LEFT | D_RIGHT
	jr nz, .loop
	ld hl, wPickStarterPicDelay
	ld a, [hl]
	and a
	jr z, .loop
	dec [hl]
	jr nz, .loop
	call PickStarter_DrawPic
	jr .loop

.up
	ld hl, wCurrentMenuItem
	ld a, [hl]
	and a
	jr z, .scrollUp
	dec [hl]
	jr .moved
.scrollUp
	ld hl, wListScrollOffset
	ld a, [hl]
	and a
	jr z, .wrapToBottom
	dec [hl]
	jr .moved
.wrapToBottom
	ld a, PICK_STARTER_MAX_TOP
	ld [wListScrollOffset], a
	ld a, PICK_STARTER_LIST_ROWS - 1
	ld [wCurrentMenuItem], a
	jr .moved

.down
	ld hl, wCurrentMenuItem
	ld a, [hl]
	cp PICK_STARTER_LIST_ROWS - 1
	jr z, .scrollDown
	inc [hl]
	jr .moved
.scrollDown
	ld hl, wListScrollOffset
	ld a, [hl]
	cp PICK_STARTER_MAX_TOP
	jr z, .wrapToTop
	inc [hl]
	jr .moved
.wrapToTop
	xor a
	ld [wListScrollOffset], a
	ld [wCurrentMenuItem], a
	jr .moved

.pageUp
	ld hl, wListScrollOffset
	ld a, [hl]
	and a
	jr z, .firstRow ; already showing the top of the list
	sub PICK_STARTER_LIST_ROWS
	jr nc, .storeTop
	xor a
	jr .storeTop
.firstRow
	xor a
	ld [wCurrentMenuItem], a
	jr .moved

.pageDown
	ld hl, wListScrollOffset
	ld a, [hl]
	cp PICK_STARTER_MAX_TOP
	jr z, .lastRow ; already showing the bottom of the list
	add PICK_STARTER_LIST_ROWS
	cp PICK_STARTER_MAX_TOP
	jr c, .storeTop
	ld a, PICK_STARTER_MAX_TOP
	jr .storeTop
.lastRow
	ld a, PICK_STARTER_LIST_ROWS - 1
	ld [wCurrentMenuItem], a
	jr .moved

.storeTop
	ld [hl], a
.moved
	call PickStarter_Redraw
	jp .loop

.confirm
	; show the highlighted mon's picture if it hasn't loaded yet
	ld a, [wPickStarterPicDelay]
	and a
	call nz, PickStarter_DrawPic
	; YesNoChoice uses wCurrentMenuItem, so save the list position
	ld a, [wCurrentMenuItem]
	push af
	call PickStarter_CanAttack
	ld hl, PickStarterConfirmText ; wNameBuffer still holds the highlighted mon's name
	jr nz, .printConfirm
	ld hl, PickStarterConfirmCantAttackText
.printConfirm
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	ld b, a
	pop af
	ld [wCurrentMenuItem], a
	ld a, b
	and a
	jr z, .chosen
	call ClearScreen
	call PickStarter_Redraw
	call PickStarter_DrawPic
	jp .loop

.chosen
	ld a, [wCurPartySpecies]
	ld [wPlayerStarter], a
	xor a
	ldh [hJoy7], a
	call GBPalWhiteOutWithDelay3
	call RunDefaultPaletteCommand
	call ReloadMapData
	call LoadScreenTilesFromBuffer2
	call Delay3
	call LoadGBPal
	pop af
	ld [wListScrollOffset], a
	pop af
	ldh [hTileAnimations], a
	pop af
	ld [wUpdateSpritesEnabled], a
	call UpdateSprites
	ld a, [wPlayerStarter]
	ret

; Draws the list and the highlighted mon's number, name and types, and
; schedules its picture (see PICK_STARTER_PIC_DELAY).
; Leaves the highlighted mon in [wCurPartySpecies] and its name in wNameBuffer.
PickStarter_Redraw:
	ld hl, wStatusFlags5
	set 6, [hl] ; no printing delay, or every letter would wait on the text speed
	call PickStarter_DrawList
	call PickStarter_DrawPreview
	ld hl, wStatusFlags5
	res 6, [hl]
	ld a, PICK_STARTER_PIC_DELAY
	ld [wPickStarterPicDelay], a
	ret

; Returns nz if the highlighted mon ([wCurSpecies]/[wCurPartySpecies]) would
; know a damaging move at STARTER_LEVEL, i.e. among the moves AddPartyMon gives it.
; wEnemyMonMoves is free here (battle data, reloaded when a battle starts);
; wBuffer can't be used because it shares space with wLearningMovesFromDayCare.
PickStarter_CanAttack:
	call GetMonHeader ; level 1 moves in wMonHMoves
	ld hl, wMonHMoves
	ld de, wEnemyMonMoves
	ld bc, NUM_MOVES
	call CopyData
	ld a, STARTER_LEVEL
	ld [wCurEnemyLevel], a
	xor a
	ld [wLearningMovesFromDayCare], a
	ld de, wEnemyMonMoves
	predef WriteMonMoves ; adds the moves learned up to STARTER_LEVEL
	ld hl, wEnemyMonMoves
	ld c, NUM_MOVES
.loop
	ld a, [hli]
	and a
	jr z, .next
	push hl
	push bc
	dec a
	ld hl, Moves + MOVE_POWER
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	pop bc
	pop hl
	and a
	ret nz ; power > 0 (fixed-damage moves have power 1)
.next
	dec c
	jr nz, .loop
	xor a
	ret

PickStarter_DrawPic:
	xor a
	ld [wPickStarterPicDelay], a
	hlcoord 1, 1
	call LoadFrontSpriteByMonIndex ; uses [wCurPartySpecies]
	ld b, SET_PAL_POKEDEX ; uses [wCurPartySpecies]
	jp RunPaletteCommand

PickStarter_DrawPreview:
	hlcoord 0, 0
	lb bc, 9, SCREEN_WIDTH
	call ClearScreenArea
	ld a, [wListScrollOffset]
	ld b, a
	ld a, [wCurrentMenuItem]
	add b
	inc a
	ld [wPokedexNum], a
	hlcoord 9, 1
	ld de, PickStarterNoText
	call PlaceString
	hlcoord 12, 1
	ld de, wPokedexNum
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	ld [wNamedObjectIndex], a
	call GetMonName
	hlcoord 9, 3
	call PlaceString
	hlcoord 9, 5
	ld de, PickStarterTypesText
	call PlaceString
	hlcoord 10, 6
	predef_jump PrintMonType ; uses [wCurSpecies]

PickStarter_DrawList:
	hlcoord 0, 9
	lb bc, PICK_STARTER_LIST_ROWS, SCREEN_WIDTH - 2
	call TextBoxBorder
	ld a, [wListScrollOffset]
	ld c, a ; 0-based Pokédex index of the current row
	ld b, PICK_STARTER_LIST_ROWS
	hlcoord 2, 10
.loop
	push bc
	push hl
	ld a, c
	inc a
	ld [wPokedexNum], a
	ld de, wPokedexNum
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wNamedObjectIndex], a
	call GetMonName
	pop hl
	push hl
	ld bc, 4
	add hl, bc
	call PlaceString
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	inc c
	dec b
	jr nz, .loop
	hlcoord 1, 10
	ld a, [wCurrentMenuItem]
	ld bc, SCREEN_WIDTH
	call AddNTimes
	ld [hl], '▶'
	ret

PickStarterNoText:
	db "No.@"

PickStarterTypesText:
	db   "TYPE1/"
	next "TYPE2/@"

PickStarterConfirmText:
	text_far _PickStarterConfirmText
	text_end

PickStarterConfirmCantAttackText:
	text_far _PickStarterConfirmCantAttackText
	text_end
