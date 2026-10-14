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
	ld bc, -SCREEN_WIDTH
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
	ld bc, -SCREEN_WIDTH * 2
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
	ld bc, -SCREEN_WIDTH * 2
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
	cp NUM_TRAINERS + 1
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
	cp NUM_TRAINERS + 1
	jr nc, .asm_feba6
	and a
	jp nz, Func_feb35
.asm_feba6
	ld b, NUM_TRAINERS
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

ELSE
	ret
ENDC
