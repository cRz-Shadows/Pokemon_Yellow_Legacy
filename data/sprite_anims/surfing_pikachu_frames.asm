SurfingPikachuFrames:
	dw SurfingPikachuFrames_SingleTile ; 00
	dw SurfingPikachuFrames_Rotation1 ; 01
	dw SurfingPikachuFrames_Rotation2 ; 02
	dw SurfingPikachuFrames_Rotation3 ; 03
	dw SurfingPikachuFrames_Rotation4 ; 04
	dw SurfingPikachuFrames_Rotation5 ; 05
	dw SurfingPikachuFrames_Rotation6 ; 06
	dw SurfingPikachuFrames_Rotation7 ; 07
	dw SurfingPikachuFrames_Rotation8 ; 08
	dw SurfingPikachuFrames_Rotation9 ; 09
	dw SurfingPikachuFrames_Rotation10 ; 0a
	dw SurfingPikachuFrames_Rotation11 ; 0b
	dw SurfingPikachuFrames_Rotation12 ; 0c
	dw SurfingPikachuFrames_Rotation13 ; 0d
	dw SurfingPikachuFrames_Rotation14 ; 0e
	dw SurfingPikachuFrames_Results ; 0f
	dw SurfingPikachuFrames_Wipeout ; 10
	dw SurfingPikachuFrames_StartBanner ; 11
	dw SurfingPikachuFrames_GoalBanner ; 12
	dw SurfingPikachuFrames_OhNoBanner ; 13
	dw SurfingPikachuFrames_WaterSpray ; 14
	dw SurfingPikachuFrames_Plus50Pts ; 15
	dw SurfingPikachuFrames_Plus150Pts ; 16
	dw SurfingPikachuFrames_Plus350Pts ; 17
	dw SurfingPikachuFrames_Plus750Pts ; 18
	dw SurfingPikachuFrames_Plus180Pts ; 19
	dw SurfingPikachuFrames_Plus500Pts ; 1a
	dw SurfingPikachuFrames_IntroPikachu ; 1b

; Frameset 00: static single-tile frame for the null object
SurfingPikachuFrames_SingleTile:
	frame $00, 32
	endanim

; Frameset 01: surfing Pikachu rotation step 1 of 14 (steepest tilt)
SurfingPikachuFrames_Rotation1:
	frame $01, 8
	frame $02, 8
	dorestart

; Frameset 02: surfing Pikachu rotation step 2 of 14 (downhill slope tilt)
SurfingPikachuFrames_Rotation2:
	frame $03, 8
	frame $04, 8
	dorestart

; Frameset 03: surfing Pikachu rotation step 3 of 14 (slight tilt)
SurfingPikachuFrames_Rotation3:
	frame $05, 8
	frame $06, 8
	dorestart

; Frameset 04: surfing Pikachu rotation step 4 of 14 (level board; default riding)
SurfingPikachuFrames_Rotation4:
	frame $07, 8
	frame $08, 8
	dorestart

; Frameset 05: surfing Pikachu rotation step 5 of 14 (slight uphill tilt)
SurfingPikachuFrames_Rotation5:
	frame $09, 8
	frame $0a, 8
	dorestart

; Frameset 06: surfing Pikachu rotation step 6 of 14 (uphill slope tilt)
SurfingPikachuFrames_Rotation6:
	frame $0b, 8
	frame $0c, 8
	dorestart

; Frameset 07: surfing Pikachu rotation step 7 of 14 (steep uphill tilt)
SurfingPikachuFrames_Rotation7:
	frame $0d, 8
	frame $0e, 8
	dorestart

; Frameset 08: rotation step 8 of 14 = step 1 flipped (upside-down mid-flip)
SurfingPikachuFrames_Rotation8:
	frame $01, 8, OAM_HFLIP, OAM_VFLIP
	frame $02, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; Frameset 09: rotation step 9 of 14 = step 2 flipped (upside-down mid-flip)
SurfingPikachuFrames_Rotation9:
	frame $03, 8, OAM_HFLIP, OAM_VFLIP
	frame $04, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; Frameset 0a: rotation step 10 of 14 = step 3 flipped (upside-down mid-flip)
