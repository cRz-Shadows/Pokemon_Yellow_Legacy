SummerBeachHouse_Script:
	call EnableAutoTextBoxDrawing
	ret

SummerBeachHouse_TextPointers:
	def_text_pointers
	dw_const SummerBeachHouseSurfinDudeText, TEXT_SUMMERBEACHHOUSE_SURFINDUDE
	dw_const SummerBeachHousePikachuText,    TEXT_SUMMERBEACHHOUSE_PIKACHU
	dw_const SummerBeachHousePoster1Text,    TEXT_SUMMERBEACHHOUSE_POSTER1
	dw_const SummerBeachHousePoster2Text,    TEXT_SUMMERBEACHHOUSE_POSTER2
	dw_const SummerBeachHousePoster3Text,    TEXT_SUMMERBEACHHOUSE_POSTER3
	dw_const SummerBeachHousePrinterText,    TEXT_SUMMERBEACHHOUSE_PRINTER

SummerBeachHouseSurfinDudeText:
	text_asm
	ld a, [wd472]
	vc_patch Bypass_need_Pikachu_with_Surf_for_minigame
IF DEF (_YELLOW_VC)
	bit 7, a
ELSE
	bit 6, a
ENDC
	vc_patch_end
	jr nz, .next
	call SummerBeachHouseCheckPickStarterSurfer
	jr nz, .next
	ld hl, .SurfinDudeText4
	call PrintText
	jr .done
.next
	ld hl, wPikachuMapScriptFlags
	bit 0, [hl]
	set 0, [hl]
	jr nz, .next2
	ld hl, .SurfinDudeText1
	ld a, [wd472]
	bit 6, a
	jr nz, .next3
	call SummerBeachHouseCheckPickStarterSurfer
	jr z, .next3
	ld hl, .SurfinDudePickStarterText1 ; it isn't a PIKACHU that surfs
	jr .next3
.next2
	ld hl, .SurfinDudeText3
.next3
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .asm_f226b
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	farcall SurfingPikachuMinigame
	ld hl, wPikachuMapScriptFlags
	set 1, [hl]
	jr .done
.asm_f226b
	ld hl, .SurfinDudeText2
	call PrintText
.done
	jp TextScriptEnd

.SurfinDudeText1
	text_far _SummerBeachHouseSurfinDudeText1
	text_end

.SurfinDudePickStarterText1
	text_far _SummerBeachHouseSurfinDudePickStarterText1
	text_end
.SurfinDudeText2
	text_far _SummerBeachHouseSurfinDudeText2
	text_end
.SurfinDudeText3
	text_far _SummerBeachHouseSurfinDudeText3
	text_end
.SurfinDudeText4
	text_far _SummerBeachHouseSurfinDudeText4
	text_end

SummerBeachHousePikachuText:
	text_asm
	ld hl, .SummerBeachHousePikachuText
	call PrintText
	ld a, PIKACHU
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd

.SummerBeachHousePikachuText
	text_far _SummerBeachHousePikachuText
	text_end

SummerBeachHousePoster1Text:
	text_asm
	ld hl, .SummerBeachHousePoster1Text2
	ld a, [wd472]
	bit 6, a
	jr nz, .surfer
	call SummerBeachHouseCheckPickStarterSurfer
	jr z, .next
.surfer
	ld hl, .SummerBeachHousePoster1Text1
.next
	call PrintText
	jp TextScriptEnd

.SummerBeachHousePoster1Text1
	text_far _SummerBeachHousePoster1Text1
	text_end
.SummerBeachHousePoster1Text2
	text_far _SummerBeachHousePoster1Text2
	text_end

SummerBeachHousePoster2Text:
	text_asm
	ld hl, .SummerBeachHousePoster2Text2
	ld a, [wd472]
	bit 6, a
	jr nz, .surfer
	call SummerBeachHouseCheckPickStarterSurfer
	jr z, .next
.surfer
	ld hl, .SummerBeachHousePoster2Text1
