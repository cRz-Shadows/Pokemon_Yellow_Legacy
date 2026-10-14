Printer_GetMonStats:
	call GBPalWhiteOutWithDelay3
	call ClearScreen
	call LoadHpBarAndStatusTilePatterns
	ld de, PrinterHPLabelGFX
	ld hl, vChars2 + $710
	lb bc, BANK(PrinterHPLabelGFX), (GFX_ea563End - PrinterHPLabelGFX) / 8
	call CopyVideoDataDouble

	ld de, PrinterLevelLabelGFX
	ld hl, vChars2 + $6e0
	lb bc, BANK(PrinterLevelLabelGFX), (GFX_ea56bEnd - PrinterLevelLabelGFX) / 8
	call CopyVideoDataDouble

	xor a
	ldh [hAutoBGTransferEnabled], a
	xor a
	ld [wWhichTradeMonSelectionMenu], a
	call LoadMonData

	ld hl, wTileMap
	lb bc, 16, 18
	call TextBoxBorder

	hlcoord 0, 12
	lb bc, 4, 18
	call TextBoxBorder

	hlcoord 3, 10
	call PrintLevelFull

	hlcoord 2, 10
	ld a, $6e
	ld [hli], a
	ld [hl], ' '

	hlcoord 2, 11
	ld [hl], '’'

	hlcoord 4, 11
	ld de, wLoadedMonMaxHP
	lb bc, 2, 3
	call PrintNumber

	ld a, [wMonHeader]
	ld [wPokeBallAnimData], a
	ld [wCurSpecies], a
	ld hl, wPartyMonNicks
	call .GetNamePointer
	hlcoord 8, 2
	call PlaceString

	call GetMonName
	hlcoord 9, 3
	call PlaceString

	predef IndexToPokedex
	hlcoord 2, 8
	ld [hl], '№'
	inc hl
	ld [hl], $f2
	inc hl
	ld de, wPokeBallAnimData
	lb bc, $80 | 1, 3
	call PrintNumber

	hlcoord 8, 4
	ld de, .OT
	call PlaceString

	ld hl, wPartyMonOT
	call .GetNamePointer
	hlcoord 9, 5
	call PlaceString

	hlcoord 9, 6
	ld de, .IDNo
	call PlaceString

	hlcoord 13, 6
	ld de, wLoadedMonOTID
	lb bc, $80 | 2, 5
	call PrintNumber

	hlcoord 9, 8
	ld de, .Stats
	ldh a, [hUILayoutFlags]
	set 2, a
	ldh [hUILayoutFlags], a
	call PlaceString
	ldh a, [hUILayoutFlags]
	res 2, a
	ldh [hUILayoutFlags], a

	hlcoord 16, 8
	ld de, wLoadedMonAttack
	ld a, 4
.loop
	push af
	push de

	push hl
	lb bc, 2, 3
	call PrintNumber
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc

	pop de
	inc de
	inc de
	pop af
	dec a
	jr nz, .loop

	hlcoord 1, 13
	ld a, [wLoadedMonMoves]
	call .PlaceMoveName

	hlcoord 1, 14
	ld a, [wLoadedMonMoves + 1]
	call .PlaceMoveName

	hlcoord 1, 15
	ld a, [wLoadedMonMoves + 2]
	call .PlaceMoveName

	hlcoord 1, 16
	ld a, [wLoadedMonMoves + 3]
	call .PlaceMoveName

	ld b, SET_PAL_POKEDEX
	call RunPaletteCommand

	ld a, $1
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	call GBPalNormal
	hlcoord 1, 1
	call LoadFlippedFrontSpriteByMonIndex
	ret

.GetNamePointer:
	ld bc, NAME_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld e, l
	ld d, h
	ret

.PlaceMoveName:
	and a
	jr z, .no_move
	ld [wPokeBallAnimData], a
	call GetMoveName
	jr .place_string

.no_move
	ld de, .Blank
.place_string
	call PlaceString
	ret

.OT:
	db "OT/@"

.IDNo:
	db $73, "№/@"

.Stats:
	db   "ATTACK"
	next "DEFENSE"
	next "SPEED"
	next "SPECIAL@"

