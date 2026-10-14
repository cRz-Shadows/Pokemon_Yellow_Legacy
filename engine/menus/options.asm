DisplayOptionMenu_:
	call InitOptionsMenu
.optionMenuLoop
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	and PAD_START | PAD_B
	jr nz, .exitOptionMenu
	call OptionsControl
	jr c, .dpadDelay
	call GetOptionPointer
	jr c, .exitOptionMenu
.dpadDelay
	call OptionsMenu_UpdateCursorPosition
	call DelayFrame
	call DelayFrame
	call DelayFrame
	jr .optionMenuLoop
.exitOptionMenu
	ret

GetOptionPointer:
	ld a, [wOptionsCursorLocation]
	ld e, a
	ld d, $0
	ld hl, OptionMenuJumpTable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl ; jump to the function for the current highlighted option

OptionMenuJumpTable:
	dw OptionsMenu_TextSpeed
	dw OptionsMenu_BattleAnimations
	dw OptionsMenu_BattleStyle
	dw OptionsMenu_SpeakerSettings
	dw OptionsMenu_GBPrinterBrightness
	dw OptionsMenu_Dummy
	dw OptionsMenu_Dummy
	dw OptionsMenu_Cancel

OptionsMenu_TextSpeed:
	call GetTextSpeed
	ldh a, [hJoy5]
	bit B_PAD_RIGHT, a
	jr nz, .pressedRight
	bit B_PAD_LEFT, a
	jr nz, .pressedLeft
	jr .nonePressed
.pressedRight
	ld a, c
	cp $2
	jr c, .increase
	ld c, $ff
.increase
	inc c
	ld a, e
	jr .save
.pressedLeft
	ld a, c
	and a
	jr nz, .decrease
	ld c, $3
.decrease
	dec c
	ld a, d
.save
	ld b, a
	ld a, [wOptions]
	and ~TEXT_DELAY_MASK
	or b
	ld [wOptions], a
.nonePressed
	ld b, $0
	ld hl, TextSpeedStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 14, 2
	call PlaceString
	and a
	ret

TextSpeedStringsPointerTable:
	dw FastText
	dw MidText
	dw SlowText

FastText:
	db "FAST@"
MidText:
	db "MID @"
SlowText:
	db "SLOW@"

GetTextSpeed:
	ld a, [wOptions]
	and TEXT_DELAY_MASK
	cp TEXT_DELAY_SLOW
	jr z, .slowTextOption
	cp TEXT_DELAY_FAST
	jr z, .fastTextOption
; mid text option
	ld c, $1
	lb de, 1, 5
	ret
.slowTextOption
	ld c, $2
	lb de, TEXT_DELAY_MEDIUM, TEXT_DELAY_FAST
	ret
.fastTextOption
	ld c, $0
	lb de, TEXT_DELAY_SLOW, TEXT_DELAY_MEDIUM
	ret

OptionsMenu_BattleAnimations:
	ldh a, [hJoy5]
	and PAD_LEFT | PAD_RIGHT
	jr nz, .buttonPressed
	ld a, [wOptions]
	and 1 << BIT_BATTLE_ANIMATION
	jr .nothingPressed
.buttonPressed
	ld a, [wOptions]
	xor 1 << BIT_BATTLE_ANIMATION
	ld [wOptions], a
.nothingPressed
	ld bc, $0
	sla a
	rl c
	ld hl, AnimationOptionStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 14, 4
	call PlaceString
	and a
	ret

AnimationOptionStringsPointerTable:
	dw AnimationOnText
	dw AnimationOffText

AnimationOnText:
	db "ON @"
AnimationOffText:
	db "OFF@"

OptionsMenu_BattleStyle:
	ldh a, [hJoy5]
	and PAD_LEFT | PAD_RIGHT
	jr nz, .buttonPressed
	ld a, [wOptions]
	and 1 << BIT_BATTLE_SHIFT
	jr .nothingPressed
.buttonPressed
	ld a, [wOptions]
	xor 1 << BIT_BATTLE_SHIFT
	ld [wOptions], a
.nothingPressed
	ld bc, $0
	sla a
	sla a
	rl c
	ld hl, BattleStyleOptionStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 14, 6
	call PlaceString
	and a
	ret

BattleStyleOptionStringsPointerTable:
	dw BattleStyleShiftText
	dw BattleStyleSetText

BattleStyleShiftText:
	db "SHIFT@"
BattleStyleSetText:
	db "SET  @"

OptionsMenu_SpeakerSettings:
	ld a, [wOptions]
	and SOUND_MASK
	swap a
	ld c, a
	ldh a, [hJoy5]
	bit B_PAD_RIGHT, a
	jr nz, .pressedRight
	bit B_PAD_LEFT, a
	jr nz, .pressedLeft
	jr .nothingPressed
.pressedRight
	ld a, c
	inc a
	and SOUND_MASK >> 4
	jr .save
.pressedLeft
	ld a, c
	dec a
	and $3
.save
	ld c, a
	swap a
	ld b, a
	xor a
	ldh [rAUDTERM], a
	ld a, [wOptions]
	and ~SOUND_MASK
	or b
	ld [wOptions], a
.nothingPressed
	ld b, $0
	ld hl, SpeakerOptionStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 8, 8
	call PlaceString
	and a
	ret

