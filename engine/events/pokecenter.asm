DisplayPokemonCenterDialogue_::
	ld a, [wCurMap]
	cp PEWTER_POKECENTER
	jr nz, .regularCenter
	call CheckPikachuFollowingPlayer
	jr z, .regularCenter
	ld hl, LooksContentText ; if pikachu is sleeping, don't heal
	call PrintText
	ret
.regularCenter
	call SaveScreenTilesToBuffer1 ; save screen
	CheckEvent EVENT_FIRST_POKECENTER
	jr nz, .skiptext1
	ld hl, PokemonCenterWelcomeText
	call PrintText
	ld a, [wPartyCount]
	and a
	jp z, .naotenho
	ld hl, wStatusFlags4
	bit BIT_USED_POKECENTER, [hl]
	set BIT_UNKNOWN_4_1, [hl]
	set BIT_USED_POKECENTER, [hl]
	jr nz, .skipShallWeHealYourPokemon
	ld hl, ShallWeHealYourPokemonText
	call PrintText
.skipShallWeHealYourPokemon
	call YesNoChoicePokeCenter ; yes/no menu
	call UpdateSprites
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .declinedHealing ; if the player chose No
	jr .skipHealingText
.skiptext1
	ld hl, ShallWeHealYourPokemonFastText
	call PrintText
.skipHealingText
	call SetLastBlackoutMap
	callfar IsStarterPikachuAliveInOurParty
	jr nc, .notHealingPlayerPikachu
	call CheckPikachuFollowingPlayer
	jr nz, .notHealingPlayerPikachu
	call LoadCurrentMapView
	call Delay3
	call UpdateSprites
	callfar PikachuWalksToNurseJoy ; todo
.notHealingPlayerPikachu
	call LoadCurrentMapView
	call Delay3
	call UpdateSprites
	CheckEvent EVENT_FIRST_POKECENTER
	jr nz, .skiptext2
	ld hl, NeedYourPokemonText
	call PrintText
.skiptext2
	ld c, 34
	call DelayFrames
	call CheckPikachuFollowingPlayer
	jr nz, .playerPikachuNotOnScreen
	call DisablePikachuOverworldSpriteDrawing
	callfar IsStarterPikachuAliveInOurParty
	call c, PokeCenterNurseTurnAround
.playerPikachuNotOnScreen
	lb bc, 1, 8
	call SetSpriteFacingAndImageIndex
	ld c, 30
	call DelayFrames
	farcall AnimateHealingMachine ; do the healing machine animation
	predef HealParty
	xor a
	ld [wAudioFadeOutControl], a
	ld a, [wAudioSavedROMBank]
	ld [wAudioROMBank], a
	ld a, [wMapMusicSoundID]
	ld [wLastMusicSoundID], a
	ld [wNewSoundID], a
	call PlaySound
	call CheckPikachuFollowingPlayer
	jr nz, .doNotReturnPikachu
	callfar IsStarterPikachuAliveInOurParty
	call c, PokeCenterNurseTurnAround
	ld a, $5
	ld [wPikachuSpawnState], a
	call EnablePikachuOverworldSpriteDrawing
.doNotReturnPikachu
	lb bc, 1, 0
	call SetSpriteFacingAndImageIndex
	CheckEvent EVENT_FIRST_POKECENTER
	jr nz, .FightingFitShort
	ld hl, PokemonFightingFitText
	call PrintText
.FightingFitShort
	call UpdateSprites
	callfar IsStarterPikachuAliveInOurParty
	jr nc, .notInParty
	lb bc, 15, 0
	call SetSpriteFacingAndImageIndex
.notInParty
	call LoadCurrentMapView
	call Delay3
	call UpdateSprites
	callfar ReloadWalkingTilePatterns
	ld a, $1
	ldh [hSpriteIndex], a
	ld a, $1
	ldh [hSpriteImageIndex], a
	call SetSpriteImageIndexFromPicID
	ld c, 40
	call DelayFrames
	call UpdateSprites
	call LoadFontTilePatterns
	jr .done
.declinedHealing
	call LoadScreenTilesFromBuffer1 ; restore screen
	jr .skipEventFirstPokecenter
.done
	SetEvent EVENT_FIRST_POKECENTER
.skipEventFirstPokecenter
	ld hl, PokemonCenterFarewellText
	call PrintText
	call UpdateSprites
	ld a, PLAYER_DIR_DOWN
	ld [wPlayerMovingDirection], a
	ret

.naotenho
	ld hl, TemPokemonOuNao
	jp PrintText

TemPokemonOuNao:
	text_far _TemPokemonOuNao
	text_end

; Turns the nurse (sprite 1) to face the back wall and waits 64 frames.
; Used when she takes the starter Pikachu to heal it and when she returns it.
PokeCenterNurseTurnAround:
	ld a, $1
	ldh [hSpriteIndex], a
	ld a, $4
	ldh [hSpriteImageIndex], a
	call SetSpriteImageIndexFromPicID
	ld c, 64
	call DelayFrames
	ret

; Sets sprite b's facing direction to c (with delay), then its image index to c
SetSpriteFacingAndImageIndex:
	ld a, b
	ldh [hSpriteIndex], a
	ld a, c
	ldh [hSpriteImageIndex], a
	push bc
	call SetSpriteFacingDirectionAndDelay
	pop bc
	ld a, b
	ldh [hSpriteIndex], a
	ld a, c
	ldh [hSpriteImageIndex], a
	call SetSpriteImageIndexFromPicID
	ret

PokemonCenterWelcomeText:
	text_far _PokemonCenterWelcomeText
	text_end

ShallWeHealYourPokemonText:
	text_pause
	text_far _ShallWeHealYourPokemonText
	text_end

ShallWeHealYourPokemonFastText:
	text_far _ShallWeHealYourPokemonText
	text_pause
	text_end

NeedYourPokemonText:
	text_far _NeedYourPokemonText
	text_end

PokemonFightingFitText:
	text_far _PokemonFightingFitText
	text_end

; PokemonFightingFitShortText:
; 	text_far _PokemonFightingFitShortText
; 	text_pause
; 	text_end

PokemonCenterFarewellText:
	; text_pause
	text_far _PokemonCenterFarewellText
	text_pause
	text_end

LooksContentText:
	text_far _LooksContentText
	text_end
