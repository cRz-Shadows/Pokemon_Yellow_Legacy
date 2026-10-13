SurfingPikachuFrames:
	dw Unkn_f943d ; 00
	dw Unkn_f9440 ; 01
	dw Unkn_f9445 ; 02
	dw Unkn_f944a ; 03
	dw Unkn_f944f ; 04
	dw Unkn_f9454 ; 05
	dw Unkn_f9459 ; 06
	dw Unkn_f945e ; 07
	dw Unkn_f9463 ; 08
	dw Unkn_f9468 ; 09
	dw Unkn_f946d ; 0a
	dw Unkn_f9472 ; 0b
	dw Unkn_f9477 ; 0c
	dw Unkn_f947c ; 0d
	dw Unkn_f9481 ; 0e
	dw Unkn_f9486 ; 0f
	dw Unkn_f948b ; 10
	dw Unkn_f9494 ; 11
	dw Unkn_f9499 ; 12
	dw Unkn_f949e ; 13
	dw Unkn_f94fb ; 14
	dw Unkn_f94a1 ; 15
	dw Unkn_f94b0 ; 16
	dw Unkn_f94bf ; 17
	dw Unkn_f94ce ; 18
	dw Unkn_f94dd ; 19
	dw Unkn_f94ec ; 1a
	dw Unkn_f94fe ; 1b

; SUGGESTED NAME: SurfingPikachuFrames_SingleTile
; Frameset 00: static single-tile frame for the null object (confidence: medium)
Unkn_f943d:
	frame $00, 32
	endanim

; SUGGESTED NAME: SurfingPikachuFrames_Rotation1
; Frameset 01: surfing Pikachu rotation step 1 of 14 (steepest tilt) (confidence: medium)
Unkn_f9440:
	frame $01, 8
	frame $02, 8
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation2
; Frameset 02: surfing Pikachu rotation step 2 of 14 (downhill slope tilt) (confidence: medium)
Unkn_f9445:
	frame $03, 8
	frame $04, 8
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation3
; Frameset 03: surfing Pikachu rotation step 3 of 14 (slight tilt) (confidence: medium)
Unkn_f944a:
	frame $05, 8
	frame $06, 8
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation4
; Frameset 04: surfing Pikachu rotation step 4 of 14 (level board; default riding) (confidence: high)
Unkn_f944f:
	frame $07, 8
	frame $08, 8
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation5
; Frameset 05: surfing Pikachu rotation step 5 of 14 (slight uphill tilt) (confidence: medium)
Unkn_f9454:
	frame $09, 8
	frame $0a, 8
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation6
; Frameset 06: surfing Pikachu rotation step 6 of 14 (uphill slope tilt) (confidence: medium)
Unkn_f9459:
	frame $0b, 8
	frame $0c, 8
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation7
; Frameset 07: surfing Pikachu rotation step 7 of 14 (steep uphill tilt) (confidence: medium)
Unkn_f945e:
	frame $0d, 8
	frame $0e, 8
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation8
; Frameset 08: rotation step 8 of 14 = step 1 flipped (upside-down mid-flip) (confidence: high)
Unkn_f9463:
	frame $01, 8, OAM_HFLIP, OAM_VFLIP
	frame $02, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation9
; Frameset 09: rotation step 9 of 14 = step 2 flipped (upside-down mid-flip) (confidence: high)
Unkn_f9468:
	frame $03, 8, OAM_HFLIP, OAM_VFLIP
	frame $04, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation10
; Frameset 0a: rotation step 10 of 14 = step 3 flipped (upside-down mid-flip) (confidence: high)
Unkn_f946d:
	frame $05, 8, OAM_HFLIP, OAM_VFLIP
	frame $06, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation11
; Frameset 0b: rotation step 11 of 14 = step 4 flipped (upside-down mid-flip) (confidence: high)
Unkn_f9472:
	frame $07, 8, OAM_HFLIP, OAM_VFLIP
	frame $08, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation12
; Frameset 0c: rotation step 12 of 14 = step 5 flipped (upside-down mid-flip) (confidence: high)
Unkn_f9477:
	frame $09, 8, OAM_HFLIP, OAM_VFLIP
	frame $0a, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation13
; Frameset 0d: rotation step 13 of 14 = step 6 flipped (upside-down mid-flip) (confidence: high)
Unkn_f947c:
	frame $0b, 8, OAM_HFLIP, OAM_VFLIP
	frame $0c, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Rotation14