.Blank:
	db "--------------@"

; 1bpp "HP" label tiles used on the printed Pokémon stats page
PrinterHPLabelGFX:
INCBIN "gfx/printer/hp.1bpp"
GFX_ea563End:

; 1bpp "Lv" label tiles used on the printed Pokémon stats page
PrinterLevelLabelGFX:
INCBIN "gfx/printer/lv.1bpp"
GFX_ea56bEnd:

PrinterDebug_LoadGFX:
	ld hl, vChars1 + $7e0
	ld de, PrinterDebugBitDigitsGFX
	lb bc, BANK(PrinterDebugBitDigitsGFX), (GFX_ea597End - PrinterDebugBitDigitsGFX) / 16
	call CopyVideoData

	ld hl, wShadowOAMSprite32
	ld a, $8
	ld c, $8
.loop
	ld [hl], $10
	inc hl
	ld [hl], a
	inc hl
	ld [hl], $fe
	inc hl
	ld [hl], $0
	inc hl
	add $8
	dec c
	jr nz, .loop
	ret

; "0"/"1" tiles used to show printer status flag bits as sprites in printer debug
PrinterDebugBitDigitsGFX:
INCBIN "gfx/printer/01.2bpp"
GFX_ea597End:

PrinterDebug_ConvertStatusFlagsToTiles:
	ld hl, wShadowOAMSprite32TileID
	ld de, 4
	ld a, [wPrinterStatusFlags]
	ld c, 8
.loop
	sla a
	jr c, .place_1
	ld [hl], $fe
	jr .okay

.place_1
	ld [hl], $ff
.okay
	add hl, de
	dec c
	jr nz, .loop
	ret

PrinterDebug_DoFunction:
	ld a, [wPrinterSendState]
	ld e, a
	ld d, 0
	ld hl, .Jumptable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.Jumptable:
	dw PrinterDebug_InitSerial
	dw PrinterDebug_CheckConnectionStatus
	dw PrinterDebug_WaitSerial
	dw PrinterDebug_StartTransmittingTilemap
	dw PrinterDebug_TransmissionLoop
	dw PrinterDebug_WaitSerialAndLoopBack2
	dw PrinterDebug_EndTilemapTransmission
	dw PrinterDebug_TransmissionLoop
	dw PrinterDebug_WaitSerial
	dw PrinterDebug_SignalSendHeader
	dw PrinterDebug_TransmissionLoop
	dw PrinterDebug_WaitSerial
	dw PrinterDebug_WaitUntilFinished
	dw PrinterDebug_Quit
	dw PrinterDebug_Next_
	dw PrinterDebug_WaitSerial
	dw PrinterDebug_Restart
	dw PrinterDebug_WaitLoopBack
	dw PrinterDebug_WaitLoopBack_

; Debug copy of Printer_Next: advances wPrinterSendState
PrinterDebug_Next:
	ld hl, wPrinterSendState
	inc [hl]
	ret

; Debug copy of Printer_Back: steps wPrinterSendState back one
PrinterDebug_Back:
	ld hl, wPrinterSendState
	dec [hl]
	ret

; Debug copy of Printer_Quit: clears status flags and sets send-state done bit 7
PrinterDebug_Quit:
	xor a
	ld [wPrinterStatusFlags], a
	ld hl, wPrinterSendState
	set 7, [hl]
	ret

; Debug copy of Printer_Next_: wrapper that advances the send state
PrinterDebug_Next_:
	call PrinterDebug_Next
	ret

; Resets wPrinterSendState to 0 to retry from init (cf. Printer_LoopBack, which uses 1)
PrinterDebug_Restart:
	xor a
	ld [wPrinterSendState], a
	ret

; Debug copy of Printer_InitSerial: sends the init ($01) packet
PrinterDebug_InitSerial:
	call PrinterDebug_ResetData
	ld hl, PrinterDebugInitPacket
	call PrinterDebug_CopyDataHeader
	xor a
	ld [wPrinterDataSize], a
	ld [wPrinterDataSize + 1], a
	ld a, [wPrinterQueueLength]
	ld [wPrinterRowIndex], a
	call PrinterDebug_Next
	call PrinterDebug_PrepareToSend
	ld a, $1
	ld [wPrinterStatusIndicator], a
	ret

