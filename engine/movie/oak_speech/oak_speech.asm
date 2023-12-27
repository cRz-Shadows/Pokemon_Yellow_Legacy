PrepareOakSpeech:
	ld a, [wLetterPrintingDelayFlags]
	push af
	ld a, [wOptions]
	push af
	; Retrieve BIT_DEBUG_MODE set in DebugMenu for StartNewGameDebug.
	; BUG: StartNewGame carries over bit 5 from previous save files,
	; which causes CheckForceBikeOrSurf to not return.
	; To fix this in debug builds, reset bit 5 here or in StartNewGame.
	; In non-debug builds, the instructions can be removed.
	ld a, [wd732]
	push af
	ld a, [wPrinterSettings]
	push af
	ld hl, wPlayerName
	ld bc, wBoxDataEnd - wPlayerName
	xor a
	call FillMemory
	ld hl, wSpriteDataStart
	ld bc, wSpriteDataEnd - wSpriteDataStart
	xor a
	call FillMemory
	xor a
	ld [wSurfingMinigameHiScore], a
	ld [wSurfingMinigameHiScore + 1], a
	ld [wSurfingMinigameHiScore + 2], a
	pop af
	ld [wPrinterSettings], a
	pop af
	ld [wd732], a
	pop af
	ld [wOptions], a
	pop af
	ld [wLetterPrintingDelayFlags], a
	ld a, [wOptionsInitialized]
	and a
	call z, InitOptions
	; These debug names are used for StartNewGameDebug.
	; TestBattle uses the debug names from DebugMenu.
	; A variant of this process is performed in PrepareTitleScreen.
	ld hl, DebugNewGamePlayerName
	ld de, wPlayerName
	ld bc, NAME_LENGTH
	call CopyData
	ld hl, DebugNewGameRivalName
	ld de, wRivalName
	ld bc, NAME_LENGTH
	call CopyData ; rip optimizations
	ret

OakSpeech:
	call StopAllMusic ; stop music
	ld a, BANK(Music_Routes2)
	ld c, a
	ld a, MUSIC_ROUTES2
	call PlayMusic
	call ClearScreen
	call LoadTextBoxTilePatterns
	call PrepareOakSpeech
	predef InitPlayerData2
	ld hl, wNumBoxItems
	ld a, POTION
	ld [wcf91], a
	ld a, 1
	ld [wItemQuantity], a
	call AddItemToInventory
	ld a, [wDefaultMap]
	ld [wDestinationMap], a
	call PrepareForSpecialWarp
	xor a
	ldh [hTileAnimations], a
	ld a, [wd732]
	bit BIT_DEBUG_MODE, a
	jp nz, .skipSpeech
.MenuCursorLoop ; difficulty menu
	ld hl, DifficultyText
  	call PrintText
  	call DifficultyChoice
	ld a, [wCurrentMenuItem]
	ld [wDifficulty], a
	cp 0 ; normal
	jr z, .SelectedNormalMode
	cp 1 ; hard
	jr z, .SelectedHardMode
	; space for more game modes down the line
.SelectedNormalMode
	ld hl, NormalModeText
	call PrintText
	jp .YesNoNormalHard
.SelectedHardMode
	ld hl, HardModeText
	call PrintText
.YesNoNormalHard ; Give the player a brief description of each game mode and make sure that's what they want
  	call YesNoNormalHardChoice
	ld a, [wCurrentMenuItem]
	cp 0
	jr z, .doneLoop
	jp .MenuCursorLoop ; If player says no, back to difficulty selection
