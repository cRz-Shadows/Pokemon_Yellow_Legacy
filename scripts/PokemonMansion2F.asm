PokemonMansion2F_Script:
	call Mansion2CheckReplaceSwitchDoorBlocks
	call EnableAutoTextBoxDrawing
	ld hl, Mansion2TrainerHeaders
	ld de, PokemonMansion2F_ScriptPointers
	ld a, [wPokemonMansion2FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wPokemonMansion2FCurScript], a
	ret

Mansion2CheckReplaceSwitchDoorBlocks:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	ret z
	CheckEvent EVENT_MANSION_SWITCH_ON
	jr nz, .switchTurnedOn
	ld a, $e
	lb bc, 2, 4
	call Mansion2ReplaceBlock
	ld a, $54
	lb bc, 4, 9
	call Mansion2ReplaceBlock
	ld a, $5f
	lb bc, 11, 3
	call Mansion2ReplaceBlock
	ret
.switchTurnedOn
	ld a, $5f
	lb bc, 2, 4
	call Mansion2ReplaceBlock
	ld a, $e
	lb bc, 4, 9
	call Mansion2ReplaceBlock
	ld a, $e
	lb bc, 11, 3
	call Mansion2ReplaceBlock
	ret

Mansion2ReplaceBlock:
	ld [wNewTileBlockID], a
	predef_jump ReplaceTileBlock

Mansion2Script_Switches::
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ret nz
	xor a
	ldh [hJoyHeld], a
	ld a, TEXT_POKEMONMANSION2F_SWITCH
	ldh [hTextID], a
	jp DisplayTextID

PokemonMansion2F_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_POKEMONMANSION2F_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_POKEMONMANSION2F_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_POKEMONMANSION2F_END_BATTLE
	dw_const PokemonMansion2FOakPostBattleScript,   SCRIPT_POKEMONMANSION2F_POST_BATTLE

PokemonMansion2F_TextPointers:
	def_text_pointers
	dw_const PokemonMansion2FSuperNerdText, TEXT_POKEMONMANSION2F_SUPER_NERD
	dw_const PokemonMansion2FOakText,		TEXT_POKEMONMANSION2F_OAK
	dw_const PickUpItemText,                TEXT_POKEMONMANSION2F_CALCIUM
	dw_const PokemonMansion2FDiary1Text,    TEXT_POKEMONMANSION2F_DIARY1
	dw_const PokemonMansion2FDiary2Text,    TEXT_POKEMONMANSION2F_DIARY2
	dw_const PokemonMansion2FSwitchText,    TEXT_POKEMONMANSION2F_SWITCH
	dw_const PokemonMansion2F_OakPostBattleText, TEXT_POKEMONMANSION2F_OAK_POST_BATTLE
	dw_const PokemonMansion2F_MewText, 		TEXT_POKEMONMANSION2F_MEW

Mansion2TrainerHeaders:
	def_trainers
Mansion2TrainerHeader0:
	trainer EVENT_BEAT_MANSION_2_TRAINER_0, 0, PokemonMansion2FSuperNerdBattleText, PokemonMansion2FSuperNerdEndBattleText, PokemonMansion2FSuperNerdAfterBattleText
	db -1 ; end

PokemonMansion2FSuperNerdText:
	text_asm
	ld hl, Mansion2TrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

PokemonMansion2FSuperNerdBattleText:
	text_far _PokemonMansion2FSuperNerdBattleText
	text_end

PokemonMansion2FSuperNerdEndBattleText:
	text_far _PokemonMansion2FSuperNerdEndBattleText
	text_end

PokemonMansion2FSuperNerdAfterBattleText:
	text_far _PokemonMansion2FSuperNerdAfterBattleText
	text_end

PokemonMansion2FDiary1Text:
	text_far _PokemonMansion2FDiary1Text
	text_end

PokemonMansion2FDiary2Text:
	text_far _PokemonMansion2FDiary2Text
	text_end

PokemonMansion2FSwitchText:
	text_asm
	ld hl, .Text
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .not_pressed
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, wCurrentMapScriptFlags
	set BIT_CUR_MAP_LOADED_1, [hl]
	ld hl, .PressedText
	call PrintText
	ld a, SFX_GO_INSIDE
	call PlaySound
	CheckAndSetEvent EVENT_MANSION_SWITCH_ON
	jr z, .done
	ResetEventReuseHL EVENT_MANSION_SWITCH_ON
	jr .done
.not_pressed
	ld hl, .NotPressed
	call PrintText
.done
	jp TextScriptEnd

.Text:
	text_far _PokemonMansion2FSwitchText
	text_end

.PressedText:
	text_far _PokemonMansion2FSwitchPressedText
	text_end

.NotPressed:
	text_far _PokemonMansion2FSwitchNotPressedText
	text_end

PokemonMansion2FOakText:
	text_asm
	ld hl, PokemonMansion2F_OakBeforeBattleText1
	call PrintText

	ld a, SPRITE_FACING_RIGHT
	ld [wSprite02StateData1FacingDirection], a
	call Delay3

	ld hl, PokemonMansion2F_OakBeforeBattleText2
	call PrintText

	call GetNPCFacePlayerDirection
	ld [wSprite02StateData1FacingDirection], a
	call Delay3

	ld hl, PokemonMansion2F_OakBeforeBattleText3
	call PrintText

	ld a, [wPlayerDirection]
	bit PLAYER_DIR_BIT_DOWN, a
	jr z, .FaceUpInstead
	ld a, SPRITE_FACING_DOWN
	jr .Turn
