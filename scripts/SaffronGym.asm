SaffronGym_Script:
	ld hl, wCurrentMapScriptFlags
	bit 6, [hl]
	res 6, [hl]
	call nz, .LoadNames
	call EnableAutoTextBoxDrawing
	ld hl, SaffronGymTrainerHeaders
	ld de, SaffronGym_ScriptPointers
	ld a, [wSaffronGymCurScript]
	call ExecuteCurMapScriptInTable
	ld [wSaffronGymCurScript], a
	ret

.LoadNames:
	ld hl, .CityName
	ld de, .LeaderName
	jp LoadGymLeaderAndCityName

.CityName:
	db "SAFFRON CITY@"

.LeaderName:
	db "SABRINA@"

SaffronGymResetScripts:
	xor a ; SCRIPT_SAFFRONGYM_DEFAULT
	ld [wJoyIgnore], a
	ld [wSaffronGymCurScript], a
	ld [wCurMapScript], a
	ret

SaffronGym_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_SAFFRONGYM_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_SAFFRONGYM_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_SAFFRONGYM_END_BATTLE
	dw_const SaffronGymSabrinaPostBattle,           SCRIPT_SAFFRONGYM_SABRINA_POST_BATTLE

SaffronGymSabrinaPostBattle:
	ld a, [wIsInBattle]
	cp $ff
	jp z, SaffronGymResetScripts
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, SabrinaRematchPostBattle
; fallthrough
SaffronGymSabrinaReceiveTM46Script:
	ld a, TEXT_SAFFRONGYM_SABRINA_MARSH_BADGE_INFO
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_SABRINA
	lb bc, TM_PSYWAVE, 1
	call GiveItem
	jr nc, .BagFull
	ld a, TEXT_SAFFRONGYM_SABRINA_RECEIVED_TM46
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_GOT_TM46
	jr .gymVictory
.BagFull
	ld a, TEXT_SAFFRONGYM_SABRINA_TM46_NO_ROOM
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
.gymVictory
	ld hl, wObtainedBadges
	set BIT_MARSHBADGE, [hl]
	ld hl, wBeatGymFlags
	set BIT_MARSHBADGE, [hl]

	; deactivate gym trainers
	SetEventRange EVENT_BEAT_SAFFRON_GYM_TRAINER_0, EVENT_BEAT_SAFFRON_GYM_TRAINER_6

	jp SaffronGymResetScripts

SabrinaRematchPostBattle:
	ld a, TEXT_SAFFRONGYM_REMATCH_POST_BATTLE
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	jp SaffronGymResetScripts

SaffronGym_TextPointers:
	def_text_pointers
	dw_const SaffronGymSabrinaText,               TEXT_SAFFRONGYM_SABRINA
	dw_const SaffronGymChanneler1Text,            TEXT_SAFFRONGYM_CHANNELER1
	dw_const SaffronGymYoungster1Text,            TEXT_SAFFRONGYM_YOUNGSTER1
	dw_const SaffronGymChanneler2Text,            TEXT_SAFFRONGYM_CHANNELER2
	dw_const SaffronGymYoungster2Text,            TEXT_SAFFRONGYM_YOUNGSTER2
	dw_const SaffronGymChanneler3Text,            TEXT_SAFFRONGYM_CHANNELER3
	dw_const SaffronGymYoungster3Text,            TEXT_SAFFRONGYM_YOUNGSTER3
	dw_const SaffronGymYoungster4Text,            TEXT_SAFFRONGYM_YOUNGSTER4
	dw_const SaffronGymGymGuideText,              TEXT_SAFFRONGYM_GYM_GUIDE
	dw_const SaffronGymSabrinaMarshBadgeInfoText, TEXT_SAFFRONGYM_SABRINA_MARSH_BADGE_INFO
	dw_const SaffronGymSabrinaReceivedTM46Text,   TEXT_SAFFRONGYM_SABRINA_RECEIVED_TM46
	dw_const SaffronGymSabrinaTM46NoRoomText,     TEXT_SAFFRONGYM_SABRINA_TM46_NO_ROOM
	dw_const SaffronGymRematchPostBattleText,     TEXT_SAFFRONGYM_REMATCH_POST_BATTLE

SaffronGymTrainerHeaders:
	def_trainers 2