; Frameset 0e: rotation step 14 of 14 = step 7 flipped (upside-down mid-flip) (confidence: high)
Unkn_f9481:
	frame $0d, 8, OAM_HFLIP, OAM_VFLIP
	frame $0e, 8, OAM_HFLIP, OAM_VFLIP
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Results
; Frameset 0f: Pikachu's 2-frame idle loop on the results screen (confidence: high)
Unkn_f9486:
	frame $11, 7
	frame $12, 7
	dorestart

; SUGGESTED NAME: SurfingPikachuFrames_Wipeout
; Frameset 10: crash animation, small/large splash x8 then empty surfboard (confidence: high)
Unkn_f948b:
	frame $13, 2
	frame $14, 2
	dorepeat 8
	frame $15, 2
	endanim

; SUGGESTED NAME: SurfingPikachuFrames_StartBanner
; Frameset 11: "Start" banner slid to center at game start, deleted after 64 frames (confidence: high)
Unkn_f9494:
	frame $16, 32
	frame $16, 32
	delanim

; SUGGESTED NAME: SurfingPikachuFrames_GoalBanner
; Frameset 12: "Goal" banner (spawn 3), deleted after 64 frames (confidence: high)
Unkn_f9499:
	frame $17, 32
	frame $17, 32
	delanim

; SUGGESTED NAME: SurfingPikachuFrames_OhNoBanner
; Frameset 13: "Oh no.." banner bounced in on game over (HP ran out) (confidence: high)
Unkn_f949e:
	frame $18, 32
	endanim

; SUGGESTED NAME: SurfingPikachuFrames_Plus50Pts
; Frameset 15: flickering "+50" points popup after a trick, then deleted (confidence: high)
Unkn_f94a1:
	frame $1a, 4
	dorepeat 1
	frame $1a, 3
	dorepeat 1
	frame $1a, 2
	dorepeat 1
	frame $1a, 1
	delanim

; SUGGESTED NAME: SurfingPikachuFrames_Plus150Pts
; Frameset 16: flickering "+150" points popup after a trick, then deleted (confidence: high)
Unkn_f94b0:
	frame $1b, 4
	dorepeat 1
	frame $1b, 3
	dorepeat 1
	frame $1b, 2
	dorepeat 1
	frame $1b, 1
	delanim

; SUGGESTED NAME: SurfingPikachuFrames_Plus350Pts
; Frameset 17: flickering "+350" points popup after a trick, then deleted (confidence: high)
Unkn_f94bf:
	frame $1c, 4
	dorepeat 1
	frame $1c, 3
	dorepeat 1
	frame $1c, 2
	dorepeat 1
	frame $1c, 1
	delanim

; SUGGESTED NAME: SurfingPikachuFrames_Plus750Pts
; Frameset 18: flickering "+750" points popup after a trick, then deleted (confidence: high)
Unkn_f94ce:
	frame $1d, 4
	dorepeat 1
	frame $1d, 3
	dorepeat 1
	frame $1d, 2
	dorepeat 1
	frame $1d, 1
	delanim

; SUGGESTED NAME: SurfingPikachuFrames_Plus180Pts
; Frameset 19: flickering "+180" points popup (mixed trick chain), then deleted (confidence: high)
Unkn_f94dd:
	frame $1e, 4
	dorepeat 1
	frame $1e, 3
	dorepeat 1
	frame $1e, 2
	dorepeat 1
	frame $1e, 1
	delanim

; SUGGESTED NAME: SurfingPikachuFrames_Plus500Pts
; Frameset 1a: flickering "+500" points popup (mixed trick chain), then deleted (confidence: high)
Unkn_f94ec:
	frame $1f, 4
	dorepeat 1
	frame $1f, 3
	dorepeat 1
	frame $1f, 2
	dorepeat 1
	frame $1f, 1
	delanim

; SUGGESTED NAME: SurfingPikachuFrames_WaterSpray
; Frameset 14: one-frame water spray behind the surfboard (confidence: high)
Unkn_f94fb:
	frame $19, 1
	delanim

; SUGGESTED NAME: SurfingPikachuFrames_IntroPikachu
; Frameset 1b: 4-frame surfing Pikachu loop on the minigame intro/title screen (confidence: high)
Unkn_f94fe:
	frame $20, 7
	frame $21, 7
	frame $22, 7
	frame $23, 7
	dorestart