.doneLoop
   	call ClearScreen ; clear the screen before resuming normal intro

	; Gender Menu
	ld hl, BoyGirlText  ; added to the same file as the other oak text
	call PrintText     ; show this text
	call BoyGirlChoice ; added routine at the end of this file
	ld a, [wCurrentMenuItem]
	ld [wPlayerGender], a ; store player's gender. 00 for boy, 01 for girl
	call ClearScreen ; clear the screen before resuming normal intro

	ld de, ProfOakPic
	lb bc, BANK(ProfOakPic), $00
	call IntroDisplayPicCenteredOrUpperRight
	call FadeInIntroPic
	ld hl, OakSpeechText1
	call PrintText
	call GBFadeOutToWhite
	call ClearScreen
	ld a, STARTER_PIKACHU
	ld [wd0b5], a
	ld [wcf91], a
	call GetMonHeader
	hlcoord 6, 4
	call LoadFlippedFrontSpriteByMonIndex
	call MovePicLeft
	ld hl, OakSpeechText2
	call PrintText
	call GBFadeOutToWhite
	call ClearScreen
	ld de, RedPicFront
	lb bc, BANK(RedPicFront), $00
	ld a, [wPlayerGender] 	; check gender
	and a      				; check gender
	jr z, .NotGreen1
	ld de, GreenPicFront
	lb bc, BANK(GreenPicFront), $00
.NotGreen1:
	call IntroDisplayPicCenteredOrUpperRight
	call MovePicLeft
	ld hl, IntroducePlayerText
	call PrintText
	call ChoosePlayerName
	call GBFadeOutToWhite
	call ClearScreen
	ld de, Rival1Pic
	lb bc, BANK(Rival1Pic), $00
	call IntroDisplayPicCenteredOrUpperRight
	call FadeInIntroPic
	ld hl, IntroduceRivalText
	call PrintText
	call ChooseRivalName
.skipSpeech
	call GBFadeOutToWhite
	call ClearScreen
	ld de, RedPicFront
	lb bc, BANK(RedPicFront), $00
	ld a, [wPlayerGender] ; check gender
	and a      ; check gender
	jr z, .NotGreen2
	ld de, GreenPicFront
	lb bc, Bank(GreenPicFront), $00
.NotGreen2:
	call IntroDisplayPicCenteredOrUpperRight
	call GBFadeInFromWhite
	ld a, [wd72d]
	and a
	jr nz, .next
	ld hl, OakSpeechText3
	call PrintText
.next
	ldh a, [hLoadedROMBank]
	push af
	ld a, SFX_SHRINK
	call PlaySound
	pop af
	call BankswitchCommon
	ld c, 4
	call DelayFrames
	ld hl, vSprites
	ld de, RedSprite
	ld b, BANK(RedSprite)
	ld c, $0C
	; call CopyVideoData
	; ld de, ShrinkPic1
	; lb bc, BANK(ShrinkPic1), $00
	; call IntroDisplayPicCenteredOrUpperRight
	ld a, [wPlayerGender] ; check gender
	and a      ; check gender
	jr z, .NotGreen3
	ld de,GreenSprite
	lb bc, BANK(GreenSprite), $0C
.NotGreen3:
	ld hl, vSprites
	call CopyVideoData
	ld de, ShrinkPic1
	lb bc, BANK(ShrinkPic1), $00
	call IntroDisplayPicCenteredOrUpperRight
	ld c, 4
	call DelayFrames
	ld de, ShrinkPic2
	lb bc, BANK(ShrinkPic2), $00
	call IntroDisplayPicCenteredOrUpperRight
	call ResetPlayerSpriteData
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(Music_PalletTown)
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	ld a, 10
	ld [wAudioFadeOutControl], a
	call StopAllMusic
	pop af
	call BankswitchCommon
	ld c, 20
	call DelayFrames
	hlcoord 6, 5
	lb bc, 7, 7
	call ClearScreenArea
	call LoadTextBoxTilePatterns
	ld a, 1
	ld [wUpdateSpritesEnabled], a
	ld c, 50
	call DelayFrames
	call GBFadeOutToWhite
	call ClearScreen ; rip more tail-end optimizations
	ret

OakSpeechText1:
	text_far _OakSpeechText1
	text_end
OakSpeechText2:
	text_far _OakSpeechText2A
	sound_cry_pikachu
	text_far _OakSpeechText2B
	text_end
IntroducePlayerText:
	text_far _IntroducePlayerText
	text_end
IntroduceRivalText:
	text_far _IntroduceRivalText
	text_end
