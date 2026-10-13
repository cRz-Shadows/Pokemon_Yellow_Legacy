YellowIntro_AnimatedObjectFramesData:
	dw Unkn_fa100
	dw Unkn_fa103
	dw Unkn_fa10a
	dw Unkn_fa111
	dw Unkn_fa118
	dw Unkn_fa11b
	dw Unkn_fa11e
	dw Unkn_fa121
	dw Unkn_fa124
	dw Unkn_fa127
	dw Unkn_fa138

; SUGGESTED NAME: YellowIntroFrames_Blank
; Intro frameset 0: static single-tile frame for null object 0 (unused) (confidence: medium)
Unkn_fa100:
	frame $00, 32
	endanim

; SUGGESTED NAME: YellowIntroFrames_PikachuWalkSmall
; Intro scene 0: tiny distant Pikachu walking toward camera, 3-frame loop (confidence: high)
Unkn_fa103:
	frame $01, 4
	frame $02, 4
	frame $03, 4
	dorestart

; SUGGESTED NAME: YellowIntroFrames_PikachuWalkMedium
; Intro scene 4: medium-size Pikachu walking toward camera, 3-frame loop (confidence: high)
Unkn_fa10a:
	frame $04, 4
	frame $05, 4
	frame $06, 4
	dorestart

; SUGGESTED NAME: YellowIntroFrames_PikachuWalkLarge
; Intro scene 8: large Pikachu walking toward camera, 3-frame loop (confidence: high)
Unkn_fa111:
	frame $07, 4
	frame $08, 4
	frame $09, 4
	dorestart

; SUGGESTED NAME: YellowIntroFrames_PikachuDash
; Leaping/dashing Pikachu sprite; spawn 4 overloaded in scene 2, unused (confidence: medium)
Unkn_fa118:
	frame $0a, 32
	endanim

; SUGGESTED NAME: YellowIntroFrames_SurfingPikachu
; Intro scene 6: Pikachu riding a surfboard on the waves (confidence: high)
Unkn_fa11b:
	frame $0b, 32
	endanim

; SUGGESTED NAME: YellowIntroFrames_FlyingPikachu
; Intro scene 10: Pikachu floating with balloons above the clouds (confidence: high)
Unkn_fa11e:
	frame $0c, 32
	endanim

; SUGGESTED NAME: YellowIntroFrames_PikachuFinalPose
; Intro scene 15: big angry/fighting Pikachu pose at the end of the intro (confidence: medium)
Unkn_fa121:
	frame $0d, 32
	endanim

; SUGGESTED NAME: YellowIntroFrames_SpeedLine
; Intro scene 2: white horizontal speed line streaks (spawned 8x) (confidence: high)
Unkn_fa124:
	frame $0e, 32
	endanim

; SUGGESTED NAME: YellowIntroFrames_PikachuEyesBlink
; Intro scene 12: eyes over the big Pikachu face; blinks twice, then a final glance (confidence: high)
Unkn_fa127:
	frame $0f, 31
	frame $11, 2
	frame $0f, 2
	frame $11, 2
	frame $0f, 31
	frame $11, 2
	frame $0f, 23
	frame $10, 32
	endanim

; SUGGESTED NAME: YellowIntroFrames_CheekSparks
; Intro scene 13: electric sparks crackling from Pikachu's cheeks, 2-frame loop (confidence: high)
Unkn_fa138:
	frame $12, 4
	frame $13, 4
	dorestart