; Sends 2 tile rows (with sprites composited) as a data ($04) packet; ends when none left
PrinterDebug_StartTransmittingTilemap:
	call PrinterDebug_ResetData
	ld hl, wPrinterRowIndex
	ld a, [hl]
	and a
	jr z, PrinterDebug_EndTilemapTransmission
	ld hl, PrinterDebugDataPacket
	call PrinterDebug_CopyDataHeader
	call PrinterDebug_PrepOAMForPrinting
	ld a, $80
	ld [wPrinterDataSize], a
	ld a, $2
	ld [wPrinterDataSize + 1], a
	call PrinterDebug_ComputeChecksum
	call PrinterDebug_Next
	call PrinterDebug_PrepareToSend
	ld a, $2
	ld [wPrinterStatusIndicator], a
	ret

; Debug copy: sends the empty data ($04) packet that ends image transfer
PrinterDebug_EndTilemapTransmission:
	ld a, $6
	ld [wPrinterSendState], a
	ld hl, PrinterDebugEndDataPacket
	call PrinterDebug_CopyDataHeader
	xor a
	ld [wPrinterDataSize], a
	ld [wPrinterDataSize + 1], a
	call PrinterDebug_Next
	call PrinterDebug_PrepareToSend
	ret

; Debug copy: sends the print ($02) packet with its 4-byte parameters
PrinterDebug_SignalSendHeader:
	call PrinterDebug_ResetData
	ld hl, PrinterDebugPrintPacket
	call PrinterDebug_CopyDataHeader
	call PrinterDebug_StageHeaderForSend
	ld a, $4
	ld [wPrinterDataSize], a
	ld a, $0
	ld [wPrinterDataSize + 1], a
	call PrinterDebug_ComputeChecksum
	call PrinterDebug_Next
	call PrinterDebug_PrepareToSend
	ld a, $3
	ld [wPrinterStatusIndicator], a
	ret

; Debug copy of Printer_WaitSerial: waits 6 frames then advances the send state
PrinterDebug_WaitSerial:
	ld hl, wPrinterSerialFrameDelay
	inc [hl]
	ld a, [hl]
	cp $6
	ret c
	xor a
	ld [hl], a
	call PrinterDebug_Next
	ret

; Waits 6 frames, decrements rows left, and goes back two states to send next rows
PrinterDebug_WaitSerialAndLoopBack2:
	ld hl, wPrinterSerialFrameDelay
	inc [hl]
	ld a, [hl]
	cp 6
	ret c
	xor a
	ld [hl], a
	ld hl, wPrinterRowIndex
	dec [hl]
	call PrinterDebug_Back
	call PrinterDebug_Back
	ret

; Checks printer reply ($81 + no errors) after init; else jumps to the retry states
PrinterDebug_CheckConnectionStatus:
	call PrinterDebug_CheckSerialBusy
	ret c
	ld a, [wPrinterHandshake]
	cp $ff
	jr nz, .asm_ea6e4
	ld a, [wPrinterStatusFlags]
	cp $ff
	jr z, .asm_ea6fb
.asm_ea6e4
	ld a, [wPrinterHandshake]
	cp $81
	jr nz, .asm_ea6fb
	ld a, [wPrinterStatusFlags]
	cp $0
	jr nz, .asm_ea6fb
	ld hl, wPrinterConnectionOpen
	set 1, [hl]
	call PrinterDebug_Next
	ret

.asm_ea6fb
	ld a, $e
	ld [wPrinterSendState], a
	ret

; Waits for packet reply; advances, re-sends if busy, or goes to error wait on error
PrinterDebug_TransmissionLoop:
	call PrinterDebug_CheckSerialBusy
	ret c
	ld a, [wPrinterStatusFlags]
	and $f0
	jr nz, .asm_ea71b
	ld a, [wPrinterStatusFlags]
	and $1
	jr nz, .asm_ea717
	call PrinterDebug_Next
	ret

