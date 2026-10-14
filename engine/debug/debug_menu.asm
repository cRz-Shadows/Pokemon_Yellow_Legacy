DebugMenu:
IF DEF(_DEBUG)
	call ClearScreen

	; These debug names are used for TestBattle.
	; StartNewGameDebug uses the debug names from PrepareOakSpeech.
	ld hl, DebugBattlePlayerName
	ld de, wPlayerName
	ld bc, NAME_LENGTH
	call CopyData

	ld hl, DebugBattleRivalName
	ld de, wRivalName
	ld bc, NAME_LENGTH
	call CopyData

	call LoadFontTilePatterns
	call LoadHpBarAndStatusTilePatterns
	call ClearSprites
	call RunDefaultPaletteCommand

	hlcoord 5, 6
	lb bc, 3, 9
	call TextBoxBorder

	hlcoord 7, 7
	ld de, DebugMenuOptions
	call PlaceString

	ld a, TEXT_DELAY_MEDIUM
	ld [wOptions], a

	ld a, PAD_A | PAD_B | PAD_START
	ld [wMenuWatchedKeys], a
	xor a
	ld [wMenuJoypadPollCount], a
	inc a
	ld [wMaxMenuItem], a
	ld a, 7
	ld [wTopMenuItemY], a
	dec a
	ld [wTopMenuItemX], a
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld [wMenuWatchMovingOutOfBounds], a

	call HandleMenuInput
	bit B_PAD_B, a
	ld hl, DisplayTitleScreen
	ret nz

	ld a, [wCurrentMenuItem]
	and a ; FIGHT?
	jp z, TestBattle

	; DEBUG
	ld hl, wStatusFlags6
	set BIT_DEBUG_MODE, [hl]
	ld hl, StartNewGameDebug
	ret

DebugBattlePlayerName:
	db "Tom@"

DebugBattleRivalName:
	db "Juerry@"

DebugMenuOptions:
	db   "FIGHT"
	next "DEBUG@"

TestBattle: ; unreferenced except in _DEBUG
	ld a, 1
	ldh [hJoy7], a

	; Don't mess around with obedience.
	ld a, 1 << BIT_EARTHBADGE
	ld [wObtainedBadges], a

	ld hl, wStatusFlags7
	set BIT_TEST_BATTLE, [hl]

	ld hl, wNumBagItems
	ld de, TestBattleItems
.loop
	ld a, [de]
	cp -1
	jr z, .done
	inc de
	ld [wCurItem], a
	ld a, [de]
	inc de
	ld [wItemQuantity], a
	push de
	call AddItemToInventory
	pop de
	jr .loop
.done
	call LoadHpBarAndStatusTilePatterns
	call ClearScreen
	call ClearSprites
	hlcoord 0, 0
	lb bc, 1, 18
	call TextBoxBorder
	hlcoord 6, 1
	ld de, TestBattleTitleText
	call PlaceString
	hlcoord 4, 4
	ld de, TestBattlePartyHeaderText
	call PlaceString
	hlcoord 1, 6
	ld de, TestBattlePartyListText
	call PlaceString
	xor a
	ld [wWhichPokemon], a
	ld [wEnemyMon], a
	ld [wEnemyMonLevel], a
	ld [wTrainerClass], a
	ld [wGrassMons + 1], a
	ld b, a
	ld c, a
	ld hl, wEnemyPartySpecies
	call TestBattle_ClearSpeciesList
	ld hl, wPartyCount
	call TestBattle_ClearSpeciesList
	ld de, wPartySpecies
	hlcoord 4, 6
	; fallthrough
; Moves the cursor to the party species column, then enters its input loop
TestBattle_SelectPartySpecies:
	push hl
	push bc
	dec hl
	ld a, '▶'
	ld [hl], a
	ld bc, 11
	add hl, bc
	ld a, ' '
	ld [hl], a
	push de
	pop de
	pop bc
	pop hl
	; fallthrough
