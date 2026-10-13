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

	ld a, A_BUTTON | B_BUTTON | START
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
	bit BIT_B_BUTTON, a
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
	ld de, Data_feded
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
	ld de, Text_fed18
	call PlaceString
	hlcoord 4, 4
	ld de, Text_fed21
	call PlaceString
	hlcoord 1, 6
	ld de, Text_fed30
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
	call Func_fe809
	ld hl, wPartyCount
	call Func_fe809
	ld de, wPartySpecies
	hlcoord 4, 6
	; fallthrough
; SUGGESTED NAME: TestBattle_SelectPartySpecies
; Moves the cursor to the party species column, then enters its input loop (confidence: high)
Func_fe7ca:
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
; SUGGESTED NAME: TestBattle_PartySpeciesInputLoop
; Input loop for the party species column (A/B species, Up/Down slot, Start confirms) (confidence: high)
Func_fe7db:
	push bc
	push de
	call JoypadLowSensitivity
	pop de
	pop bc
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_fe812
	bit BIT_B_BUTTON, a
	jp nz, Func_fe850
	bit BIT_SELECT, a
	jp nz, DebugMenu
	bit BIT_START, a
	jp nz, Func_fe97f
	bit BIT_D_RIGHT, a
	jp nz, Func_fe8a1
	bit BIT_D_UP, a
	jp nz, Func_fe85d
	bit BIT_D_DOWN, a
	jp nz, Func_fe880
	jr Func_fe7db

; SUGGESTED NAME: TestBattle_ClearSpeciesList
; Zeroes a 7-byte count+species list at hl (the party and the level buffer) (confidence: high)
Func_fe809:
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret

; SUGGESTED NAME: TestBattle_NextPartySpecies
; Moves the current slot's species index up by one, wrapping to 0 (empty) (confidence: high)
Func_fe812:
	inc b
	ld a, b
	cp NUM_POKEMON_INDEXES + 1
	jr c, Func_fe81a
	xor a
	ld b, a
	; fallthrough
; SUGGESTED NAME: TestBattle_SetPartySpecies
; Stores species a in the current slot and prints its number and name (or dashes if 0) (confidence: high)
Func_fe81a:
	ld [de], a
	ld [wTempByteValue], a
	push bc
	push hl
	push de
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	push hl
	ld de, Text_fed9c
	call PlaceString
	ld bc, hSavedMapTextPtr
	add hl, bc
	ld de, Text_fed9c
	call PlaceString
	pop hl
	ld a, [wTempByteValue]
	and a
	jr nz, .asm_fe845
	ld de, Text_feda2
	jr .asm_fe848
.asm_fe845
	call GetMonName
.asm_fe848
	call PlaceString
	pop de
	pop hl
	pop bc
	jr Func_fe7db

; SUGGESTED NAME: TestBattle_PrevPartySpecies
; Moves the current slot's species index down by one, wrapping to NUM_POKEMON_INDEXES (confidence: high)
Func_fe850:
	dec b
	ld a, b
	cp OPP_ID_OFFSET + 1
	jp c, Func_fe81a
	ld a, NUM_POKEMON_INDEXES
	ld b, a
	jp Func_fe81a

; SUGGESTED NAME: TestBattle_SpeciesCursorUp
; Moves the species column cursor up one party slot (confidence: high)
Func_fe85d:
	ld a, [wWhichPokemon]
	dec a
	cp -1
	jp z, Func_fe7db
	ld [wWhichPokemon], a
	dec de
	dec hl
	ld a, ' '
	ld [hl], a
	push bc
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	pop bc
	ld a, '▶'
	ld [hl], a
	inc hl
	push hl
	call Func_fe964
	pop hl
	jp Func_fe7db

; SUGGESTED NAME: TestBattle_SpeciesCursorDown
; Moves the species column cursor down one party slot (confidence: high)
Func_fe880:
	ld a, [wWhichPokemon]
	inc a
	cp 6
	jp nc, Func_fe7db
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
	call Func_fe964
	pop hl
	jp Func_fe7db

; SUGGESTED NAME: TestBattle_SelectPartyLevel
; Moves the cursor to the party level column, then enters its input loop (confidence: high)
Func_fe8a1:
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
; SUGGESTED NAME: TestBattle_PartyLevelInputLoop
; Input loop for the party level column (A/B change level, Up/Down slot, Left/Start) (confidence: high)
Func_fe8b0:
	push bc
	push de
	call JoypadLowSensitivity
	pop de
	pop bc
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_fe8d9
	bit BIT_B_BUTTON, a
	jp nz, Func_fe902
	bit BIT_START, a
	jp nz, Func_fe97f
	bit BIT_D_LEFT, a
	jp nz, Func_fe7ca
	bit BIT_D_UP, a
	jp nz, Func_fe912
	bit BIT_D_DOWN, a
	jp nz, Func_fe93b
	jr Func_fe8b0

; SUGGESTED NAME: TestBattle_IncPartyLevel
; Raises the current slot's level by one, wrapping to 1 after MAX_LEVEL (confidence: high)
Func_fe8d9:
	inc c
	ld a, c
	cp MAX_LEVEL + 1
	jr c, Func_fe8e2
	ld a, 1
	ld c, a
	; fallthrough
