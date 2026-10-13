IsPlayerOnDungeonWarp::
	xor a
	ld [wWhichDungeonWarp], a
	ld a, [wStatusFlags3]
	bit 4, a
	ret nz
	call ArePlayerCoordsInArray
	ret nc
	ld a, [wCoordIndex]
	ld [wWhichDungeonWarp], a
	ld hl, wStatusFlags3
	set 4, [hl]
	ld hl, wStatusFlags6
	set 4, [hl]
	ret