SpeakerOptionStringsPointerTable:
	dw MonoSoundText
	dw Earphone1SoundText
	dw Earphone2SoundText
	dw Earphone3SoundText

MonoSoundText:
	db "MONO     @"
Earphone1SoundText:
	db "EARPHONE1@"
Earphone2SoundText:
	db "EARPHONE2@"
Earphone3SoundText:
	db "EARPHONE3@"

OptionsMenu_GBPrinterBrightness:
	call GetGBPrinterBrightness
	ldh a, [hJoy5]
	bit B_PAD_RIGHT, a
	jr nz, .pressedRight
	bit B_PAD_LEFT, a
	jr nz, .pressedLeft
	jr .nothingPressed
.pressedRight
	ld a, c
	cp $4
	jr c, .increase
	ld c, $ff
.increase
	inc c
	ld a, e
	jr .save
.pressedLeft
	ld a, c
	and a
	jr nz, .decrease
	ld c, $5
.decrease
	dec c
	ld a, d
.save
	ld b, a
	ld [wPrinterSettings], a
.nothingPressed
	ld b, $0
	ld hl, GBPrinterOptionStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 8, 10
	call PlaceString
	and a
	ret

GBPrinterOptionStringsPointerTable:
	dw LightestPrintText
	dw LighterPrintText
	dw NormalPrintText
	dw DarkerPrintText
	dw DarkestPrintText

LightestPrintText:
	db "LIGHTEST@"
LighterPrintText:
	db "LIGHTER @"
NormalPrintText:
	db "NORMAL  @"
DarkerPrintText:
	db "DARKER  @"
DarkestPrintText:
	db "DARKEST @"

GetGBPrinterBrightness:
	ld a, [wPrinterSettings]
	and a
	jr z, .setLightest
	cp PRINTER_BRIGHTNESS_LIGHTER
	jr z, .setLighter
	cp PRINTER_BRIGHTNESS_DARKER
	jr z, .setDarker
	cp PRINTER_BRIGHTNESS_DARKEST
	jr z, .setDarkest
	ld c, $2
	lb de, PRINTER_BRIGHTNESS_LIGHTER, PRINTER_BRIGHTNESS_DARKER
	ret
.setLightest
	ld c, $0
	lb de, PRINTER_BRIGHTNESS_DARKEST, PRINTER_BRIGHTNESS_LIGHTER
	ret
.setLighter
	ld c, $1
	lb de, PRINTER_BRIGHTNESS_LIGHTEST, PRINTER_BRIGHTNESS_NORMAL
	ret
.setDarker
	ld c, $3
	lb de, PRINTER_BRIGHTNESS_NORMAL, PRINTER_BRIGHTNESS_DARKEST
	ret
.setDarkest
	ld c, $4
	lb de, PRINTER_BRIGHTNESS_DARKER, PRINTER_BRIGHTNESS_LIGHTEST
	ret

OptionsMenu_Dummy:
	and a
	ret

OptionsMenu_Cancel:
	ldh a, [hJoy5]
	and PAD_A
	jr nz, .pressedCancel
	and a
	ret
.pressedCancel
	scf
	ret

OptionsControl:
	ld hl, wOptionsCursorLocation
	ldh a, [hJoy5]
	cp PAD_DOWN
	jr z, .pressedDown
	cp PAD_UP
	jr z, .pressedUp
	and a
	ret
.pressedDown
	ld a, [hl]
	cp $7
	jr nz, .doNotWrap
	ld [hl], $0
	scf
	ret
.doNotWrap
	cp $4
	jr c, .increase
	ld [hl], $6
.increase
	inc [hl]
	scf
	ret
.pressedUp
	ld a, [hl]
	cp $7
	jr nz, .doNotSkip
	ld [hl], $4
	scf
	ret
.doNotSkip
	and a
	jr nz, .decrease
	ld [hl], $8
.decrease
	dec [hl]
	scf
	ret

OptionsMenu_UpdateCursorPosition:
	hlcoord 1, 1
	ld de, SCREEN_WIDTH
	ld c, 16
.loop
	ld [hl], ' '
	add hl, de
	dec c
	jr nz, .loop
	hlcoord 1, 2
	ld bc, SCREEN_WIDTH * 2
	ld a, [wOptionsCursorLocation]
	call AddNTimes
	ld [hl], '▶'
	ret

InitOptionsMenu:
	hlcoord 0, 0
	lb bc, SCREEN_HEIGHT - 2, SCREEN_WIDTH - 2
	call TextBoxBorder
	hlcoord 2, 2
	ld de, AllOptionsText
	call PlaceString
	hlcoord 2, 16
	ld de, OptionMenuCancelText
	call PlaceString
	xor a
	ld [wOptionsCursorLocation], a
	ld c, 5 ; the number of options to loop through
.loop
	push bc
	call GetOptionPointer ; updates the next option
	pop bc
	ld hl, wOptionsCursorLocation
	inc [hl] ; moves the cursor for the highlighted option
	dec c
	jr nz, .loop
	xor a
	ld [wOptionsCursorLocation], a
	inc a
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	ret

AllOptionsText:
	db   "TEXT SPEED :"
	next "ANIMATION  :"
	next "BATTLESTYLE:"
	next "SOUND:"
	next "PRINT:@"

OptionMenuCancelText:
	db "CANCEL@"