; Input loop for the party species column (A/B species, Up/Down slot, Start confirms)
TestBattle_PartySpeciesInputLoop:
	push bc
	push de
	call JoypadLowSensitivity
	pop de
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, TestBattle_NextPartySpecies
	bit B_PAD_B, a
	jp nz, TestBattle_PrevPartySpecies
	bit B_PAD_SELECT, a
	jp nz, DebugMenu
	bit B_PAD_START, a
	jp nz, TestBattle_BuildPartyAndSelectOpponent
	bit B_PAD_RIGHT, a
	jp nz, TestBattle_SelectPartyLevel
	bit B_PAD_UP, a
	jp nz, TestBattle_SpeciesCursorUp
	bit B_PAD_DOWN, a
	jp nz, TestBattle_SpeciesCursorDown
	jr TestBattle_PartySpeciesInputLoop

; Zeroes a 7-byte count+species list at hl (the party and the level buffer)
TestBattle_ClearSpeciesList:
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret

; Moves the current slot's species index up by one, wrapping to 0 (empty)
TestBattle_NextPartySpecies:
	inc b
	ld a, b
	cp NUM_POKEMON_INDEXES + 1
	jr c, TestBattle_SetPartySpecies
	xor a
	ld b, a
	; fallthrough
; Stores species a in the current slot and prints its number and name (or dashes if 0)
TestBattle_SetPartySpecies:
	ld [de], a
	ld [wTempByteValue], a
	push bc
	push hl
	push de
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	push hl
	ld de, TestBattleBlankNameText
	call PlaceString
	ld bc, -SCREEN_WIDTH
	add hl, bc
	ld de, TestBattleBlankNameText
	call PlaceString
	pop hl
	ld a, [wTempByteValue]
	and a
	jr nz, .asm_fe845
	ld de, TestBattleNoMonText
	jr .asm_fe848
.asm_fe845
	call GetMonName
.asm_fe848
	call PlaceString
	pop de
	pop hl
	pop bc
	jr TestBattle_PartySpeciesInputLoop

; Moves the current slot's species index down by one, wrapping to NUM_POKEMON_INDEXES
TestBattle_PrevPartySpecies:
	dec b
	ld a, b
	cp OPP_ID_OFFSET + 1
	jp c, TestBattle_SetPartySpecies
	ld a, NUM_POKEMON_INDEXES
	ld b, a
	jp TestBattle_SetPartySpecies

; Moves the species column cursor up one party slot
TestBattle_SpeciesCursorUp:
	ld a, [wWhichPokemon]
	dec a
	cp -1
	jp z, TestBattle_PartySpeciesInputLoop
	ld [wWhichPokemon], a
	dec de
	dec hl
	ld a, ' '
	ld [hl], a
	push bc
	ld bc, -SCREEN_WIDTH * 2
	add hl, bc
	pop bc
	ld a, '▶'
	ld [hl], a
	inc hl
	push hl
	call TestBattle_LoadSlotSpeciesAndLevel
	pop hl
	jp TestBattle_PartySpeciesInputLoop

; Moves the species column cursor down one party slot
TestBattle_SpeciesCursorDown:
	ld a, [wWhichPokemon]
	inc a
	cp 6
	jp nc, TestBattle_PartySpeciesInputLoop
	ld [wWhichPokemon], a
	inc de
	dec hl
	ld a, ' '
	ld [hl], a
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	ld a, '▶'
	ld [hl], a
	inc hl
	push hl
	call TestBattle_LoadSlotSpeciesAndLevel
	pop hl
	jp TestBattle_PartySpeciesInputLoop

; Moves the cursor to the party level column, then enters its input loop
TestBattle_SelectPartyLevel:
	push hl
	push bc
	dec hl
	ld a, ' '
	ld [hl], a
	ld bc, 11
	add hl, bc
	ld a, '▶'
	ld [hl], a
	pop bc
	pop hl
	; fallthrough
