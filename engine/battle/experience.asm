GainExperience:
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	ret z ; return if link battle
	call DivideExpDataByNumMonsGainingExp
	ld a, [wBoostExpByExpAll] ;load in a if the EXP All is being used
	ld hl, WithExpAllText ; this is preparing the text to show
	and a ;check wBoostExpByExpAll value
	jr z, .skipExpAll ; if wBoostExpByExpAll is zero, we are not using it, so we don't show anything and keep going on
	call PrintText ; if the code reaches this point it means we have the Exp.All, so show the message
.skipExpAll
	ld hl, wPartyMon1
	xor a
	ld [wWhichPokemon], a
.partyMonLoop ; loop over each mon and add gained exp
	inc hl
	ld a, [hli]
	or [hl] ; is mon's HP 0?
	jp z, .nextMon ; if so, go to next mon
	push hl
	ld hl, wPartyGainExpFlags
	ld a, [wWhichPokemon]
	ld c, a
	ld b, FLAG_TEST
	predef FlagActionPredef
	ld a, c
	and a ; is mon's gain exp flag set?
	pop hl
	jp z, .nextMon ; if mon's gain exp flag not set, go to next mon
	ld de, (wPartyMon1HPExp + 1) - (wPartyMon1HP + 1)
	add hl, de
	ld d, h
	ld e, l
	ld hl, wEnemyMonBaseStats
	ld c, NUM_STATS
.gainStatExpLoop
	ld a, [hli]
	ld b, a ; enemy mon base stat
	ld a, [de] ; stat exp
	add b ; add enemy mon base state to stat exp
	ld [de], a
	jr nc, .nextBaseStat
; if there was a carry, increment the upper byte
	dec de
	ld a, [de]
	inc a
	jr z, .maxStatExp ; jump if the value overflowed
	ld [de], a
	inc de
	jr .nextBaseStat
.maxStatExp ; if the upper byte also overflowed, then we have hit the max stat exp
	dec a ; ld a, $ff; a is 0 from previous check
	ld [de], a
	inc de
	ld [de], a
.nextBaseStat
	dec c
	jr z, .statExpDone
	inc de
	inc de
	jr .gainStatExpLoop
.statExpDone
	xor a
	ldh [hMultiplicand], a
	ldh [hMultiplicand + 1], a
	ld a, [wEnemyMonBaseExp]
	ldh [hMultiplicand + 2], a
	ld a, [wEnemyMonLevel]
	ldh [hMultiplier], a
	call Multiply
	ld a, 7
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ld hl, wPartyMon1OTID - (wPartyMon1DVs - 1)
	add hl, de
	ld b, [hl] ; party mon OTID
	inc hl
	ld a, [wPlayerID]
	cp b
	jr nz, .tradedMon
	ld b, [hl]
	ld a, [wPlayerID + 1]
	cp b
	ld a, 0
	jr z, .next
.tradedMon
	call BoostExp ; traded mon exp boost
	ld a, 1
.next
	ld [wGainBoostedExp], a
	ld a, [wIsInBattle]
	dec a ; is it a trainer battle?
	call nz, BoostExp ; if so, boost exp
	inc hl
	inc hl
	inc hl
; add the gained exp to the party mon's exp
	ld b, [hl]
	ldh a, [hQuotient + 3]
	ld [wExpAmountGained + 1], a
	add b
	ld [hld], a
	ld b, [hl]
	ldh a, [hQuotient + 2]
	ld [wExpAmountGained], a
	adc b
	ld [hl], a
	jr nc, .noCarry
	dec hl
	inc [hl]
	inc hl
