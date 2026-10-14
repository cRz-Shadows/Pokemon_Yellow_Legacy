; Prints a Super Nerd's quiz remark (index e) and ends the text script
CinnabarGymPrintTrainerQuizRemark:
	callfar PrintCinnabarGymTrainerQuizRemark
	jp TextScriptEnd

; Tests and clears wCinnabarGymQuizFlags bit 7 (battle started by a wrong quiz answer)
CinnabarGymCheckAndResetQuizBattleFlag:
	push hl
	ld hl, wCinnabarGymQuizFlags
	bit 7, [hl]
	res 7, [hl]
	pop hl
	ret

; Tests wCinnabarGymQuizFlags bit 7 (battle started by a wrong quiz answer)
CinnabarGymCheckQuizBattleFlag:
	push hl
	ld hl, wCinnabarGymQuizFlags
	bit 7, [hl]
	pop hl
	ret
