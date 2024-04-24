ChampionsRoom_Script:
	call EnableAutoTextBoxDrawing
	ld hl, ChampionsRoom_ScriptPointers
	ld a, [wChampionsRoomCurScript]
	call CallFunctionInTable
	ret

ResetRivalScript:
	xor a ; SCENE_CHAMPIONSROOM_DEFAULT
	ld [wJoyIgnore], a
	ld [wChampionsRoomCurScript], a
	ret

ChampionsRoom_ScriptPointers:
	def_script_pointers
	dw_const ChampionsRoomDefaultScript,                  SCRIPT_CHAMPIONSROOM_DEFAULT
	dw_const ChampionsRoomPlayerEntersScript,             SCRIPT_CHAMPIONSROOM_PLAYER_ENTERS
	dw_const ChampionsRoomRivalReadyToBattleScript,       SCRIPT_CHAMPIONSROOM_RIVAL_READY_TO_BATTLE
	dw_const ChampionsRoomRivalDefeatedScript,            SCRIPT_CHAMPIONSROOM_RIVAL_DEFEATED
	dw_const ChampionsRoomOakArrivesScript,               SCRIPT_CHAMPIONSROOM_OAK_ARRIVES
	dw_const ChampionsRoomOakCongratulatesPlayerScript,   SCRIPT_CHAMPIONSROOM_OAK_CONGRATULATES_PLAYER
	dw_const ChampionsRoomOakDisappointedWithRivalScript, SCRIPT_CHAMPIONSROOM_OAK_DISAPPOINTED_WITH_RIVAL
	dw_const ChampionsRoomOakComeWithMeScript,            SCRIPT_CHAMPIONSROOM_OAK_COME_WITH_ME
	dw_const ChampionsRoomOakExitsScript,                 SCRIPT_CHAMPIONSROOM_OAK_EXITS
	dw_const ChampionsRoomPlayerFollowsOakScript,         SCRIPT_CHAMPIONSROOM_PLAYER_FOLLOWS_OAK
	dw_const ChampionsRoomCleanupScript,                  SCRIPT_CHAMPIONSROOM_CLEANUP_SCRIPT

ChampionsRoomDefaultScript:
	ret

ChampionsRoomPlayerEntersScript:
	ld a, A_BUTTON | B_BUTTON | SELECT | START | D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, RivalEntrance_RLEMovement
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, SCRIPT_CHAMPIONSROOM_RIVAL_READY_TO_BATTLE
	ld [wChampionsRoomCurScript], a
	ret

RivalEntrance_RLEMovement:
	db D_UP, 1
	db D_RIGHT, 1
	db D_UP, 3
	db -1 ; end

ChampionsRoomRivalReadyToBattleScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	call Delay3
	xor a
	ld [wJoyIgnore], a
	ld hl, wOptions
	res 7, [hl]  ; Turn on battle animations to make the battle feel more epic.
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, .ChampionRematchBattle
	ld a, TEXT_CHAMPIONSROOM_RIVAL
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	call Delay3
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, RivalDefeatedText
	ld de, RivalVictoryText
	call SaveEndBattleTextPointers
	ld a, OPP_RIVAL3
	ld [wCurOpponent], a

	; select which team to use during the encounter
	ld a, [wRivalStarter]
	add $0 ; Wow GameFreak
	ld [wTrainerNo], a
.done
	xor a
	ldh [hJoyHeld], a
	ld a, SCRIPT_CHAMPIONSROOM_RIVAL_DEFEATED
	ld [wChampionsRoomCurScript], a
	ret
.ChampionRematchBattle
	ld a, TEXT_CHAMPIONSROOM_RIVAL_REMATCH_INTRO
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	call Delay3
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, RivalRematchDefeatedText
	ld de, RivalRematchVictoryText
	call SaveEndBattleTextPointers
	ld a, OPP_RIVAL3
	ld [wCurOpponent], a

	; select which team to use during the encounter
	ld a, $4
	ld [wTrainerNo], a
	jr .done

ChampionsRoomRivalDefeatedScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, ResetRivalScript
	call UpdateSprites
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, .ChampionRematchDefeated
	SetEvent EVENT_BEAT_CHAMPION_RIVAL
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, TEXT_CHAMPIONSROOM_RIVAL
.continue
	ldh [hSpriteIndexOrTextID], a
	call ChampionsRoom_DisplayTextID_AllowABSelectStart
	ld a, CHAMPIONSROOM_RIVAL
	ldh [hSpriteIndex], a
	call SetSpriteMovementBytesToFF
	ld a, SCRIPT_CHAMPIONSROOM_OAK_ARRIVES
	ld [wChampionsRoomCurScript], a
	ret
