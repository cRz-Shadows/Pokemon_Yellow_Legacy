GameCornerPrizeRoom_Script:
	jp EnableAutoTextBoxDrawing

GameCornerPrizeRoom_TextPointers:
	def_text_pointers
	dw_const GameCornerPrizeRoomBaldingGuyText,  TEXT_GAMECORNERPRIZEROOM_BALDING_GUY
	dw_const GameCornerPrizeRoomGamblerText,     TEXT_GAMECORNERPRIZEROOM_GAMBLER
	dw_const GameCornerPrizeRoomClerkText,		 TEXT_GAMECORNERPRIZEROOM_SHADY_CLERK
	dw_const GameCornerPRizeRoomPrizeVendorText, TEXT_GAMECORNERPRIZEROOM_PRIZE_VENDOR_1
	dw_const GameCornerPRizeRoomPrizeVendorText, TEXT_GAMECORNERPRIZEROOM_PRIZE_VENDOR_2
	dw_const GameCornerPRizeRoomPrizeVendorText, TEXT_GAMECORNERPRIZEROOM_PRIZE_VENDOR_3

GameCornerPrizeRoomClerkText:
	text_asm
	; Show player's coins
	call GameCornerDrawCoinBox
	ld hl, .DoYouNeedSomeGameCoins
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declined
	; Can only get more coins if you
	; - have the Coin Case
	ld b, COIN_CASE
	call IsItemInBag
	jr z, .no_coin_case
	; - have room in the Coin Case for at least 9 coins
	call Has9990Coins
	jr nc, .coin_case_full
	; - have at least 1000 yen
	xor a
	ldh [hMoney], a
	ldh [hMoney + 2], a
	ld a, $10
	ldh [hMoney + 1], a
	ld a, $01
	ldh [hMoney + 0], a
	call HasEnoughMoney
	jr nc, .buy_coins
	ld hl, .CantAffordTheCoins
	jr .print_ret
.buy_coins
	; Spend 11000 yen
	xor a
	ldh [hMoney], a
	ldh [hMoney + 2], a
	ld a, $10
	ldh [hMoney + 1], a
	ld a, $01
	ldh [hMoney + 0], a
	ld hl, hMoney + 2
	ld de, wPlayerMoney + 2
	ld c, $3
	predef SubBCDPredef
	; Receive 50 coins
	xor a
	ldh [hUnusedCoinsByte], a
	ldh [hCoins], a
	ld hl, $0500
	ld a, l
	ld [hCoins + 1], a
	ld a, h
	ld [hCoins + 0], a
	ld de, wPlayerCoins + 1
	ld hl, hCoins + 1
	ld c, $2
	predef AddBCDPredef
	; Update display
	call GameCornerDrawCoinBox
	ld hl, .ThanksHereAre500Coins
	jr .print_ret
.declined
	ld hl, .PleaseComePlaySometime
	jr .print_ret
.coin_case_full
	ld hl, .CoinCaseIsFull
	jr .print_ret
.no_coin_case
	ld hl, .DontHaveCoinCase
.print_ret
	call PrintText
	jp TextScriptEnd

.DoYouNeedSomeGameCoins:
	text_far _GameCornerPrizeRoomClerkDoYouNeedSomeGameCoinsText
	text_end

.ThanksHereAre500Coins:
	text_far _GameCornerPrizeRoomClerkThanksHereAre50CoinsText
	text_end

.PleaseComePlaySometime:
	text_far _GameCornerPrizeRoomClerkPleaseComePlaySometimeText
	text_end

.CantAffordTheCoins:
	text_far _GameCornerPrizeRoomClerkCantAffordTheCoinsText
	text_end

.CoinCaseIsFull:
	text_far _GameCornerPrizeRoomClerkCoinCaseIsFullText
	text_end

.DontHaveCoinCase:
	text_far _GameCornerPrizeRoomClerkDontHaveCoinCaseText
	text_end

GameCornerPrizeRoomBaldingGuyText:
	text_far _GameCornerPrizeRoomBaldingGuyText
	text_end

GameCornerPrizeRoomGamblerText:
	text_far _GameCornerPrizeRoomGamblerText
	text_end

GameCornerPRizeRoomPrizeVendorText:
	script_prize_vendor
