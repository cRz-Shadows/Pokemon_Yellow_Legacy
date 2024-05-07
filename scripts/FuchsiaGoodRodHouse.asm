FuchsiaGoodRodHouse_Script:
	jp EnableAutoTextBoxDrawing

FuchsiaGoodRodHouse_TextPointers:
	def_text_pointers
	dw_const FuchsiaGoodRodHouseFishingGuruText, TEXT_FUCHSIAGOODRODHOUSE_FISHING_GURU

FuchsiaGoodRodHouseFishingGuruText:
	text_asm
	CheckEvent EVENT_GOT_FUCHSIA_FOSSIL_GIFT
	jr nz, .got_gift
	ld hl, .Text
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .refused
	CheckEvent EVENT_GOT_DOME_FOSSIL
	jr nz, .giveOmanyte
	lb bc, KABUTO, 10
	jr .giveGiftMon
.giveOmanyte
	lb bc, OMANYTE, 10
.giveGiftMon
	call GivePokemon
	jp nc, TextScriptEnd
	SetEvent EVENT_GOT_FUCHSIA_FOSSIL_GIFT
	jr .done
.refused
	ld hl, .ThatsSoDisappointingText
	call PrintText
	jr .done
.got_gift
	ld hl, .HowAreTheFishText
	call PrintText
.done
	jp TextScriptEnd

.Text:
	text_far _FuchsiaGoodRodHouseFishingGuruText
	text_end

.ReceivedGiftText:
	text_far _FuchsiaGoodRodHouseFishingGuruReceivedGiftText
	sound_get_item_1
	text_end

.UnusedText:
	para "つり　こそ"
	line "おとこの　ロマン　だ！"

	para "へぼいつりざおは"
	line "コイキングしか　つれ　なんだが"
	line "この　いいつりざおなら"
	line "もっと　いいもんが　つれるんじゃ！"
	done

.ThatsSoDisappointingText:
	text_far _FuchsiaGoodRodHouseFishingGuruThatsSoDisappointingText
	text_end

.HowAreTheFishText:
	text_far _FuchsiaGoodRodHouseFishingGuruHowAreTheFishText
	text_end

.NoRoomText:
	text_far _FuchsiaGoodRodHouseFishingGuruNoRoomText
	text_end
