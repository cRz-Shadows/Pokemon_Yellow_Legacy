; Syntactic sugar macros

MACRO lb ; r, hi, lo
	ld \1, ((\2) & $ff) << 8 + ((\3) & $ff)
ENDM

MACRO ldpal
	ld \1, \2 << 6 | \3 << 4 | \4 << 2 | \5
ENDM

; Game mode checks (see the wDifficulty flags in constants/misc_constants.asm)

; z if Hard rules apply (DIFFICULTY_HARD_FLAG); clobbers a
MACRO check_hard_rules
	ld a, [wDifficulty]
	and DIFFICULTY_HARD_FLAG
	cp DIFFICULTY_HARD_FLAG
ENDM

; z if the player picks their starter (DIFFICULTY_PICK_FLAG); clobbers a
MACRO check_pick_starter
	ld a, [wDifficulty]
	and DIFFICULTY_PICK_FLAG
	cp DIFFICULTY_PICK_FLAG
ENDM

; z if the player's starter is PIKACHU (always true unless picked otherwise in
; Pick Starter mode); clobbers a. Pikachu-only story scenes check this.
MACRO check_starter_pikachu
	ld a, [wPlayerStarter]
	cp STARTER_PIKACHU
ENDM

; Rival team selection (data/trainers/parties.asm): a = the rival's team
; number in his trainer class, for wTrainerNo; clobbers a.
; A counter starter (RIVAL_STARTER_BULBASAUR-SQUIRTLE, Pick Starter mode) uses
; team \2 + 0-2 instead.

; \1: the EEVEE rival's team
MACRO rival_team_fixed
	ld a, [wRivalStarter]
	cp FIRST_RIVAL_COUNTER_STARTER
	jr c, :+
	add \2 - FIRST_RIVAL_COUNTER_STARTER
	jr :++
:	ld a, \1
:
ENDM

; \1 + wRivalStarter: the Jolteon/Flareon/Vaporeon rival's team
MACRO rival_team_by_variant
	ld a, [wRivalStarter]
	cp FIRST_RIVAL_COUNTER_STARTER
	jr c, :+
	add \2 - FIRST_RIVAL_COUNTER_STARTER - (\1)
:	add \1
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
