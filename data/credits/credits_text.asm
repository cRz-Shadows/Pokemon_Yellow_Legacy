CreditsTextPointers:
; entries correspond to CRED_* constants
	table_width 2, CreditsTextPointers
	dw CreditsText_Version
	dw CreditsText_Tajiri
	dw CreditsText_Oota
	dw CreditsText_Morimoto
	dw CreditsText_Watanabe
	dw CreditsText_Masuda
	dw CreditsText_Nishino
	dw CreditsText_Sugimori
	dw CreditsText_Nishida
	dw CreditsText_Miyamoto
	dw CreditsText_Kawaguchi
	dw CreditsText_Ishihara
	dw CreditsText_Yamauchi
	dw CreditsText_Zinnai
	dw CreditsText_Hishida
	dw CreditsText_Sakai
	dw CreditsText_Yamaguchi
	dw CreditsText_Yamamoto
	dw CreditsText_Taniguchi
	dw CreditsText_Nonomura
	dw CreditsText_Fuziwara
	dw CreditsText_Matsusima
	dw CreditsText_Tomisawa
	dw CreditsText_Kawamoto
	dw CreditsText_Kakei
	dw CreditsText_Tsuchiya
	dw CreditsText_Nakamura
	dw CreditsText_Yuda
	dw CreditsText_Pokemon
	dw CreditsText_Director
	dw CreditsText_Programmers
	dw CreditsText_CharacterDesign
	dw CreditsText_Music
	dw CreditsText_SoundEffects
	dw CreditsText_GameDesign
	dw CreditsText_MonsterDesign
	dw CreditsText_GameScenario
	dw CreditsText_ParametricDesign
	dw CreditsText_MapDesign
	dw CreditsText_Testing
	dw CreditsText_SpecialThanks
	dw CreditsText_Producer
	dw CreditsText_ExecutiveProducer
	dw CreditsText_Tamada
	dw CreditsText_Oota2
	dw CreditsText_Yoshikawa
	dw CreditsText_Oota23
	dw CreditsText_Yoshida
	dw CreditsText_Matsumita
	dw CreditsText_Seya
	dw CreditsText_Sekine
	dw CreditsText_Shimamura
	dw CreditsText_Shimoyamada
	dw CreditsText_SuperMarioClub
	dw CreditsText_Izushi
	dw CreditsText_Nomura
	dw CreditsText_Harada
	dw CreditsText_Yamagami
	dw CreditsText_Nishimura
	dw CreditsText_Saeki
	dw CreditsText_Fuzii
	dw CreditsText_Shogakukan
	dw CreditsText_Ootani
	dw CreditsText_PikachuVoice
	dw CreditsText_USStaff
	dw CreditsText_USCoord
	dw CreditsText_Tilden
	dw CreditsText_Kawakami
	dw CreditsText_Nakamura2
	dw CreditsText_Shoemake
	dw CreditsText_Osborne
	dw CreditsText_Translation
	dw CreditsText_Ogasawara
	dw CreditsText_Iwata
	dw CreditsText_Izushi2
	dw CreditsText_Harada2
	dw CreditsText_Murakawa
	dw CreditsText_Fukui
	dw CreditsText_SuperMarioClub2
	dw CreditsText_Paad
	dw CreditsText_Producers
	dw CreditsText_Hosokawa
	dw CreditsText_Okubo
	dw CreditsText_Nakamichi
	dw CreditsText_Yoshimura
	dw CreditsText_Yamazaki

	dw CreditsText_Creator
	dw CreditsText_Developer
	dw CreditsText_Editor
	dw CreditsText_Moderators
	dw CreditsText_Playtesters
	dw CreditsText_SpriteArtists
	dw CreditsText_BackspriteArtists
	dw CreditsText_Tutorials
	dw CreditsText_Pret1
	dw CreditsText_Pret2
	dw CreditsText_Pret3
	dw CreditsText_Pret4
	dw CreditsText_SmithPlaysPokemon
	dw CreditsText_Smith
	dw CreditsText_cRzShadows
	dw CreditsText_Weebra
	dw CreditsText_Aero
	dw CreditsText_Zach
	dw CreditsText_Karlos
	dw CreditsText_Isona
	dw CreditsText_Regi
	dw CreditsText_Daily
	dw CreditsText_Obelisk
	dw CreditsText_Disq
	dw CreditsText_Brice
	dw CreditsText_ReaderDragon
	dw CreditsText_Sable
	dw CreditsText_Soul
	dw CreditsText_Talos
	dw CreditsText_Alakadoof
	dw CreditsText_Rwne
	dw CreditsText_Rangi42
	dw CreditsText_PlagueVonKarma
	dw CreditsText_Jojobear13
	dw CreditsText_YakiNeen
	dw CreditsText_Pgattic
	dw CreditsText_Xillicis
	dw CreditsText_Dannye
	dw CreditsText_SoupPotato
	dw CreditsText_Voloved
	dw CreditsText_Veganlies2me
	dw CreditsText_SatoMew
	dw CreditsText_TPP
	dw CreditsText_Idain
	dw CreditsText_Nayru62
	dw CreditsText_Jaas
	dw CreditsText_Longlostsoul
	dw CreditsText_GhostMissingNo
	dw CreditsText_ZetaNull
	dw CreditsText_Chamber
	dw CreditsText_Soloo993
	dw CreditsText_BlueEmerald
	dw CreditsText_Lake
	dw CreditsText_Neslug
	dw CreditsText_TomWang
	assert_table_length NUM_CRED_STRINGS

