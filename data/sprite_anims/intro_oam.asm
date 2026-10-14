YellowIntro_AnimatedObjectOAMData:
	dbw $00, YellowIntroOAM_SingleTile
	dbw $96, YellowIntroOAM_PikachuWalkSmall
	dbw $98, YellowIntroOAM_PikachuWalkSmall
	dbw $9a, YellowIntroOAM_PikachuWalkSmall
	dbw $0c, YellowIntroOAM_PikachuWalkMedium
	dbw $0e, YellowIntroOAM_PikachuWalkMedium
	dbw $3c, YellowIntroOAM_PikachuWalkMedium
	dbw $60, YellowIntroOAM_PikachuWalkLarge
	dbw $70, YellowIntroOAM_PikachuWalkLarge
	dbw $80, YellowIntroOAM_PikachuWalkLarge
	dbw $90, YellowIntroOAM_Pikachu48x48
	dbw $00, YellowIntroOAM_Pikachu48x48
	dbw $06, YellowIntroOAM_Pikachu48x48
	dbw $c6, YellowIntroOAM_PikachuFinalPose
	dbw $6d, YellowIntroOAM_SpeedLine
	dbw $f0, YellowIntroOAM_PikachuEyes
	dbw $f4, YellowIntroOAM_PikachuEyes
	dbw $f8, YellowIntroOAM_PikachuEyes
	dbw $9c, YellowIntroOAM_CheekSparks
	dbw $ec, YellowIntroOAM_CheekSparks

; Intro OAM: a single 8x8 tile
YellowIntroOAM_SingleTile:
	db 1
	db $fc, $fc, $00, $00
; Intro OAM: 16x16 tiny walking Pikachu silhouette
YellowIntroOAM_PikachuWalkSmall:
	db 4
	db $f8, $f8, $00, $00
	db $f8, $00, $01, $00
	db $00, $f8, $10, $00
	db $00, $00, $11, $00

; Intro OAM: 16x32 medium walking Pikachu, lower half mirrored
YellowIntroOAM_PikachuWalkMedium:
	db 8
	db $f0, $f8, $00, $00
	db $f0, $00, $01, $00
	db $f8, $f8, $10, $00
	db $f8, $00, $11, $00
	db $00, $f8, $20, $00
	db $00, $00, $20, $20
	db $08, $f8, $21, $00
	db $08, $00, $21, $20

; Intro OAM: 32x48 large walking Pikachu, mostly mirrored
YellowIntroOAM_PikachuWalkLarge:
	db 20
	db $e8, $f8, $00, $00
	db $e8, $00, $01, $00
	db $f0, $f8, $02, $00
	db $f0, $00, $03, $00
	db $f8, $f0, $04, $00
	db $f8, $f8, $05, $00
	db $f8, $00, $06, $00
	db $f8, $08, $04, $20
	db $00, $f0, $07, $00
	db $00, $f8, $08, $00
	db $00, $00, $08, $20
	db $00, $08, $07, $20
	db $08, $f0, $09, $00
	db $08, $f8, $0a, $00
	db $08, $00, $0a, $20
	db $08, $08, $09, $20
	db $10, $f0, $0b, $00
	db $10, $f8, $0c, $00
	db $10, $00, $0c, $20
	db $10, $08, $0b, $20

; Intro OAM: 6x6-tile (48x48) sprite used for dashing, surfing and flying Pikachu
YellowIntroOAM_Pikachu48x48:
	db 36
	db $e8, $e8, $00, $00
	db $e8, $f0, $01, $00
	db $e8, $f8, $02, $00
	db $e8, $00, $03, $00
	db $e8, $08, $04, $00
	db $e8, $10, $05, $00
	db $f0, $e8, $10, $00
	db $f0, $f0, $11, $00
	db $f0, $f8, $12, $00
	db $f0, $00, $13, $00
	db $f0, $08, $14, $00
	db $f0, $10, $15, $00
	db $f8, $e8, $20, $00
	db $f8, $f0, $21, $00
	db $f8, $f8, $22, $00
	db $f8, $00, $23, $00
	db $f8, $08, $24, $00
	db $f8, $10, $25, $00
	db $00, $e8, $30, $00
	db $00, $f0, $31, $00
	db $00, $f8, $32, $00
	db $00, $00, $33, $00
	db $00, $08, $34, $00
	db $00, $10, $35, $00
	db $08, $e8, $40, $00
	db $08, $f0, $41, $00
	db $08, $f8, $42, $00
	db $08, $00, $43, $00
	db $08, $08, $44, $00
	db $08, $10, $45, $00
	db $10, $e8, $50, $00
	db $10, $f0, $51, $00
	db $10, $f8, $52, $00
	db $10, $00, $53, $00
	db $10, $08, $54, $00
	db $10, $10, $55, $00

; Intro OAM: 5x5-tile (40x40) final angry Pikachu pose
YellowIntroOAM_PikachuFinalPose:
	db 25
	db $ec, $f0, $00, $00
	db $ec, $f8, $01, $00
	db $ec, $00, $02, $00
	db $ec, $08, $03, $00
	db $ec, $10, $04, $00
	db $f4, $f0, $05, $00
	db $f4, $f8, $06, $00
	db $f4, $00, $07, $00
	db $f4, $08, $08, $00
	db $f4, $10, $09, $00
	db $fc, $f0, $10, $00
	db $fc, $f8, $11, $00
	db $fc, $00, $12, $00
	db $fc, $08, $13, $00
	db $fc, $10, $14, $00
	db $04, $f0, $15, $00
	db $04, $f8, $16, $00
	db $04, $00, $17, $00
	db $04, $08, $18, $00
	db $04, $10, $19, $00
	db $0c, $f0, $20, $00
	db $0c, $f8, $21, $00
	db $0c, $00, $22, $00
	db $0c, $08, $23, $00
	db $0c, $10, $24, $00

; Intro OAM: 32x8 mirrored horizontal speed line
YellowIntroOAM_SpeedLine:
	db 4
	db $fc, $f0, $00, $00
	db $fc, $f8, $01, $00
	db $fc, $00, $01, $20
	db $fc, $08, $00, $20

; Intro OAM: pair of mirrored 16x16 eyes (OBP1) placed over the big Pikachu face
YellowIntroOAM_PikachuEyes:
	db 8
	db $f8, $e8, $00, $10
	db $f8, $f0, $01, $10
	db $00, $e8, $02, $10
	db $00, $f0, $03, $10
	db $f8, $08, $01, $30
	db $f8, $10, $00, $30
	db $00, $08, $03, $30
	db $00, $10, $02, $30

; Intro OAM: pair of mirrored 24x16 electric sparks either side of Pikachu's face
YellowIntroOAM_CheekSparks:
	db 12
	db $f8, $d8, $00, $10
	db $f8, $e0, $01, $10
	db $f8, $e8, $02, $10
	db $00, $d8, $10, $10
	db $00, $e0, $11, $10
	db $00, $e8, $12, $10
	db $f8, $10, $02, $30
	db $f8, $18, $01, $30
	db $f8, $20, $00, $30
	db $00, $10, $12, $30
	db $00, $18, $11, $30
	db $00, $20, $10, $30
