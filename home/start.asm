_Start::
	cp GBC
	jr z, .cgb
	xor a
	jr .ok
.cgb
	ld a, TRUE
.ok
	ldh [hOnCGB], a
	jp Init
