VictoryRoad1F_Script:
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	res 5, [hl]
	call nz, .next
	call EnableAutoTextBoxDrawing
	ld hl, VictoryRoad1TrainerHeaders
	ld de, VictoryRoad1F_ScriptPointers
	ld a, [wVictoryRoad1FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wVictoryRoad1FCurScript], a
	ret
.next
	CheckEvent EVENT_VICTORY_ROAD_1_BOULDER_ON_SWITCH
	ret z
	ld a, $1d
	ld [wNewTileBlockID], a
	lb bc, 6, 4
	predef_jump ReplaceTileBlock

VictoryRoad1F_ScriptPointers:
	def_script_pointers
	dw_const VictoryRoad1FDefaultScript,            SCRIPT_VICTORYROAD1F_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_VICTORYROAD1F_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_VICTORYROAD1F_END_BATTLE

VictoryRoad1FDefaultScript:
	CheckEvent EVENT_VICTORY_ROAD_1_BOULDER_ON_SWITCH
	jp nz, CheckFightingMapTrainers
	ld hl, .SwitchCoords
	call CheckBoulderCoords
	jp nc, CheckFightingMapTrainers
	ldh a, [hSpriteIndex]
	cp $f
	jp z, CheckFightingMapTrainers
	ld hl, wCurrentMapScriptFlags
	set 5, [hl]
	SetEvent EVENT_VICTORY_ROAD_1_BOULDER_ON_SWITCH
	ld a, 1
	ld [wBoulderSFXCheck], a
	ret

.SwitchCoords:
	dbmapcoord 17, 13
	db -1 ; end

VictoryRoad1F_TextPointers:
	def_text_pointers
	dw_const VictoryRoad1FCooltrainerFText, TEXT_VICTORYROAD1F_COOLTRAINER_F
	dw_const VictoryRoad1FCooltrainerMText, TEXT_VICTORYROAD1F_COOLTRAINER_M
	dw_const VictoryRoad1FBugCatcherText, 	TEXT_VICTORYROAD1F_BUG_CATCHER
	dw_const VictoryRoad1FBeautyText, 		TEXT_VICTORYROAD1F_BEAUTY
	dw_const VictoryRoad1FBurglarText, 		TEXT_VICTORYROAD1F_BURGLAR
	dw_const VictoryRoad1FBlackbeltText, 	TEXT_VICTORYROAD1F_BLACKBELT
	dw_const PickUpItemText,                TEXT_VICTORYROAD1F_TM_SKY_ATTACK
	dw_const PickUpItemText,                TEXT_VICTORYROAD1F_RARE_CANDY
	dw_const BoulderText,                   TEXT_VICTORYROAD1F_BOULDER1
	dw_const BoulderText,                   TEXT_VICTORYROAD1F_BOULDER2
	dw_const BoulderText,                   TEXT_VICTORYROAD1F_BOULDER3

VictoryRoad1TrainerHeaders:
	def_trainers
VictoryRoad1TrainerHeader0:
	trainer EVENT_BEAT_VICTORY_ROAD_1_TRAINER_0, 2, VictoryRoad1FCooltrainerFBattleText, VictoryRoad1FCooltrainerFEndBattleText, VictoryRoad1FCooltrainerFAfterBattleText
VictoryRoad1TrainerHeader1:
	trainer EVENT_BEAT_VICTORY_ROAD_1_TRAINER_1, 2, VictoryRoad1FCooltrainerMBattleText, VictoryRoad1FCooltrainerMEndBattleText, VictoryRoad1FCooltrainerMAfterBattleText
VictoryRoad1TrainerHeader2:
	trainer EVENT_BEAT_VICTORY_ROAD_1_TRAINER_2, 2, VictoryRoad1FBugCatcherBattleText, VictoryRoad1FBugCatcherEndBattleText, VictoryRoad1FBugCatcherAfterBattleText
VictoryRoad1TrainerHeader3:
	trainer EVENT_BEAT_VICTORY_ROAD_1_TRAINER_3, 3, VictoryRoad1FBeautyBattleText, VictoryRoad1FBeautyEndBattleText, VictoryRoad1FBeautyAfterBattleText
