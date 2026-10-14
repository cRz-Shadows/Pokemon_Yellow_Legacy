CeladonMansion1FPrintGrannyText::
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, CeladonMansion1FGrannyKeepMeCompanyText
	call PrintText
	callfar IsStarterPikachuAliveInOurParty
	ret nc
	ld hl, CeladonMansion1FGrannyAdorablePikachuText
	call PrintText
	ld a, $0
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	call CeladonMansion1FGetPikachuHappinessText
	call PrintText
	ret

; Granny: "My dear #MON keep me company."
CeladonMansion1FGrannyKeepMeCompanyText:
	text_far _CeladonMansion1Text2
	text_waitbutton
	text_end

; Granny: "Oh, you have an adorable PIKACHU with you."
CeladonMansion1FGrannyAdorablePikachuText:
	text_far _CeladonMansion1Text6
	text_promptbutton
	text_end

; Returns in hl the granny's text for the current wPikachuHappiness bracket
CeladonMansion1FGetPikachuHappinessText:
	ld hl, CeladonMansion1FPikachuHappinessTexts
.asm_f1ea5
	ld a, [hli]
	inc hl
	and a
	jr z, .asm_f1eb5
	ld b, a
	ld a, [wPikachuHappiness]
	cp b
	jr c, .asm_f1eb5
	inc hl
	inc hl
	jr .asm_f1ea5

.asm_f1eb5
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

; Table of (happiness threshold, text) pairs used by the granny
CeladonMansion1FPikachuHappinessTexts:
	dw   51, CeladonMansion1FPikachuUntamedText
	dw  101, CeladonMansion1FPikachuTakeMoreCareText
	dw  131, CeladonMansion1FPikachuCuteText
	dw  161, CeladonMansion1FPikachuTamedText
	dw  201, CeladonMansion1FPikachuLooksHappyText
	dw  255, CeladonMansion1FPikachuFantasticDuoText
	dw -256, CeladonMansion1FPikachuFantasticDuoText

; Happiness < 51: "It seems like it hasn't been tamed at all."
CeladonMansion1FPikachuUntamedText:
	text_far _CeladonMansion1Text7
	text_end

; Happiness < 101: "Why don't you take more care with PIKACHU?"
CeladonMansion1FPikachuTakeMoreCareText:
	text_far _CeladonMansion1Text8
	text_end

; Happiness < 131: "You must be happy to have a #MON that cute."
CeladonMansion1FPikachuCuteText:
	text_far _CeladonMansion1Text9
	text_end

; Happiness < 161: "Your PIKACHU seems tamed."
CeladonMansion1FPikachuTamedText:
	text_far _CeladonMansion1Text10
	text_end

; Happiness < 201: "Your PIKACHU looks happy with you."
CeladonMansion1FPikachuLooksHappyText:
	text_far _CeladonMansion1Text11
	text_end

; Happiness >= 201: "You look like a fantastic duo."
CeladonMansion1FPikachuFantasticDuoText:
	text_far _CeladonMansion1Text12
	text_end
