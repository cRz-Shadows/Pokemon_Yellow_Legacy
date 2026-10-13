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

; SUGGESTED NAME: PrintCinnabarGymTrainerQuizRemark
; Prints quiz remark e from CinnabarGymTrainerQuizRemarkTexts (confidence: high)
Func_f2150::
	ld hl, TextPointers_f215d
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp PrintText

; SUGGESTED NAME: CinnabarGymTrainerQuizRemarkTexts
; Remarks Super Nerds 2-7 make when talked to before their quiz gate is solved (confidence: high)
TextPointers_f215d:
	dw CinnabarGymText_f2169
	dw CinnabarGymText_f216e
	dw CinnabarGymText_f2173
	dw CinnabarGymText_f2178
	dw CinnabarGymText_f217d
	dw CinnabarGymText_f2182

; SUGGESTED NAME: CinnabarGymSuperNerd2QuizRemarkText
; Super Nerd 2: "This GYM is also known as the QUIZ GYM..." (confidence: high)
CinnabarGymText_f2169:
	text_far _CinnabarGymText_1
	text_end

; SUGGESTED NAME: CinnabarGymSuperNerd3QuizRemarkText
; Super Nerd 3: "Think you can do it?" (confidence: high)
CinnabarGymText_f216e:
	text_far _CinnabarGymText_2
	text_end

; SUGGESTED NAME: CinnabarGymSuperNerd4QuizRemarkText
; Super Nerd 4: "This one's tricky!" (confidence: high)
CinnabarGymText_f2173:
	text_far _CinnabarGymText_3
	text_end

; SUGGESTED NAME: CinnabarGymSuperNerd5QuizRemarkText
; Super Nerd 5: "#MON enjoy quizzes too!" (confidence: high)
CinnabarGymText_f2178:
	text_far _CinnabarGymText_4
	text_end

; SUGGESTED NAME: CinnabarGymSuperNerd6QuizRemarkText
; Super Nerd 6: "I like it here at QUIZ GYM." (confidence: high)
CinnabarGymText_f217d:
	text_far _CinnabarGymText_5
	text_end

; SUGGESTED NAME: CinnabarGymSuperNerd7QuizRemarkText
; Super Nerd 7: "This is the last question." (confidence: high)
CinnabarGymText_f2182:
	text_far _CinnabarGymText_6
	text_end

; SUGGESTED NAME: CinnabarGymUnusedAnswerQuestionText
; Unused quiz remark: "Come on, answer the question!" (confidence: high)
CinnabarGymText_f2187:
	text_far _CinnabarGymText_7 ; unused
	text_end
