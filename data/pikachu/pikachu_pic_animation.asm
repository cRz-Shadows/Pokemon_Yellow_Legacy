PikaPicAnimThunderboltPals:
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db 4, %11000000
	db 4, %11100100
	db -1 ; end

PikaPicAnimScript0:
PikaPicAnimScript1:
PikaPicAnimScript29:
	pikapic_setduration 40
	pikapic_loadgfx PikaPicNeutralPic
	pikapic_loadgfx PikaPicNeutralBlinkGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_6, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry3
	pikapic_looptofinish

PikaPicAnimScript2:
	pikapic_setduration 44
	pikapic_loadgfx PikaPicCheeksHappyPic
	pikapic_loadgfx PikaPicCheeksHappyGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_7, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript3:
	pikapic_setduration 80
	pikapic_loadgfx PikaPicUnimpressedPic
	pikapic_loadgfx PikaPicUnimpressedEarGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_8, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript4:
	pikapic_setduration 70
	pikapic_loadgfx PikaPicContentPic
	pikapic_loadgfx PikaPicContentEyesOpenGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_9, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript5:
	pikapic_setduration 32
	pikapic_loadgfx PikaPicBlankStarePic
	pikapic_loadgfx PikaPicBlankStareEarGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_10, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript6:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicTurnedAwayPic
	pikapic_loadgfx PikaPicTurnedAwayGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_11, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry38
	pikapic_looptofinish

PikaPicAnimScript7:
	pikapic_setduration 58
	pikapic_loadgfx PikaPicExcitedPic
	pikapic_loadgfx PikaPicExcitedGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_12, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript8:
	pikapic_setduration 44
	pikapic_loadgfx PikaPicSmilePic
	pikapic_loadgfx PikaPicSmileGrinGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_13, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript9:
	pikapic_setduration 56
	pikapic_loadgfx PikaPicBackTurnedPic
	pikapic_loadgfx PikaPicBackTurnedEarGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_14, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript10:
	pikapic_setduration 56
	pikapic_loadgfx PikaPicHeartPic
	pikapic_loadgfx PikaPicHeartGFX1
	pikapic_loadgfx PikaPicHeartGFX2
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_16, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript11:
	pikapic_setduration 100
	pikapic_loadgfx PikaPicSleepingPic
	pikapic_loadgfx PikaPicSleepingGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_17, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript12:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicDozingPic
	pikapic_loadgfx PikaPicDozingYawnGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_18, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry25
	pikapic_looptofinish

PikaPicAnimScript13:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicLookAwayPic
	pikapic_loadgfx PikaPicLookAwayGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_19, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript14:
	pikapic_setduration 40
	pikapic_loadgfx PikaPicAngrySparksPic
	pikapic_loadgfx PikaPicAngrySparksGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_20, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript15:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicWavePic
	pikapic_loadgfx PikaPicWaveGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_21, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript16:
	pikapic_setduration 32
	pikapic_loadgfx PikaPicSmallHeartPic
	pikapic_loadgfx PikaPicSmallHeartGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_22, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript17:
	pikapic_setduration 100
	pikapic_loadgfx PikaPicGrimacePic
	pikapic_loadgfx PikaPicGrimaceGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_23, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript18:
	pikapic_setduration 32
	pikapic_loadgfx PikaPicWinkGFX1
	pikapic_loadgfx PikaPicWinkGFX2
	pikapic_animation PikaPicAnimBGFrames_5, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_24, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry18
	pikapic_looptofinish

PikaPicAnimScript19:
	pikapic_setduration 44
	pikapic_loadgfx PikaPicHeartsPic
	pikapic_loadgfx PikaPicHeartsGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_25, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript20:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicManyHeartsPic
	pikapic_loadgfx PikaPicManyHeartsGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_26, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript21:
	pikapic_setduration 40
	pikapic_loadgfx PikaPicBucketPic
	pikapic_loadgfx PikaPicBucketGFX1
	pikapic_loadgfx PikaPicBucketGFX2
	pikapic_loadgfx PikaPicBucketGFX3
	pikapic_loadgfx PikaPicBucketGFX4
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_27, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry PikachuCry20
	pikapic_looptofinish

