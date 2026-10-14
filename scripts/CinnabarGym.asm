CinnabarGym_Script:
	call CinnabarGymSetMapAndTiles
	call EnableAutoTextBoxDrawing
	ld hl, CinnabarGym_ScriptPointers
	ld a, [wCinnabarGymCurScript]
	jp CallFunctionInTable

CinnabarGymSetMapAndTiles:
	ld hl, wCurrentMapScriptFlags
	bit 6, [hl]
	res 6, [hl]
	push hl
	call nz, .LoadNames
	pop hl
	bit 5, [hl]
	res 5, [hl]
	call nz, UpdateCinnabarGymGateTileBlocks
	ResetEvent EVENT_2A7
	ret

.LoadNames:
	ld hl, .CityName
	ld de, .LeaderName
	jp LoadGymLeaderAndCityName

.CityName:
	db "CINNABAR ISLAND@"

.LeaderName:
	db "BLAINE@"

CinnabarGymResetScripts:
	xor a ; SCRIPT_CINNABARGYM_DEFAULT
	ld [wJoyIgnore], a
	ld [wCinnabarGymCurScript], a
	ld [wCurMapScript], a
	ld [wOpponentAfterWrongAnswer], a
	ret

CinnabarGymSetTrainerHeader:
	ldh a, [hTextID]
	ld [wTrainerHeaderFlagBit], a
	ret

CinnabarGymFlagAction:
	predef_jump FlagActionPredef

CinnabarGym_ScriptPointers:
	def_script_pointers
	dw_const CinnabarGymDefaultScript,          SCRIPT_CINNABARGYM_DEFAULT
	dw_const CinnabarGymGetOpponentTextScript,  SCRIPT_CINNABARGYM_GET_OPPONENT_TEXT
	dw_const CinnabarGymOpenGateScript,         SCRIPT_CINNABARGYM_OPEN_GATE
	dw_const CinnabarGymBlainePostBattleScript, SCRIPT_CINNABARGYM_BLAINE_POST_BATTLE

CinnabarGymDefaultScript:
	ld a, [wOpponentAfterWrongAnswer]
	and a
	ret z
	ldh [hSpriteIndex], a
	cp CINNABARGYM_SUPER_NERD3
	jr nz, .not_super_nerd3
	ld a, PLAYER_DIR_DOWN
	ld [wPlayerMovingDirection], a
	ld hl, CinnabarGymPikachuMovement_SuperNerd3
	ld b, SPRITE_FACING_DOWN
	call CinnabarGymMovePikachuOutOfWay
	ld de, MovementNpcToLeftAndUp
	jr .MoveSprite
.not_super_nerd3
	cp CINNABARGYM_SUPER_NERD1
	jr z, .super_nerd
	cp CINNABARGYM_SUPER_NERD2
	jr z, .super_nerd
	cp CINNABARGYM_SUPER_NERD4
	jr z, .super_nerd
	cp CINNABARGYM_SUPER_NERD5
	jr z, .super_nerd
	cp CINNABARGYM_SUPER_NERD6
	jr z, .super_nerd
	cp CINNABARGYM_SUPER_NERD7
	jr z, .super_nerd
	ret
.super_nerd
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld hl, CinnabarGymPikachuMovement_SuperNerd
	ld b, SPRITE_FACING_RIGHT
	call CinnabarGymMovePikachuOutOfWay
	ld de, MovementNpcToLeft
.MoveSprite
	call MoveSprite
	ld a, SCRIPT_CINNABARGYM_GET_OPPONENT_TEXT
	ld [wCinnabarGymCurScript], a
	ld [wCurMapScript], a
	ret

MovementNpcToLeftAndUp:
	db NPC_MOVEMENT_LEFT
	db NPC_MOVEMENT_UP
	db -1 ; end

; Pikachu sidestep when Super Nerd 3 walks up to battle after a wrong answer
CinnabarGymPikachuMovement_SuperNerd3:
	db $00
	db $20
	db $1e
	db $35
	db $3f

MovementNpcToLeft:
	db NPC_MOVEMENT_LEFT
	db -1 ; end

; Pikachu sidestep when another Super Nerd walks over to battle after a wrong answer
CinnabarGymPikachuMovement_SuperNerd:
	db $00
	db $1d
	db $1f
	db $38
	db $3f

