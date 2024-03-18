PrizeDifferentMenuPtrs:
	dw PrizeMenuMon1Entries, PrizeMenuMon1Cost
	dw PrizeMenuMon2Entries, PrizeMenuMon2Cost
	dw PrizeMenuTMsEntries,  PrizeMenuTMsCost

PrizeMenuMon1Entries:
	db ABRA
	db SEEL
	db MAGMAR
	db "@"

PrizeMenuMon1Cost:
	bcd2 230
	bcd2 500
	bcd2 1500
	db "@"

PrizeMenuMon2Entries:
	db ELECTABUZZ
	db DRATINI
	db PORYGON
	db "@"

PrizeMenuMon2Cost:
	bcd2 1500
	bcd2 3000
	bcd2 4500
	db "@"

PrizeMenuTMsEntries:
	db TM_DRAGON_RAGE
	db TM_HYPER_BEAM
	db TM_SUBSTITUTE
	db "@"

PrizeMenuTMsCost:
	bcd2 1000
	bcd2 5000
	bcd2 3000
	db "@"