SaffronGymTrainerHeader0:
	trainer EVENT_BEAT_SAFFRON_GYM_TRAINER_0, 3, SaffronGymChanneler1BattleText, SaffronGymChanneler1EndBattleText, SaffronGymChanneler1AfterBattleText
SaffronGymTrainerHeader1:
	trainer EVENT_BEAT_SAFFRON_GYM_TRAINER_1, 3, SaffronGymYoungster1BattleText, SaffronGymYoungster1EndBattleText, SaffronGymYoungster1AfterBattleText
SaffronGymTrainerHeader2:
	trainer EVENT_BEAT_SAFFRON_GYM_TRAINER_2, 3, SaffronGymChanneler2BattleText, SaffronGymChanneler2EndBattleText, SaffronGymChanneler2AfterBattleText
SaffronGymTrainerHeader3:
	trainer EVENT_BEAT_SAFFRON_GYM_TRAINER_3, 3, SaffronGymYoungster2BattleText, SaffronGymYoungster2EndBattleText, SaffronGymYoungster2AfterBattleText
SaffronGymTrainerHeader4:
	trainer EVENT_BEAT_SAFFRON_GYM_TRAINER_4, 3, SaffronGymChanneler3BattleText, SaffronGymChanneler3EndBattleText, SaffronGymChanneler3AfterBattleText
SaffronGymTrainerHeader5:
	trainer EVENT_BEAT_SAFFRON_GYM_TRAINER_5, 3, SaffronGymYoungster3BattleText, SaffronGymYoungster3EndBattleText, SaffronGymYoungster3AfterBattleText
SaffronGymTrainerHeader6:
	trainer EVENT_BEAT_SAFFRON_GYM_TRAINER_6, 3, SaffronGymYoungster4BattleText, SaffronGymYoungster4EndBattleText, SaffronGymYoungster4AfterBattleText
	db -1 ; end

SaffronGymSabrinaText:
	text_asm
	CheckEvent EVENT_BEAT_SABRINA
	jr z, .beforeBeat
	CheckEventReuseA EVENT_GOT_TM46
	jr nz, .afterBeat
	call z, SaffronGymSabrinaReceiveTM46Script
	call DisableWaitingAfterTextDisplay
	jp TextScriptEnd
.afterBeat
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, .SabrinaRematch
	ld hl, .PostBattleAdviceText
	call PrintText
	jp TextScriptEnd
.beforeBeat
	ld hl, .Text
	call PrintText
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, .ReceivedMarshBadgeText
	ld de, .ReceivedMarshBadgeText
	call SaveEndBattleTextPointers
	farcall GetBadgesObtained
	ld a, [wNumSetBits]
	cp 5
	jr nc, .Sabrina6thGym
	jr .Sabrina5thGym
.SabrinaRematch
	ld hl, .PreBattleRematch1Text
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .refused
	ld hl, .PreBattleRematch2Text
	call PrintText
	call Delay3
	ld a, OPP_SABRINA
	ld [wCurOpponent], a
	ld a, 3
	ld [wTrainerNo], a
	ld a, $4 ; new script
	ld [wSaffronGymCurScript], a
	ld [wCurMapScript], a
	jr .endBattle
.refused
	ld hl, .PreBattleRematchRefusedText
	call PrintText
	jp TextScriptEnd
.Sabrina5thGym
	call Delay3
	ld a, OPP_SABRINA
	ld [wCurOpponent], a
	ld a, 2
	ld [wTrainerNo], a
	ld a, $4 ; new script
	ld [wSaffronGymCurScript], a
	ld [wCurMapScript], a
	jr .afterBatttle
.Sabrina6thGym
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
.afterBatttle
	ld a, $6
	ld [wGymLeaderNo], a
.endBattle
	ld a, SCRIPT_SAFFRONGYM_SABRINA_POST_BATTLE
	ld [wSaffronGymCurScript], a
	jp TextScriptEnd

.Text:
	text_far _SaffronGymSabrinaText
	text_end

.ReceivedMarshBadgeText:
	text_far _SaffronGymSabrinaReceivedMarshBadgeText
	sound_get_key_item ; actually plays the second channel of SFX_BALL_POOF due to the wrong music bank being loaded
	text_promptbutton
	text_end

.PostBattleAdviceText:
	text_far _SaffronGymSabrinaPostBattleAdviceText
	text_end

.PreBattleRematch1Text
	text_far _SaffronGymRematchPreBattle1Text
	text_end

