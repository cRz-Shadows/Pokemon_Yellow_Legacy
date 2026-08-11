DisplayMonFrontSpriteInBox:
; Displays a pokemon's front sprite in a pop-up window.
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	xor a
	ldh [hWY], a
	call SaveScreenTilesToBuffer1
	ld a, MON_SPRITE_POPUP
	ld [wTextBoxID], a
	call DisplayTextBoxID
	call UpdateSprites
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	call GetMonHeader
	ld de, vChars1 tile $31
	call LoadMonFrontSprite
	ld a, $80
	ldh [hStartTileID], a
	hlcoord 10, 11
	predef AnimateSendingOutMon
	ld a, [wCurPartySpecies]
	cp FOSSIL_KABUTOPS
	jr z, .skipCry
	cp FOSSIL_AERODACTYL
	jr z, .skipCry
	call PlayCry
.skipCry
	call WaitForTextScrollButtonPress
	call LoadScreenTilesFromBuffer1
	call Delay3
	ld a, $90
	ldh [hWY], a
	ret