OakSpeechText3:
	text_far _OakSpeechText3
	text_end
NormalModeText:
	text_far _NormalModeText
	text_end
HardModeText:
	text_far _HardModeText
	text_end
DifficultyText:
	text_far _DifficultyText
	text_end
YesNoNormalHardText:
	text_far _AreYouSureText
	text_end
BoyGirlText:
    text_far _BoyGirlText
    text_end

FadeInIntroPic:
	ld hl, IntroFadePalettes
	ld b, 6
.next
	ld a, [hli]
	ldh [rBGP], a
	call UpdateGBCPal_BGP
	ld c, 10
	call DelayFrames
	dec b
	jr nz, .next
	ret

IntroFadePalettes:
	dc 1, 1, 1, 0
	dc 2, 2, 2, 0
	dc 3, 3, 3, 0
	dc 3, 3, 2, 0
	dc 3, 3, 1, 0
	dc 3, 2, 1, 0

MovePicLeft:
	ld a, 119
	ldh [rWX], a
	call DelayFrame

	ld a, %11100100
	ldh [rBGP], a
	call UpdateGBCPal_BGP
.next
	call DelayFrame
	ldh a, [rWX]
	sub 8
	cp $FF
	ret z
	ldh [rWX], a
	jr .next

DisplayPicCenteredOrUpperRight:
	call GetPredefRegisters
IntroDisplayPicCenteredOrUpperRight:
; b = bank
; de = address of compressed pic
; c: 0 = centred, non-zero = upper-right
	push bc
	ld a, b
	call UncompressSpriteFromDE
	ld a, $0
	call SwitchSRAMBankAndLatchClockData
	ld hl, sSpriteBuffer1
	ld de, sSpriteBuffer0
	ld bc, $310
	call CopyData
	call PrepareRTCDataAndDisableSRAM
	ld de, vFrontPic
	call InterlaceMergeSpriteBuffers
	pop bc
	ld a, c
	and a
	hlcoord 15, 1
	jr nz, .next
	hlcoord 6, 4
.next
	xor a
	ldh [hStartTileID], a
	predef_jump CopyUncompressedPicToTilemap

; displays difficulty choice
DifficultyChoice::
	call SaveScreenTilesToBuffer1
	call InitDifficultyTextBoxParameters
	jr DisplayDifficultyChoice

InitDifficultyTextBoxParameters::
  	ld a, $8 ; loads the value for the difficulty menu
	ld [wTwoOptionMenuID], a
	coord hl, 5, 5
	ld bc, $606 ; Cursor Pos
	ret
	
DisplayDifficultyChoice::
	ld a, $14
	ld [wTextBoxID], a
	call DisplayTextBoxID
	jp LoadScreenTilesFromBuffer1

; display yes/no choice
YesNoNormalHardChoice::
	call SaveScreenTilesToBuffer1
	call InitYesNoNormalHardTextBoxParameters
	jr DisplayYesNoNormalHardChoice

InitYesNoNormalHardTextBoxParameters::
  	ld a, $0 ; loads the value for the difficulty menu
	ld [wTwoOptionMenuID], a
	coord hl, 7, 5
	ld bc, $608 ; Cursor Pos
	ret
	
DisplayYesNoNormalHardChoice::
	ld a, $14
	ld [wTextBoxID], a
	call DisplayTextBoxID
	jp LoadScreenTilesFromBuffer1

; displays boy/girl choice
BoyGirlChoice::
	call SaveScreenTilesToBuffer1
	call InitBoyGirlTextBoxParameters
	jr DisplayBoyGirlChoice

InitBoyGirlTextBoxParameters::
   ld a, $1 ; loads the value for the unused North/West choice, that was changed to say Boy/Girl
	ld [wTwoOptionMenuID], a
	coord hl, 6, 5 
	ld bc, $607
	ret
	
DisplayBoyGirlChoice::
	  ld a, $14
	  ld [wTextBoxID], a
	  call DisplayTextBoxID
	  jp LoadScreenTilesFromBuffer1