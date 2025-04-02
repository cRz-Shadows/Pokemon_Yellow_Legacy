; TypeNames indexes (see data/types/names.asm)
	const_def

DEF PHYSICAL EQU const_value
	const NORMAL       ; $00
	const FIGHTING     ; $01
	const FLYING       ; $02
	const POISON       ; $03
	const GROUND       ; $04
	const ROCK         ; $05
	const BIRD         ; $06
	const BUG          ; $07
	const STEEL		   ; $08

DEF UNUSED_TYPES EQU const_value
	const_next 20
DEF UNUSED_TYPES_END EQU const_value

; SPECIAL continued, doing this maintains trade functionality with crystal
	const FIRE         ; $14
	const WATER        ; $15
	const GRASS        ; $16
	const ELECTRIC     ; $17
	const PSYCHIC_TYPE ; $18
	const GHOST 	   ; $19
	const ICE          ; $1A
	const DRAGON       ; $1B
	const DARK		   ; $1C
	const FAIRY		   ; $1D
	const TYPELESS	   ; $1E

DEF NUM_TYPES EQU const_value