; 
; 5  / 4  = -1
; 7  / 6  = -2
; 9  / 8  = -3
; 11 / 10 = -4
; 13 / 12 = -5
; 15 / 14 = -6
; 16 / 17 = -7
; 18 / 19 = -8
CreditsText_Version:
	db -6, "YELLOW LEGACY"
	next   "    STAFF@"
CreditsText_Tajiri:
	db -6, "SATOSHI TAJIRI@"
CreditsText_Oota:
	db -6, "TAKENORI OOTA@"
CreditsText_Morimoto:
	db -7, "SHIGEKI MORIMOTO@"
CreditsText_Watanabe:
	db -7, "TETSUYA WATANABE@"
CreditsText_Masuda:
	db -6, "JUNICHI MASUDA@"
CreditsText_Nishino:
	db -5, "KOHJI NISHINO@"
CreditsText_Sugimori:
	db -5, "KEN SUGIMORI@"
CreditsText_Nishida:
	db -6, "ATSUKO NISHIDA@"
CreditsText_Miyamoto:
	db -7, "SHIGERU MIYAMOTO@"
CreditsText_Kawaguchi:
	db -8, "TAKASHI KAWAGUCHI@"
CreditsText_Ishihara:
	db -8, "TSUNEKAZU ISHIHARA@"
CreditsText_Yamauchi:
	db -7, "HIROSHI YAMAUCHI@"
CreditsText_Zinnai:
	db -7, "HIROYUKI ZINNAI@"
CreditsText_Hishida:
	db -7, "TATSUYA HISHIDA@"
CreditsText_Sakai:
	db -6, "YASUHIRO SAKAI@"
CreditsText_Yamaguchi:
	db -7, "WATARU YAMAGUCHI@"
CreditsText_Yamamoto:
	db -8, "KAZUYUKI YAMAMOTO@"
CreditsText_Taniguchi:
	db -8, "RYOHSUKE TANIGUCHI@"
CreditsText_Nonomura:
	db -8, "FUMIHIRO NONOMURA@"
CreditsText_Fuziwara:
	db -7, "MOTOFUMI FUZIWARA@"
CreditsText_Matsusima:
	db -7, "KENJI MATSUSIMA@"
CreditsText_Tomisawa:
	db -7, "AKIHITO TOMISAWA@"
CreditsText_Kawamoto:
	db -7, "HIROSHI KAWAMOTO@"
CreditsText_Kakei:
	db -6, "AKIYOSHI KAKEI@"
CreditsText_Tsuchiya:
	db -7, "KAZUKI TSUCHIYA@"
CreditsText_Nakamura:
	db -6, "TAKEO NAKAMURA@"
CreditsText_Yuda:
	db -6, "MASAMITSU YUDA@"
CreditsText_Pokemon:
	db -3, "#MON@"
CreditsText_Director:
	db -3, "DIRECTOR@"
CreditsText_Programmers:
	db -5, "PROGRAMMERS@"
CreditsText_CharacterDesign:
	db -7, "CHARACTER DESIGN@"
CreditsText_Music:
	db -2, "MUSIC@"
CreditsText_SoundEffects:
	db -6, "SOUND EFFECTS@"
CreditsText_GameDesign:
	db -5, "GAME DESIGN@"
CreditsText_MonsterDesign:
	db -6, "MONSTER DESIGN@"
