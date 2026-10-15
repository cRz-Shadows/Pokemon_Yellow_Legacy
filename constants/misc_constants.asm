; Boolean checks
DEF FALSE EQU 0
DEF TRUE  EQU 1

; flag operations
	const_def
	const FLAG_RESET ; 0
	const FLAG_SET   ; 1
	const FLAG_TEST  ; 2

; wStatusFlags6 flags

; wDifficulty values, as chosen in the new-game menu. The byte is a set of flags
; (rules and how the starter is chosen are independent), so check it with the
; test_hard_rules / test_pick_starter macros rather than comparing values.
	const_def
	const DIFFICULTY_NORMAL ; 0
	const DIFFICULTY_HARD   ; 1
	const DIFFICULTY_PICK_STARTER ; 2: Normal rules, but the player picks any starter
DEF NUM_DIFFICULTIES EQU const_value

DEF BIT_DIFFICULTY_HARD EQU 0 ; Hard rules: level caps, Set mode, no items in trainer battles
DEF BIT_DIFFICULTY_PICK EQU 1 ; pick any starter in Oak's lab
DEF DIFFICULTY_HARD_FLAG EQU 1 << BIT_DIFFICULTY_HARD
DEF DIFFICULTY_PICK_FLAG EQU 1 << BIT_DIFFICULTY_PICK
DEF DIFFICULTY_FLAGS_MASK EQU DIFFICULTY_HARD_FLAG | DIFFICULTY_PICK_FLAG
ASSERT DIFFICULTY_HARD == DIFFICULTY_HARD_FLAG
ASSERT DIFFICULTY_PICK_STARTER == DIFFICULTY_PICK_FLAG

; level of the starter received in Oak's lab
DEF STARTER_LEVEL EQU 5

; Melanie (Cerulean City) offers BULBASAUR once Pikachu is this happy
DEF MELANIE_HAPPINESS_THRESHOLD EQU 147

; input
DEF NO_INPUT EQU 0

; SGB command MLT_REQ can be used to detect SGB hardware
DEF JOYP_SGB_MLT_REQ EQU %00000011