; Input loop for the party level column (A/B change level, Up/Down slot, Left/Start)
TestBattle_PartyLevelInputLoop:
	push bc
	push de
	call JoypadLowSensitivity
	pop de
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, TestBattle_IncPartyLevel
	bit B_PAD_B, a
	jp nz, TestBattle_DecPartyLevel
	bit B_PAD_START, a
	jp nz, TestBattle_BuildPartyAndSelectOpponent
	bit B_PAD_LEFT, a
	jp nz, TestBattle_SelectPartySpecies
	bit B_PAD_UP, a
	jp nz, TestBattle_LevelCursorUp
	bit B_PAD_DOWN, a
	jp nz, TestBattle_LevelCursorDown
	jr TestBattle_PartyLevelInputLoop

; Raises the current slot's level by one, wrapping to 1 after MAX_LEVEL
TestBattle_IncPartyLevel:
	inc c
	ld a, c
	cp MAX_LEVEL + 1
	jr c, TestBattle_SetPartyLevel
	ld a, 1
	ld c, a
	; fallthrough
; Stores level c in the level buffer (wEnemyPartySpecies) for the slot and prints it
TestBattle_SetPartyLevel:
	ld a, [wWhichPokemon]
	push de
	ld de, wEnemyPartySpecies
	add e
	ld e, a
	jr nc, .asm_fe8ee
	inc d
.asm_fe8ee
	ld a, c
	ld [de], a
	push bc
	push hl
	ld bc, 11
	add hl, bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	pop hl
	pop bc
	pop de
	jp TestBattle_PartyLevelInputLoop

; Lowers the current slot's level by one, wrapping to MAX_LEVEL
TestBattle_DecPartyLevel:
	dec c
	ld a, c
	cp MAX_LEVEL + 1
	jr nc, .asm_fe90c
	and a
	jp nz, TestBattle_SetPartyLevel
.asm_fe90c
	ld a, MAX_LEVEL
	ld c, a
	jp TestBattle_SetPartyLevel

; Moves the level column cursor up one party slot
TestBattle_LevelCursorUp:
	ld a, [wWhichPokemon]
	dec a
	cp -1
	jp z, TestBattle_PartyLevelInputLoop
	ld [wWhichPokemon], a
	dec de
	push hl
	ld bc, 10
	add hl, bc
	ld a, ' '
	ld [hl], a
	pop hl
	ld bc, -SCREEN_WIDTH * 2
	add hl, bc
	push hl
	ld bc, 10
	add hl, bc
	ld a, '▶'
	ld [hl], a
	call TestBattle_LoadSlotSpeciesAndLevel
	pop hl
	jp TestBattle_PartyLevelInputLoop

; Moves the level column cursor down one party slot
TestBattle_LevelCursorDown:
	ld a, [wWhichPokemon]
	inc a
	cp 6
	jp nc, TestBattle_PartyLevelInputLoop
	ld [wWhichPokemon], a
	inc de
	push hl
	ld bc, 10
	add hl, bc
	ld a, ' '
	ld [hl], a
	pop hl
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	push hl
	ld bc, 10
	add hl, bc
	ld a, '▶'
	ld [hl], a
	call TestBattle_LoadSlotSpeciesAndLevel
	pop hl
	jp TestBattle_PartyLevelInputLoop

; Loads b = species and c = level of party slot [wWhichPokemon] from the edit buffers
TestBattle_LoadSlotSpeciesAndLevel:
	ld hl, wPartySpecies
	ld a, [wWhichPokemon]
	add l
	ld l, a
	jr nc, .asm_fe96f
	inc h
.asm_fe96f
	ld a, [hl]
	ld b, a
	ld hl, wEnemyPartySpecies
	ld a, [wWhichPokemon]
	add l
	ld l, a
	jr nc, .asm_fe97c
	inc h