.noCarry
; calculate exp for the mon at max level, and cap the exp at that value
	inc hl
	push hl
	ld a, [wWhichPokemon]
	ld c, a
	ld b, 0
	ld hl, wPartySpecies
	add hl, bc
	ld a, [hl] ; species
	ld [wd0b5], a
	call GetMonHeader
	ld d, MAX_LEVEL

	ld a, [wDifficulty] ; Check if player is on hard mode
	and a
	jr z, .next1 ; no level caps if not on hard mode

	ld a, [wGameStage] ; Check if player has beat the game
	and a
	ld d, 100
	jr nz, .next1
	call GetBadgesObtained
	ld a, [wNumSetBits]
	cp 8
	ld d, 65 ; Jolteon/Flareon/Vaporeon's level
	jr nc, .next1
	cp 7
	ld d, 55 ; Rhydon's level
	jr nc, .next1
	cp 6
	ld d, 53 ; Magmar's level
	jr nc, .next1
	cp 5
	ld d, 50 ; Alakazam's level
	jr nc, .next1
    cp 4
	ld d, 43 ; Venomoth's level
	jr nc, .next1
	cp 3
	ld d, 35 ; Vileplume's level
	jr nc, .next1
	cp 2
    ld d, 24 ; Bit below Raichu's level
	jr nc, .next1
	cp 1
	ld d, 21 ; Starmie's level
	jr nc, .next1
	ld d, 12 ; Onix's level
.next1
	callfar CalcExperience ; get max exp
; compare max exp with current exp
	ldh a, [hExperience]
	ld b, a
	ldh a, [hExperience + 1]
	ld c, a
	ldh a, [hExperience + 2]
	ld d, a
	pop hl
	ld a, [hld]
	sub d
	ld a, [hld]
	sbc c
	ld a, [hl]
	sbc b
	jr c, .next2
; the mon's exp is greater than the max exp, so overwrite it with the max exp
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, d
	ld [hld], a
	dec hl
.next2
	push hl
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld a, [wBoostExpByExpAll] ; get using ExpAll flag
	and a ; check the flag
	jr nz, .skipExpText ; if there's EXP. all, skip showing any text
	ld hl, GainedText ;there's no EXP. all, load the text to show
	call PrintText
.skipExpText
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
	call LoadMonData
	call AnimateEXPBar
	pop hl
	ld bc, wPartyMon1Level - wPartyMon1Exp
	add hl, bc
	push hl
	farcall CalcLevelFromExperience
	pop hl
	ld a, [hl] ; current level
;;;;;;;;;; PureRGBnote: FIXED: fixing skip move-learn glitch: need to store the current level in wram
	ld [wTempLevelStore], a
	cp d
	jp z, .nextMon ; if level didn't change, go to next mon
;;;;;;;;;;
	ld a, [wCurEnemyLVL]
	push af
	push hl
	ld a, d
	ld [wCurEnemyLVL], a
	ld [hl], a
	ld bc, wPartyMon1Species - wPartyMon1Level
	add hl, bc
	ld a, [hl] ; species
	ld [wd0b5], a
	ld [wd11e], a
	call GetMonHeader
	ld bc, (wPartyMon1MaxHP + 1) - wPartyMon1Species
	add hl, bc
	push hl
	ld a, [hld]
	ld c, a
	ld b, [hl]
	push bc ; push max HP (from before levelling up)
	ld d, h
	ld e, l
	ld bc, (wPartyMon1HPExp - 1) - wPartyMon1MaxHP
	add hl, bc
	ld b, $1 ; consider stat exp when calculating stats
	call CalcStats
	pop bc ; pop max HP (from before levelling up)
	pop hl
	ld a, [hld]
	sub c
	ld c, a
	ld a, [hl]
	sbc b
	ld b, a ; bc = difference between old max HP and new max HP after levelling
	ld de, (wPartyMon1HP + 1) - wPartyMon1MaxHP
	add hl, de
; add to the current HP the amount of max HP gained when levelling
	ld a, [hl] ; wPartyMon1HP + 1
	add c
	ld [hld], a
	ld a, [hl] ; wPartyMon1HP + 1
	adc b
	ld [hl], a ; wPartyMon1HP
	ld a, [wPlayerMonNumber]
	ld b, a
	ld a, [wWhichPokemon]
	cp b ; is the current mon in battle?
	jr nz, .printGrewLevelText
