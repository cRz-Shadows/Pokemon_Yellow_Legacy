; pokemon ids
; indexes for:
; - MonsterNames (see data/pokemon/names.asm)
; - EvosMovesPointerTable (see data/pokemon/evos_moves.asm)
; - CryData (see data/pokemon/cries.asm)
; - PokedexOrder (see data/pokemon/dex_order.asm)
; - PokedexEntryPointers (see data/pokemon/dex_entries.asm)
	const_def
	const NO_MON             ; $00
	const RHYDON             ; $01
	const KANGASKHAN         ; $02
	const NIDORAN_M          ; $03
	const CLEFAIRY           ; $04
	const SPEAROW            ; $05
	const VOLTORB            ; $06
	const NIDOKING           ; $07
	const SLOWBRO            ; $08
	const IVYSAUR            ; $09
	const EXEGGUTOR          ; $0A
	const LICKITUNG          ; $0B
	const EXEGGCUTE          ; $0C
	const GRIMER             ; $0D
	const GENGAR             ; $0E
	const NIDORAN_F          ; $0F
	const NIDOQUEEN          ; $10
	const CUBONE             ; $11
	const RHYHORN            ; $12
	const LAPRAS             ; $13
	const ARCANINE           ; $14
	const MEW                ; $15
	const GYARADOS           ; $16
	const SHELLDER           ; $17
	const TENTACOOL          ; $18
	const GASTLY             ; $19
	const SCYTHER            ; $1A
	const STARYU             ; $1B
	const BLASTOISE          ; $1C
	const PINSIR             ; $1D
	const TANGELA            ; $1E
	const GROWLITHE          ; $1F
	const ONIX               ; $20
	const FEAROW         	 ; $21
	const PIDGEY             ; $22
	const SLOWPOKE           ; $23
	const KADABRA            ; $24
	const GRAVELER           ; $25
	const CHANSEY            ; $26
	const MACHOKE            ; $27
	const MR_MIME            ; $28
	const HITMONLEE          ; $29
	const HITMONCHAN         ; $2A
	const ARBOK		         ; $2B
	const PARASECT         	 ; $2C
	const PSYDUCK            ; $2D
	const DROWZEE            ; $2E
	const GOLEM	             ; $2F
	const MAGMAR             ; $30
	const ELECTABUZZ         ; $31
	const MAGNETON           ; $32
	const KOFFING            ; $33
	const MANKEY             ; $34
	const SEEL     		     ; $35
	const DIGLETT            ; $36
	const TAUROS             ; $37
	const FARFETCHD          ; $38
	const VENONAT            ; $39
	const DRAGONITE          ; $3A
	const DODUO              ; $3B
	const POLIWAG            ; $3C
	const JYNX               ; $3D
	const MOLTRES            ; $3E
	const ARTICUNO           ; $3F
	const ZAPDOS	         ; $40
	const DITTO              ; $41
	const MEOWTH          	 ; $42
	const KRABBY             ; $43
	const VULPIX             ; $44
	const NINETALES          ; $45
	const PIKACHU            ; $46
	const RAICHU             ; $47
	const DRATINI            ; $48
	const DRAGONAIR          ; $49
	const KABUTO             ; $4A
	const KABUTOPS           ; $4B
	const HORSEA             ; $4C
	const SEADRA             ; $4D
	const SANDSHREW          ; $4E
	const SANDSLASH          ; $4F
	const OMANYTE            ; $50
	const OMASTAR            ; $51
	const JIGGLYPUFF         ; $52
	const WIGGLYTUFF         ; $53
	const EEVEE              ; $54
	const FLAREON            ; $55
	const JOLTEON            ; $56
	const VAPOREON           ; $57
	const MACHOP             ; $58
	const ZUBAT		         ; $59
	const EKANS              ; $5A
	const PARAS              ; $5B
	const POLIWHIRL          ; $5C
	const POLIWRATH          ; $5D
	const WEEDLE             ; $5E
	const KAKUNA             ; $5F
	const BEEDRILL           ; $60
	const DODRIO             ; $61
	const PRIMEAPE           ; $62
	const DUGTRIO            ; $63
	const VENOMOTH	         ; $64
	const DEWGONG        	 ; $65
	const CATERPIE           ; $66
	const METAPOD            ; $67
	const BUTTERFREE         ; $68
	const MACHAMP            ; $69
	const GOLDUCK            ; $6A
	const HYPNO              ; $6B
	const GOLBAT             ; $6C
	const MEWTWO             ; $6D
	const SNORLAX	         ; $6E
	const MAGIKARP           ; $6F
	const MUK	             ; $70
	const KINGLER            ; $71
	const CLOYSTER           ; $72
	const ELECTRODE          ; $73
	const CLEFABLE           ; $74
	const WEEZING            ; $75
	const PERSIAN            ; $76
	const MAROWAK            ; $77
	const HAUNTER            ; $78
	const ABRA               ; $79
	const ALAKAZAM           ; $7A
	const PIDGEOTTO          ; $7B
	const PIDGEOT            ; $7C
	const STARMIE	         ; $7D
	const BULBASAUR          ; $7E
	const VENUSAUR           ; $7F
	const TENTACRUEL         ; $80
	const GOLDEEN            ; $81
	const SEAKING            ; $82
	const PONYTA             ; $83
	const RAPIDASH           ; $84
	const RATTATA            ; $85
	const RATICATE           ; $86
	const NIDORINO           ; $87
	const NIDORINA           ; $88
	const GEODUDE            ; $89
	const PORYGON            ; $8A
	const AERODACTYL         ; $8B
	const MAGNEMITE          ; $8C
	const CHARMANDER         ; $8D
	const SQUIRTLE           ; $8E
	const CHARMELEON         ; $8F
	const WARTORTLE          ; $90
	const CHARIZARD          ; $91
	const FOSSIL_KABUTOPS    ; $92
	const FOSSIL_AERODACTYL  ; $93
	const MON_GHOST          ; $94
	const ODDISH             ; $95
	const GLOOM		         ; $96
	const VILEPLUME          ; $97
	const BELLSPROUT         ; $98
	const WEEPINBELL         ; $99
	const VICTREEBEL         ; $9A

DEF NUM_POKEMON_INDEXES EQU const_value - 1

; player starter
DEF STARTER_PIKACHU EQU PIKACHU

; rival starters (wRivalStarter)
DEF RIVAL_STARTER_JOLTEON  EQU 1
DEF RIVAL_STARTER_FLAREON  EQU 2
DEF RIVAL_STARTER_VAPOREON EQU 3
; Pick Starter mode: the rival counters a Bulbasaur/Charmander/Squirtle-line
; pick with this starter's line; his teammates are the Jolteon/Flareon/Vaporeon
; teams' (data/trainers/parties.asm)
DEF RIVAL_STARTER_BULBASAUR  EQU 4
DEF RIVAL_STARTER_CHARMANDER EQU 5
DEF RIVAL_STARTER_SQUIRTLE   EQU 6
DEF FIRST_RIVAL_COUNTER_STARTER EQU RIVAL_STARTER_BULBASAUR

; ghost Marowak in Pokémon Tower
DEF RESTLESS_SOUL EQU MAROWAK