; If Pikachu is out and faces direction b, applies Pikachu movement data hl
CinnabarGymMovePikachuOutOfWay:
	ld a, [wPikachuPartyFlags]
	bit 7, a
	ret z
	push hl
	push bc
	callfar GetPikachuFacingDirectionAndReturnToE
	pop bc
	pop hl
	ld a, b
	cp e
	ret nz
	call ApplyPikachuMovementData
	ret

CinnabarGymGetOpponentTextScript:
	ld a, [wStatusFlags5]
	bit 0, a
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, [wOpponentAfterWrongAnswer]
	ld [wTrainerHeaderFlagBit], a
	ldh [hTextID], a
	jp DisplayTextID

CinnabarGymOpenGateScript:
	call CinnabarGymCheckAndResetQuizBattleFlag
	ld a, [wIsInBattle]
	cp $ff
	jp z, CinnabarGymResetScripts
	ld a, [wTrainerHeaderFlagBit]
	sub $2
	ld c, a
	ld b, FLAG_TEST
	EventFlagAddress hl, EVENT_CINNABAR_GYM_GATE0_UNLOCKED
	call CinnabarGymFlagAction
	ld a, c
	and a
	jr nz, .no_sound
	ld a, [wTrainerHeaderFlagBit]
	cp 2
	jr z, .no_sound
	ld c, 30
	call DelayFrames
	call CinnabarGymSetTrainerBeaten
	call CinnabarGymUnlockGate
	call WaitForSoundToFinish
	ld a, SFX_GO_INSIDE
	call PlaySound
	call WaitForSoundToFinish
	jr .asm_75013
.no_sound
	call CinnabarGymSetTrainerBeaten
	call CinnabarGymUnlockGate
.asm_75013
	xor a
	ld [wJoyIgnore], a
	ld [wOpponentAfterWrongAnswer], a
	ld a, SCRIPT_CINNABARGYM_DEFAULT
	ld [wCinnabarGymCurScript], a
	ld [wCurMapScript], a
	ret

; Sets EVENT_BEAT_CINNABAR_GYM_TRAINER_n for wTrainerHeaderFlagBit
CinnabarGymSetTrainerBeaten:
	ld a, [wTrainerHeaderFlagBit]
	ldh [hGymGateIndex], a
	ld c, a
	ld b, FLAG_SET
	EventFlagAddress hl, EVENT_BEAT_CINNABAR_GYM_TRAINER_0
	call CinnabarGymFlagAction
	ret

; Sets the gate-unlocked event for this trainer and redraws the gate blocks
CinnabarGymUnlockGate:
	ld a, [wTrainerHeaderFlagBit]
	sub 2
	ld c, a
	ld b, FLAG_SET
	EventFlagAddress hl, EVENT_CINNABAR_GYM_GATE0_UNLOCKED
	call CinnabarGymFlagAction
	call UpdateCinnabarGymGateTileBlocks
	ret

CinnabarGymBlainePostBattleScript:
	call CinnabarGymCheckAndResetQuizBattleFlag
	ld a, [wIsInBattle]
	cp $ff
	jp z, CinnabarGymResetScripts
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, BlaineRematchPostBattle
; fallthrough
CinnabarGymReceiveTM38:
	ld a, TEXT_CINNABARGYM_BLAINE_VOLCANO_BADGE_INFO
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_BLAINE
	lb bc, TM_FIRE_BLAST, 1
	call GiveItem
	jr nc, .BagFull
	ld a, TEXT_CINNABARGYM_BLAINE_RECEIVED_TM38
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_GOT_TM38
	jr .gymVictory
.BagFull
	ld a, TEXT_CINNABARGYM_BLAINE_TM38_NO_ROOM
	ldh [hTextID], a
	call DisplayTextID
.gymVictory
	ld hl, wObtainedBadges
	set BIT_VOLCANOBADGE, [hl]
	ld hl, wBeatGymFlags
	set BIT_VOLCANOBADGE, [hl]

	; deactivate gym trainers
	SetEventRange EVENT_BEAT_CINNABAR_GYM_TRAINER_0, EVENT_BEAT_CINNABAR_GYM_TRAINER_6

	ld hl, wCurrentMapScriptFlags
	set 5, [hl]

	jp CinnabarGymResetScripts

BlaineRematchPostBattle:
	ld a, TEXT_CINNABARGYM_REMATCH_POST_BATTLE
	ldh [hTextID], a
	call DisplayTextID
	jp CinnabarGymResetScripts

