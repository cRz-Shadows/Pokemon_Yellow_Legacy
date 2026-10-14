; Prints the surfing minigame high score, then says done or error
SummerBeachHousePrintHighScoreScript:
	call SaveScreenTilesToBuffer2
	xor a
	ld [wUpdateSpritesEnabled], a
	ld hl, wStatusFlags5
	set 6, [hl]
	callfar PrintSurfingMinigameHighScore
	ld hl, wStatusFlags5
	res 6, [hl]
	call GBPalWhiteOutWithDelay3
	call ReloadTilesetTilePatterns
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadScreenTilesFromBuffer2
	call Delay3
	call GBPalNormal
	ld hl, SummerBeachHousePrintErrorText
	ldh a, [hOaksAideResult]
	and a
	jr nz, .asm_f2406
	ld hl, SummerBeachHousePrintCompletedText
.asm_f2406
	call PrintText
	jp TextScriptEnd

; "PRINT completed."
SummerBeachHousePrintCompletedText:
	text_far _SummerBeachHousePrinterText5
	text_waitbutton
	text_end

; "PRINT error!"
SummerBeachHousePrintErrorText:
	text_far _SummerBeachHousePrinterText6
	text_waitbutton
	text_end
