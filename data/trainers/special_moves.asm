; Yellow entry format:
;	db trainerclass, trainerid
;	repeat { db partymon location, partymon move, move id }
;	db 0

SpecialTrainerMoves:
	db YOUNGSTER, 14
	db 1, 4, FISSURE
	db 0

	db BROCK, 1
	db 1, 3, ROCK_THROW
	db 2, 1, CONSTRICT
	db 2, 3, BIDE
	db 2, 4, BIND
	db 0

	db MISTY, 1
	db 2, 1, TAIL_WHIP

	db LT_SURGE, 1
	db 1, 3, BODY_SLAM
	db 1, 4, SURF
	db 0

	db ERIKA, 1
	db 1, 1, BIND
	db 2, 1, MEGA_DRAIN
	db 3, 1, RAZOR_LEAF
	db 3, 2, ACID
	db 3, 3, LEECH_SEED
	db 4, 1, ACID
	db 4, 2, SOLARBEAM
	db 4, 3, STUN_SPORE
	db 4, 4, SLEEP_POWDER
	db 0

	db ERIKA, 2
	db 1, 1, BIND
    db 2, 3, SWORDS_DANCE
    db 3, 1, RAZOR_LEAF
    db 3, 2, LEECH_SEED
    db 3, 3, SLUDGE
    db 4, 2, SLEEP_POWDER
    db 0 

	db ERIKA, 3
	db 1, 2, STUN_SPORE
    db 1, 3, SOLAR_BEAM
    db 2, 4, RAZOR_LEAF
    db 3, 2, SOLAR_BEAM
    db 3, 3, LEECH_SEED
    db 4, 1, REFLECT
    db 5, 1, LEECH SEED
    db 0

	db KOGA, 1
	db 1, 2, TOXIC
	db 1, 3, BITE
	db 2, 1, ACID_ARMOR
	db 2, 2, MEGA_DRAIN
	db 3, 1, SURF
	db 3, 3, ICE_BEAM
	db 4, 1, SOLARBEAM
	db 4, 2, DOUBLE_TEAM
	db 4, 3, TOXIC
	db 0

	db KOGA, 2
	db 1, 1, TOXIC
	db 1, 2, CONFUSE_RAY
	db 1, 4, BITE
	db 2, 3, MEGA_DRAIN
	db 3, 2, SURF
	db 4, 2, SLUDGE
	db 4, 3, THUNDERBOLT
	db 5, 1, SOLARBEAM
	db 5, 2, DOUBLE_TEAM
	db 5, 3, TOXIC
	db 0

	db BLAINE, 1
	db 2, 1, FIRE_BLAST
	db 2, 2, WING_ATTACK
	db 2, 3, SLASH
	db 2, 4, SEISMIC_TOSS
	db 3, 1, FIRE_BLAST
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
	db 2, 2, PSYWAVE
	db 3, 1, LIGHT_SCREEN
	db 3, 2, MIMIC
	db 4, 1, REFLECT
	db 4, 2, PSYWAVE
	db 4, 3, PSYCHIC_M
	db 4, 4, RECOVER 
	db 5, 1, THUNDER_WAVE
	db 0

	db SABRINA, 2
	db 1, 1, PSYCHIC_M
	db 2, 1, SUBSTITUTE
	db 2, 2, MIMIC
	db 2, 3, LIGHT_SCREEN
	db 3, 1, PSYWAVE
	db 4, 1, THUNDER_WAVE
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
	db 2, 1, DIG
	db 2, 3, ROCK_SLIDE
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
	db 1, 1, EARTHQUAKE
	db 1, 2, BLIZZARD
	db 2, 1, SURF
	db 2, 3, EXPLOSION
	db 3, 1, SURF
	db 3, 2, REST
	db 4, 2, BUBBLEBEAM
	db 4, 3, LOVELY_KISS
	db 5, 1, THUNDERBOLT
	db 5, 3, SURF
	db 0

	db BRUNO, 1
	db 1, 3, ICE_PUNCH
	db 1, 4, THUNDERPUNCH
	db 2, 1, ICE_BEAM
	db 3, 1, BODY_SLAM
	db 5, 3, BODY_SLAM
	db 5, 4, SEISMIC_TOSS
	db 0

	db AGATHA, 1
	db 1, 1, MEGA_DRAIN
	db 2, 1, FLY
	db 2, 2, TOXIC
	db 2, 4, DOUBLE_TEAM
	db 3, 1, SWORDS_DANCE
	db 3, 2, BODY_SLAM
	db 3, 3, ROCK_SLIDE 
	db 4, 2, SUBSTITUTE
	db 5, 1, PSYCHIC_M
	db 5, 3, BLIZZARD
	db 5, 4, THUNDER
	db 0

	db LANCE, 1
	db 1, 1, WRAP
	db 1, 3, THUNDER_WAVE
	db 2, 1, FLY
	db 2, 2, SURF
	db 2, 3, SLAM
	db 3, 2, HYPER_BEAM
	db 3, 4, EARTHQUAKE
	db 4, 3, EARTHQUAKE
	db 5, 1, BLIZZARD
	db 5, 2, FIRE_BLAST
	db 5, 3, THUNDER
	db 0

	db RIVAL3, 1
	db 1, 1, DIG
	db 1, 4, HYPER_BEAM
	db 2, 1, SKY_ATTACK
	db 2, 4, HYPER_BEAM
	db 3, 1, THUNDER_WAVE
	db 4, 1, ROCK_SLIDE
	db 5, 3, SURF
	db 6, 2, HEADBUTT
	db 6, 4, THUNDERBOLT
	db 0

	db RIVAL3, 2
	db 1, 1, THUNDER_WAVE
	db 2, 3, THUNDERBOLT
	db 2, 4, BODY_SLAM
	db 3, 1, FLY
	db 3, 2, BLIZZARD
	db 3, 4, SURF
	db 4, 1, THUNDER_WAVE
	db 4, 3, REFLECT
	db 4, 3, REFLECT
	db 5, 1, SOFTBOILED
	db 6, 3, FLAMETHROWER
	db 6, 4, DOUBLE_KICK
	db 0

	db RIVAL3, 3
	db 1, 1, EARTHQUAKE
	db 1, 2, ROCK_SLIDE
	db 2, 1, DOUBLE_EDGE
	db 2, 2, HYPER_BEAM
	db 2, 4, DOUBLE_TEAM
	db 3, 4, PSYWAVE
	db 4, 1, SLEEP_POWDER
	db 5, 1, THUNDER_WAVE
	db 6, 1, ICE_BEAM
	db 6, 4, SURF
	db 0

	db PROFOAK, 1
    db 1, 1, HYPER_BEAM
    db 1, 2, EARTHQUAKE
    db 1, 3, BLIZZARD
    db 1, 4, THUNDER
    db 2, 1, FIRE_BLAST
    db 2, 2, EARTHQUAKE
    db 2, 3, SLASH
    db 2, 4, DOUBLE_TEAM
    db 3, 1, SWORDS_DANCE
    db 3, 2, EARTHQUAKE
    db 4, 1, REFLECT
    db 4, 2, EARTHQUAKE
    db 5, 2, AMNESIA
    db 5, 3, PSYCHIC_M
    db 5, 4, REST
    db 6, 1, EARTHQUAKE
    db 6, 2, ROCK_SLIDE
    db 6, 3, SLUDGE
    db 6, 4, BLIZZARD
    db 0


db PROFOAK, 2
    db 1, 1, EARTHQUAKE
    db 1, 2, ROCK_SLIDE
    db 1, 3, THUNDER
    db 1, 4, SLUDGE
    db 2, 1, AGILITY
    db 2, 2, SOLAR_BEAM
    db 3, 1, HYPER_BEAM
    db 3, 2, EARTHQUAKE
    db 3, 3, BLIZZARD
    db 3, 4, THUNDER
    db 4, 1, BUBBLEBEAM
    db 4, 2, BLIZZARD
    db 4, 3, SKY_ATTACK
    db 4, 4, REFLECT
    db 5, 2, AMNESIA
    db 5, 3, REFLECT
    db 5, 4, REST
    db 6, 1, THUNDER_WAVE
    db 0
	db -1 ; end