CinnabarGym_TextPointers:
	def_text_pointers
	dw_const CinnabarGymBlaineText,                 TEXT_CINNABARGYM_BLAINE
	dw_const CinnabarGymSuperNerd1,                 TEXT_CINNABARGYM_SUPER_NERD1
	dw_const CinnabarGymSuperNerd2,                 TEXT_CINNABARGYM_SUPER_NERD2
	dw_const CinnabarGymSuperNerd3,                 TEXT_CINNABARGYM_SUPER_NERD3
	dw_const CinnabarGymSuperNerd4,                 TEXT_CINNABARGYM_SUPER_NERD4
	dw_const CinnabarGymSuperNerd5,                 TEXT_CINNABARGYM_SUPER_NERD5
	dw_const CinnabarGymSuperNerd6,                 TEXT_CINNABARGYM_SUPER_NERD6
	dw_const CinnabarGymSuperNerd7,                 TEXT_CINNABARGYM_SUPER_NERD7
	dw_const CinnabarGymGymGuideText,               TEXT_CINNABARGYM_GYM_GUIDE
	dw_const CinnabarGymBlaineVolcanoBadgeInfoText, TEXT_CINNABARGYM_BLAINE_VOLCANO_BADGE_INFO
	dw_const CinnabarGymBlaineReceivedTM38Text,     TEXT_CINNABARGYM_BLAINE_RECEIVED_TM38
	dw_const CinnabarGymBlaineTM38NoRoomText,       TEXT_CINNABARGYM_BLAINE_TM38_NO_ROOM
	dw_const CinnabarGymRematchPostBattleText, 	  	TEXT_CINNABARGYM_REMATCH_POST_BATTLE

CinnabarGymStartBattleScript:
	ldh a, [hTextID]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	ld hl, wStatusFlags3
	set 6, [hl]
	set 7, [hl]
	ld a, [wSpriteIndex]
	cp CINNABARGYM_BLAINE
	jr z, .blaine
	ld a, SCRIPT_CINNABARGYM_OPEN_GATE
	jr .not_blaine
.blaine
	ld a, SCRIPT_CINNABARGYM_BLAINE_POST_BATTLE
.not_blaine
	ld [wCinnabarGymCurScript], a
	ld [wCurMapScript], a
	jp TextScriptEnd

CinnabarGymStartRematchScript:
	ld hl, .PreBattleRematch1Text
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .refused
	ld hl, .PreBattleRematch2Text
	call PrintText
	call Delay3
	ld a, OPP_BLAINE
	ld [wCurOpponent], a
	ld a, 2
	ld [wTrainerNo], a
	ld a, $4 ; new script
	ld [wCinnabarGymCurScript], a
	ld [wCurMapScript], a
	ld a, SCRIPT_CINNABARGYM_BLAINE_POST_BATTLE
	ld [wCinnabarGymCurScript], a
	ld [wCurMapScript], a
	jp TextScriptEnd
.refused
	ld hl, .PreBattleRematchRefusedText
	call PrintText
	jp TextScriptEnd

.PreBattleRematch1Text
	text_far _CinnabarGymRematchPreBattle1Text
	text_end

.PreBattleRematchRefusedText
	text_far _GymRematchRefusedText
	text_end

.PreBattleRematch2Text
	text_far _CinnabarGymPreRematchBattle2Text
	text_end

CinnabarGymRematchPostBattleText:
	text_far _CinnabarGymRematchPostBattleText
	text_end

CinnabarGymBlaineText:
	text_asm
	CheckEvent EVENT_BEAT_BLAINE
	jr z, .beforeBeat
	CheckEventReuseA EVENT_GOT_TM38
	jr nz, .afterBeat
	call z, CinnabarGymReceiveTM38
	call DisableWaitingAfterTextDisplay
	jp TextScriptEnd
.afterBeat
	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, .BlaineRematch
	ld hl, .PostBattleAdviceText
	call PrintText
	jp TextScriptEnd
.beforeBeat
	ld hl, .PreBattleText
	call PrintText
	ld hl, .ReceivedVolcanoBadgeText
	ld de, .ReceivedVolcanoBadgeText
	call SaveEndBattleTextPointers
	ld a, $7
	ld [wGymLeaderNo], a
	jp CinnabarGymStartBattleScript
.BlaineRematch
	jp CinnabarGymStartRematchScript