.asm_fe97c
	ld a, [hl]
	ld c, a
	ret

; Adds the chosen mons to the party, then draws the wild/trainer opponent select screen
TestBattle_BuildPartyAndSelectOpponent:
	ld hl, wPartyCount
	ld de, wEnemyPartyCount
	xor a
	ld [hl], a
	inc hl
	ld a, [hli]
	ld b, a
	ld c, 6
	xor a
	ld [wIsInBattle], a
.asm_fe990
	ld a, b
	ld [wCurPartySpecies], a
	ld a, [hl]
	ld b, a
	inc de
	ld a, [de]
	and a
	jr z, .asm_fe9ab
	ld [wCurEnemyLevel], a
	xor a
	ld [wMonDataLocation], a
	ld a, [wCurPartySpecies]
	and a
	jr z, .asm_fe9ab
	call AddPartyMon
.asm_fe9ab
	inc hl
	dec c
	jr nz, .asm_fe990
	ld b, 7
	ld hl, wPartySpecies
	ld de, wEnemyPartyCount
.asm_fe9b7
	inc de
	dec b
	jp z, TestBattle
	ld a, [hli]
	and a
	jr z, .asm_fe9b7
	ld a, [de]
	and a
	jr z, .asm_fe9b7
	hlcoord 0, 3
	lb bc, 15, 20
	call ClearScreenArea
	ld c, 20
	call DelayFrames
	ld a, 1
	ld [wIsInBattle], a
	ld de, TestBattleWildText
	ld a, [wGrassMons + 1]
	cp MAX_LEVEL + 1
	jr c, .asm_fe9fb
	ld a, 2
	ld [wIsInBattle], a
	ld de, TestBattleTrainerText
.asm_fe9fb
	hlcoord 1, 4
	call PlaceString
	hlcoord 1, 6
	ld de, TestBattleOpponentHeaderText
	call PlaceString
	ld a, [wEnemyMon]
	ld b, a
	ld a, [wIsInBattle]
	dec a
	jr z, .asm_fea40
	ld a, [wTrainerClass]
	ld [wTempByteValue], a
	ld b, a
	ld de, wTempByteValue
	hlcoord 1, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	hlcoord 5, 8
	ld de, TestBattleClearNameText
	call PlaceString
	call GetTrainerName
	hlcoord 5, 8
	ld de, wTrainerName
	call PlaceString
	pop bc
	jr .asm_fea65
.asm_fea40
	ld a, b
	and a
	jr z, .asm_fea65
	ld de, wTempByteValue
	ld [de], a
	hlcoord 1, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	hlcoord 5, 8
	ld de, TestBattleClearNameText
	call PlaceString
	call GetMonName
	hlcoord 5, 8
	call PlaceString
	pop bc
.asm_fea65
	ld a, [wEnemyMonLevel]
	ld c, a
	ld de, wTempByteValue
	ld [de], a
	hlcoord 16, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	pop bc
	; fallthrough
; Moves the cursor to the wild/trainer battle type row, then enters its input loop
TestBattle_SelectBattleType:
	ld a, ' '
	ldcoord_a 0, 8
	ldcoord_a 15, 8
	ld a, '▶'
	ldcoord_a 0, 4
	; fallthrough
; Input loop for the battle type row (A toggles, Down goes to opponent, Start fights)
TestBattle_BattleTypeInputLoop:
	push bc
	call JoypadLowSensitivity
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, TestBattle_ToggleBattleType
	bit B_PAD_START, a
	jp nz, TestBattle_StartBattle
	bit B_PAD_DOWN, a
	jp nz, TestBattle_SelectOpponentID
	jr TestBattle_BattleTypeInputLoop

