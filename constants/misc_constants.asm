; Boolean checks
DEF FALSE EQU 0
DEF TRUE  EQU 1

; flag operations
	const_def
	const FLAG_RESET ; 0
	const FLAG_SET   ; 1
	const FLAG_TEST  ; 2

; wOptions
DEF TEXT_DELAY_FAST   EQU %001 ; 1
DEF TEXT_DELAY_MEDIUM EQU %011 ; 3
DEF TEXT_DELAY_SLOW   EQU %101 ; 5

	const_def 6
	const BIT_BATTLE_SHIFT     ; 6
	const BIT_BATTLE_ANIMATION ; 7

; wStatusFlags6 flags
DEF BIT_DEBUG_MODE EQU 1

; wDifficulty values, as chosen in the new-game menu. The byte is a set of flags
; (rules and how the starter is chosen are independent), so check it with the
; check_hard_rules / check_pick_starter macros rather than comparing values.
	const_def
	const DIFFICULTY_NORMAL ; 0
	const DIFFICULTY_HARD   ; 1
	const DIFFICULTY_PICK_STARTER ; 2: Normal rules, but the player picks any starter
DEF NUM_DIFFICULTIES EQU const_value

DEF DIFFICULTY_HARD_FLAG EQU 1 << 0 ; Hard rules: level caps, Set mode, no items in battle
DEF DIFFICULTY_PICK_FLAG EQU 1 << 1 ; pick any starter in Oak's lab
ASSERT DIFFICULTY_HARD == DIFFICULTY_HARD_FLAG
ASSERT DIFFICULTY_PICK_STARTER == DIFFICULTY_PICK_FLAG

; level of the starter received in Oak's lab
DEF STARTER_LEVEL EQU 5

; Melanie (Cerulean City) offers BULBASAUR once Pikachu is this happy
DEF MELANIE_HAPPINESS_THRESHOLD EQU 147
