_DisplayPokedex::
	ld hl, wStatusFlags5
	set 6, [hl]
	predef ShowPokedexData
	ld hl, wStatusFlags5
	res 6, [hl]
	call ReloadMapData
	ld c, 10
	call DelayFrames
	predef IndexToPokedex
	ld a, [wPokedexNum]
	dec a
	ld c, a
	ld b, FLAG_SET
	ld hl, wPokedexSeen
	predef FlagActionPredef
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ret