.asm_ea717
	call PrinterDebug_Back
	ret

.asm_ea71b
	ld a, $11
	ld [wPrinterSendState], a
	ret

; Waits until the printer reports no errors and not printing, then advances
PrinterDebug_WaitUntilFinished:
	call PrinterDebug_CheckSerialBusy
	ret c
	ld a, [wPrinterStatusFlags]
	and $f3
	ret nz
	call PrinterDebug_Next
	ret

; Advances state, then falls into PrinterDebug_WaitLoopBack_
PrinterDebug_WaitLoopBack:
	call PrinterDebug_Next
; Waits until idle with no error bits, then resets send state to 0 to retry
PrinterDebug_WaitLoopBack_:
	ld a, [wPrinterOpcode]
	and a
	ret nz
	ld a, [wPrinterStatusFlags]
	and $f0
	ret nz
	xor a
	ld [wPrinterSendState], a
	ret

; Returns carry if a serial packet is still being sent (wPrinterOpcode nonzero)
PrinterDebug_CheckSerialBusy:
	ld a, [wPrinterOpcode]
	and a
	jr nz, .asm_ea74a
	and a
	ret

.asm_ea74a
	scf
	ret

; Debug copy of Printer_PrepareToSend: starts a packet by sending magic byte $88
PrinterDebug_PrepareToSend:
.asm_ea74c
	ld a, [wPrinterOpcode]
	and a
	jr nz, .asm_ea74c
	ld a, $1
	ld [wPrinterOpcode], a
	xor a
	ld [wPrinterSendByteOffset], a
	ld [wPrinterSendByteOffset + 1], a
	ld a, $88
	ldh [rSB], a
	ld a, $1
	ldh [rSC], a
	ld a, $81
	ldh [rSC], a
	ret

; Debug copy of CopyPrinterDataHeader: copies a 6-byte packet header/checksum
PrinterDebug_CopyDataHeader:
	ld a, [hli]
	ld [wPrinterDataHeader], a
	ld a, [hli]
	ld [wPrinterDataHeader + 1], a
	ld a, [hli]
	ld [wPrinterDataHeader + 2], a
	ld a, [hli]
	ld [wPrinterDataHeader + 3], a
	ld a, [hli]
	ld [wPrinterDataHeader + 4], a
	ld a, [hl]
	ld [wPrinterDataHeader + 5], a
	ret

; Debug copy of ResetPrinterData: clears header, checksum, size, and send buffer
PrinterDebug_ResetData:
	xor a
	ld hl, wPrinterDataHeader
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld hl, wPrinterDataHeader + 4
	ld [hli], a
	ld [hl], a
	xor a
	ld [wPrinterDataSize], a
	ld [wPrinterDataSize + 1], a
	ld hl, wPrinterSendDataSource1
	ld bc, $280
	call FillMemory
	ret

; Debug copy of ComputePrinterChecksum: sums header and data into the checksum
PrinterDebug_ComputeChecksum:
	ld hl, $0
	ld bc, $4
	ld de, wPrinterDataHeader
	call PrinterDebug_AddToChecksum
	ld a, [wPrinterDataSize]
	ld c, a
	ld a, [wPrinterDataSize + 1]
	ld b, a
	ld de, wPrinterSendDataSource1
	call PrinterDebug_AddToChecksum
	ld a, l
	ld [wPrinterDataHeader + 4], a
	ld a, h
	ld [wPrinterDataHeader + 5], a
	ret

; Adds bc bytes at de into the 16-bit sum in hl
PrinterDebug_AddToChecksum:
.asm_ea7c5
	ld a, [de]
	inc de
	add l
	jr nc, .asm_ea7cb
	inc h
.asm_ea7cb
	ld l, a
	dec bc
	ld a, c
	or b
	jr nz, .asm_ea7c5
	ret

; Fills print packet params: 1 sheet, margins (wPrinterMargins), palette $e4, exposure setting
PrinterDebug_StageHeaderForSend:
	ld a, $1
	ld [wPrinterSendDataSource1], a
	ld a, [wPrinterMargins]
	ld [wPrinterStatusReceived], a
	ld a, $e4
	ld [wPrinterPrintCmdPalette], a
	ld a, [wPrinterSettingsTempCopy]
	ld [wPrinterPrintCmdExposure], a
	ret

