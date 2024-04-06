; CreditsTextPointers indexes (see data/credits/credits_text.asm)
	const_def
	const CRED_VERSION               ; 00
	const CRED_TAJIRI                ; 01
	const CRED_OOTA                  ; 02
	const CRED_MORIMOTO              ; 03
	const CRED_WATANABE              ; 04
	const CRED_MASUDA                ; 05
	const CRED_NISHINO               ; 06
	const CRED_SUGIMORI              ; 07
	const CRED_NISHIDA               ; 08
	const CRED_MIYAMOTO              ; 09
	const CRED_KAWAGUCHI             ; 0a
	const CRED_ISHIHARA              ; 0b
	const CRED_YAMAUCHI              ; 0c
	const CRED_ZINNAI                ; 0d
	const CRED_HISHIDA               ; 0e
	const CRED_SAKAI                 ; 0f
	const CRED_YAMAGUCHI             ; 10
	const CRED_YAMAMOTO              ; 11
	const CRED_TANIGUCHI             ; 12
	const CRED_NONOMURA              ; 13
	const CRED_FUZIWARA              ; 14
	const CRED_MATSUSIMA             ; 15
	const CRED_TOMISAWA              ; 16
	const CRED_KAWAMOTO              ; 17
	const CRED_KAKEI                 ; 18
	const CRED_TSUCHIYA              ; 19
	const CRED_NAKAMURA              ; 1a
	const CRED_YUDA                  ; 1b
	const CRED_POKEMON               ; 1c
	const CRED_DIRECTOR              ; 1d
	const CRED_PROGRAMMERS           ; 1e
	const CRED_CHARACTER_DESIGN      ; 1f
	const CRED_MUSIC                 ; 20
	const CRED_SOUND_EFFECTS         ; 21
	const CRED_GAME_DESIGN           ; 22
	const CRED_MONSTER_DESIGN        ; 23
	const CRED_GAME_SCENARIO         ; 24
	const CRED_PARAMETRIC_DESIGN     ; 25
	const CRED_MAP_DESIGN            ; 26
	const CRED_TESTING               ; 27
	const CRED_SPECIAL_THANKS        ; 28
	const CRED_PRODUCER              ; 29
	const CRED_EXECUTIVE_PRODUCER    ; 2a
	const CRED_TAMADA                ; 2b
	const CRED_OOTA2                 ; 2c
	const CRED_YOSHIKAWA             ; 2d
	const CRED_OOTA23                ; 2e
	const CRED_YOSHIDA               ; 2f
	const CRED_MATSUMITA             ; 30
	const CRED_SEYA                  ; 31
	const CRED_SEKINE                ; 32
	const CRED_SHIMAMURA             ; 33
	const CRED_SHIMOYAMADA           ; 34
	const CRED_SUPER_MARIO_CLUB      ; 35
	const CRED_IZUSHI                ; 36
	const CRED_NOMURA                ; 37
	const CRED_HARADA                ; 38
	const CRED_YAMAGAMI              ; 39
	const CRED_NISHIMURA             ; 3a
	const CRED_SAEKI                 ; 3b
	const CRED_FUZII                 ; 3c
	const CRED_SHOGAKUKAN            ; 3d
	const CRED_OOTANI                ; 3e
	const CRED_PIKACHU_VOICE         ; 3f
	const CRED_U_S_STAFF             ; 40
	const CRED_U_S_COORD             ; 41
	const CRED_TILDEN                ; 42
	const CRED_KAWAKAMI              ; 43
	const CRED_NAKAMURA2             ; 44
	const CRED_SHOEMAKE              ; 45
	const CRED_OSBORNE               ; 46
	const CRED_TRANSLATION           ; 47
	const CRED_OGASAWARA             ; 48
	const CRED_IWATA                 ; 49
	const CRED_IZUSHI2               ; 4a
	const CRED_HARADA2               ; 4b
	const CRED_MURAKAWA              ; 4c
	const CRED_FUKUI                 ; 4d
	const CRED_SUPER_MARIO_CLUB2     ; 4e
	const CRED_PAAD                  ; 4f
	const CRED_PRODUCERS             ; 50
	const CRED_HOSOKAWA              ; 51
	const CRED_OKUBO                 ; 52
	const CRED_NAKAMICHI             ; 53
	const CRED_YOSHIMURA             ; 54
	const CRED_YAMAZAKI              ; 55
	const CRED_CREATOR
	const CRED_DEVELOPER
	const CRED_EDITOR
	const CRED_MODERATORS
	const CRED_PLAYTESTERS
	const CRED_SPRITE_ARTISTS
	const CRED_BACKSPRITE_ARTISTS
	const CRED_TUTORIALS
	const CRED_PRET1
	const CRED_PRET2
	const CRED_PRET3
	const CRED_PRET4
	const CRED_SMITH_PLAYS_POKEMON
	const CRED_SMITH
	const CRED_CRZSHADOWS
	const CRED_WEEBRA
	const CRED_AERO
	const CRED_ZACH
	const CRED_KARLOS
	const CRED_ISONA
	const CRED_REGI
	const CRED_DAILY
	const CRED_OBELISK
	const CRED_DISQ
	const CRED_BRICE
	const CRED_READERDRAGON
	const CRED_SABLE
	const CRED_SOUL
	const CRED_TALOS
	const CRED_ALAKADOOFF
	const CRED_RWNE
	const CRED_RANGI42
	const CRED_PLAGUEVONKARMA
	const CRED_JOJOBEAR13
	const CRED_YAKINEED
	const CRED_PGATTIC
	const CRED_XILLICIS
	const CRED_DANNYE
	const CRED_SOUPPOTATO
	const CRED_VOLOVED
	const CRED_VEGANLIES2ME
	const CRED_SATOMEW
	const CRED_TPP
	const CRED_IDAIN
	const CRED_NAYRU62
	const CRED_JAAS
	const CRED_LONGLOSTSOUL
	const CRED_GHOSTMISSINGNO
	const CRED_ZETANULL
	const CRED_CHAMBER
	const CRED_SOLOO993
	const CRED_BLUE_EMERALD
	const CRED_LAKE
	const CRED_NESLUG
	const CRED_TOM_WANG
DEF NUM_CRED_STRINGS EQU const_value

	const_def -1, -1
	const CRED_TEXT_FADE_MON ; $FF
	const CRED_TEXT_MON      ; $FE
	const CRED_TEXT_FADE     ; $FD
	const CRED_TEXT          ; $FC
	const CRED_COPYRIGHT     ; $FB
	const CRED_THE_END       ; $FA
