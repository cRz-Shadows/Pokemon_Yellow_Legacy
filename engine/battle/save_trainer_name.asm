SaveTrainerName::
	ld hl, wTrainerName
	ld de, wNameBuffer
.CopyCharacter
	ld a, [hli]
	ld [de], a
	inc de
	cp '@'
	jr nz, .CopyCharacter
	ret