.PreBattleText:
	text_far _CinnabarGymBlainePreBattleText
	text_end

.ReceivedVolcanoBadgeText:
	text_far _CinnabarGymBlaineReceivedVolcanoBadgeText
	sound_get_key_item ; actually plays the second channel of SFX_BALL_POOF due to the wrong music bank being loaded
	text_waitbutton
	text_end

.PostBattleAdviceText:
	text_far _CinnabarGymBlainePostBattleAdviceText
	text_end

CinnabarGymBlaineVolcanoBadgeInfoText:
	text_far _CinnabarGymBlaineVolcanoBadgeInfoText
	text_end

CinnabarGymBlaineReceivedTM38Text:
	text_far _CinnabarGymBlaineReceivedTM38Text
	sound_get_item_1
	text_far _CinnabarGymBlaineTM38ExplanationText
	text_end

CinnabarGymBlaineTM38NoRoomText:
	text_far _CinnabarGymBlaineTM38NoRoomText
	text_end

CinnabarGymSuperNerd1:
	text_asm
	call CinnabarGymSetTrainerHeader
	CheckEvent EVENT_BEAT_CINNABAR_GYM_TRAINER_0
	jr nz, .defeated
	ld hl, .BattleText
	call PrintText
	ld hl, .EndBattleText
	ld de, .EndBattleText
	call SaveEndBattleTextPointers
	jp CinnabarGymStartBattleScript
.defeated
	ld hl, .AfterBattleText
	call PrintText
	jp TextScriptEnd

.BattleText:
	text_far _CinnabarGymSuperNerd1BattleText
	text_end

.EndBattleText:
	text_far _CinnabarGymSuperNerd1EndBattleText
	text_end

.AfterBattleText:
	text_far _CinnabarGymSuperNerd1AfterBattleText
	text_end

CinnabarGymSuperNerd2:
	text_asm
	call CinnabarGymSetTrainerHeader
	CheckEvent EVENT_BEAT_CINNABAR_GYM_TRAINER_1
	jr nz, .defeated
	call CinnabarGymCheckQuizBattleFlag
	jr nz, .asm_75196
	CheckEvent EVENT_CINNABAR_GYM_GATE1_UNLOCKED
	jr nz, .asm_75196
	ld e, $00
	jp CinnabarGymPrintTrainerQuizRemark
.asm_75196
	ld hl, .BattleText
	call PrintText
	ld hl, .EndBattleText
	ld de, .EndBattleText
	call SaveEndBattleTextPointers
	jp CinnabarGymStartBattleScript
.defeated
	ld hl, .AfterBattleText
	call PrintText
	jp TextScriptEnd

.BattleText:
	text_far _CinnabarGymSuperNerd2BattleText
	text_end

.EndBattleText:
	text_far _CinnabarGymSuperNerd2EndBattleText
	text_end

.AfterBattleText:
	text_far _CinnabarGymSuperNerd2AfterBattleText
	text_end

CinnabarGymSuperNerd3:
	text_asm
	call CinnabarGymSetTrainerHeader
	CheckEvent EVENT_BEAT_CINNABAR_GYM_TRAINER_2
	jr nz, .defeated
	call CinnabarGymCheckQuizBattleFlag
	jr nz, .asm_751dc
	CheckEvent EVENT_CINNABAR_GYM_GATE2_UNLOCKED
	jr nz, .asm_751dc
	ld e, $1
	jp CinnabarGymPrintTrainerQuizRemark
.asm_751dc
	ld hl, .BattleText
	call PrintText
	ld hl, .EndBattleText
	ld de, .EndBattleText
	call SaveEndBattleTextPointers
	jp CinnabarGymStartBattleScript
.defeated
	ld hl, .AfterBattleText
	call PrintText
	jp TextScriptEnd

.BattleText:
	text_far _CinnabarGymSuperNerd3BattleText
	text_end

.EndBattleText:
	text_far _CinnabarGymSuperNerd3EndBattleText
	text_end

.AfterBattleText:
	text_far _CinnabarGymSuperNerd3AfterBattleText
	text_end

CinnabarGymSuperNerd4:
	text_asm
	call CinnabarGymSetTrainerHeader
	CheckEvent EVENT_BEAT_CINNABAR_GYM_TRAINER_3
	jr nz, .defeated
	call CinnabarGymCheckQuizBattleFlag
	jr nz, .asm_75222
	CheckEvent EVENT_CINNABAR_GYM_GATE3_UNLOCKED
	jr nz, .asm_75222
	ld e, $2
	jp CinnabarGymPrintTrainerQuizRemark
