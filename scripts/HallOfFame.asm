HallOfFame_Script:
	call EnableAutoTextBoxDrawing
	ld hl, HallOfFame_ScriptPointers
	ld a, [wHallOfFameCurScript]
	jp CallFunctionInTable

HallofFameRoomClearScripts: ; unreferenced
	xor a
	ld [wJoyIgnore], a
	ld [wHallOfFameCurScript], a
	ret

HallOfFame_ScriptPointers:
	def_script_pointers
	dw_const HallOfFameDefaultScript,            SCRIPT_HALLOFFAME_DEFAULT
	dw_const HallOfFameOakCongratulationsScript, SCRIPT_HALLOFFAME_OAK_CONGRATULATIONS
	dw_const HallOfFameResetEventsAndSaveScript, SCRIPT_HALLOFFAME_RESET_EVENTS_AND_SAVE
	dw_const HallOfFameNoopScript,               SCRIPT_HALLOFFAME_NOOP

HallOfFameNoopScript:
	ret

HallOfFameResetEventsAndSaveScript:
	call Delay3
	ld a, [wLetterPrintingDelayFlags]
	push af
	xor a
	ld [wJoyIgnore], a
	predef HallOfFamePC
	pop af
	ld [wLetterPrintingDelayFlags], a
	ld hl, wStatusFlags7
	res BIT_NO_MAP_MUSIC, [hl]
	inc hl
	set BIT_TEST_BATTLE, [hl] ; debug, unused?
	xor a ; SCRIPT_*_DEFAULT
	ld hl, wLoreleisRoomCurScript
	ld [hli], a ; wLoreleisRoomCurScript
	ld [hli], a ; wBrunosRoomCurScript
	ld [hl], a ; wAgathasRoomCurScript
	ld [wLancesRoomCurScript], a
	ld [wHallOfFameCurScript], a
	; Elite 4 events
	ResetEventRange INDIGO_PLATEAU_EVENTS_START, INDIGO_PLATEAU_EVENTS_END, 1
	ld a, 1
	ld [wGameStage], a
	xor a
	ld [wHallOfFameCurScript], a
	ld a, PALLET_TOWN
	ld [wLastBlackoutMap], a
	farcall SaveGameData
	ld b, 5
.delayLoop
	ld c, 600 / 5
	call DelayFrames
	dec b
	jr nz, .delayLoop
	call WaitForTextScrollButtonPress
	jp Init

HallOfFameDefaultScript:
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, HallOfFameEntryMovement
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, SCRIPT_HALLOFFAME_OAK_CONGRATULATIONS
	ld [wHallOfFameCurScript], a
	ret

HallOfFameEntryMovement:
	db PAD_UP, 5
	db -1 ; end

HallOfFameOakCongratulationsScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, HALLOFFAME_OAK
	ldh [hSpriteIndex], a
	call SetSpriteMovementBytesToFF
	ld a, SPRITE_FACING_LEFT
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	call Delay3
	xor a
	ld [wJoyIgnore], a
	inc a ; PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jp nz, .RematchText
.OriginalText
	ld a, TEXT_HALLOFFAME_OAK
	jr .continue
.RematchText
	ld a, TEXT_HALLOFFAME_REMATCH_OAK
.continue
	ldh [hTextID], a
	call DisplayTextID
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, HS_CERULEAN_CAVE_GUY
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld a, HS_OAKS_LAB_OAK_1
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld a, HS_ROUTE_1_OAK
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ld a, HS_CHAMPIONS_ROOM_OAK
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld a, HS_INDIGO_PLATEU_LOBBY_CLERK_HS
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ld a, HS_LORELEISROOM_LORELEI
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld a, HS_LORELEISROOM_LORELEI_REMATCH
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ld a, HS_BRUNOSROOM_BRUNO
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld a, HS_BRUNOSROOM_BRUNO_REMATCH
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ld a, HS_AGATHASROOM_AGATHA
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld a, HS_AGATHASROOM_AGATHA_REMATCH
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ld a, HS_LANCESROOM_LANCE
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld a, HS_LANCESROOM_LANCE_REMATCH
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ld a, [wRivalStarter]
	cp FIRST_RIVAL_COUNTER_STARTER
	jr nc, .noEeveelution ; Pick Starter mode: the rival has a counter starter
	cp RIVAL_STARTER_FLAREON
	jr z, .UnhideFlareon
	cp RIVAL_STARTER_VAPOREON
	jr z, .UnhideVaporeon
	ld a, HS_CHAMPIONS_ROOM_JOLTEON
	jr .done
.UnhideFlareon
	ld a, HS_CHAMPIONS_ROOM_FLAREON
	jr .done
.UnhideVaporeon
	ld a, HS_CHAMPIONS_ROOM_VAPOREON
.done
	ld [wToggleableObjectIndex], a
	predef ShowObject
.noEeveelution
	ld a, SCRIPT_HALLOFFAME_RESET_EVENTS_AND_SAVE
	ld [wHallOfFameCurScript], a
	ret

HallOfFame_TextPointers:
	def_text_pointers
	dw_const HallOfFameOakText, TEXT_HALLOFFAME_OAK
	dw_const HallOfFameRematchOakText, TEXT_HALLOFFAME_REMATCH_OAK

HallOfFameOakText:
	text_far _HallOfFameOakText
	text_end

HallOfFameRematchOakText:
	text_far _HallOfFameRematchOakText
	text_end
