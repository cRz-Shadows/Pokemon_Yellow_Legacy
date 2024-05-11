InitMapSprites::
	jpfar _InitMapSprites

RestoreScreenTilesAndReloadTilePatterns::
	call ClearSprites
	ld a, $1
	ld [wUpdateSpritesEnabled], a
	call ReloadMapSpriteTilePatterns
	call LoadScreenTilesFromBuffer2
	call LoadTextBoxTilePatterns
	call RunDefaultPaletteCommand
	jr Delay3

GBPalWhiteOutWithDelay3::
	call GBPalWhiteOut

Delay3::
; The bg map is updated each frame in thirds.
; Wait three frames to let the bg map fully update.
	ld c, 3
	jp DelayFrames

GBPalNormal::
; Reset OBP0 to default
	ld a, %11010000 ; 3100
	jr GBPalOBP0Set
GBPalIcons::
; Reset OBP0 for icons
	ld a, %11100100 ; 3210
	; fallthrough
GBPalOBP0Set:
; Set OBP0
	ldh [rOBP0], a
	ld a, %11100100 ; 3210
	jr GBPalBGPSet
GBPalWhiteOut::
; White out all palettes.
	xor a
	ldh [rOBP0], a
	ldh [rOBP1], a
	; fallthrough
GBPalBGPSet:
; Set BGP
	ldh [rBGP], a
	call UpdateGBCPal_BGP
	call UpdateGBCPal_OBP0
	call UpdateGBCPal_OBP1
	ret

RunDefaultPaletteCommand::
	ld b, SET_PAL_DEFAULT
RunPaletteCommand::
	ld a, [wOnSGB]
	and a
	ret z
	predef_jump _RunPaletteCommand

GetHealthBarColor::
; Return at hl the palette of
; an HP bar e pixels long.
	ld a, e
	cp 27
	ld d, 0 ; green
	jr nc, .gotColor
	cp 10
	inc d ; yellow
	jr nc, .gotColor
	inc d ; red
.gotColor
	ld [hl], d
	ret
