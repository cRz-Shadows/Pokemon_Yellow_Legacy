Route1_Script:
	call EnableAutoTextBoxDrawing
	ld hl, Route1_ScriptPointers
	ld a, [wRoute1CurScript]
	jp CallFunctionInTable
	ret

Route1_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_ROUTE1_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_ROUTE1_START_BATTLE
	dw_const OakPostBattleScript,                   SCRIPT_ROUTE1_POST_BATTLE

Route1_TextPointers:
	def_text_pointers
	dw_const Route1Youngster1Text, TEXT_ROUTE1_YOUNGSTER1
	dw_const Route1Youngster2Text, TEXT_ROUTE1_YOUNGSTER2
	dw_const Route1OakText,		   TEXT_ROUTE1_OAK
	dw_const Route1SignText,       TEXT_ROUTE1_SIGN

OakPostBattleScript:
	CheckEvent EVENT_BEAT_ROUTE_1_OAK
	jr z, .notBeat
	call EndTrainerBattle
	ld a, HS_OAKS_LAB_OAK_2
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, HS_ROUTE_1_OAK
	ld [wMissableObjectIndex], a
	predef HideObject
	ret
.notBeat
	call EndTrainerBattle
	xor a ; SCRIPT_BRUNOSROOM_DEFAULT
	ld [wRoute1CurScript], a
	ret

Route1Youngster1Text:
	text_asm
	farcall Route1PrintYoungster1Text
	jp TextScriptEnd

Route1Youngster2Text:
	text_asm
	farcall Route1PrintYoungster2Text
	jp TextScriptEnd

Route1SignText:
	text_asm
	farcall Route1PrintSignText
	jp TextScriptEnd

Route1OakText:
	text_asm
	ld hl, OakBeforeBattleText
	call PrintText

	call YesNoChoice ; this whole bit doesn't work for some reason
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .refused
	
	ld c, BANK(Music_MeetMaleTrainer)
	ld a, MUSIC_MEET_MALE_TRAINER
	call PlayMusic

	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	
	call Delay3
	ld a, OPP_PROF_OAK
	ld [wCurOpponent], a

	ld a, $1
	ld [wTrainerNo], a

	ld a, $2
	ld [wRoute1CurScript], a
	
	ld hl, OakDefeatedText
	ld de, OakWonText
	call SaveEndBattleTextPointers
	ld hl, OakRealChallengeBattleText
	call PrintText
	jp .done
.refused
	ld hl, OakRefusedBattleText
	call PrintText
.done
	jp TextScriptEnd

OakBeforeBattleText:
	text_far _OakBeforeBattleText
	text_end

OakRealChallengeBattleText:
	text_far _OakRealChallengeBattleText
	text_end

OakRefusedBattleText:
	text_far _OakRefusedBattleText
	text_end

OakDefeatedText:
	text_far _OakDefeatedText
	text_asm
	SetEvent EVENT_BEAT_ROUTE_1_OAK
	text_end

OakWonText:
	text_far _OakWonText
	text_end