.PreBattleRematchRefusedText
	text_far _GymRematchRefusedText
	text_end

.PreBattleRematch2Text
	text_far _SaffronGymPreRematchBattle2Text
	text_end

SaffronGymRematchPostBattleText:
	text_far _SaffronGymRematchPostBattleText
	text_end

SaffronGymSabrinaMarshBadgeInfoText:
	text_far _SaffronGymSabrinaMarshBadgeInfoText
	text_end

SaffronGymSabrinaReceivedTM46Text:
	text_far _SaffronGymSabrinaReceivedTM46Text
	sound_get_item_1
	text_far _TM46ExplanationText
	text_end

SaffronGymSabrinaTM46NoRoomText:
	text_far _SaffronGymSabrinaTM46NoRoomText
	text_end

SaffronGymChanneler1Text:
	text_asm
	ld hl, SaffronGymTrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymYoungster1Text:
	text_asm
	ld hl, SaffronGymTrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymChanneler2Text:
	text_asm
	ld hl, SaffronGymTrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymYoungster2Text:
	text_asm
	ld hl, SaffronGymTrainerHeader3
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymChanneler3Text:
	text_asm
	ld hl, SaffronGymTrainerHeader4
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymYoungster3Text:
	text_asm
	ld hl, SaffronGymTrainerHeader5
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymYoungster4Text:
	text_asm
	ld hl, SaffronGymTrainerHeader6
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymGymGuideText:
	text_asm
	CheckEvent EVENT_BEAT_SABRINA
	jr nz, .afterBeat
	ld hl, .ChampInMakingText
	call PrintText
	jr .done
.afterBeat
	ld hl, .BeatSabrinaText
	call PrintText
.done
	jp TextScriptEnd

.ChampInMakingText:
	text_far _SaffronGymGuideChampInMakingText
	text_end

.BeatSabrinaText:
	text_far _SaffronGymGuideBeatSabrinaText
	text_end

SaffronGymChanneler1BattleText:
	text_far _SaffronGymChanneler1BattleText
	text_end

SaffronGymChanneler1EndBattleText:
	text_far _SaffronGymChanneler1EndBattleText
	text_end

SaffronGymChanneler1AfterBattleText:
	text_far _SaffronGymChanneler1AfterBattleText
	text_end

SaffronGymYoungster1BattleText:
	text_far _SaffronGymYoungster1BattleText
	text_end

SaffronGymYoungster1EndBattleText:
	text_far _SaffronGymYoungster1EndBattleText
	text_end

SaffronGymYoungster1AfterBattleText:
	text_far _SaffronGymYoungster1AfterBattleText
	text_end

SaffronGymChanneler2BattleText:
	text_far _SaffronGymChanneler2BattleText
	text_end

SaffronGymChanneler2EndBattleText:
	text_far _SaffronGymChanneler2EndBattleText
	text_end

SaffronGymChanneler2AfterBattleText:
	text_far _SaffronGymChanneler2AfterBattleText
	text_end

SaffronGymYoungster2BattleText:
	text_far _SaffronGymYoungster2BattleText
	text_end

SaffronGymYoungster2EndBattleText:
	text_far _SaffronGymYoungster2EndBattleText
	text_end

SaffronGymYoungster2AfterBattleText:
	text_far _SaffronGymYoungster2AfterBattleText
	text_end

SaffronGymChanneler3BattleText:
	text_far _SaffronGymChanneler3BattleText
	text_end

SaffronGymChanneler3EndBattleText:
	text_far _SaffronGymChanneler3EndBattleText
	text_end

SaffronGymChanneler3AfterBattleText:
	text_far _SaffronGymChanneler3AfterBattleText
	text_end

SaffronGymYoungster3BattleText:
	text_far _SaffronGymYoungster3BattleText
	text_end

SaffronGymYoungster3EndBattleText:
	text_far _SaffronGymYoungster3EndBattleText
	text_end

SaffronGymYoungster3AfterBattleText:
	text_far _SaffronGymYoungster3AfterBattleText
	text_end

SaffronGymYoungster4BattleText:
	text_far _SaffronGymYoungster4BattleText
	text_end

SaffronGymYoungster4EndBattleText:
	text_far _SaffronGymYoungster4EndBattleText
	text_end

SaffronGymYoungster4AfterBattleText:
	text_far _SaffronGymYoungster4AfterBattleText
	text_end
