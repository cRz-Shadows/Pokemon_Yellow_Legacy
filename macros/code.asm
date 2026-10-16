; Syntactic sugar macros

MACRO lb ; r, hi, lo
	ld \1, ((\2) & $ff) << 8 + ((\3) & $ff)
ENDM

MACRO ldpal
	ld \1, \2 << 6 | \3 << 4 | \4 << 2 | \5
ENDM

; Game mode checks (see the wDifficulty flags in constants/misc_constants.asm)

; nz if Hard rules apply (BIT_DIFFICULTY_HARD); clobbers a
MACRO test_hard_rules
	ld a, [wDifficulty]
	bit BIT_DIFFICULTY_HARD, a
ENDM

; nz if Hard rules apply to this battle: like test_hard_rules, except in link
; battles, which always use the Normal rules so both consoles draw the same
; random numbers; clobbers a
MACRO test_hard_battle_rules
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	jr z, :+ ; z: not Hard
	test_hard_rules
:
ENDM

; nz if the player picks their starter (BIT_DIFFICULTY_PICK); clobbers a
MACRO test_pick_starter
	ld a, [wDifficulty]
	bit BIT_DIFFICULTY_PICK, a
ENDM

; z if the player's starter is PIKACHU (always true unless picked otherwise in
; Pick Starter mode); clobbers a.
; Two checks decide Pikachu-only content; use the one that fits:
; - check_starter_pikachu asks "was PIKACHU the starter the player chose?" (story
;   scenes tied to that choice: Oak's lab, Melanie, the Summer Beach House).
; - BIT_STARTER_PIKACHU_IN_PARTY (wPikachuPartyFlags) asks "is the starter PIKACHU
;   alive in the party right now?" (the follower, Bill's House, gyms, the Fan Club).
MACRO check_starter_pikachu
	ld a, [wPlayerStarter]
	cp STARTER_PIKACHU
ENDM

; Rival team selection (data/trainers/parties.asm): a = the rival's team
; number in his trainer class, for wTrainerNo; clobbers a.
; A counter (Pick Starter mode) uses team \2 + 0-2 instead: the team of the
; starter in RIVAL_STARTER_BULBASAUR-SQUIRTLE order (RIVAL_COUNTER_TEAM_MASK).

; \1: the EEVEE rival's team
MACRO rival_team_fixed
	ld a, [wRivalStarter]
	cp FIRST_RIVAL_COUNTER_STARTER
	jr c, :+
	and RIVAL_COUNTER_TEAM_MASK
	add \2
	jr :++
:	ld a, \1
:
ENDM

; \1 + wRivalStarter: the Jolteon/Flareon/Vaporeon rival's team
MACRO rival_team_by_variant
	ld a, [wRivalStarter]
	cp FIRST_RIVAL_COUNTER_STARTER
	jr c, :+
	and RIVAL_COUNTER_TEAM_MASK
	add \2 - (\1)
:	add \1
ENDM

; Pick Starter mode: an entry of PickStarterRivalCounterPicks for a Pokémon
; that replaces the starter in that starter's rival teams.
; \1: species, \2: the starter's RIVAL_STARTER_* constant (whose teams he uses)
MACRO rival_counter_line
	DEF RIVAL_COUNTER_LINES += 1
	db \1, \2 + RIVAL_COUNTER_LINES * RIVAL_COUNTER_LINE_STEP
ENDM

; Design patterns

MACRO dict
	IF \1 == 0
		and a
	ELSE
		cp \1
	ENDC
	jp z, \2
ENDM