PrinterDebug_PrepOAMForPrinting:
	ld a, [wPrinterRowIndex]
	ld b, a
	ld a, [wPrinterQueueLength]
	sub b
	ld hl, wPrinterTileBuffer
	ld de, $28
.get_start_addr
	and a
	jr z, .start_working
	add hl, de
	dec a
	jr .get_start_addr

.start_working
	ld e, l
	ld d, h
	ld hl, wPrinterSendDataSource1
	ld c, $28
.prep_loop
	ld a, [de]
	inc de
	push bc
	push de
	push hl
	swap a
	ld d, a
	and $f0
	ld e, a
	ld a, d
	and $f
	ld d, a
	and $8
	ld a, d
	jr nz, .vtiles1
	or $90
	jr .got_vram_address

.vtiles1
	or $80
.got_vram_address
	ld d, a
	lb bc, BANK(PrinterDebug_PrepOAMForPrinting), $1
	call CopyVideoData
	pop hl
	ld de, $10
	add hl, de
	pop de
	pop bc
	dec c
	jr nz, .prep_loop
	call .UnnecessaryCall
	ret

.UnnecessaryCall:
	ld hl, wPrinterOAMTileBuffer
	ld bc, $20
	xor a
	call FillMemory
	ld hl, wShadowOAM
	ld c, $28
.master_loop
	push bc
	push hl
	call .AreWePrintingThisSegment
	jr nc, .skip_segment
	call .GetVRAMAddress
	call .GetOAMFlags
	call .ApplyObjectPalettes
	call .PlaceObject
.skip_segment
	pop hl
	inc hl
	inc hl
	inc hl
	inc hl
	pop bc
	dec c
	jr nz, .master_loop
	ret

.AreWePrintingThisSegment:
	ld a, [wPrinterRowIndex]
	ld b, a
	ld a, [wPrinterQueueLength]
	sub b
	ld c, a
	ld b, $10
.add_n_times
	ld a, c
	and a
	jr z, .check
	ld a, b
	add $10
	ld b, a
	dec c
	jr .add_n_times

.check
	ld a, b
	ld e, a
	add $10
	ld d, a
	ld a, [hl]
	cp e
	jr c, .not_printing
	cp d
	jr nc, .not_printing
	scf
	ret

.not_printing
	and a
	ret

.GetVRAMAddress:
	push hl
	inc hl
	inc hl
	ld a, [hl]
	swap a
	ld d, a
	and $f0
	ld e, a
	ld a, d
	and $f
	or $80
	ld d, a
	ld hl, wPrinterOAMTileBuffer
	lb bc, BANK(.GetVRAMAddress), $1
	call CopyVideoData
	pop hl
	ret

.GetOAMFlags:
	push hl
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	call .DoBitOperation
	pop hl
	ret

.DoBitOperation:
	and $60
	swap a
	ld e, a
	ld d, 0
	ld hl, .Jumptable
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.Jumptable:
	dw .nop
	dw .xflip
	dw .yflip
	dw .both

.nop:
	ret

.xflip:
	call .XFlip
	ret

.yflip:
	call .YFlip
	ret

.both:
	call .XFlip
	call .YFlip
	ret

.XFlip:
	ld hl, wPrinterOAMTileBuffer
	ld c, 16
.byte_loop
	ld d, [hl]
	ld a, 0
	ld b, 8
.bit_loop
	sla d
	rr a
	dec b
	jr nz, .bit_loop
	ld [hli], a
	dec c
	jr nz, .byte_loop
	ret

.YFlip:
	ld hl, wPrinterOAMTileBuffer
	ld de, wPrinterOAMTileBufferLastRow
	ld c, $4
.swap_loop
	ld b, [hl]
	ld a, [de]
	ld [hli], a
	ld a, b
	ld [de], a
	inc de
	ld b, [hl]
	ld a, [de]
	ld [hli], a
	ld a, b
	ld [de], a
	dec de
	dec de
	dec de
	dec c
	jr nz, .swap_loop
	ret