.asm_75222
	ld hl, .BattleText
	call PrintText
	ld hl, .EndBattleText
	ld de, .EndBattleText
	call SaveEndBattleTextPointers
	jp CinnabarGymStartBattleScript
.defeated
	ld hl, .AfterBattleText
	call PrintText
	jp TextScriptEnd

.BattleText:
	text_far _CinnabarGymSuperNerd4BattleText
	text_end

.EndBattleText:
	text_far _CinnabarGymSuperNerd4EndBattleText
	text_end

.AfterBattleText:
	text_far _CinnabarGymSuperNerd4AfterBattleText
	text_end

CinnabarGymSuperNerd5:
	text_asm
	call CinnabarGymSetTrainerHeader
	CheckEvent EVENT_BEAT_CINNABAR_GYM_TRAINER_4
	jr nz, .defeated
	call CinnabarGymCheckQuizBattleFlag
	jr nz, .asm_75222
	CheckEvent EVENT_CINNABAR_GYM_GATE4_UNLOCKED
	jr nz, .asm_75222
	ld e, $3
	jp CinnabarGymPrintTrainerQuizRemark
.asm_75222
	ld hl, .BattleText
	call PrintText
	ld hl, .EndBattleText
	ld de, .EndBattleText
	call SaveEndBattleTextPointers
	jp CinnabarGymStartBattleScript
.defeated
	ld hl, .AfterBattleText
	call PrintText
	jp TextScriptEnd

.BattleText:
	text_far _CinnabarGymSuperNerd5BattleText
	text_end

.EndBattleText:
	text_far _CinnabarGymSuperNerd5EndBattleText
	text_end

.AfterBattleText:
	text_far _CinnabarGymSuperNerd5AfterBattleText
	text_end

CinnabarGymSuperNerd6:
	text_asm
	call CinnabarGymSetTrainerHeader
	CheckEvent EVENT_BEAT_CINNABAR_GYM_TRAINER_5
	jr nz, .defeated
	call CinnabarGymCheckQuizBattleFlag
	jr nz, .asm_75222
	CheckEvent EVENT_CINNABAR_GYM_GATE5_UNLOCKED
	jr nz, .asm_75222
	ld e, $4
	jp CinnabarGymPrintTrainerQuizRemark
.asm_75222
	ld hl, .BattleText
	call PrintText
	ld hl, .EndBattleText
	ld de, .EndBattleText
	call SaveEndBattleTextPointers
	jp CinnabarGymStartBattleScript
.defeated
	ld hl, .AfterBattleText
	call PrintText
	jp TextScriptEnd

.BattleText:
	text_far _CinnabarGymSuperNerd6BattleText
	text_end

.EndBattleText:
	text_far _CinnabarGymSuperNerd6EndBattleText
	text_end

.AfterBattleText:
	text_far _CinnabarGymSuperNerd6AfterBattleText
	text_end

CinnabarGymSuperNerd7:
	text_asm
	call CinnabarGymSetTrainerHeader
	CheckEvent EVENT_BEAT_CINNABAR_GYM_TRAINER_6
	jr nz, .defeated
	call CinnabarGymCheckQuizBattleFlag
	jr nz, .asm_75222
	CheckEvent EVENT_CINNABAR_GYM_GATE6_UNLOCKED
	jr nz, .asm_75222
	ld e, $5
	jp CinnabarGymPrintTrainerQuizRemark
.asm_75222
	ld hl, .BattleText
	call PrintText
	ld hl, .EndBattleText
	ld de, .EndBattleText
	call SaveEndBattleTextPointers
	jp CinnabarGymStartBattleScript
.defeated
	ld hl, .AfterBattleText
	call PrintText
	jp TextScriptEnd

.BattleText:
	text_far _CinnabarGymSuperNerd7BattleText
	text_end

.EndBattleText:
	text_far _CinnabarGymSuperNerd7EndBattleText
	text_end

.AfterBattleText:
	text_far _CinnabarGymSuperNerd7AfterBattleText
	text_end

CinnabarGymGymGuideText:
	text_asm
	callfar CinnabarGymPrintGymGuideText
	jp TextScriptEnd
