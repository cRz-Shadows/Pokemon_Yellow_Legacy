; SUGGESTED NAME: CinnabarGymPrintTrainerQuizRemark
; Prints a Super Nerd's quiz remark (index e) and ends the text script (confidence: high)
CinnabarGymScript_753de:
	callfar Func_f2150
	jp TextScriptEnd

; SUGGESTED NAME: CinnabarGymCheckAndResetQuizBattleFlag
; Tests and clears wd474 bit 7 (battle started by a wrong quiz answer) (confidence: high)
CinnabarGymScript_753e9:
	push hl
	ld hl, wd474
	bit 7, [hl]
	res 7, [hl]
	pop hl
	ret

; SUGGESTED NAME: CinnabarGymCheckQuizBattleFlag
; Tests wd474 bit 7 (battle started by a wrong quiz answer) (confidence: high)
CinnabarGymScript_753f3:
	push hl
	ld hl, wd474
	bit 7, [hl]
	pop hl
	ret
