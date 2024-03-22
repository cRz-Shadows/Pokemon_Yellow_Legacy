SeafoamIslandsB4F_Script:
	call EnableAutoTextBoxDrawing
	ld hl, SeafoamIslandsB4FTrainerHeaders
	ld de, SeafoamIslandsB4F_ScriptPointers
	ld a, [wSeafoamIslandsB4FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wSeafoamIslandsB4FCurScript], a
	CheckEvent EVENT_INITIATED_WEEBRA_BATTLE
	ret nz
	CheckEvent EVENT_BEAT_WEEBRA
	ret nz
	ld hl, WeebraFightCheckCoords
	call ArePlayerCoordsInArray
	ret nc
	SetEvent EVENT_INITIATED_WEEBRA_BATTLE
	ld a, SCRIPT_SEAFOAMISLANDSB4F_DEFAULT
	ld [wSeafoamIslandsB4FCurScript], a
	ret

WeebraFightCheckCoords:
	dbmapcoord 7, 2
	dbmapcoord 7, 3
	db -1 ; end

SeafoamIslandsB4FResetScript:
	xor a
	ld [wJoyIgnore], a
	ld [wSeafoamIslandsB4FCurScript], a
	ld [wCurMapScript], a
	ret

SeafoamIslandsB4F_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,       		SCRIPT_SEAFOAMISLANDSB4F_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_SEAFOAMISLANDSB4F_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_SEAFOAMISLANDSB4F_END_BATTLE
	dw_const SeafoamIslandsB4FObjectMoving1Script, SCRIPT_SEAFOAMISLANDSB4F_OBJECT_MOVING1
	dw_const SeafoamIslandsB4FMoveObjectScript,    SCRIPT_SEAFOAMISLANDSB4F_MOVE_OBJECT
	dw_const SeafoamIslandsB4FObjectMoving2Script, SCRIPT_SEAFOAMISLANDSB4F_OBJECT_MOVING2
	dw_const SeafoamIslandsB4FObjectMoving3Script, SCRIPT_SEAFOAMISLANDSB4F_OBJECT_MOVING3
	EXPORT SCRIPT_SEAFOAMISLANDSB4F_MOVE_OBJECT ; used by engine/overworld/player_state.asm

SeafoamIslandsB4FObjectMoving3Script:
	ld a, [wIsInBattle]
	cp $ff
	jr z, SeafoamIslandsB4FResetScript
	call EndTrainerBattle
	ld a, SCRIPT_SEAFOAMISLANDSB4F_DEFAULT
	ld [wSeafoamIslandsB4FCurScript], a
	ret

SeafoamIslandsB4FDefaultScript:
	CheckBothEventsSet EVENT_SEAFOAM3_BOULDER1_DOWN_HOLE, EVENT_SEAFOAM3_BOULDER2_DOWN_HOLE
	ret z
	ld hl, .Coords
	call ArePlayerCoordsInArray
	ret nc
	ld a, [wCoordIndex]
	cp $3
	jr nc, .only1UpInputNeeded
	ld a, NPC_MOVEMENT_UP
	ld [wSimulatedJoypadStatesEnd + 1], a
	ld a, 2
	jr .forcePlayerUpFromSurfExit
.only1UpInputNeeded
	ld a, 1
.forcePlayerUpFromSurfExit
	ld [wSimulatedJoypadStatesIndex], a
	ld a, D_UP | B_BUTTON
	ld [wSimulatedJoypadStatesEnd], a
	call StartSimulatingJoypadStates
	ld hl, wFlags_D733
	res 2, [hl]
	ld a, SCRIPT_SEAFOAMISLANDSB4F_OBJECT_MOVING1
	ld [wSeafoamIslandsB4FCurScript], a
	ret

.Coords
	dbmapcoord 20, 17
	dbmapcoord 21, 17
	dbmapcoord 20, 16
	dbmapcoord 21, 16
	db -1 ; end

SeafoamIslandsB4FObjectMoving1Script:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, SCRIPT_SEAFOAMISLANDSB4F_DEFAULT
	ld [wSeafoamIslandsB4FCurScript], a
	ret

SeafoamIslandsB4FMoveObjectScript:
	CheckBothEventsSet EVENT_SEAFOAM4_BOULDER1_DOWN_HOLE, EVENT_SEAFOAM4_BOULDER2_DOWN_HOLE
	ld a, SCRIPT_SEAFOAMISLANDSB4F_DEFAULT
	jr z, .playerNotInStrongCurrent
	ld hl, .Coords
	call ArePlayerCoordsInArray
	ld a, SCRIPT_SEAFOAMISLANDSB4F_DEFAULT
	jr nc, .playerNotInStrongCurrent
	ld a, [wCoordIndex]
	cp $1
	jr nz, .nearRightBoulder
	ld de, .RLEList_StrongCurrentNearLeftBoulder
	jr .forceSurfMovement