; Switches wIsInBattle between wild (1) and trainer (2) and resets the opponent fields
TestBattle_ToggleBattleType:
	hlcoord 1, 8
	ld de, TestBattleBlankOpponentText
	call PlaceString
	hlcoord 5, 7
	ld de, TestBattleClearNameText
	call PlaceString
	xor a
	ld b, a
	ld c, a
	ld a, [wIsInBattle]
	dec a
	jr nz, .asm_feace
	ld a, 2
	ld [wIsInBattle], a
	ld a, ' '
	ldcoord_a 4, 3
	hlcoord 1, 4
	ld de, TestBattleTrainerText
	call PlaceString
	jp TestBattle_BattleTypeInputLoop
.asm_feace
	ld a, 1
	ld [wIsInBattle], a
	ld a, ' '
	ldcoord_a 1, 3
	hlcoord 1, 4
	ld de, TestBattleWildText
	call PlaceString
	jp TestBattle_BattleTypeInputLoop

; Moves the cursor to the opponent species/trainer class field, then enters its loop
TestBattle_SelectOpponentID:
	ld a, '▶'
	ldcoord_a 0, 8
	ld a, ' '
	ldcoord_a 15, 8
	ldcoord_a 0, 4
	; fallthrough
; Input loop for the opponent species/class field (A/B change, Right level, Up type)
TestBattle_OpponentIDInputLoop:
	push bc
	call JoypadLowSensitivity
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, TestBattle_NextOpponentID
	bit B_PAD_B, a
	jp nz, TestBattle_PrevOpponentID
	bit B_PAD_START, a
	jp nz, TestBattle_StartBattle
	bit B_PAD_RIGHT, a
	jp nz, TestBattle_SelectOpponentLevel
	bit B_PAD_UP, a
	jp nz, TestBattle_SelectBattleType
	jr TestBattle_OpponentIDInputLoop

; Moves the opponent species (wild) or trainer class (trainer) up by one, with wrapping
TestBattle_NextOpponentID:
	push bc
	hlcoord 5, 7
	ld de, TestBattleClearNameText
	call PlaceString
	hlcoord 5, 8
	ld de, TestBattleClearNameText
	call PlaceString
	pop bc
	ld a, [wIsInBattle]
	dec a
	jr z, TestBattle_SetTrainerClass.asm_feb5c
	inc b
	ld a, b
	cp NUM_TRAINERS + 1
	jr c, TestBattle_SetTrainerClass
	ld b, 1
	; fallthrough
; Prints trainer class b's number and name as the opponent
TestBattle_SetTrainerClass:
	ld a, b
	ld [wTempByteValue], a
	ld de, wTempByteValue
	hlcoord 1, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	ld a, [wTempByteValue]
	ld [wTrainerClass], a
	call GetTrainerName
	hlcoord 5, 8
	ld de, wTrainerName
	call PlaceString
	pop bc
	jp TestBattle_OpponentIDInputLoop
.asm_feb5c
	inc b
	ld a, b
	cp NUM_POKEMON_INDEXES + 1
	jr c, TestBattle_SetWildSpecies
	ld b, 1
	; fallthrough
; Prints species b's number and name as the wild opponent
TestBattle_SetWildSpecies:
	ld a, b
	ld [wTempByteValue], a
	ld de, wTempByteValue
	hlcoord 1, 8
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	call GetMonName
	hlcoord 5, 8
	call PlaceString
	pop bc
	jp TestBattle_OpponentIDInputLoop

; Moves the opponent species (wild) or trainer class (trainer) down by one, with wrapping
TestBattle_PrevOpponentID:
	push bc
	hlcoord 5, 7
	ld de, TestBattleClearNameText
	call PlaceString
	hlcoord 5, 8
	ld de, TestBattleClearNameText
	call PlaceString
	pop bc
	ld a, [wIsInBattle]
	dec a
	jr z, .asm_febab
	dec b
	ld a, b
	cp NUM_TRAINERS + 1
	jr nc, .asm_feba6
	and a
	jp nz, TestBattle_SetTrainerClass
