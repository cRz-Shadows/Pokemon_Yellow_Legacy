LoadSpinnerArrowTiles::
	ld a, [wSpritePlayerStateData1ImageIndex]
	srl a
	srl a
	ld hl, SpinnerPlayerFacingDirections
	ld c, a
	ld b, $0
	add hl, bc
	ld a, [hl]
	ld [wSpritePlayerStateData1ImageIndex], a
	ld a, [wCurMapTileset]
	cp FACILITY
	ld hl, FacilitySpinnerArrows
	jr z, .gotSpinnerArrows
	ld hl, GymSpinnerArrows
.gotSpinnerArrows
	ld a, [wSimulatedJoypadStatesIndex]
	bit 0, a
	jr nz, .alternateGraphics
	ld de, 6 * 4
	add hl, de
.alternateGraphics
	ld a, $4
	ld bc, $0
.loop
	push af
	push hl
	push bc
	add hl, bc
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CopySpinnerTiles
	pop bc
	ld a, $6
	add c
	ld c, a
	pop hl
	pop af
	dec a
	jr nz, .loop
	call DelayFrame ;Delay a frame because CopySpinnerTiles does not do this 
	ret

CopySpinnerTiles:
	di	;prevent vblank functions from running
	;back up destination address
	ld b, h
	ld c, l
	;back up stack pointer
	ld hl, sp + 0
	ld a, h
	ld [hstemp], a
	ld a, l
	ld [hstemp + 1], a
	;set stack pointer to source address
	ld h, d
	ld l, e
	ld sp, hl
	;restore destination address
	ld h, b
	ld l, c
	;Stack Pointer = tile source address
	;HL = tile destination address
	ld c, 8
.loop
	pop de
.waitVRAM
	ldh a, [rSTAT]		;read from stat register to get the mode
	and %10				
	jr nz, .waitVRAM	
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	dec c
	jr nz, .loop
	;restore stack spointer
	ld a, [hstemp]
	ld h, a
	ld a, [hstemp + 1]
	ld l, a
	ld sp, hl
	ei	;re-enable vblank functions
	ret

INCLUDE "data/tilesets/spinner_tiles.asm"

SpinnerPlayerFacingDirections:
; This isn't the order of the facing directions.  Rather, it's a list of
; the facing directions that come next. For example, when the player is
; facing down (00), the next facing direction is left (08).
	db $08 ; down -> left
	db $0C ; up -> right
	db $04 ; left -> up
	db $00 ; right -> down

; these tiles are the animation for the tiles that push the player in dungeons like Rocket HQ
SpinnerArrowAnimTiles:
	INCBIN "gfx/overworld/spinners.2bpp"