; SUGGESTED NAME: TestBattle_SetPartyLevel
; Stores level c in the level buffer (wEnemyPartySpecies) for the slot and prints it (confidence: high)
Func_fe8e2:
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
	jp Func_fe8b0

; SUGGESTED NAME: TestBattle_DecPartyLevel
; Lowers the current slot's level by one, wrapping to MAX_LEVEL (confidence: high)
Func_fe902:
	dec c
	ld a, c
	cp MAX_LEVEL + 1
	jr nc, .asm_fe90c
	and a
	jp nz, Func_fe8e2
.asm_fe90c
	ld a, MAX_LEVEL
	ld c, a
	jp Func_fe8e2

; SUGGESTED NAME: TestBattle_LevelCursorUp
; Moves the level column cursor up one party slot (confidence: high)
Func_fe912:
	ld a, [wWhichPokemon]
	dec a
	cp -1
	jp z, Func_fe8b0
	ld [wWhichPokemon], a
	dec de
	push hl
	ld bc, 10
	add hl, bc
	ld a, ' '
	ld [hl], a
	pop hl
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	push hl
	ld bc, 10
	add hl, bc
	ld a, '▶'
	ld [hl], a
	call Func_fe964
	pop hl
	jp Func_fe8b0

; SUGGESTED NAME: TestBattle_LevelCursorDown
; Moves the level column cursor down one party slot (confidence: high)
Func_fe93b:
	ld a, [wWhichPokemon]
	inc a
	cp 6
	jp nc, Func_fe8b0
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
	call Func_fe964
	pop hl
	jp Func_fe8b0

; SUGGESTED NAME: TestBattle_LoadSlotSpeciesAndLevel
; Loads b = species and c = level of party slot [wWhichPokemon] from the edit buffers (confidence: high)
Func_fe964:
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

; SUGGESTED NAME: TestBattle_BuildPartyAndSelectOpponent
; Adds the chosen mons to the party, then draws the wild/trainer opponent select screen (confidence: high)
Func_fe97f:
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
	hlcoord 0, 3
	lb bc, 15, 20
	call ClearScreenArea
	hlcoord 0, 3
	lb bc, 15, 20
	call ClearScreenArea
	ld c, 20
	call DelayFrames
	ld a, 1
	ld [wIsInBattle], a
	ld de, Text_feda8
	ld a, [wGrassMons + 1]
	cp MAX_LEVEL + 1
	jr c, .asm_fe9fb
	ld a, 2
	ld [wIsInBattle], a
	ld de, Text_fedb2
.asm_fe9fb
	hlcoord 1, 4
	call PlaceString
	hlcoord 1, 6
	ld de, Text_fedbc
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
	ld de, Text_fede2
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
	ld de, Text_fede2
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
; SUGGESTED NAME: TestBattle_SelectBattleType
; Moves the cursor to the wild/trainer battle type row, then enters its input loop (confidence: high)
Func_fea78:
	ld a, ' '
	ldcoord_a 0, 8
	ldcoord_a 15, 8
	ld a, '▶'
	ldcoord_a 0, 4
	; fallthrough
; SUGGESTED NAME: TestBattle_BattleTypeInputLoop
; Input loop for the battle type row (A toggles, Down goes to opponent, Start fights) (confidence: high)
Func_fea85:
	push bc
	call JoypadLowSensitivity
	pop bc
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_fea9d
	bit BIT_START, a
	jp nz, Func_fec10
	bit BIT_D_DOWN, a
	jp nz, Func_feae4
	jr Func_fea85

; SUGGESTED NAME: TestBattle_ToggleBattleType
; Switches wIsInBattle between wild (1) and trainer (2) and resets the opponent fields (confidence: high)
Func_fea9d:
	hlcoord 1, 8
	ld de, Text_fedcf
	call PlaceString
	hlcoord 5, 7
	ld de, Text_fede2
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
	ld de, Text_fedb2
	call PlaceString
	jp Func_fea85
.asm_feace
	ld a, 1
	ld [wIsInBattle], a
	ld a, ' '
	ldcoord_a 1, 3
	hlcoord 1, 4
	ld de, Text_feda8
	call PlaceString
	jp Func_fea85

; SUGGESTED NAME: TestBattle_SelectOpponentID
; Moves the cursor to the opponent species/trainer class field, then enters its loop (confidence: high)
Func_feae4:
	ld a, '▶'
	ldcoord_a 0, 8
	ld a, ' '
	ldcoord_a 15, 8
	ldcoord_a 0, 4
	; fallthrough
; SUGGESTED NAME: TestBattle_OpponentIDInputLoop
; Input loop for the opponent species/class field (A/B change, Right level, Up type) (confidence: high)
Func_feaf1:
	push bc
	call JoypadLowSensitivity
	pop bc
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_feb13
	bit BIT_B_BUTTON, a
	jp nz, Func_feb82
	bit BIT_START, a
	jp nz, Func_fec10
	bit BIT_D_RIGHT, a
	jp nz, Func_febba
	bit BIT_D_UP, a
	jp nz, Func_fea78
	jr Func_feaf1