VictoryRoad1TrainerHeader4:
	trainer EVENT_BEAT_VICTORY_ROAD_1_TRAINER_4, 3, VictoryRoad1FBurglarBattleText, VictoryRoad1FBurglarEndBattleText, VictoryRoad1FBurglarAfterBattleText
VictoryRoad1TrainerHeader5:
	trainer EVENT_BEAT_VICTORY_ROAD_1_TRAINER_5, 4, VictoryRoad1FBlackbeltBattleText, VictoryRoad1FBlackbeltEndBattleText, VictoryRoad1FBlackbeltAfterBattleText
	db -1 ; end

VictoryRoad1FCooltrainerFText:
	text_asm
	ld hl, VictoryRoad1TrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

VictoryRoad1FCooltrainerMText:
	text_asm
	ld hl, VictoryRoad1TrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

VictoryRoad1FBugCatcherText:
	text_asm
	ld hl, VictoryRoad1TrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

VictoryRoad1FBeautyText:
	text_asm
	ld hl, VictoryRoad1TrainerHeader3
	call TalkToTrainer
	jp TextScriptEnd

VictoryRoad1FBurglarText:
	text_asm
	ld hl, VictoryRoad1TrainerHeader4
	call TalkToTrainer
	jp TextScriptEnd

VictoryRoad1FBlackbeltText:
	text_asm
	ld hl, VictoryRoad1TrainerHeader5
	call TalkToTrainer
	jp TextScriptEnd

VictoryRoad1FCooltrainerFBattleText:
	text_far _VictoryRoad1FCooltrainerFBattleText
	text_end

VictoryRoad1FCooltrainerFEndBattleText:
	text_far _VictoryRoad1FCooltrainerFEndBattleText
	text_end

VictoryRoad1FCooltrainerFAfterBattleText:
	text_far _VictoryRoad1FCooltrainerFAfterBattleText
	text_end

VictoryRoad1FCooltrainerMBattleText:
	text_far _VictoryRoad1FCooltrainerMBattleText
	text_end

VictoryRoad1FCooltrainerMEndBattleText:
	text_far _VictoryRoad1FCooltrainerMEndBattleText
	text_end

VictoryRoad1FCooltrainerMAfterBattleText:
	text_far _VictoryRoad1FCooltrainerMAfterBattleText
	text_end

VictoryRoad1FBugCatcherBattleText:
	text_far _VictoryRoad1FBugCatcherBattleText
	text_end

VictoryRoad1FBugCatcherEndBattleText:
	text_far _VictoryRoad1FBugCatcherEndBattleText
	text_end

VictoryRoad1FBugCatcherAfterBattleText:
	text_far _VictoryRoad1FBugCatcherAfterBattleText
	text_end

VictoryRoad1FBeautyBattleText:
	text_far _VictoryRoad1FBeautyBattleText
	text_end

VictoryRoad1FBeautyEndBattleText:
	text_far _VictoryRoad1FBeautyEndBattleText
	text_end

VictoryRoad1FBeautyAfterBattleText:
	text_far _VictoryRoad1FBeautyAfterBattleText
	text_end

VictoryRoad1FBurglarBattleText:
	text_far _VictoryRoad1FBurglarBattleText
	text_end

VictoryRoad1FBurglarEndBattleText:
	text_far _VictoryRoad1FBurglarEndBattleText
	text_end

VictoryRoad1FBurglarAfterBattleText:
	text_far _VictoryRoad1FBurglarAfterBattleText
	text_end

VictoryRoad1FBlackbeltBattleText:
	text_far _VictoryRoad1FBlackbeltBattleText
	text_end

VictoryRoad1FBlackbeltEndBattleText:
	text_far _VictoryRoad1FBlackbeltEndBattleText
	text_end

VictoryRoad1FBlackbeltAfterBattleText:
	text_far _VictoryRoad1FBlackbeltAfterBattleText
	text_end