PikaPicAnimScript22:
	pikapic_setduration 40
	pikapic_loadgfx PikaPicScaredGFX1
	pikapic_loadgfx PikaPicScaredGFX2
	pikapic_animation PikaPicAnimBGFrames_5, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_28, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript23:
	pikapic_setduration 70
	pikapic_loadgfx PikaPicConfusedGFX1
	pikapic_loadgfx PikaPicConfusedGFX2
	pikapic_animation PikaPicAnimBGFrames_5, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_29, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript24:
	pikapic_setduration 60
	pikapic_loadgfx PikaPicHuffyGFX1
	pikapic_loadgfx PikaPicHuffyGFX2
	pikapic_animation PikaPicAnimBGFrames_5, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_30, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript25:
	pikapic_setduration 50
	pikapic_loadgfx PikaPicThunderboltPic
	pikapic_loadgfx PikaPicThunderboltChargeGFX
	pikapic_loadgfx PikaPicThunderboltGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_31, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_writebyte 13
	pikapic_waitbgmap
	pikapic_thunderbolt
	pikapic_ret

; Unreferenced alt entry: waits for BG map, then falls through into PikaPicAnimScript26
PikaPicAnimScript26_WaitBGMap:
	pikapic_waitbgmap
PikaPicAnimScript26:
	pikapic_setduration 100
	pikapic_loadgfx PikaPicSleepingPic
	pikapic_loadgfx PikaPicSleepingGFX
	pikapic_loadgfx PikaPicWakeUpGFX1
	pikapic_loadgfx PikaPicWakeUpGFX2
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_32, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript27:
	pikapic_setduration 30
	pikapic_loadgfx PikaPicShockedPic
	pikapic_loadgfx PikaPicShockedGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_33, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

PikaPicAnimScript28:
	pikapic_setduration 64
	pikapic_loadgfx PikaPicSickPic
	pikapic_loadgfx PikaPicSickGFX
	pikapic_animation PikaPicAnimBGFrames_4, $80, $0, $0
	pikapic_animation PikaPicAnimBGFrames_34, $99, $0, $0
	pikapic_waitbgmap
	pikapic_cry
	pikapic_looptofinish

MACRO pikapicanimgfx
	IF _NARG == 2
	\2_id::
		db \1  ; size (-1 if compressed)
		dba \2 ; pointer
	ELSE
		db \1 ; size
		dbw \2, \3 ; bank, address
	ENDC
ENDM

