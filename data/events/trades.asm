MACRO npctrade
; give mon, get mon, dialog id, nickname
	db \1, \2, \3
	dname \4, NAME_LENGTH
ENDM

TradeMons:
; entries correspond to TRADE_FOR_* constants
	table_width 3 + NAME_LENGTH
	; The two instances of TRADE_DIALOGSET_EVOLUTION are a leftover
	; from the Japanese Blue trades, which used species that evolve.
	; Japanese Red and Green used TRADE_DIALOGSET_CASUAL, and had
	; the same species as English Red and Blue.
	npctrade LICKITUNG,  DUGTRIO,  TRADE_DIALOGSET_CASUAL,    "GURIO"
	npctrade CLEFAIRY,   MR_MIME,  TRADE_DIALOGSET_CASUAL,    "MILES"
	npctrade BUTTERFREE, BEEDRILL, TRADE_DIALOGSET_HAPPY,     "STINGER" ; unused
	npctrade KANGASKHAN, MUK,      TRADE_DIALOGSET_CASUAL,    "STICKY"
	npctrade MEW,        MEW,      TRADE_DIALOGSET_HAPPY,     "BART" ; unused
	npctrade TANGELA,    PARASECT, TRADE_DIALOGSET_CASUAL,    "SPIKE"
	npctrade POLIWHIRL,  JYNX,     TRADE_DIALOGSET_EVOLUTION, "LOLA"
	npctrade GOLDUCK,    RHYDON,   TRADE_DIALOGSET_EVOLUTION, "BUFFY"
	npctrade GROWLITHE,  DEWGONG,  TRADE_DIALOGSET_HAPPY,     "CEZANNE"
	npctrade CUBONE,     MACHOKE,  TRADE_DIALOGSET_HAPPY,     "RICKY"
	assert_table_length NUM_NPC_TRADES