.ChampionRematchDefeated
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, TEXT_CHAMPIONSROOM_RIVAL_REMATCH_AFTER_BATTLE
	jr .continue

ChampionsRoomOakArrivesScript:
	farcall Music_Cities1AlternateTempo
	ld a, TEXT_CHAMPIONSROOM_OAK
	ldh [hSpriteIndexOrTextID], a
	call ChampionsRoom_DisplayTextID_AllowABSelectStart
	ld a, CHAMPIONSROOM_OAK
	ldh [hSpriteIndex], a
	call SetSpriteMovementBytesToFF
	ld de, OakEntranceAfterVictoryMovement
	ld a, CHAMPIONSROOM_OAK
	ldh [hSpriteIndex], a
	call MoveSprite
	ld a, HS_CHAMPIONS_ROOM_OAK
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, SCRIPT_CHAMPIONSROOM_OAK_CONGRATULATES_PLAYER
	ld [wChampionsRoomCurScript], a
	ret

OakEntranceAfterVictoryMovement:
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db -1 ; end

ChampionsRoomOakCongratulatesPlayerScript:
	ld a, [wd730]
	bit 0, a
	ret nz
	ld a, PLAYER_DIR_LEFT
	ld [wPlayerMovingDirection], a
	ld a, CHAMPIONSROOM_RIVAL
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_LEFT
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	ld a, CHAMPIONSROOM_OAK
	ldh [hSpriteIndex], a
	xor a ; SPRITE_FACING_DOWN
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, .ChampionRematchDefeated
	ld a, TEXT_CHAMPIONSROOM_OAK_CONGRATULATES_PLAYER
.continue
	ldh [hSpriteIndexOrTextID], a
	call ChampionsRoom_DisplayTextID_AllowABSelectStart
	ld a, SCRIPT_CHAMPIONSROOM_OAK_DISAPPOINTED_WITH_RIVAL
	ld [wChampionsRoomCurScript], a
	ret
.ChampionRematchDefeated
	ld a, TEXT_CHAMPIONSROOM_REMATCH_OAK_CONGRATULATES_PLAYER
	jr .continue

ChampionsRoomOakDisappointedWithRivalScript:
	ld a, CHAMPIONSROOM_OAK
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_RIGHT
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, .ChampionRematchDefeated
	ld a, TEXT_CHAMPIONSROOM_OAK_DISAPPOINTED_WITH_RIVAL
.continue
	ldh [hSpriteIndexOrTextID], a
	call ChampionsRoom_DisplayTextID_AllowABSelectStart
	ld a, SCRIPT_CHAMPIONSROOM_OAK_COME_WITH_ME
	ld [wChampionsRoomCurScript], a
	ret
.ChampionRematchDefeated
	ld a, TEXT_CHAMPIONSROOM_REMATCH_OAK_DISAPPOINTED_WITH_RIVAL
	jr .continue

ChampionsRoomOakComeWithMeScript:
	ld a, CHAMPIONSROOM_OAK
	ldh [hSpriteIndex], a
	xor a ; SPRITE_FACING_DOWN
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, .ChampionRematchDefeated
	ld a, TEXT_CHAMPIONSROOM_OAK_COME_WITH_ME
.continue
	ldh [hSpriteIndexOrTextID], a
	call ChampionsRoom_DisplayTextID_AllowABSelectStart
	ld de, OakExitChampionsRoomMovement
	ld a, CHAMPIONSROOM_OAK
	ldh [hSpriteIndex], a
	call MoveSprite
	ld a, SCRIPT_CHAMPIONSROOM_OAK_EXITS
	ld [wChampionsRoomCurScript], a
	ret
.ChampionRematchDefeated
	ld a, TEXT_CHAMPIONSROOM_REMATCH_OAK_COME_WITH_ME
	jr .continue

OakExitChampionsRoomMovement:
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db -1 ; end

ChampionsRoomOakExitsScript:
	ld a, [wd730]
	bit 0, a
	ret nz
	ld a, HS_CHAMPIONS_ROOM_OAK
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, SCRIPT_CHAMPIONSROOM_PLAYER_FOLLOWS_OAK
	ld [wChampionsRoomCurScript], a
	ret

ChampionsRoomPlayerFollowsOakScript:
	ld a, A_BUTTON | B_BUTTON | SELECT | START | D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, WalkToHallOfFame_RLEMovement
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, SCRIPT_CHAMPIONSROOM_CLEANUP_SCRIPT
	ld [wChampionsRoomCurScript], a
	ret

WalkToHallOfFame_RLEMovement:
	db D_UP, 4
	db D_LEFT, 1
	db -1 ; end

ChampionsRoomCleanupScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, SCRIPT_CHAMPIONSROOM_DEFAULT
	ld [wChampionsRoomCurScript], a
	ret

ChampionsRoom_DisplayTextID_AllowABSelectStart:
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	call DisplayTextID
	ld a, A_BUTTON | B_BUTTON | SELECT | START | D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ret

ChampionsRoom_TextPointers:
	def_text_pointers
	dw_const ChampionsRoomRivalText,                    TEXT_CHAMPIONSROOM_RIVAL
	dw_const ChampionsRoomOakText,                      TEXT_CHAMPIONSROOM_OAK
	dw_const ChampionsRoomJolteonText,                  TEXT_CHAMPIONSROOM_JOLTEON
	dw_const ChampionsRoomFlareonText,                  TEXT_CHAMPIONSROOM_FLAREON
	dw_const ChampionsRoomVaporeonText,                 TEXT_CHAMPIONSROOM_VAPOREON
	dw_const ChampionsRoomOakCongratulatesPlayerText,   TEXT_CHAMPIONSROOM_OAK_CONGRATULATES_PLAYER
	dw_const ChampionsRoomOakDisappointedWithRivalText, TEXT_CHAMPIONSROOM_OAK_DISAPPOINTED_WITH_RIVAL
	dw_const ChampionsRoomOakComeWithMeText,            TEXT_CHAMPIONSROOM_OAK_COME_WITH_ME
	dw_const ChampionsRoomRivalRematchIntroText,		TEXT_CHAMPIONSROOM_RIVAL_REMATCH_INTRO
	dw_const ChampionsRoomRivalRematchAfterBattleText,	TEXT_CHAMPIONSROOM_RIVAL_REMATCH_AFTER_BATTLE
	dw_const ChampionsRoomRematchOakCongratulatesPlayerText,   TEXT_CHAMPIONSROOM_REMATCH_OAK_CONGRATULATES_PLAYER
	dw_const ChampionsRoomRematchOakDisappointedWithRivalText, TEXT_CHAMPIONSROOM_REMATCH_OAK_DISAPPOINTED_WITH_RIVAL
	dw_const ChampionsRoomRematchOakComeWithMeText,            TEXT_CHAMPIONSROOM_REMATCH_OAK_COME_WITH_ME

ChampionsRoomRivalText:
	text_asm
	CheckEvent EVENT_BEAT_CHAMPION_RIVAL
	ld hl, .IntroText
	jr z, .printText
	ld hl, ChampionsRoomRivalAfterBattleText
.printText
	call PrintText
	jp TextScriptEnd

.IntroText:
	text_far _ChampionsRoomRivalIntroText
	text_end

RivalDefeatedText:
	text_far _RivalDefeatedText
	text_end

RivalVictoryText:
	text_far _RivalVictoryText
	text_end

ChampionsRoomRivalAfterBattleText:
	text_far _ChampionsRoomRivalAfterBattleText
	text_end

ChampionsRoomRivalRematchIntroText:
	text_far _ChampionsRoomRivalRematchIntroText
	text_end

RivalRematchDefeatedText:
	text_far _RivalRematchDefeatedText
	text_end

RivalRematchVictoryText:
	text_far _RivalRematchVictoryText
	text_end

ChampionsRoomRivalRematchAfterBattleText:
	text_far _ChampionsRoomRivalRematchAfterBattleText
	text_end

ChampionsRoomOakText:
	text_far _ChampionsRoomOakText
	text_end

ChampionsRoomOakCongratulatesPlayerText:
	text_asm
	ld a, [wPlayerStarter]
	ld [wd11e], a
	call GetMonName
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _ChampionsRoomOakCongratulatesPlayerText
	text_end

ChampionsRoomOakDisappointedWithRivalText:
	text_far _ChampionsRoomOakDisappointedWithRivalText
	text_end

ChampionsRoomOakComeWithMeText:
	text_far _ChampionsRoomOakComeWithMeText
	text_end

ChampionsRoomRematchOakCongratulatesPlayerText:
	text_far _ChampionsRoomRematchOakCongratulatesPlayerText
	text_end

ChampionsRoomRematchOakDisappointedWithRivalText:
	text_far _ChampionsRoomRematchOakDisappointedWithRivalText
	text_end

ChampionsRoomRematchOakComeWithMeText:
	text_far _ChampionsRoomRematchOakComeWithMeText
	text_end

ChampionsRoomJolteonText:
	text_far _ChampionsRoomJolteonText
	text_end

ChampionsRoomFlareonText:
	text_far _ChampionsRoomFlareonText
	text_end

ChampionsRoomVaporeonText:
	text_far _ChampionsRoomVaporeonText
	text_end
