; Yellow entry format:
;	db trainerclass, trainerid
;	repeat { db partymon location, partymon move, move id }
;	db 0

SpecialTrainerMoves:
	db YOUNGSTER, 14
	db 1, 4, FISSURE
	db 0

	db BROCK, 1
	db 2, 1, CONSTRICT
	db 2, 4, BIDE
	db 0

	db LT_SURGE, 1
	db 1, 3, BODY_SLAM
	db 1, 4, SURF
	db 0

	db ERIKA, 1
	db 1, 1, BIND
	db 2, 3, MEGA_DRAIN
	db 3, 1, RAZOR_LEAF
	db 3, 2, ACID
	db 3, 3, LEECH_SEED
	db 4, 1, ACID
	db 4, 2, SOLARBEAM
	db 4, 3, STUN_SPORE
	db 4, 4, SLEEP_POWDER
	db 0

	db KOGA, 1
	db 1, 1, EXPLOSION
	db 1, 2, TOXIC
	db 1, 3, SLUDGE
	db 2, 1, TOXIC
	db 2, 2, CONFUSE_RAY
	db 2, 3, FLY
	db 3, 1, TOXIC
	db 3, 2, SLUDGE
	db 3, 3, ACID_ARMOR
	db 3, 4, MEGA_DRAIN
	db 4, 1, LEECH_LIFE
	db 4, 2, DOUBLE_TEAM
	db 4, 3, PSYCHIC_M
	db 4, 4, TOXIC
	db 0

	db BLAINE, 1
	db 1, 1, FIRE_SPIN
	db 1, 2, DOUBLE_KICK
	db 1, 3, TAKE_DOWN
	db 2, 1, FIRE_BLAST
	db 2, 2, WING_ATTACK
	db 2, 3, SLASH
	db 2, 4, SEISMIC_TOSS
	db 3, 1, FIRE_SPIN
	db 3, 2, CONFUSE_RAY
	db 3, 3, SOLARBEAM
	db 4, 1, FIRE_BLAST 
	db 4, 2, DOUBLE_EDGE
	db 4, 3, DIG
	db 5, 1, FIRE_BLAST
	db 5, 2, PSYCHIC_M
	db 5, 3, CONFUSE_RAY
	db 5, 4, THUNDERPUNCH
	db 0

	db SABRINA, 1
	db 1, 1, PSYCHIC_M
	db 2, 1, DREAM_EATER
	db 2, 2, HYPNOSIS
	db 2, 3, PSYWAVE
	db 3, 1, PSYCHIC_M
	db 3, 2, MIMIC
	db 3, 3, LIGHT_SCREEN
	db 3, 4, SUBSTITUTE
	db 4, 1, REFLECT
	db 4, 2, PSYWAVE
	db 4, 3, PSYCHIC_M
	db 4, 4, RECOVER 
	db 5, 1, PSYCHIC_M
	db 5, 2, RECOVER 
	db 5, 3, TRI_ATTACK
	db 0

	db GIOVANNI, 1
	db 1, 1, ROCK_THROW
	db 1, 2, DIG
	db 1, 3, SCREECH
	db 1, 4, TAKE_DOWN
	db 2, 1, MEGA_PUNCH
	db 2, 2, SUBMISSION
	db 3, 1, BONE_CLUB
	db 3, 2, HEADBUTT
	db 3, 3, CUT
	db 4, 1, TAKE_DOWN
	db 4, 2, BUBBLEBEAM
	db 4, 3, THUNDERBOLT
	db 0

	db GIOVANNI, 2
	db 1, 1, CRABHAMMER
	db 1, 2, CUT 
	db 1, 3, BODY_SLAM
	db 2, 1, ICE_BEAM
	db 2, 2, SURF 
	db 2, 3, SELFDESTRUCT
	db 3, 1, EARTHQUAKE
	db 3, 2, ROCK_SLIDE
	db 3, 3, EXPLOSION
	db 4, 1, SLASH
	db 4, 2, BUBBLEBEAM
	db 4, 3, THUNDERBOLT
	db 0

	db GIOVANNI, 3
	db 1, 1, EARTHQUAKE
	db 1, 2, SLASH
	db 1, 3, FISSURE
	db 1, 4, ROCK_SLIDE
	db 2, 1, EARTHQUAKE
	db 2, 2, ICE_BEAM
	db 2, 3, THUNDERBOLT
	db 2, 4, BODY_SLAM
	db 3, 1, SLASH
	db 3, 2, HYPER_BEAM
	db 3, 3, BUBBLEBEAM
	db 3, 4, THUNDERBOLT
	db 4, 1, EARTHQUAKE
	db 4, 2, BLIZZARD
	db 4, 3, THUNDER
	db 4, 4, SLUDGE
	db 5, 1, ROCK_SLIDE
	db 5, 2, EARTHQUAKE
	db 5, 3, SUBMISSION
	db 5, 4, THUNDERBOLT
	db 0

	db LORELEI, 1
	db 1, 1, BUBBLEBEAM
	db 2, 3, ICE_BEAM
	db 3, 1, PSYCHIC_M
	db 3, 2, SURF
	db 4, 3, LOVELY_KISS
	db 5, 3, BLIZZARD
	db 0

	db BRUNO, 1
	db 1, 1, ROCK_SLIDE
	db 1, 2, SCREECH
	db 1, 4, DIG
	db 2, 3, FIRE_PUNCH
	db 2, 4, DOUBLE_TEAM
	db 3, 1, DOUBLE_KICK
	db 3, 2, MEGA_KICK
	db 3, 4, DOUBLE_TEAM
	db 4, 1, ROCK_SLIDE
	db 4, 2, SCREECH
	db 4, 4, EARTHQUAKE
	db 5, 2, KARATE_CHOP
	db 5, 3, STRENGTH
	db 0

	db AGATHA, 1
	db 1, 2, SUBSTITUTE
	db 1, 3, LICK
	db 1, 4, MEGA_DRAIN
	db 2, 2, TOXIC
	db 2, 4, LEECH_LIFE
	db 3, 2, LICK
	db 4, 1, WRAP
	db 5, 2, PSYCHIC_M
	db 0

	db LANCE, 1
	db 1, 1, DRAGON_RAGE
	db 2, 1, THUNDER_WAVE
	db 2, 3, THUNDERBOLT
	db 3, 1, BUBBLEBEAM
	db 3, 2, WRAP
	db 3, 3, ICE_BEAM
	db 4, 1, WING_ATTACK
	db 4, 2, SWIFT
	db 4, 3, FLY
	db 5, 1, BLIZZARD
	db 5, 2, FIRE_BLAST
	db 5, 3, THUNDER
	db 0

	db RIVAL3, 1
	db 1, 3, EARTHQUAKE
	db 2, 4, KINESIS
	db 3, 4, LEECH_SEED
	db 4, 1, ICE_BEAM
	db 5, 1, CONFUSE_RAY
	db 5, 4, FIRE_SPIN
	db 6, 3, QUICK_ATTACK
	db 0

	db RIVAL3, 2
	db 1, 3, EARTHQUAKE
	db 2, 4, KINESIS
	db 3, 4, LEECH_SEED
	db 4, 1, THUNDERBOLT
	db 5, 1, ICE_BEAM
	db 6, 2, REFLECT
	db 6, 3, QUICK_ATTACK
	db 0

	db RIVAL3, 3
	db 1, 3, EARTHQUAKE
	db 2, 4, KINESIS
	db 3, 4, LEECH_SEED
	db 4, 1, CONFUSE_RAY
	db 4, 4, FIRE_SPIN
	db 5, 1, THUNDERBOLT
	db 6, 1, AURORA_BEAM
	db 6, 3, QUICK_ATTACK
	db 0

	db -1 ; end