; SUGGESTED NAME: TestBattle_NextOpponentID
; Moves the opponent species (wild) or trainer class (trainer) up by one, with wrapping (confidence: high)
Func_feb13:
	push bc
	hlcoord 5, 7
	ld de, Text_fede2
	call PlaceString
	hlcoord 5, 8
	ld de, Text_fede2
	call PlaceString
	pop bc
	ld a, [wIsInBattle]
	dec a
	jr z, Func_feb35.asm_feb5c
	inc b
	ld a, b
	cp 48
	jr c, Func_feb35
	ld b, 1
	; fallthrough
; SUGGESTED NAME: TestBattle_SetTrainerClass
; Prints trainer class b's number and name as the opponent (confidence: high)
Func_feb35:
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
	jp Func_feaf1
.asm_feb5c
	inc b
	ld a, b
	cp NUM_POKEMON_INDEXES + 1
	jr c, Func_feb64
	ld b, 1
	; fallthrough
; SUGGESTED NAME: TestBattle_SetWildSpecies
; Prints species b's number and name as the wild opponent (confidence: high)
Func_feb64:
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
	jp Func_feaf1

; SUGGESTED NAME: TestBattle_PrevOpponentID
; Moves the opponent species (wild) or trainer class (trainer) down by one, with wrapping (confidence: high)
Func_feb82:
	push bc
	hlcoord 5, 7
	ld de, Text_fede2
	call PlaceString
	hlcoord 5, 8
	ld de, Text_fede2
	call PlaceString
	pop bc
	ld a, [wIsInBattle]
	dec a
	jr z, .asm_febab
	dec b
	ld a, b
	cp 48
	jr nc, .asm_feba6
	and a
	jp nz, Func_feb35
.asm_feba6
	ld b, 47
	jp Func_feb35
.asm_febab
	dec b
	ld a, b
	cp NUM_POKEMON_INDEXES + 1
	jr nc, .asm_febb5
	and a
	jp nz, Func_feb64
.asm_febb5
	ld b, NUM_POKEMON_INDEXES
	jp Func_feb64

; SUGGESTED NAME: TestBattle_SelectOpponentLevel
; Moves the cursor to the opponent level (trainer number) field, then enters its loop (confidence: high)
Func_febba:
	ld a, ' '
	ldcoord_a 0, 8
	ld a, '▶'
	ldcoord_a 15, 8
	; fallthrough
; SUGGESTED NAME: TestBattle_OpponentLevelInputLoop
; Input loop for the opponent level field (A/B change, Left/Up move, Start fights) (confidence: high)
Func_febc4:
	push bc
	call JoypadLowSensitivity
	pop bc
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_febe6
	bit BIT_B_BUTTON, a
	jp nz, Func_fec01
	bit BIT_START, a
	jp nz, Func_fec10
	bit BIT_D_LEFT, a
	jp nz, Func_feae4
	bit BIT_D_UP, a
	jp nz, Func_fea78
	jr Func_febc4

; SUGGESTED NAME: TestBattle_IncOpponentLevel
; Raises the opponent level by one, wrapping to 1 after MAX_LEVEL (confidence: high)
Func_febe6:
	inc c
	ld a, c
	cp MAX_LEVEL + 1
	jr c, Func_febee
	ld c, 1
; SUGGESTED NAME: TestBattle_SetOpponentLevel
; Stores c in wCurEnemyLevel and prints it in the opponent level field (confidence: high)
Func_febee:
	hlcoord 16, 8
	ld a, c
	ld de, wCurEnemyLevel
	ld [de], a
	push bc
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	pop bc
	jp Func_febc4

; SUGGESTED NAME: TestBattle_DecOpponentLevel
; Lowers the opponent level by one, wrapping to MAX_LEVEL (confidence: high)
Func_fec01:
	dec c
	ld a, c
	cp MAX_LEVEL + 1
	jr nc, .asm_fec0b
	and a
	jp nz, Func_febee
.asm_fec0b
	ld c, MAX_LEVEL
	jp Func_febee

; SUGGESTED NAME: TestBattle_StartBattle
; Sets up the chosen wild/trainer opponent, runs the battle, then redraws the party screen (confidence: high)
Func_fec10:
	ld a, b
	and a
	jp z, Func_fea78
	ld a, c
	and a
	jp z, Func_fea78
	ld a, [wIsInBattle]
	dec a
	jr z, .asm_fec28
	ld a, b
	add OPP_ID_OFFSET
	ld b, a
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
	ld de, Text_fed18
	call PlaceString
	hlcoord 4, 4
	ld de, Text_fed21
	call PlaceString
	hlcoord 1, 6
	ld de, Text_fed30
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
; SUGGESTED NAME: TestBattle_RedrawPartyList
; After the battle, prints each party mon's species and level and refills the level buffer (confidence: high)
Func_fec9b:
	ld a, [wWhichPokemon]
	ld de, wPartySpecies
	add e
	ld e, a
	jr nc, .asm_feca6
	inc d
.asm_feca6
	ld a, [de]
	cp -1
	jp z, Func_fed01
	ld [wTempByteValue], a
	push hl
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	ld de, Text_fed9c
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
	jp Func_fec9b

; SUGGESTED NAME: TestBattle_ReturnToPartyEditor
; Ends the post-battle redraw and goes back to the party species column for slot 1 (confidence: high)
Func_fed01:
	pop hl
	pop de
	ld a, [wPartyMon1]
	ld b, a
	ld a, [wPartyMon1Level]
	ld c, a
	xor a
	ld [wWhichPokemon], a
	jp Func_fe7ca