.FaceUpInstead
	ld a, SPRITE_FACING_UP
.Turn
	ld [wSprite02StateData1FacingDirection], a
	call Delay3

	ld hl, PokemonMansion2F_OakBeforeBattleText4
	call PrintText

	ld a, SPRITE_FACING_RIGHT
	ld [wSprite02StateData1FacingDirection], a
	call Delay3

	ld hl, PokemonMansion2F_OakBeforeBattleText5
	call PrintText

	call GetNPCFacePlayerDirection
	ld [wSprite02StateData1FacingDirection], a
	call Delay3

	ld hl, PokemonMansion2F_OakBeforeBattleText6
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .refused
	
	ld c, BANK(Music_MeetMaleTrainer)
	ld a, MUSIC_MEET_MALE_TRAINER
	call PlayMusic

	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	
	call Delay3
	ld a, OPP_PROF_OAK
	ld [wCurOpponent], a

	ld a, $2
	ld [wTrainerNo], a

	ld a, $3
	ld [wPokemonMansion2FCurScript], a
	ld [wCurMapScript], a	;joenote - also set the value for current map script or you will have a bad time
	
	ld hl, PokemonMansion2F_OakDefeatedText
	ld de, PokemonMansion2F_OakWonText
	call SaveEndBattleTextPointers
	ld hl, PokemonMansion2F_OakRealChallengeBattleText
	call PrintText
	jp .done
.refused
	ld hl, PokemonMansion2F_OakRefusedBattleText
	call PrintText
.done
	jp TextScriptEnd

PokemonMansion2FOakPostBattleScript:
	ld a, [wIsInBattle]	;if wIsInBattle is -1, then the battle was lost
	inc a	;if A holds -1, it will increment to 0 and set the z flag (but not the c flag, dec and inc cannot affect it).
	jr z, .skip	;Kick out if the player lost.

	ld a, TEXT_POKEMONMANSION2F_OAK_POST_BATTLE
	ldh [hTextID], a
	call DisplayTextID

	call GBFadeOutToBlack
	SetEvent EVENT_BEAT_POKEMONMANSION2F_OAK
	ld a, HS_OAKS_LAB_OAK_1
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, HS_POKEMON_MANSION_2F_OAK
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_POKEMON_MANSION_B1F_MEW
	ld [wMissableObjectIndex], a
	predef ShowObject
	call UpdateSprites
	call Delay3
	call GBFadeInFromBlack

	ld a, TEXT_POKEMONMANSION2F_MEW
	ldh [hTextID], a
	call DisplayTextID
.skip
	ld a, $0
	ld [wPokemonMansion2FCurScript], a
	ld [wCurMapScript], a	;joenote - also set the value for current map script or you will have a bad time
	ret

PokemonMansion2F_OakBeforeBattleText1:
	text_far _PokemonMansion2F_OakBeforeBattleText1
	text_end

PokemonMansion2F_OakBeforeBattleText2:
	text_far _PokemonMansion2F_OakBeforeBattleText2
	text_end

PokemonMansion2F_OakBeforeBattleText3:
	text_far _PokemonMansion2F_OakBeforeBattleText3
	text_end

PokemonMansion2F_OakBeforeBattleText4:
	text_far _PokemonMansion2F_OakBeforeBattleText4
	text_end

PokemonMansion2F_OakBeforeBattleText5:
	text_far _PokemonMansion2F_OakBeforeBattleText5
	text_end

PokemonMansion2F_OakBeforeBattleText6:
	text_far _PokemonMansion2F_OakBeforeBattleText6
	text_end

PokemonMansion2F_OakRealChallengeBattleText:
	text_far _PokemonMansion2F_OakRealChallengeBattleText
	text_end

PokemonMansion2F_OakRefusedBattleText:
	text_far _PokemonMansion2F_OakRefusedBattleText
	text_end

PokemonMansion2F_OakDefeatedText:
	text_far _PokemonMansion2F_OakDefeatedText
	text_end

PokemonMansion2F_OakWonText:
	text_far _PokemonMansion2F_OakWonText
	text_end

PokemonMansion2F_OakPostBattleText:
	text_far _PokemonMansion2F_OakPostBattleText
	text_end

PokemonMansion2F_MewText:
	text_far _PokemonMansion2F_MewText
	text_end

GetNPCFacePlayerDirection:
		ld a, [wPlayerDirection]
		bit PLAYER_DIR_BIT_UP, a
		jr z, .notFacingDown
		ld c, SPRITE_FACING_DOWN
		jr .facingDirectionDetermined
	.notFacingDown
		bit PLAYER_DIR_BIT_DOWN, a
		jr z, .notFacingUp
		ld c, SPRITE_FACING_UP
		jr .facingDirectionDetermined
	.notFacingUp
		bit PLAYER_DIR_BIT_LEFT, a
		jr z, .notFacingRight
		ld c, SPRITE_FACING_RIGHT
		jr .facingDirectionDetermined
	.notFacingRight
		ld c, SPRITE_FACING_LEFT
	.facingDirectionDetermined
		ld a, c
		ret