MACRO spinner
; \1: source
; \2: offset (BANK() chokes on literals)
; \3: dest
	dw \1 tile \2
	db 1
	db BANK(\1)
	dw vTileset tile \3
ENDM

FacilitySpinnerArrows:
	spinner SpinnerArrowAnimTiles, 0,   $20
	spinner SpinnerArrowAnimTiles, 1,   $21
	spinner SpinnerArrowAnimTiles, 2,   $30
	spinner SpinnerArrowAnimTiles, 3,   $31
	spinner SpinnerArrowAnimTiles, 4,   $20
	spinner SpinnerArrowAnimTiles, 5,   $21
	spinner SpinnerArrowAnimTiles, 6,   $30
	spinner SpinnerArrowAnimTiles, 7,   $31

GymSpinnerArrows:
	spinner SpinnerArrowAnimTiles, 1,   $3c
	spinner SpinnerArrowAnimTiles, 3,   $3d
	spinner SpinnerArrowAnimTiles, 0,   $4c
	spinner SpinnerArrowAnimTiles, 2,   $4d
	spinner SpinnerArrowAnimTiles, 5,   $3c
	spinner SpinnerArrowAnimTiles, 7,   $3d
	spinner SpinnerArrowAnimTiles, 4,   $4c
	spinner SpinnerArrowAnimTiles, 6,   $4d