; SUGGESTED NAME: TestBattleUnusedNameText
; Unused debug name string "KENSHIROU" (confidence: medium)
Text_fed12:
	db   "けんしろう@" ; "KENSHIROU@"

; SUGGESTED NAME: TestBattleTitleText
; "FIGHT TEST" title shown at the top of the test battle screens (confidence: high)
Text_fed18:
	db   "テスト ファイト@" ; "FIGHT TEST@"

; SUGGESTED NAME: TestBattlePartyHeaderText
; "No. NAME LEVEL" column header for the party editor (confidence: high)
Text_fed21:
	db   "№．  なまえ    レべル@" ; "№．  NAME  LEVEL@"

; SUGGESTED NAME: TestBattlePartyListText
; Blank six-slot party list template (number, name and level placeholders) (confidence: high)
Text_fed30:
	db   "１．▶０００ ーーーーー  ０００"
	next "２． ０００ ーーーーー  ０００"
	next "３． ０００ ーーーーー  ０００"
	next "４． ０００ ーーーーー  ０００"
	next "５． ０００ ーーーーー  ０００"
	next "６． ０００ ーーーーー  ０００@"

; SUGGESTED NAME: TestBattleBlankNameText
; Five spaces used to clear a mon name field (confidence: high)
Text_fed9c:
	db   "     @"

; SUGGESTED NAME: TestBattleNoMonText
; Dashes shown in place of a name for an empty party slot (confidence: high)
Text_feda2:
	db   "ーーーーー@"

; SUGGESTED NAME: TestBattleWildText
; "WILD #MON" battle type label (confidence: high)
Text_feda8:
	db   "ワイルドモンスター@" ; "WILD #MON@"

; SUGGESTED NAME: TestBattleTrainerText
; "TRAINER" battle type label (padded to clear the wild label) (confidence: high)
Text_fedb2:
	db   "ディーラー    @" ; "TRAINER      @"

; SUGGESTED NAME: TestBattleOpponentHeaderText
; "No. NAME LEVEL" header for the opponent row, followed by its blank entry row (confidence: high)
Text_fedbc:
	db   "№．  なまえ        レべル" ; "№．  NAME     LABEL"
	next ""
; SUGGESTED NAME: TestBattleBlankOpponentText
; Blank opponent row template ("000 ---------- 000") (confidence: high)
Text_fedcf:
	db   "０００ ーーーーーーーーーー ０００@"

; SUGGESTED NAME: TestBattleClearNameText
; Ten spaces used to clear the opponent/trainer name field (confidence: high)
Text_fede2:
	db   "          @"

; SUGGESTED NAME: TestBattleItems
; Item and quantity list added to the bag when the test battle starts (confidence: high)
Data_feded:
	db GREAT_BALL, 99
	db POKE_BALL, 99
	db ANTIDOTE, 99
	db FULL_RESTORE, 99
	db MAX_POTION, 99
	db HYPER_POTION, 99
	db SUPER_POTION, 99
	db POTION, 99
	db -1 ; end

; SUGGESTED NAME: BoxMonDebugMenu
; Unused debug editor: pick species, level, moves, DVs and stat exp, then send mon to box (confidence: medium)
Func_fedfe:
	ld a, [wBoxCount]
	cp 30
	jp nc, Func_ff1ad
	call ClearScreen
	call UpdateSprites
	ld a, [wLetterPrintingDelayFlags]
	push af
	xor a
	ld [wLetterPrintingDelayFlags], a
	ld hl, wEnemyMonOT
	ld [hli], a
	ld [hli], a
	ld [hl], a
	inc a
	ldh [hJoy7], a
	ld [wCurPartySpecies], a
	ld [wCurEnemyLevel], a
	; fallthrough
; SUGGESTED NAME: BoxMonDebug_SelectSpecies
; Moves the cursor to the species row and runs its input loop (A/B change, Down next) (confidence: high)
Func_fee23:
	hlcoord 0, 3
	ld [hl], ' '
	hlcoord 0, 1
	ld [hl], '▶'
	call Func_fee60
.asm_fee30
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_fee49
	bit BIT_B_BUTTON, a
	jp nz, Func_fee56
	bit BIT_D_DOWN, a
	jp nz, Func_fee96
	jr .asm_fee30

; SUGGESTED NAME: BoxMonDebug_NextSpecies
; Moves the Pokedex number up by one, wrapping to Bulbasaur after Mew (confidence: high)
Func_fee49:
	ld hl, wCurPartySpecies
	inc [hl]
	ld a, [hl]
	cp NUM_POKEMON + 1
	jr c, Func_fee23
	ld [hl], DEX_BULBASAUR
	jr Func_fee23

; SUGGESTED NAME: BoxMonDebug_PrevSpecies
; Moves the Pokedex number down by one, wrapping to Mew (confidence: high)
Func_fee56:
	ld hl, wCurPartySpecies
	dec [hl]
	jr nz, Func_fee23
	ld [hl], DEX_MEW
	jr Func_fee23