.next
	call PrintText
	jp TextScriptEnd

.SummerBeachHousePoster2Text1
	text_far _SummerBeachHousePoster2Text1
	text_end
.SummerBeachHousePoster2Text2
	text_far _SummerBeachHousePoster2Text2
	text_end

SummerBeachHousePoster3Text:
	text_asm
	ld hl, .SummerBeachHousePoster3Text2
	ld a, [wd472]
	bit 6, a
	jr nz, .surfer
	call SummerBeachHouseCheckPickStarterSurfer
	jr z, .next
.surfer
	ld hl, .SummerBeachHousePoster3Text1
.next
	call PrintText
	jp TextScriptEnd

.SummerBeachHousePoster3Text1
	text_far _SummerBeachHousePoster3Text1
	text_end
.SummerBeachHousePoster3Text2
	text_far _SummerBeachHousePoster3Text2
	text_end

SummerBeachHousePrinterText:
	text_asm
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld a, [wd472]
	vc_patch Bypass_need_Pikachu_with_Surf_for_high_score
IF DEF(_YELLOW_VC)
	bit 7, a
ELSE
	bit 6, a
ENDC
	vc_patch_end
	jr nz, .canSurf
	call SummerBeachHouseCheckPickStarterSurfer
	jr z, .asm_f2369
.canSurf
	ld hl, wPikachuMapScriptFlags
	bit 1, [hl]
	jr z, .next2
	ld a, 0
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
.next2
	ld hl, .SummerBeachHousePrinterText2
	call PrintText
	ld a, [wPikachuMapScriptFlags]
	bit 1, a
	jr z, .asm_f236f

	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, .SummerBeachHousePrinterText3
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp z, Func_f23d0
	call SaveScreenTilesToBuffer2
	ld hl, wStatusFlags5
	set 6, [hl]
	xor a
	ld [wUpdateSpritesEnabled], a
	callfar Printer_PrepareSurfingMinigameHighScoreTileMap
	call WaitForTextScrollButtonPress
	ld hl, wStatusFlags5
	res 6, [hl]
	call GBPalWhiteOutWithDelay3
	call ReloadTilesetTilePatterns
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadScreenTilesFromBuffer2
	call Delay3
	call GBPalNormal
	ld a, 1
	ld [wUpdateSpritesEnabled], a
	jr .asm_f236f
.asm_f2369
	ld hl, .SummerBeachHousePrinterText1
	call PrintText
.asm_f236f
	jp TextScriptEnd

.SummerBeachHousePrinterText1
	text_far _SummerBeachHousePrinterText1
	text_waitbutton
	text_end

.SummerBeachHousePrinterText2
	text_far _SummerBeachHousePrinterText2
	text_waitbutton
	text_end

.SummerBeachHousePrinterText3
	text_far _SummerBeachHousePrinterText3
	text_end

.SummerBeachHousePrinterText4
	text_far _SummerBeachHousePrinterText4
	text_end

; In Pick Starter mode without a starter Pikachu, any party Pokémon that knows
; SURF can play the surfing minigame (normally only a PIKACHU with SURF can).
; Returns nz if that applies and such a Pokémon is in the party.
SummerBeachHouseCheckPickStarterSurfer:
	ld a, [wDifficulty]
	cp DIFFICULTY_PICK_STARTER
	jr nz, .no
	ld a, [wPlayerStarter]
	cp STARTER_PIKACHU
	jr z, .no
	ld a, [wPartyCount]
	and a
	jr z, .no
	ld c, a
	ld hl, wPartyMon1Moves
.monLoop
	push hl
	ld b, NUM_MOVES
.moveLoop
	ld a, [hli]
	cp SURF
	jr z, .found
	dec b
	jr nz, .moveLoop
	pop hl
	ld de, PARTYMON_STRUCT_LENGTH
	add hl, de
	dec c
	jr nz, .monLoop
.no
	xor a
	ret
.found
	pop hl
	or 1
	ret