.nearRightBoulder
	ld de, .RLEList_StrongCurrentNearRightBoulder
.forceSurfMovement
	ld hl, wSimulatedJoypadStatesEnd
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, SCRIPT_SEAFOAMISLANDSB4F_OBJECT_MOVING2
.playerNotInStrongCurrent
	ld [wSeafoamIslandsB4FCurScript], a
	ret

.Coords
	dbmapcoord  4, 14
	dbmapcoord  5, 14
	db -1 ; end

.RLEList_StrongCurrentNearRightBoulder:
	db D_UP, 3
	db D_RIGHT, 2
	db D_UP, 1
	db -1 ; end

.RLEList_StrongCurrentNearLeftBoulder:
	db D_UP, 3
	db D_RIGHT, 3
	db D_UP, 1
	db -1 ; end

SeafoamIslandsB4FObjectMoving2Script:
	ld a, [wSimulatedJoypadStatesIndex]
	ld b, a
	cp $1
	call z, .doneForcedSurfMovement
	ld a, b
	and a
	ret nz
	ld a, SCRIPT_SEAFOAMISLANDSB4F_DEFAULT
	ld [wSeafoamIslandsB4FCurScript], a
	ret

.doneForcedSurfMovement:
	xor a
	ld [wWalkBikeSurfState], a
	ld [wWalkBikeSurfStateCopy], a
	jp ForceBikeOrSurf

SeafoamIslandsB4F_TextPointers:
	def_text_pointers
	dw_const BoulderText,                       TEXT_SEAFOAMISLANDSB4F_BOULDER1
	dw_const BoulderText,                       TEXT_SEAFOAMISLANDSB4F_BOULDER2
	dw_const SeafoamIslandsB4FArticunoText,     TEXT_SEAFOAMISLANDSB4F_ARTICUNO
	dw_const SeafoamIslandsWeebraText1,      	TEXT_SEAFOAM_ISLANDS_WEEBRA
	dw_const SeafoamIslandsB4FBouldersSignText, TEXT_SEAFOAMISLANDSB4F_BOULDERS_SIGN
	dw_const SeafoamIslandsB4FDangerSignText,   TEXT_SEAFOAMISLANDSB4F_DANGER_SIGN

; Articuno is object 3, but its event flag is bit 2.
; This is not a problem because its sight range is 0, and
; trainer headers were not stored by ExecuteCurMapScriptInTable.
SeafoamIslandsB4FTrainerHeaders:
	def_trainers 3
ArticunoTrainerHeader:
	trainer EVENT_BEAT_ARTICUNO, 0, SeafoamIslandsB4FArticunoBattleText, SeafoamIslandsB4FArticunoBattleText, SeafoamIslandsB4FArticunoBattleText
WeebraTrainerHeader:
	trainer EVENT_BEAT_WEEBRA, 5, SeafoamIslandsWeebraBattleText1, SeafoamIslandsWeebraEndBattleText1, SeafoamIslandsWeebraAfterBattleText1
	db -1 ; end

SeafoamIslandsWeebraText1:
	text_asm
	ld hl, WeebraTrainerHeader
	call TalkToTrainer
	jp TextScriptEnd
	
SeafoamIslandsWeebraBattleText1:
	text_far _SeafoamIslandsWeebraBattleText1
	text_end
	
SeafoamIslandsWeebraEndBattleText1:
	text_far _SeafoamIslandsWeebraEndBattleText1
	text_end
	
SeafoamIslandsWeebraAfterBattleText1:
	text_far _SeafoamIslandsWeebraAfterBattleText1
	text_asm
	ClearEvent EVENT_INITIATED_WEEBRA_BATTLE
	jp TextScriptEnd

SeafoamIslandsB4FArticunoText:
	text_asm
	ld hl, ArticunoTrainerHeader
	call TalkToTrainer
	ld a, SCRIPT_SEAFOAMISLANDSB4F_OBJECT_MOVING3
	ld [wSeafoamIslandsB4FCurScript], a
	jp TextScriptEnd

SeafoamIslandsB4FArticunoBattleText:
	text_far _SeafoamIslandsB4FArticunoBattleText
	text_asm
	ld a, ARTICUNO
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd

SeafoamIslandsB4FBouldersSignText:
	text_far _SeafoamIslandsB4FBouldersSignText
	text_end

SeafoamIslandsB4FDangerSignText:
	text_far _SeafoamIslandsB4FDangerSignText
	text_end