.ApplyObjectPalettes:
	push hl
	ld hl, wPrinterOAMTileBuffer
	ld de, wPrinterOAMTileRemapBuffer
	ld a, 8
.loop1
	push af
	ld bc, $0
	ld a, 8
.loop2
	push af
	xor a
	rlc [hl]
	rl a
	inc hl
	rlc [hl]
	rl a
	dec hl
	push hl
	push de
	call .ExpandPalettesToBC
	pop de
	pop hl
	pop af
	dec a
	jr nz, .loop2
	inc hl
	inc hl
	ld a, b
	ld [de], a
	inc de
	ld a, c
	ld [de], a
	inc de
	pop af
	dec a
	jr nz, .loop1
	pop hl
	ret

.ExpandPalettesToBC:
	call .GetPaletteFunction
	call .ApplyPaletteFunction
	ret

.GetPaletteFunction:
	ld e, a
	ld d, 0
	ld hl, .PalJumptable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.PalJumptable:
	dw .Pal0
	dw .Pal1
	dw .Pal2
	dw .Pal3

.Pal0:
	ldh a, [rOBP0]
	and $3
	ret

.Pal2:
	ldh a, [rOBP0]
	and $c
	srl a
	srl a
	ret

.Pal1:
	ldh a, [rOBP0]
	and $30
	swap a
	ret

.Pal3:
	ldh a, [rOBP0]
	and $c0
	rlca
	rlca
	ret

.ApplyPaletteFunction:
	ld e, a
	ld d, 0
	ld hl, .PalFunJumptable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.PalFunJumptable:
	dw .zero_zero
	dw .xflip_zero
	dw .zero_xflip
	dw .xflip_xflip

.zero_zero:
	sla b
	sla c
	ret

.xflip_zero:
	scf
	rl b
	sla c
	ret

.zero_xflip:
	sla b
	scf
	rl c
	ret

.xflip_xflip:
	scf
	rl b
	scf
	rl c
	ret

.PlaceObject:
	push hl
	ld a, [hli]
	ld c, [hl]
	and $8
	jr nz, .use_source_2
	ld hl, wPrinterSendDataSource1
	jr .got_data_source

.use_source_2
	ld hl, wPrinterSendDataSource2
.got_data_source
	ld b, $0
	ld a, c
	and %11111000
	sub $8
	ld c, a
	sla c
	rl b
	add hl, bc
	ld e, l
	ld d, h
	ld hl, wPrinterOAMTileRemapBuffer
	ld c, $8
.coord_copy_loop
	call .GetBitMask
	ld a, [de]
	and b
	or [hl]
	ld [de], a
	inc hl
	inc de
	ld a, [de]
	and b
	or [hl]
	ld [de], a
	inc hl
	inc de
	dec c
	jr nz, .coord_copy_loop
	pop hl
	ret

.GetBitMask:
	push hl
	push de
	ld de, -$10
	add hl, de
	ld a, [hli]
	or [hl]
	xor $ff
	ld b, a
	pop de
	pop hl
	ret

; Debug copy of PrinterDataPacket1: init ($01) packet header and checksum
PrinterDebugInitPacket:
	db  1, 0, $00, 0
	dw 1
; Debug copy of PrinterDataPacket2: print ($02) packet header, 4 data bytes
PrinterDebugPrintPacket:
	db  2, 0, $04, 0
	dw 0
; Debug copy of PrinterDataPacket3: data ($04) packet header, $280 data bytes
PrinterDebugDataPacket:
	db  4, 0, $80, 2
	dw 0
; Debug copy of PrinterDataPacket4: empty data ($04) packet that ends the image
PrinterDebugEndDataPacket:
	db  4, 0, $00, 0
	dw 4
; Unused break ($08) packet header and checksum
PrinterDebugBreakPacket:
	db  8, 0, $00, 0
	dw 8
; Unused status ($0F) packet header and checksum
PrinterDebugStatusPacket:
	db 15, 0, $00, 0
	dw 15