.asm_feba6
	ld b, NUM_TRAINERS
	jp TestBattle_SetTrainerClass
.asm_febab
	dec b
	ld a, b
	cp NUM_POKEMON_INDEXES + 1
	jr nc, .asm_febb5
	and a
	jp nz, TestBattle_SetWildSpecies
.asm_febb5
	ld b, NUM_POKEMON_INDEXES
	jp TestBattle_SetWildSpecies

; Moves the cursor to the opponent level (trainer number) field, then enters its loop
TestBattle_SelectOpponentLevel:
	ld a, ' '
	ldcoord_a 0, 8
	ld a, '▶'
	ldcoord_a 15, 8
	; fallthrough
; Input loop for the opponent level field (A/B change, Left/Up move, Start fights)
TestBattle_OpponentLevelInputLoop:
	push bc
	call JoypadLowSensitivity
	pop bc
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, TestBattle_IncOpponentLevel
	bit B_PAD_B, a
	jp nz, TestBattle_DecOpponentLevel
	bit B_PAD_START, a
	jp nz, TestBattle_StartBattle
	bit B_PAD_LEFT, a
	jp nz, TestBattle_SelectOpponentID
	bit B_PAD_UP, a
	jp nz, TestBattle_SelectBattleType
	jr TestBattle_OpponentLevelInputLoop

; Raises the opponent level by one, wrapping to 1 after MAX_LEVEL
TestBattle_IncOpponentLevel:
	inc c
	ld a, c
	cp MAX_LEVEL + 1
	jr c, TestBattle_SetOpponentLevel
	ld c, 1
; Stores c in wCurEnemyLevel and prints it in the opponent level field
TestBattle_SetOpponentLevel:
	hlcoord 16, 8
	ld a, c
	ld de, wCurEnemyLevel
	ld [de], a
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	pop bc
	jp TestBattle_OpponentLevelInputLoop

; Lowers the opponent level by one, wrapping to MAX_LEVEL
TestBattle_DecOpponentLevel:
	dec c
	ld a, c
	cp MAX_LEVEL + 1
	jr nc, .asm_fec0b
	and a
	jp nz, TestBattle_SetOpponentLevel
.asm_fec0b
	ld c, MAX_LEVEL
	jp TestBattle_SetOpponentLevel

; Sets up the chosen wild/trainer opponent, runs the battle, then redraws the party screen
TestBattle_StartBattle:
	ld a, b
	and a
	jp z, TestBattle_SelectBattleType
	ld a, c
	and a
	jp z, TestBattle_SelectBattleType
	ld a, [wIsInBattle]
	dec a
	jr z, .asm_fec28
	ld a, b
	add OPP_ID_OFFSET
	ld b, a
	; for trainers, the "level" field picks which party of the class to fight
	ld a, c
	ld [wTrainerNo], a
.asm_fec28
	ld a, c
	ld [wCurEnemyLevel], a
	ld a, b
	ld [wCurOpponent], a
	xor a
	ld [wStatusFlags3], a
	predef InitOpponent
	xor a
	ld [wNumRunAttempts], a
	ld hl, wPlayerStatsToDouble
	ld bc, wEnemyStatsToDouble - wPlayerStatsToDouble
	call FillMemory
	ld hl, wEnemyStatsToDouble
	ld bc, wPlayerNumAttacksLeft - wEnemyStatsToDouble
	call FillMemory
	call LoadFontTilePatterns
	call ClearScreen
	call ClearSprites
	ld a, %11100100
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	call UpdateCGBPal_BGP
	call UpdateCGBPal_OBP0
	call UpdateCGBPal_OBP1
	hlcoord 0, 0
	lb bc, 1, 18
	call TextBoxBorder
	hlcoord 6, 1
	ld de, TestBattleTitleText
	call PlaceString
	hlcoord 4, 4
	ld de, TestBattlePartyHeaderText
	call PlaceString
	hlcoord 1, 6
	ld de, TestBattlePartyListText
	call PlaceString
	ld de, wPartyCount
	xor a
	ld [de], a
	ld [wWhichPokemon], a
	inc de
	hlcoord 4, 6
	push de
	push hl
	; fallthrough
