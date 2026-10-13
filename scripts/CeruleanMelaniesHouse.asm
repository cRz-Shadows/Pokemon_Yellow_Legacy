CeruleanMelaniesHouse_Script:
	call EnableAutoTextBoxDrawing
	ret

CeruleanMelaniesHouse_TextPointers:
	def_text_pointers
	dw_const CeruleanMelanieHouseMelanieText, TEXT_CERULEANMELANIESHOUSE_MELANIE
	dw_const CeruleanMelanieHouseBulbasaurText, TEXT_CERULEANMELANIESHOUSE_BULBASAUR
	dw_const CeruleanMelanieHouseOddishText, TEXT_CERULEANMELANIESHOUSE_ODDISH
	dw_const CeruleanMelanieHouseSandshrewText, TEXT_CERULEANMELANIESHOUSE_SANDSHREW

CeruleanMelanieHouseMelanieText:
	text_asm
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	CheckEvent EVENT_GOT_BULBASAUR_IN_CERULEAN
	jr nz, .asm_1cfbf
	ld hl, CeruleanHouse1Text_1cfc8
	call PrintText
	; Pick Starter mode without a starter Pikachu: there's no Pikachu
	; happiness to earn (it never changes), so Melanie trusts the player
	ld a, [wPlayerStarter]
	cp STARTER_PIKACHU
	jr nz, .trustsPlayer
	ld a, [wPikachuHappiness]
	cp 147
	jr c, .asm_1cfb3
.trustsPlayer
	ld hl, CeruleanHouse1Text_1cfce
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .asm_1cfb6
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld a, BULBASAUR
	ld [wNamedObjectIndex], a
	ld [wCurPartySpecies], a
	call GetMonName
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	lb bc, BULBASAUR, 10
	call GivePokemon
	jr nc, .asm_1cfb3
	ld a, [wAddedToParty]
	and a
	call z, WaitForTextScrollButtonPress
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, CeruleanHouse1Text_1cfd3
	call PrintText
	ld a, HS_CERULEAN_BULBASAUR
	ld [wToggleableObjectIndex], a
	predef HideObject
	SetEvent EVENT_GOT_BULBASAUR_IN_CERULEAN
.asm_1cfb3
	jp TextScriptEnd

.asm_1cfb6
	ld hl, CeruleanHouse1Text_1cfdf
	call PrintText
	jp TextScriptEnd

.asm_1cfbf
	ld hl, CeruleanHouse1Text_1cfd9
	call PrintText
	jp TextScriptEnd

; SUGGESTED NAME: CeruleanMelanieHouseMelanieIntroText
; Melanie: she nursed Bulbasaur and it needs a good trainer (confidence: high)
CeruleanHouse1Text_1cfc8:
	text_far MelanieText1
	text_waitbutton
	text_end

; SUGGESTED NAME: CeruleanMelanieHouseOfferBulbasaurText
; Melanie asks if you'll take Bulbasaur (only if Pikachu happiness >= 147) (confidence: high)
CeruleanHouse1Text_1cfce:
	text_far MelanieText2
	text_end

; SUGGESTED NAME: CeruleanMelanieHouseTakeCareText
; Melanie: "Please take care of BULBASAUR!" after giving it (confidence: high)
CeruleanHouse1Text_1cfd3:
	text_far MelanieText3
	text_waitbutton
	text_end

; SUGGESTED NAME: CeruleanMelanieHouseBulbasaurWellText
; Melanie after giving Bulbasaur: "Is BULBASAUR doing well?" (confidence: high)
CeruleanHouse1Text_1cfd9:
	text_far MelanieText4
	text_waitbutton
	text_end

; SUGGESTED NAME: CeruleanMelanieHouseTooBadText
; Melanie when you decline Bulbasaur: "Oh... That's too bad..." (confidence: high)
CeruleanHouse1Text_1cfdf:
	text_far MelanieText5
	text_waitbutton
	text_end

CeruleanMelanieHouseBulbasaurText:
	text_far MelanieBulbasaurText
	text_asm
	ld a, BULBASAUR
	call PlayCry
	jp TextScriptEnd

CeruleanMelanieHouseOddishText:
	text_far MelanieOddishText
	text_asm
	ld a, ODDISH
	call PlayCry
	jp TextScriptEnd

CeruleanMelanieHouseSandshrewText:
	text_far MelanieSandshrewText
	text_asm
	ld a, SANDSHREW
	call PlayCry
	jp TextScriptEnd
