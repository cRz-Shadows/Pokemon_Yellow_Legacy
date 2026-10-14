CinnabarGymPrintGymGuideText::
	CheckEvent EVENT_BEAT_BLAINE
	jr nz, .afterBeat
	ld hl, .ChampInMakingText
	jr .done
.afterBeat
	ld hl, .BeatBlaineText
.done
	call PrintText
	ret

.ChampInMakingText:
	text_far _CinnabarGymGymGuideChampInMakingText
	text_end

.BeatBlaineText:
	text_far _CinnabarGymGymGuideBeatBlaineText
	text_end

; Prints quiz remark e from CinnabarGymTrainerQuizRemarkTexts
PrintCinnabarGymTrainerQuizRemark::
	ld hl, CinnabarGymTrainerQuizRemarkTexts
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp PrintText

; Remarks Super Nerds 2-7 make when talked to before their quiz gate is solved
CinnabarGymTrainerQuizRemarkTexts:
	dw CinnabarGymSuperNerd2QuizRemarkText
	dw CinnabarGymSuperNerd3QuizRemarkText
	dw CinnabarGymSuperNerd4QuizRemarkText
	dw CinnabarGymSuperNerd5QuizRemarkText
	dw CinnabarGymSuperNerd6QuizRemarkText
	dw CinnabarGymSuperNerd7QuizRemarkText

; Super Nerd 2: "This GYM is also known as the QUIZ GYM..."
CinnabarGymSuperNerd2QuizRemarkText:
	text_far _CinnabarGymText_1
	text_end

; Super Nerd 3: "Think you can do it?"
CinnabarGymSuperNerd3QuizRemarkText:
	text_far _CinnabarGymText_2
	text_end

; Super Nerd 4: "This one's tricky!"
CinnabarGymSuperNerd4QuizRemarkText:
	text_far _CinnabarGymText_3
	text_end

; Super Nerd 5: "#MON enjoy quizzes too!"
CinnabarGymSuperNerd5QuizRemarkText:
	text_far _CinnabarGymText_4
	text_end

; Super Nerd 6: "I like it here at QUIZ GYM."
CinnabarGymSuperNerd6QuizRemarkText:
	text_far _CinnabarGymText_5
	text_end

; Super Nerd 7: "This is the last question."
CinnabarGymSuperNerd7QuizRemarkText:
	text_far _CinnabarGymText_6
	text_end