; After the battle, prints each party mon's species and level and refills the level buffer
TestBattle_RedrawPartyList:
	ld a, [wWhichPokemon]
	ld de, wPartySpecies
	add e
	ld e, a
	jr nc, .asm_feca6
	inc d
.asm_feca6
	ld a, [de]
	cp -1
	jp z, TestBattle_ReturnToPartyEditor
	ld [wTempByteValue], a
	push hl
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	ld de, TestBattleBlankNameText
	call PlaceString
	call GetMonName
	call PlaceString
	pop hl
	push hl
	ld bc, 11
	add hl, bc
	push hl
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1Level
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld d, h
	ld e, l
	ld a, [de]
	ld [wCurEnemyLevel], a
	pop hl
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	ld a, [wWhichPokemon]
	ld de, wEnemyPartySpecies
	add e
	ld e, a
	jr nc, .asm_fecee
	inc d
.asm_fecee
	ld a, [wCurEnemyLevel]
	ld [de], a
	pop hl
	ld a, [wWhichPokemon]
	inc a
	ld [wWhichPokemon], a
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	jp TestBattle_RedrawPartyList

; Ends the post-battle redraw and goes back to the party species column for slot 1
TestBattle_ReturnToPartyEditor:
	pop hl
	pop de
	ld a, [wPartyMon1]
	ld b, a
	ld a, [wPartyMon1Level]
	ld c, a
	xor a
	ld [wWhichPokemon], a
	jp TestBattle_SelectPartySpecies

; "FIGHT TEST" title shown at the top of the test battle screens
TestBattleTitleText:
	db   "テスト ファイト@" ; "FIGHT TEST@"

; "No. NAME LEVEL" column header for the party editor
TestBattlePartyHeaderText:
	db   "№．  なまえ    レべル@" ; "№．  NAME  LEVEL@"

; Blank six-slot party list template (number, name and level placeholders)
TestBattlePartyListText:
	db   "１．▶０００ ーーーーー  ０００"
	next "２． ０００ ーーーーー  ０００"
	next "３． ０００ ーーーーー  ０００"
	next "４． ０００ ーーーーー  ０００"
	next "５． ０００ ーーーーー  ０００"
	next "６． ０００ ーーーーー  ０００@"

; Five spaces used to clear a mon name field
TestBattleBlankNameText:
	db   "     @"

; Dashes shown in place of a name for an empty party slot
TestBattleNoMonText:
	db   "ーーーーー@"

; "WILD #MON" battle type label
TestBattleWildText:
	db   "ワイルドモンスター@" ; "WILD #MON@"

; "TRAINER" battle type label (padded to clear the wild label)
TestBattleTrainerText:
	db   "ディーラー    @" ; "TRAINER      @"

; "No. NAME LEVEL" header for the opponent row, followed by its blank entry row
TestBattleOpponentHeaderText:
	db   "№．  なまえ        レべル" ; "№．  NAME     LABEL"
	next ""
; Blank opponent row template ("000 ---------- 000")
TestBattleBlankOpponentText:
	db   "０００ ーーーーーーーーーー ０００@"

; Ten spaces used to clear the opponent/trainer name field
TestBattleClearNameText:
	db   "          @"

; Item and quantity list added to the bag when the test battle starts
TestBattleItems:
	db GREAT_BALL, 99
	db POKE_BALL, 99
	db ANTIDOTE, 99
	db FULL_RESTORE, 99
	db MAX_POTION, 99
	db HYPER_POTION, 99
	db SUPER_POTION, 99
	db POTION, 99
	db -1 ; end

ELSE
	ret
ENDC
