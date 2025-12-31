; tests if mon [wCurPartySpecies] can learn move [wMoveNum]
CanLearnTM:
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	call GetMonHeader
	ld hl, wMonHLearnset
	push hl
	ld a, [wMoveNum]
	ld b, a
	ld c, $0
	ld hl, TechnicalMachines
.findTMloop
	ld a, [hli]
	cp -1 ; reached terminator?
	jr z, .done
	cp b
	jr z, .TMfoundLoop
	inc c
	jr .findTMloop
.TMfoundLoop
	pop hl
	ld b, FLAG_TEST
	predef_jump FlagActionPredef
.done
	pop hl
	ld c, 0
	ret

; converts TM/HM number in [wTempTMHM] into move number
; HMs start at 51
TMToMove:
	ld a, [wTempTMHM]
	dec a
	ld hl, TechnicalMachines
	ld b, $0
	ld c, a
	add hl, bc
	ld a, [hl]
	ld [wTempTMHM], a
	ret

GetTMMoves:
	ld de, wRelearnableMoves ; reusing from move relearner for tmhm move list
	ld a, 0
	ld b, a ; current move ID / counter
.findTMloop
	inc b
	ld a, b
	cp NUM_ATTACKS ; done if looked at all moves
	jr z, .done

	ld a, b
	ld [wMoveNum], a
	ld [wTempTMHM], a
	push de
	push bc
	predef CanLearnTM
	ld a, c
	and a ; can the pokemon learn the move?
	pop bc
	pop de
	jr z, .cantLearn
.canLearn
	ld a, b
	ld [de], a ; add move ID to list of learnable moves
	inc de
.cantLearn
	ld a, b
	jr .findTMloop
.done
	ld a, 0 ; terminator
	ld [de], a
	ret

INCLUDE "data/moves/tmhm_moves.asm"
