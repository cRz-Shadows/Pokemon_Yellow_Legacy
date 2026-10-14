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

; Design patterns

MACRO dict
	IF \1 == 0
		and a
	ELSE
		cp \1
	ENDC
	jp z, \2
ENDM