; SUGGESTED NAME: BoxMonDebug_PrintSpecies
; Prints the selected Pokedex number and name and loads that species' base stats header (confidence: high)
Func_fee60:
	hlcoord 1, 0
	lb bc, 2, 9
	call ClearScreenArea
	hlcoord 1, 1
	ld de, wCurPartySpecies
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	push hl
	ld a, [wCurPartySpecies]
	ld [wPokedexNum], a
	callfar PokedexToIndex
	call GetMonName
	pop hl
	call PlaceString
	ld a, [wPokedexNum]
	ld [wCurSpecies], a
	call GetMonHeader
	ret

; SUGGESTED NAME: BoxMonDebug_SelectLevel
; Level row input loop (A/B change level, Up species, Down moves, Start sends to box) (confidence: high)
Func_fee96:
	hlcoord 0, 1
	ld [hl], ' '
	hlcoord 0, 3
	ld [hl], '▶'
	hlcoord 0, 5
	ld [hl], ' '
	call Func_feee2
	call Func_feeef
.asm_feeab
	call DelayFrame
	call JoypadLowSensitivity
	ld hl, wCurEnemyLevel
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_feed1
	bit BIT_B_BUTTON, a
	jp nz, Func_feedb
	bit BIT_START, a
	jp nz, Func_ff12c
	bit BIT_D_UP, a
	jp nz, Func_fee23
	bit BIT_D_DOWN, a
	jp nz, Func_fef60
	jr .asm_feeab

; SUGGESTED NAME: BoxMonDebug_IncLevel
; Raises the box mon level by one, wrapping to 1 after MAX_LEVEL (confidence: high)
Func_feed1:
	inc [hl]
	ld a, [hl]
	cp MAX_LEVEL + 1
	jr c, Func_fee96
	ld [hl], 1
	jr Func_fee96

; SUGGESTED NAME: BoxMonDebug_DecLevel
; Lowers the box mon level by one, wrapping to MAX_LEVEL (confidence: high)
Func_feedb:
	dec [hl]
	jr nz, Func_fee96
	ld [hl], MAX_LEVEL
	jr Func_fee96

; SUGGESTED NAME: BoxMonDebug_PrintLevel
; Prints the chosen level (wCurEnemyLevel) on the level row (confidence: high)
Func_feee2:
	hlcoord 1, 3
	ld de, wCurEnemyLevel
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	ret

; SUGGESTED NAME: BoxMonDebug_LoadDefaultMoves
; Fills wMoves with the species' default moves for the chosen level and prints them (confidence: high)
Func_feeef:
	hlcoord 1, 4
	lb bc, 8, 11
	call ClearScreenArea
	ld a, [wCurPartySpecies]
	push af
	ld [wPokedexNum], a
	ld hl, BaseStats + 15
	dec a
	ld bc, BASE_DATA_SIZE
	call AddNTimes
	ld de, wMoves
	ld bc, NUM_MOVES
	ld a, BANK(BaseStats)
	call FarCopyData
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wCurPartySpecies], a
	xor a
	ld [wChangeMonPicEnemyTurnSpecies], a
	ld de, wMoves
	predef WriteMonMoves
	hlcoord 1, 5
	ld de, wMoves
	ld b, NUM_MOVES
.asm_fef36
	ld a, [de]
	inc de
	and a
	jr z, .asm_fef5b
	push de
	push bc
	push hl
	ld [wTempByteValue], a
	ld de, wTempByteValue
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	inc hl
	call GetMoveName
	call PlaceString
	pop hl
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	pop bc
	pop de
	dec b
	jr nz, .asm_fef36
.asm_fef5b
	pop af
	ld [wCurPartySpecies], a
	ret

; SUGGESTED NAME: BoxMonDebug_EditMoves
; Starts editing at move slot 1 (confidence: high)
Func_fef60:
	ld de, wMoves
	hlcoord 0, 5
	ld b, 1
	; fallthrough
; SUGGESTED NAME: BoxMonDebug_MoveInputLoop
; Input loop for the move slots (A/B change move, Up/Down slot, Start sends to box) (confidence: high)
Func_fef68:
	call Func_fefc5
.asm_fef6b
	call DelayFrame
	push de
	push bc
	call JoypadLowSensitivity
	pop bc
	pop de
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_fef92
	bit BIT_B_BUTTON, a
	jp nz, Func_fef9e
	bit BIT_START, a
	jp nz, Func_ff12c
	bit BIT_D_UP, a
	jp nz, Func_fefa8
	bit BIT_D_DOWN, a
	jp nz, Func_fefb5
	jr .asm_fef6b

; SUGGESTED NAME: BoxMonDebug_NextMove
; Moves the current move slot's move ID up by one, wrapping to 1 (confidence: high)
Func_fef92:
	ld a, [de]
	inc a
	ld [de], a
	cp NUM_ATTACKS
	jr c, Func_fef68
	ld a, 1
	ld [de], a
	jr Func_fef68

; SUGGESTED NAME: BoxMonDebug_PrevMove
; Moves the current move slot's move ID down by one, wrapping to the last move (confidence: high)
Func_fef9e:
	ld a, [de]
	dec a
	ld [de], a
	jr nz, Func_fef68
	ld a, NUM_ATTACKS - 1
	ld [de], a
	jr Func_fef68

; SUGGESTED NAME: BoxMonDebug_MoveCursorUp
; Moves up one move slot, or back to the level row from slot 1 (confidence: high)
Func_fefa8:
	dec de
	dec b
	jp z, Func_fee96
	push bc
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	pop bc
	jr Func_fef68