; current mon is in battle
	ld de, wBattleMonHP
; copy party mon HP to battle mon HP
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
; copy other stats from party mon to battle mon
	ld bc, wPartyMon1Level - (wPartyMon1HP + 1)
	add hl, bc
	push hl
	ld de, wBattleMonLevel
	ld bc, 1 + NUM_STATS * 2 ; size of stats
	call CopyData
	pop hl
	ld a, [wPlayerBattleStatus3]
	bit 3, a ; is the mon transformed?
	jr nz, .recalcStatChanges
; the mon is not transformed, so update the unmodified stats
	ld de, wPlayerMonUnmodifiedLevel
	ld bc, 1 + NUM_STATS * 2
	call CopyData
.recalcStatChanges
	xor a ; battle mon
	ld [wCalculateWhoseStats], a
	ld hl, CalculateModifiedStats
	call CallBattleCore
	ld hl, ApplyBurnAndParalysisPenaltiesToPlayer
	call CallBattleCore
	ld hl, ApplyBadgeStatBoosts
	call CallBattleCore
	ld hl, DrawPlayerHUDAndHPBar
	call CallBattleCore
	ld hl, PrintEmptyString
	call CallBattleCore
	call SaveScreenTilesToBuffer1
.printGrewLevelText
	callabd_ModifyPikachuHappiness PIKAHAPPY_LEVELUP
	ld hl, GrewLevelText
	call PrintText
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
	call LoadMonData
	ld d, $1
	callfar PrintStatsBox
	call WaitForTextScrollButtonPress
	call LoadScreenTilesFromBuffer1
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
	ld a, [wd0b5]
	ld [wd11e], a
;;;;;;;;;;;;;;;;;;;;
;shinpokerednote: FIXED: fixing skip move-learn glitch: here is where moves are learned from level-up
	ld a, [wCurEnemyLVL]	; load the level to advance to into a. this starts out as the final level.
	ld c, a	; load the final level to grow to over to c
	ld a, [wTempLevelStore]	; load the current level into a
	ld b, a	; load the current level over to b
.inc_level	; marker for looping back 
	inc b	;increment 	the current level
	ld a, b	;put the current level in a
	ld [wCurEnemyLVL], a	;and reset the level to advance to as merely 1 higher
	push bc	;save b & c on the stack as they hold the current a true final level
	predef LearnMoveFromLevelUp
	pop bc	;get the current and final level values back from the stack
	ld a, b	;load the current level into a
	cp c	;compare it with the final level
	jr nz, .inc_level	;loop back again if final level has not been reached
;;;;;;;;;;;;;;;;;;;;
	ld hl, wCanEvolveFlags
	ld a, [wWhichPokemon]
	ld c, a
	ld b, FLAG_SET
	predef FlagActionPredef
	pop hl
	pop af
	ld [wCurEnemyLVL], a

.nextMon
	ld a, [wPartyCount]
	ld b, a
	ld a, [wWhichPokemon]
	inc a
	cp b
	jr z, .done
	ld [wWhichPokemon], a
	ld bc, wPartyMon2 - wPartyMon1
	ld hl, wPartyMon1
	call AddNTimes
	jp .partyMonLoop
.done
	ld hl, wPartyGainExpFlags
	xor a
	ld [hl], a ; clear gain exp flags
	ld a, [wPlayerMonNumber]
	ld c, a
	ld b, FLAG_SET
	push bc
	predef FlagActionPredef ; set the gain exp flag for the mon that is currently out
	ld hl, wPartyFoughtCurrentEnemyFlags
	xor a
	ld [hl], a
	pop bc
	predef_jump FlagActionPredef ; set the fought current enemy flag for the mon that is currently out

; divide enemy base stats, catch rate, and base exp by the number of mons gaining exp
DivideExpDataByNumMonsGainingExp:
	ld a, [wPartyGainExpFlags]
	ld b, a
	xor a
	ld c, $8
	ld d, $0