SurfingPikachuFrames_Rotation10:
	frame $05, 8, OAM_HFLIP, OAM_VFLIP
	frame $06, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; Frameset 0b: rotation step 11 of 14 = step 4 flipped (upside-down mid-flip)
SurfingPikachuFrames_Rotation11:
	frame $07, 8, OAM_HFLIP, OAM_VFLIP
	frame $08, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; Frameset 0c: rotation step 12 of 14 = step 5 flipped (upside-down mid-flip)
SurfingPikachuFrames_Rotation12:
	frame $09, 8, OAM_HFLIP, OAM_VFLIP
	frame $0a, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; Frameset 0d: rotation step 13 of 14 = step 6 flipped (upside-down mid-flip)
SurfingPikachuFrames_Rotation13:
	frame $0b, 8, OAM_HFLIP, OAM_VFLIP
	frame $0c, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; Frameset 0e: rotation step 14 of 14 = step 7 flipped (upside-down mid-flip)
SurfingPikachuFrames_Rotation14:
	frame $0d, 8, OAM_HFLIP, OAM_VFLIP
	frame $0e, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; Frameset 0f: Pikachu's 2-frame idle loop on the results screen
SurfingPikachuFrames_Results:
	frame $11, 7
	frame $12, 7
	dorestart

; Frameset 10: crash animation, small/large splash x8 then empty surfboard
SurfingPikachuFrames_Wipeout:
	frame $13, 2
	frame $14, 2
	dorepeat 8
	frame $15, 2
	endanim

; Frameset 11: "Start" banner slid to center at game start, deleted after 64 frames
SurfingPikachuFrames_StartBanner:
	frame $16, 32
	frame $16, 32
	delanim

; Frameset 12: "Goal" banner (spawn 3), deleted after 64 frames
SurfingPikachuFrames_GoalBanner:
	frame $17, 32
	frame $17, 32
	delanim

; Frameset 13: "Oh no.." banner bounced in on game over (HP ran out)
SurfingPikachuFrames_OhNoBanner:
	frame $18, 32
	endanim

; Frameset 15: flickering "+50" points popup after a trick, then deleted
SurfingPikachuFrames_Plus50Pts:
	frame $1a, 4
	dorepeat 1
	frame $1a, 3
	dorepeat 1
	frame $1a, 2
	dorepeat 1
	frame $1a, 1
	delanim

; Frameset 16: flickering "+150" points popup after a trick, then deleted
SurfingPikachuFrames_Plus150Pts:
	frame $1b, 4
	dorepeat 1
	frame $1b, 3
	dorepeat 1
	frame $1b, 2
	dorepeat 1
	frame $1b, 1
	delanim

; Frameset 17: flickering "+350" points popup after a trick, then deleted
SurfingPikachuFrames_Plus350Pts:
	frame $1c, 4
	dorepeat 1
	frame $1c, 3
	dorepeat 1
	frame $1c, 2
	dorepeat 1
	frame $1c, 1
	delanim

; Frameset 18: flickering "+750" points popup after a trick, then deleted
SurfingPikachuFrames_Plus750Pts:
	frame $1d, 4
	dorepeat 1
	frame $1d, 3
	dorepeat 1
	frame $1d, 2
	dorepeat 1
	frame $1d, 1
	delanim

; Frameset 19: flickering "+180" points popup (mixed trick chain), then deleted
SurfingPikachuFrames_Plus180Pts:
	frame $1e, 4
	dorepeat 1
	frame $1e, 3
	dorepeat 1
	frame $1e, 2
	dorepeat 1
	frame $1e, 1
	delanim

; Frameset 1a: flickering "+500" points popup (mixed trick chain), then deleted
SurfingPikachuFrames_Plus500Pts:
	frame $1f, 4
	dorepeat 1
	frame $1f, 3
	dorepeat 1
	frame $1f, 2
	dorepeat 1
	frame $1f, 1
	delanim

; Frameset 14: one-frame water spray behind the surfboard
SurfingPikachuFrames_WaterSpray:
	frame $19, 1
	delanim

; Frameset 1b: 4-frame surfing Pikachu loop on the minigame intro/title screen
SurfingPikachuFrames_IntroPikachu:
	frame $20, 7
	frame $21, 7
	frame $22, 7
	frame $23, 7
	dorestart