CreditsText_GameScenario:
	db -6, "GAME SCENARIO@"
CreditsText_ParametricDesign:
	db -7, "PARAMETRIC DESIGN@"
CreditsText_MapDesign:
	db -4, "MAP DESIGN@"
CreditsText_Testing:
	db -6, "PRODUCT TESTING@"
CreditsText_SpecialThanks:
	db -6, "SPECIAL THANKS@"
CreditsText_Producers:
	db -4, "PRODUCERS@"
CreditsText_Producer:
	db -3, "PRODUCER@"
CreditsText_ExecutiveProducer:
	db -8, "EXECUTIVE PRODUCER@"
CreditsText_Tamada:
	db -6, "SOUSUKE TAMADA@"
CreditsText_Oota2:
	db -5, "SATOSHI OOTA@"
CreditsText_Yoshikawa:
	db -6, "RENA YOSHIKAWA@"
CreditsText_Oota23:
	db -6, "TOMOMICHI OOTA@"
CreditsText_Matsumita:
	db -8, "TOSHINOBU MATSUMIYA@"
CreditsText_Seya:
	db -5, "NOBUHIRO SEYA@"
CreditsText_Yoshida:
	db -7, "HIRONOBU YOSHIDA@"
CreditsText_Sekine:
	db -6, "KAZUHITO SEKINE@"
CreditsText_Shimamura:
	db -7, "KAZUSHI SHIMAMURA@"
CreditsText_Shimoyamada:
	db -9, "TERUYUKI SHIMOYAMADA@"
CreditsText_SuperMarioClub:
	db -9, "NCL SUPER MARIO CLUB@"
CreditsText_Izushi:
	db -7, "TAKEHIRO IZUSHI@"
CreditsText_Nomura:
	db -5, "FUZIKO NOMURA@"
CreditsText_Harada:
	db -6, "TAKAHIRO HARADA@"
CreditsText_Yamagami:
	db -7, "HITOSHI YAMAGAMI@"
CreditsText_Nishimura:
	db -8, "KENTAROU NISHIMURA@"
CreditsText_Saeki:
	db -5, "NAOKO SAEKI@"
CreditsText_Fuzii:
	db -5, "TAKAYA FUZII@"
CreditsText_Shogakukan:
	db -4, "SHOGAKUKAN"
	next   "PRODUCTION@"
CreditsText_Ootani:
	db -5, "IKUE OOTANI@"
CreditsText_PikachuVoice:
	db -6, "PIKACHU VOICE@"

	db -3, "××××××××@"
CreditsText_USStaff:
	db -7, "US VERSION STAFF@"
CreditsText_USCoord:
	db -7, "US COORDINATION@"
CreditsText_Tilden:
	db -5, "GAIL TILDEN@"
CreditsText_Kawakami:
	db -6, "NAOKO KAWAKAMI@"
CreditsText_Nakamura2:
	db -6, "HIRO NAKAMURA@"
CreditsText_Shoemake:
	db -6, "RANDY SHOEMAKE@"
CreditsText_Osborne:
	db -5, "SARA OSBORNE@"
CreditsText_Translation:
	db -7, "TEXT TRANSLATION@"
CreditsText_Ogasawara:
	db -6, "NOB OGASAWARA@"
CreditsText_Iwata:
	db -5, "SATORU IWATA@"
CreditsText_Izushi2:
	db -7, "TAKEHIRO IZUSHI@"
CreditsText_Harada2:
	db -7, "TAKAHIRO HARADA@"
CreditsText_Murakawa:
	db -7, "TERUKI MURAKAWA@"
CreditsText_Fukui:
	db -5, "KOHTA FUKUI@"
CreditsText_SuperMarioClub2:
	db -9, "NCL SUPER MARIO CLUB@"
CreditsText_Paad:
	db -5, "PAAD TESTING@"
CreditsText_Hosokawa:
	db -8, "TAKEHIKO HOSOKAWA@"
CreditsText_Okubo:
	db -5, "KENJI OKUBO@"
CreditsText_Nakamichi:
	db -7, "KIMIKO NAKAMICHI@"
CreditsText_Yoshimura:
	db -6, "KAMON YOSHIMURA@"
CreditsText_Yamazaki:
	db -6, "SAKAE YAMAZAKI@"

CreditsText_Creator:
	db -4, "CREATED BY@"
CreditsText_Developer:
	db -3, "DEVELOPER@"
