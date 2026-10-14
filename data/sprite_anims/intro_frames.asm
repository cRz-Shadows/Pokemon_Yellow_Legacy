YellowIntro_AnimatedObjectFramesData:
	dw YellowIntroFrames_Blank
	dw YellowIntroFrames_PikachuWalkSmall
	dw YellowIntroFrames_PikachuWalkMedium
	dw YellowIntroFrames_PikachuWalkLarge
	dw YellowIntroFrames_PikachuDash
	dw YellowIntroFrames_SurfingPikachu
	dw YellowIntroFrames_FlyingPikachu
	dw YellowIntroFrames_PikachuFinalPose
	dw YellowIntroFrames_SpeedLine
	dw YellowIntroFrames_PikachuEyesBlink
	dw YellowIntroFrames_CheekSparks

; Intro frameset 0: static single-tile frame for null object 0 (unused)
YellowIntroFrames_Blank:
	frame $00, 32
	endanim

; Intro scene 0: tiny distant Pikachu walking toward camera, 3-frame loop
YellowIntroFrames_PikachuWalkSmall:
	frame $01, 4
	frame $02, 4
	frame $03, 4
	dorestart

; Intro scene 4: medium-size Pikachu walking toward camera, 3-frame loop
YellowIntroFrames_PikachuWalkMedium:
	frame $04, 4
	frame $05, 4
	frame $06, 4
	dorestart

; Intro scene 8: large Pikachu walking toward camera, 3-frame loop
YellowIntroFrames_PikachuWalkLarge:
	frame $07, 4
	frame $08, 4
	frame $09, 4
	dorestart

; Leaping/dashing Pikachu sprite; spawn 4 overloaded in scene 2, unused
YellowIntroFrames_PikachuDash:
	frame $0a, 32
	endanim

; Intro scene 6: Pikachu riding a surfboard on the waves
YellowIntroFrames_SurfingPikachu:
	frame $0b, 32
	endanim

; Intro scene 10: Pikachu floating with balloons above the clouds
YellowIntroFrames_FlyingPikachu:
	frame $0c, 32
	endanim

; Intro scene 15: big angry/fighting Pikachu pose at the end of the intro
YellowIntroFrames_PikachuFinalPose:
	frame $0d, 32
	endanim

; Intro scene 2: white horizontal speed line streaks (spawned 8x)
YellowIntroFrames_SpeedLine:
	frame $0e, 32
	endanim

; Intro scene 12: eyes over the big Pikachu face; blinks twice, then a final glance
YellowIntroFrames_PikachuEyesBlink:
	frame $0f, 31
	frame $11, 2
	frame $0f, 2
	frame $11, 2
	frame $0f, 31
	frame $11, 2
	frame $0f, 23
	frame $10, 32
	endanim

; Intro scene 13: electric sparks crackling from Pikachu's cheeks, 2-frame loop
YellowIntroFrames_CheekSparks:
	frame $12, 4
	frame $13, 4
	dorestart
