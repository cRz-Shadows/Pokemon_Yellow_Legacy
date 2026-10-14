SurfingPikachuOAMData:
	dbw $00, .SingleTile
	dbw $00, .Frame1
	dbw $36, .Frame2
	dbw $03, .Frame3
	dbw $39, .Frame4
	dbw $06, .Frame5
	dbw $3c, .Frame6
	dbw $09, .Frame7
	dbw $60, .Frame8
	dbw $0c, .Frame9
	dbw $63, .Frame10
	dbw $30, .Frame11
	dbw $66, .Frame12
	dbw $33, .Frame13
	dbw $69, .Frame14
	dbw $6c, .Frame15
	dbw $9c, .Frame16
	dbw $a0, .Frame17
	dbw $a3, .Frame18
	dbw $a7, .SmallSplash
	dbw $a8, .LargeSplash
	dbw $98, .EmptySurfboard
	dbw $e0, .Frame22
	dbw $e6, .Frame23
	dbw $ca, .Frame24
	dbw $a7, .WaterSpray
	dbw $00, .Plus50Pts
	dbw $00, .Plus150Pts
	dbw $00, .Plus350Pts
	dbw $00, .Plus750Pts
	dbw $00, .Plus180Pts
	dbw $00, .Plus500Pts
	dbw $80, .Frame32
	dbw $84, .Frame33
	dbw $88, .Frame34
	dbw $8c, .Frame35

.SingleTile:
	db 1
	db $fc, $fc, $00, $00

.Frame1:
.Frame2:
.Frame3:
.Frame4:
.Frame5:
.Frame6:
.Frame7:
.Frame8:
.Frame9:
.Frame10:
.Frame11:
.Frame12:
.Frame13:
.Frame14:
.Frame15:
.Frame16:
.Frame17:
.Frame18:
	db 9
	db $f4, $f4, $00, $00
	db $f4, $fc, $01, $00
	db $f4, $04, $02, $00
	db $fc, $f4, $10, $00
	db $fc, $fc, $11, $00
	db $fc, $04, $12, $00
	db $04, $f4, $20, $00
	db $04, $fc, $21, $00
	db $04, $04, $22, $00

.Frame22:
.Frame23:
.Frame24:
	db 12
	db $f8, $e8, $00, $00
	db $f8, $f0, $01, $00
	db $f8, $f8, $02, $00
	db $f8, $00, $03, $00
	db $f8, $08, $04, $00
	db $f8, $10, $05, $00
	db $00, $e8, $10, $00
	db $00, $f0, $11, $00
	db $00, $f8, $12, $00
	db $00, $00, $13, $00
	db $00, $08, $14, $00
	db $00, $10, $15, $00

.WaterSpray:
	db 3
	db  -4,  11, $00, OAM_PAL1
	db   4,   3, $0f, OAM_PAL1
	db   4,  11, $10, OAM_PAL1

.SmallSplash:
	db 6
	db  -4, -16, $00, OAM_PAL1 | OAM_XFLIP
	db  -4,   8, $00, OAM_PAL1
	db   4, -16, $10, OAM_PAL1 | OAM_XFLIP
	db   4,  -8, $0f, OAM_PAL1 | OAM_XFLIP
	db   4,   0, $0f, OAM_PAL1
	db   4,   8, $10, OAM_PAL1

.LargeSplash:
	db 12
	db -12, -16, $00, OAM_PAL1
	db -12,  -8, $01, OAM_PAL1
	db -12,   0, $01, OAM_PAL1 | OAM_XFLIP
	db -12,   8, $00, OAM_PAL1 | OAM_XFLIP
	db  -4, -16, $10, OAM_PAL1
	db  -4,  -8, $11, OAM_PAL1
	db  -4,   0, $11, OAM_PAL1 | OAM_XFLIP
	db  -4,   8, $10, OAM_PAL1 | OAM_XFLIP
	db   4, -16, $20, OAM_PAL1
	db   4,  -8, $21, OAM_PAL1
	db   4,   0, $21, OAM_PAL1 | OAM_XFLIP
	db   4,   8, $20, OAM_PAL1 | OAM_XFLIP

.EmptySurfboard:
	db 3
	db $04, $f4, $00, $00
	db $04, $fc, $01, $00
	db $04, $04, $02, $00

.Plus50Pts:
	db 3
	db $fc, $f4, $bf, $00
	db $fc, $fc, $d5, $00
	db $fc, $04, $d0, $00

.Plus150Pts:
	db 4
	db $fc, $f0, $bf, $00
	db $fc, $f8, $d1, $00
	db $fc, $00, $d5, $00
	db $fc, $08, $d0, $00

.Plus350Pts:
	db 4
	db $fc, $f0, $bf, $00
	db $fc, $f8, $d3, $00
	db $fc, $00, $d5, $00
	db $fc, $08, $d0, $00

.Plus750Pts:
	db 4
	db $fc, $f0, $bf, $00
	db $fc, $f8, $d7, $00
	db $fc, $00, $d5, $00
	db $fc, $08, $d0, $00

.Plus180Pts:
	db 4
	db $fc, $f0, $bf, $00
	db $fc, $f8, $d1, $00
	db $fc, $00, $d8, $00
	db $fc, $08, $d0, $00

.Plus500Pts:
	db 4
	db $fc, $f0, $bf, $00
	db $fc, $f8, $d5, $00
	db $fc, $00, $d0, $00
	db $fc, $08, $d0, $00

.Frame32:
.Frame33:
.Frame34:
.Frame35:
	db 12
	db -12, -16, $03, OAM_XFLIP
	db -12,  -8, $02, OAM_XFLIP
	db -12,   0, $01, OAM_XFLIP
	db -12,   8, $00, OAM_XFLIP
	db  -4, -16, $13, OAM_XFLIP
	db  -4,  -8, $12, OAM_XFLIP
	db  -4,   0, $11, OAM_XFLIP
	db  -4,   8, $10, OAM_XFLIP
	db   4, -16, $23, OAM_XFLIP
	db   4,  -8, $22, OAM_XFLIP
	db   4,   0, $21, OAM_XFLIP
	db   4,   8, $20, OAM_XFLIP
