; Values the CI emulator tests (.github/scripts/smoke_test.py and
; scenario_tests.py) read from pokemon_yellow_legacy.sym, so they never parse
; assembly source. EXPORT only adds .sym entries; the ROM is unchanged.

	; wStatusFlags3 bit for a warp started by a script (constants/ram_constants.asm)
	EXPORT BIT_WARP_FROM_CUR_SCRIPT
	EXPORT STARTER_LEVEL, MELANIE_HAPPINESS_THRESHOLD

	; maps
	EXPORT REDS_HOUSE_2F, REDS_HOUSE_1F, PALLET_TOWN, OAKS_LAB
	EXPORT CERULEAN_CITY, CERULEAN_MELANIES_HOUSE, CERULEAN_TRASHED_HOUSE
	EXPORT FUCHSIA_CITY, SAFARI_ZONE_GATE
	EXPORT ROUTE_19, SUMMER_BEACH_HOUSE

	; species and moves
	EXPORT PIKACHU, CHARMANDER, BULBASAUR, MEW, EEVEE, MAGIKARP, SURF
	EXPORT SQUIRTLE, WARTORTLE, RIVAL_STARTER_JOLTEON

	; charmap, for decoding the tilemap
	EXPORT DEF CI_CHAR_A EQU CHARVAL("A")
	EXPORT DEF CI_CHAR_LOWER_A EQU CHARVAL("a")
	EXPORT DEF CI_CHAR_0 EQU CHARVAL("0")
	EXPORT DEF CI_CHAR_CURSOR EQU CHARVAL("▶")