.countSetBitsLoop ; loop to count set bits in wPartyGainExpFlags
	xor a
	srl b
	adc d
	ld d, a
	dec c
	jr nz, .countSetBitsLoop
	cp $2
	ret c ; return if only one mon is gaining exp
	ld [wd11e], a ; store number of mons gaining exp
	ld hl, wEnemyMonBaseStats
	ld c, wEnemyMonBaseExp + 1 - wEnemyMonBaseStats
.divideLoop
	xor a
	ldh [hDividend], a
	ld a, [hl]
	ldh [hDividend + 1], a
	ld a, [wd11e]
	ldh [hDivisor], a
	ld b, $2
	call Divide ; divide value by number of mons gaining exp
	ldh a, [hQuotient + 3]
	ld [hli], a
	dec c
	jr nz, .divideLoop
	ret

; multiplies exp by 1.5
BoostExp:
	ldh a, [hQuotient + 2]
	ld b, a
	ldh a, [hQuotient + 3]
	ld c, a
	srl b
	rr c
	add c
	ldh [hQuotient + 3], a
	ldh a, [hQuotient + 2]
	adc b
	ldh [hQuotient + 2], a
	ret

CallBattleCore:
	ld b, BANK(BattleCore)
	jp Bankswitch

GainedText:
	text_far _GainedText
	text_asm
	ld a, [wBoostExpByExpAll]
	ld hl, WithExpAllText
	and a
	ret nz
	ld hl, ExpPointsText
	ld a, [wGainBoostedExp]
	and a
	ret z
	ld hl, BoostedText
	ret

WithExpAllText:
	text_far _WithExpAllText
	text_asm
	ld hl, ExpPointsText
	ret

BoostedText:
	text_far _BoostedText

ExpPointsText:
	text_far _ExpPointsText
	text_end

GrewLevelText:
	text_far _GrewLevelText
	sound_level_up
	text_end

AnimateEXPBarAgain:
	call IsCurrentMonBattleMon
	ret nz
	xor a
	ld [wEXPBarPixelLength], a
	coord hl, 17, 11
	ld a, $c0
	ld c, $08
.loop
	ld [hld], a
	dec c
	jr nz, .loop
AnimateEXPBar:
	call IsCurrentMonBattleMon
	ret nz
	ld a, SFX_HEAL_HP
	call PlaySoundWaitForCurrent
	ld hl, CalcEXPBarPixelLength
	ld b, BANK(CalcEXPBarPixelLength)
	call Bankswitch
	ld hl, wEXPBarPixelLength
	ld a, [hl]
	ld b, a
	ld a, [hQuotient + 3]
	ld [hl], a
	sub b
	jr z, .done
	ld b, a
	ld c, $08
	coord hl, 17, 11
.loop1
	ld a, [hl]
	cp $c8
	jr nz, .loop2
	dec hl
	dec c
	jr z, .done
	jr .loop1
.loop2
	inc a
	ld [hl], a
	call DelayFrame
	dec b
	jr z, .done
	jr .loop1
.done
	ld bc, $08
	coord hl, 10, 11
	ld de, wTileMapBackup + 10 + 11 * 20
	call CopyData
	ld c, $20
	jp DelayFrames

KeepEXPBarFull:
	call IsCurrentMonBattleMon
	ret nz
	ld a, [wEXPBarKeepFullFlag]
	set 0, a
	ld [wEXPBarKeepFullFlag], a
	ret

IsCurrentMonBattleMon:
	ld a, [wPlayerMonNumber]
	ld b, a
	ld a, [wWhichPokemon]
	cp b
	ret

; function to count the set bits in wObtainedBadges
; OUTPUT:
; a = set bits in wObtainedBadges
GetBadgesObtained::
	push hl
	push bc
	push de
	ld hl, wObtainedBadges
	ld b, $1
	call CountSetBits
	pop de
	pop bc
	pop hl
	ld a, [wNumSetBits]
	ret