; SUGGESTED NAME: BoxMonDebug_MoveCursorDown
; Moves down one move slot, or on to the DV/stat exp rows after slot 4 (confidence: high)
Func_fefb5:
	inc de
	inc b
	ld a, b
	cp 5
	jp z, Func_ff03b
	push bc
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	pop bc
	jr Func_fef68

; SUGGESTED NAME: BoxMonDebug_PrintMoveSlot
; Draws the cursor and prints the current slot's move number and name (confidence: high)
Func_fefc5:
	push hl
	push de
	push bc
	push hl
	push de
	ld bc, hSpriteMapYCoord
	add hl, bc
	lb bc, 2, 11
	call ClearScreenArea
	pop de
	pop hl
	push hl
	ld [hl], '▶'
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	ld [hl], ' '
	ld bc, SCREEN_WIDTH * 4
	add hl, bc
	ld [hl], ' '
	pop hl
	inc hl
	ld a, [de]
	ld de, wTempByteValue
	ld [de], a
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	ld a, [wTempByteValue]
	and a
	jr z, .asm_ff002
	call Func_ff006
	inc hl
	call GetMoveName
	call PlaceString
.asm_ff002
	pop bc
	pop de
	pop hl
	ret

; SUGGESTED NAME: BoxMonDebug_MarkUnlearnableMove
; Draws a cross by the move if Func_3b079 says the species can't learn it (confidence: medium)
Func_ff006:
	ld a, [wCurPartySpecies]
	push af
	ld a, [wPokedexNum]
	push af
	push hl
	ld a, [wCurPartySpecies]
	ld [wPokedexNum], a
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wCurPartySpecies], a
	pop hl
	pop af
	ld [wPokedexNum], a
	push hl
	callfar Func_3b079
	pop hl
	jr c, .asm_ff036
	ld [hl], '×'
.asm_ff036
	pop af
	ld [wCurPartySpecies], a
	ret

; SUGGESTED NAME: BoxMonDebug_EditDVsAndStatExp
; Starts editing the three DV/stat exp bytes kept in wEnemyMonOT (confidence: high)
Func_ff03b:
	ld de, wEnemyMonOT
	hlcoord 0, 13
	ld b, 1
	; fallthrough
; SUGGESTED NAME: BoxMonDebug_DVInputLoop
; Input loop for the DV/stat exp rows (A/B change value, Up/Down row, Start sends) (confidence: high)
Func_ff043:
	call Func_ff09e
.asm_ff046
	call DelayFrame
	push de
	push bc
	call JoypadLowSensitivity
	pop bc
	pop de
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_ff06d
	bit BIT_B_BUTTON, a
	jp nz, Func_ff072
	bit BIT_START, a
	jp nz, Func_ff12c
	bit BIT_D_UP, a
	jp nz, Func_ff077
	bit BIT_D_DOWN, a
	jp nz, Func_ff08f
	jr .asm_ff046

; SUGGESTED NAME: BoxMonDebug_IncDVValue
; Raises the selected DV/stat exp byte by one (no wrap check) (confidence: high)
Func_ff06d:
	ld a, [de]
	inc a
	ld [de], a
	jr Func_ff043

; SUGGESTED NAME: BoxMonDebug_DecDVValue
; Lowers the selected DV/stat exp byte by one (no wrap check) (confidence: high)
Func_ff072:
	ld a, [de]
	dec a
	ld [de], a
	jr Func_ff043

; SUGGESTED NAME: BoxMonDebug_DVCursorUp
; Moves up one DV/stat exp row, or back to move slot 4 from the first row (confidence: high)
Func_ff077:
	dec de
	dec b
	jp z, Func_ff084
	push bc
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	pop bc
	jr Func_ff043

; SUGGESTED NAME: BoxMonDebug_BackToLastMove
; Goes back to editing move slot 4 (confidence: high)
Func_ff084:
	ld de, wMoves + 3
	hlcoord 0, 11
	ld b, NUM_MOVES
	jp Func_fef68

; SUGGESTED NAME: BoxMonDebug_DVCursorDown
; Moves down one DV/stat exp row (stops at row 3) (confidence: high)
Func_ff08f:
	ld a, b
	cp 3
	jr z, Func_ff043
	inc b
	inc de
	push bc
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	pop bc
	jr Func_ff043

; SUGGESTED NAME: BoxMonDebug_PrintDVRow
; Draws the cursor, prints the selected DV/stat exp byte and updates the stat preview (confidence: high)
Func_ff09e:
	push hl
	push de
	push bc
	push hl
	ld [hl], '▶'
	ld bc, hMovingBGTilesCounter1
	add hl, bc
	ld [hl], ' '
	ld bc, SCREEN_WIDTH * 4
	add hl, bc
	ld [hl], ' '
	pop hl
	inc hl
	ld a, [de]
	ld de, wTempByteValue
	ld [de], a
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	call Func_ff0c4
	pop bc
	pop de
	pop hl
	ret

; SUGGESTED NAME: BoxMonDebug_PrintStatPreview
; Works out stats from the chosen level, DVs and stat exp and prints the five stats (confidence: high)
Func_ff0c4:
	hlcoord 12, 0
	lb bc, 18, 8
	call ClearScreenArea
	hlcoord 13, 1
	ld de, Text_ff113
	call PlaceString
	ld b, 10
	ld hl, wLoadedMonHPExp
	ld a, [wEnemyMonOT + 2]