CreditsText_Editor:
	db -2, "EDITOR@"
CreditsText_Moderators:
	db -4, "MODERATORS@"
CreditsText_Playtesters:
	db -4, "PLAYTESTERS@"
CreditsText_SpriteArtists:
	db -6, "SPRITE ARTISTS@"
CreditsText_BackspriteArtists:
	db -8, "BACKSPRITE ARTISTS@"
CreditsText_Tutorials:
	db -7, "TUTORIALS / CODE@"
CreditsText_Pret1:
	db -7, "THANK YOU TO THE@"
CreditsText_Pret2:
	db -7, "PRET TEAM FOR THE@"
CreditsText_Pret3:
	db -4, "POKEYELLOW@"
CreditsText_Pret4:
	db -4, "DISASSEMBLY@"

CreditsText_SmithPlaysPokemon:
	db -7, "SMITHPLAYSPOKEMON@"

CreditsText_Smith:
	db -6, "THE SMITH PLAYS@"
CreditsText_cRzShadows:
	db -4, "CRZ SHADOWS@"
CreditsText_Weebra:
	db -2, "WEEBRA@"

; Moderators
CreditsText_Aero:
	db -1, "AERO@"
CreditsText_Zach:
	db -3, "ZUPERZACH@"
CreditsText_Karlos:
	db -2, "KARLOS@"
CreditsText_Isona:
	db -1, "ISONA@"
CreditsText_Regi:
	db -1, "REGI@"
CreditsText_Daily:
	db -1, "DAILY@"
CreditsText_Obelisk:
	db -2, "OBELISK@"

; Playtesters
CreditsText_Disq:
	db -1, "DISQ@"
CreditsText_Brice:
	db -1, "BRICE@"
CreditsText_ReaderDragon:
	db -5, "READER DRAGON@"
CreditsText_Sable:
	db -1, "SABLE@"
CreditsText_Soul:
	db -4, "SOULXCROSS@"
CreditsText_Talos:
	db -1, "TALOS@"
CreditsText_Alakadoof:
	db -3, "ALAKADOOF@"
CreditsText_Rwne:
	db -1, "RWNE@"


; Code/Tutorials
CreditsText_Rangi42:
	db -2, "RANGI42@"
CreditsText_PlagueVonKarma:
	db -6, "PLAGUEVONKARMA@"
CreditsText_Jojobear13:
	db -4, "JOJOBEAR13@"
CreditsText_YakiNeen:
	db -3, "YAKINEEN@"
CreditsText_Pgattic:
	db -2, "PGATTIC@"
CreditsText_Xillicis:
	db -3, "XILLICIS@"
CreditsText_Dannye:
	db -2, "DANNYE@"
CreditsText_SoupPotato:
	db -4, "SOUPPOTATO@"
CreditsText_Voloved:
	db -2, "VOLOVED@"
CreditsText_Veganlies2me:
	db -5, "VEGANLIES2ME@"
CreditsText_SatoMew:
	db -2, "SATOMEW@"
CreditsText_TPP:
	db -8, "TWITCHPLAYSPOKEMON@"

; Special Thanks
CreditsText_Idain:
	db -1, "IDAIN@"
CreditsText_Nayru62:
	db -2, "NAYRU62@"
CreditsText_Jaas:
	db -4, "JaaShooUhh@"

; Sprite Artists
; Backsprites
CreditsText_ZuperZach2:
	db -3, "ZUPERZACH@"
CreditsText_Isona2:
	db -1, "ISONA@"
CreditsText_Karlos2:
	db -2, "KARLOS@"
CreditsText_ReaderDragon2:
	db -13, "READER DRAGON@"
CreditsText_Alakadoof2:
	db -3, "ALAKADOOF@"

; Green Sprite
CreditsText_Longlostsoul:
	db -4, "MADAME FROG@"
CreditsText_GhostMissingNo:
	db -6, "GHOST-MISSINGNO@"

; Porygon Sprite
CreditsText_ZetaNull:
	db -3, "ZETA NULL@"

; Party Sprites
CreditsText_Chamber:
	db -2, "CHAMBER@"
CreditsText_Soloo993:
	db -3, "SOLOO993@"
CreditsText_BlueEmerald:
	db -5, "BLUE EMERALD@"
CreditsText_Lake:
	db -1, "LAKE@"
CreditsText_Neslug:
	db -2, "NESLUG@"
CreditsText_TomWang:
	db -3, "TOM WANG@"