PikaPicAnimGFXHeaders:
	pikapicanimgfx  1, $39, NULL     ; 00
	pikapicanimgfx -1, PikaPicNeutralPic     ; 01
	pikapicanimgfx  5, PikaPicNeutralBlinkGFX     ; 02
	pikapicanimgfx -1, PikaPicCheeksHappyPic     ; 03
	pikapicanimgfx 10, PikaPicCheeksHappyGFX     ; 04
	pikapicanimgfx -1, PikaPicUnimpressedPic     ; 05
	pikapicanimgfx  6, PikaPicUnimpressedEarGFX     ; 06
	pikapicanimgfx -1, PikaPicContentPic     ; 07
	pikapicanimgfx 20, PikaPicContentEyesOpenGFX     ; 08
	pikapicanimgfx -1, PikaPicBlankStarePic     ; 09
	pikapicanimgfx  4, PikaPicBlankStareEarGFX     ; 0a
	pikapicanimgfx -1, PikaPicTurnedAwayPic     ; 0b
	pikapicanimgfx  4, PikaPicTurnedAwayGFX     ; 0c
	pikapicanimgfx -1, PikaPicExcitedPic     ; 0d
	pikapicanimgfx 25, PikaPicExcitedGFX     ; 0e
	pikapicanimgfx -1, PikaPicSmilePic     ; 0f
	pikapicanimgfx 10, PikaPicSmileGrinGFX     ; 00
	pikapicanimgfx -1, PikaPicBackTurnedPic     ; 11
	pikapicanimgfx  6, PikaPicBackTurnedEarGFX     ; 12
	pikapicanimgfx -1, PikaPicHeartPic     ; 13
	pikapicanimgfx 25, PikaPicHeartGFX1     ; 14
	pikapicanimgfx 25, PikaPicHeartGFX2     ; 15
	pikapicanimgfx -1, PikaPicSleepingPic     ; 16
	pikapicanimgfx 25, PikaPicSleepingGFX     ; 17
	pikapicanimgfx -1, PikaPicDozingPic     ; 18
	pikapicanimgfx 25, PikaPicDozingYawnGFX     ; 19
	pikapicanimgfx -1, PikaPicLookAwayPic     ; 1a
	pikapicanimgfx 25, PikaPicLookAwayGFX     ; 1b
	pikapicanimgfx -1, PikaPicAngrySparksPic     ; 1c
	pikapicanimgfx 25, PikaPicAngrySparksGFX     ; 1d
	pikapicanimgfx -1, PikaPicWavePic     ; 1e
	pikapicanimgfx 25, PikaPicWaveGFX     ; 1f
	pikapicanimgfx -1, PikaPicSmallHeartPic     ; 20
	pikapicanimgfx 25, PikaPicSmallHeartGFX     ; 21
	pikapicanimgfx -1, PikaPicGrimacePic     ; 22
	pikapicanimgfx 25, PikaPicGrimaceGFX     ; 23
	pikapicanimgfx 25, PikaPicWinkGFX1     ; 24
	pikapicanimgfx 25, PikaPicWinkGFX2     ; 25
	pikapicanimgfx -1, PikaPicHeartsPic     ; 26
	pikapicanimgfx 25, PikaPicHeartsGFX     ; 27
	pikapicanimgfx -1, PikaPicManyHeartsPic     ; 28
	pikapicanimgfx 25, PikaPicManyHeartsGFX     ; 29
	pikapicanimgfx -1, PikaPicBucketPic     ; 2a
	pikapicanimgfx 25, PikaPicBucketGFX1     ; 2b
	pikapicanimgfx 25, PikaPicBucketGFX2     ; 2c
	pikapicanimgfx 25, PikaPicBucketGFX3     ; 2d
	pikapicanimgfx 25, PikaPicBucketGFX4     ; 2e
	pikapicanimgfx 25, PikaPicScaredGFX1     ; 2f
	pikapicanimgfx 25, PikaPicScaredGFX2     ; 30
	pikapicanimgfx 25, PikaPicConfusedGFX1     ; 31
	pikapicanimgfx 25, PikaPicConfusedGFX2     ; 32
	pikapicanimgfx 25, PikaPicHuffyGFX1     ; 33
	pikapicanimgfx 25, PikaPicHuffyGFX2     ; 34
	pikapicanimgfx -1, PikaPicThunderboltPic     ; 35
	pikapicanimgfx 25, PikaPicThunderboltChargeGFX     ; 36
	pikapicanimgfx 25, PikaPicThunderboltGFX     ; 37
	pikapicanimgfx 25, PikaPicWakeUpGFX1     ; 38
	pikapicanimgfx 25, PikaPicWakeUpGFX2     ; 39
	pikapicanimgfx -1, PikaPicShockedPic     ; 3a
	pikapicanimgfx 25, PikaPicShockedGFX     ; 3b
	pikapicanimgfx -1, PikaPicSickPic     ; 3c
	pikapicanimgfx 25, PikaPicSickGFX     ; 3d
	pikapicanimgfx 24, PikachuSprite ; 3e