.asm_ff0de
	ld [hli], a
	dec b
	jr nz, .asm_ff0de
	ld a, [wEnemyMonOT]
	ld [hli], a
	ld a, [wEnemyMonOT + 1]
	ld [hl], a
	ld hl, wLoadedMonExp + 2
	ld de, wLoadedMonStats
	ld b, 1
	call CalcStats
	hlcoord 17, 1
	ld de, wLoadedMonStats
	ld b, 5
.asm_ff0fd
	push bc
	push de
	push hl
	lb bc, LEADING_ZEROES | 2, 3
	call PrintNumber
	pop hl
	ld bc, SCREEN_WIDTH * 2
	add hl, bc
	pop de
	inc de
	inc de
	pop bc
	dec b
	jr nz, .asm_ff0fd
	ret

; SUGGESTED NAME: BoxMonDebugStatNamesText
; Stat labels (HP, Attack, Defense, Speed, Special) for the stat preview (confidence: high)
Text_ff113:
	db   "たいりき"  ; hp
	next "こうげき"  ; attack
	next "ぼうぎょ"  ; defense
	next "すばやさ"  ; speed
	next "とくしゅ@" ; special

; SUGGESTED NAME: BoxMonDebug_SendToBox
; Builds wEnemyMon from the chosen species/level/moves/DVs and sends it to the box (confidence: high)
Func_ff12c:
	ld a, [wCurEnemyLevel]
	ld [wEnemyMonLevel], a
	ld a, [wCurPartySpecies]
	ld [wPokedexNum], a
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	call GetMonHeader
	ld hl, wEnemyMon
	ld a, [wCurPartySpecies]
	ld [hli], a
	ld a, [wLoadedMonStats]
	ld [hli], a
	ld a, [wLoadedMonStats + 1]
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld a, [wMonHTypes]
	ld [hli], a
	ld a, [wMonHType2]
	ld [hli], a
	ld a, [wMonHCatchRate]
	ld [hli], a
	ld a, [wMoves]
	ld [hli], a
	ld a, [wMoves + 1]
	ld [hli], a
	ld a, [wMoves + 2]
	ld [hli], a
	ld a, [wMoves + 3]
	ld [hl], a
	ld hl, wEnemyMonPP
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [wEnemyMonOT]
	ld [wEnemyMonDVs], a
	ld a, [wEnemyMonOT + 1]
	ld [wEnemyMonDVs + 1], a
	callfar SendNewMonToBox
	ld b, 10
	ld hl, wBoxMon1HPExp
	ld a, [wEnemyMonOT + 2]
.asm_ff19e
	ld [hli], a
	dec b
	jr nz, .asm_ff19e
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	pop af
	ld [wLetterPrintingDelayFlags], a
	jr Func_ff1b3
; SUGGESTED NAME: BoxMonDebug_BoxFull
; Prints "The BOX is full!" and exits (confidence: high)
Func_ff1ad:
	ld hl, Text_ff1b4
	call PrintText
; SUGGESTED NAME: BoxMonDebug_Exit
; Shared ret for the box mon debug editor (confidence: medium)
Func_ff1b3:
	ret

; SUGGESTED NAME: BoxFullDebugText
; Text pointer for "The BOX is full!" (confidence: high)
Text_ff1b4:
	text_far _BoxFullDebugText
	text_end

; SUGGESTED NAME: FillBoxesDebugMenu
; Unused debug tool: clears all boxes, then fills them with every species at a chosen level (confidence: high)
Func_ff1b9:
	ld a, 1
	ldh [hJoy7], a
	ld a, 2
	ld [wCurEnemyLevel], a
	ld hl, Text_ff290
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, Func_ff286
	ld hl, Text_ff28f
	call PrintText
	callfar EmptyAllSRAMBoxes
	ld hl, wBoxCount
	xor a
	ld [hli], a
	dec a
	ld [hl], a
	; fallthrough
; SUGGESTED NAME: FillBoxesDebug_SelectLevel
; Shows the level picker (2-MAX_LEVEL) and handles A/B to change it and Start to fill (confidence: high)
Func_ff1e7:
	hlcoord 2, 13
	ld [hl], 'ﾞ'
	hlcoord 1, 14
	ld [hl], 'レ'
	inc hl
	ld [hl], 'へ'
	inc hl
	ld [hl], 'ル'
	inc hl
	inc hl
	ld de, wCurEnemyLevel
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	bit BIT_A_BUTTON, a
	jp nz, Func_ff21b
	bit BIT_B_BUTTON, a
	jp nz, Func_ff227
	bit BIT_START, a
	jp nz, Func_ff236
	jr Func_ff1e7

; SUGGESTED NAME: FillBoxesDebug_IncLevel
; Raises the fill level by one, wrapping to 2 after MAX_LEVEL (confidence: high)
Func_ff21b:
	ld a, [wCurEnemyLevel]
	inc a
	cp MAX_LEVEL + 1
	jr c, Func_ff231
	ld a, 2
	jr Func_ff231
; SUGGESTED NAME: FillBoxesDebug_DecLevel
; Lowers the fill level by one, wrapping to MAX_LEVEL below 2 (confidence: high)
Func_ff227:
	ld a, [wCurEnemyLevel]
	dec a
	cp 2
	jr nc, Func_ff231
	ld a, MAX_LEVEL
; SUGGESTED NAME: FillBoxesDebug_SetLevel
; Stores the fill level in wCurEnemyLevel and redraws the picker (confidence: high)
Func_ff231:
	ld [wCurEnemyLevel], a
	jr Func_ff1e7

; SUGGESTED NAME: FillBoxesDebug_FillBoxes
; Sends Pokedex #1 to NUM_POKEMON to boxes, 30 per box, saving each box as it goes (confidence: high)
Func_ff236:
	ld c, 0
	ld d, 0
.asm_ff23a
	push bc
	push de
	call Func_ff295
	ld hl, wChangeMonPicEnemyTurnSpecies
	inc [hl]
	pop de
	pop bc
	ld b, 30
.asm_ff247
	inc c
	push bc
	push de
	ld a, c
	ld [wPokedexNum], a
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wEnemyMonSpecies2], a
	ld [wCurPartySpecies], a
	xor a
	ld [wEnemyBattleStatus3], a
	callfar LoadEnemyMonData
	ld a, [wEnemyMonSpecies2]
	ld [wCurPartySpecies], a
	callfar SendNewMonToBox
	pop de
	pop bc
	ld a, c
	cp NUM_POKEMON
	jr z, Func_ff286
	dec b
	jr nz, .asm_ff247
	inc d
	jr .asm_ff23a
	; fallthrough
; SUGGESTED NAME: FillBoxesDebug_Exit
; Clears hJoy7, sets wDoNotWaitForButtonPressAfterDisplayingText and returns (confidence: high)
Func_ff286:
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	xor a
	ldh [hJoy7], a
	ret

; SUGGESTED NAME: FillBoxesDebugEmptyText
; Empty text printed after the clear prompt is confirmed (confidence: medium)
Text_ff28f:
	text_end

; SUGGESTED NAME: BoxWillBeClearedText
; Text pointer for "The BOX will be cleared." confirm prompt (confidence: high)
Text_ff290:
	text_far _BoxWillBeClearedText
	text_end

; SUGGESTED NAME: FillBoxesDebug_SwitchBox
; Saves wBox data to the current SRAM box, loads box d, and saves the game (confidence: high)
Func_ff295:
	push de
	ld a, SFX_SAVE
	call PlaySoundWaitForCurrent
	call WaitForSoundToFinish
	call Func_ff2d1
	ld e, l
	ld d, h
	ld hl, wBoxCount
	call Func_ff2f3
	pop de
	ld a, d
	set 7, a
	ld [wCurrentBoxNum], a
	push de
	call Func_ff2d1
	ld de, wBoxCount
	call Func_ff2f3
	ld a, [wLetterPrintingDelayFlags]
	push af
	ld a, 1
	ld [wLetterPrintingDelayFlags], a
	callfar SaveGameData
	pop af
	ld [wLetterPrintingDelayFlags], a
	pop de
	ret

; SUGGESTED NAME: FillBoxesDebug_GetBoxSRAMAddress
; Returns hl = SRAM address and b = SRAM bank of box [wCurrentBoxNum] (confidence: high)
Func_ff2d1:
	ld hl, Data_ff2eb
	ld a, [wCurrentBoxNum]
	and %01111111
	cp 4
	ld b, 2
	jr c, .asm_ff2e2
	inc b
	and 3
.asm_ff2e2
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

; SUGGESTED NAME: FillBoxesDebugBoxAddresses
; SRAM addresses of the four boxes in an SRAM bank (confidence: high)
Data_ff2eb:
	dw sBox1
	dw sBox2
	dw sBox3
	dw sBox4

; SUGGESTED NAME: FillBoxesDebug_CopyBox
; Copies a box between wBox and SRAM, empties the source box and updates the bank checksum (confidence: high)
Func_ff2f3:
	push hl
	call Func_ff316
	ld a, b
	ld [MBC1SRamBank], a
	ld bc, sBox2 - sBox1
	call CopyData
	pop hl
	xor a
	ld [hli], a
	dec a
	ld [hl], a
	ld hl, sBox1
	ld bc, sBox5 - sBox1 + 1
	call Func_ff32a
	ld [sBox5], a
	call Func_ff321
	ret

; SUGGESTED NAME: DebugEnableSRAM
; Enables SRAM and selects RAM banking mode (same as EnableSRAM) (confidence: high)
Func_ff316:
	ld a, 1
	ld [MBC1SRamBankingMode], a
	ld a, SRAM_ENABLE
	ld [MBC1SRamEnable], a
	ret

; SUGGESTED NAME: DebugDisableSRAM
; Disables SRAM and resets banking mode (same as DisableSRAM) (confidence: high)
Func_ff321:
	ld a, 0
	ld [MBC1SRamBankingMode], a
	ld [MBC1SRamEnable], a
	ret

; SUGGESTED NAME: DebugCalcBoxBankChecksum
; Returns a = complemented 8-bit sum of bc bytes at hl (SRAM box bank checksum) (confidence: high)
Func_ff32a:
	ld d, 0
.asm_ff32c
	ld a, [hli]
	add d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, .asm_ff32c
	ld a, d
	cpl
	ret
ELSE
	ret
ENDC
