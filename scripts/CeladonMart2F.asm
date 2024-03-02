CeladonMart2F_Script:
	jp EnableAutoTextBoxDrawing

CeladonMart2F_TextPointers:
	def_text_pointers
	dw_const CeladonMart2FClerk1Text,           TEXT_CELADONMART2F_CLERK1
	dw_const CeladonMart2FClerk2Text,           TEXT_CELADONMART2F_CLERK2
	dw_const CeladonMart2FMiddleAgedManText,    TEXT_CELADONMART2F_MIDDLE_AGED_MAN
	dw_const CeladonMart2FGirlText,             TEXT_CELADONMART2F_GIRL
	dw_const CeladonMart2FCurrentFloorSignText, TEXT_CELADONMART2F_CURRENT_FLOOR_SIGN

CeladonMart2FMiddleAgedManText:
	text_far _CeladonMart2FMiddleAgedManText
	text_end

CeladonMart2FGirlText:
	text_far _CeladonMart2FGirlText
	text_end

CeladonMart2FCurrentFloorSignText:
	text_far _CeladonMart2FCurrentFloorSignText
	text_end

CeladonMart2FClerk1Text::
	script_mart POKE_BALL, GREAT_BALL, POTION, SUPER_POTION, REVIVE, SUPER_REPEL, FULL_HEAL, ANTIDOTE, PARLYZ_HEAL, AWAKENING, BURN_HEAL, ICE_HEAL

CeladonMart2FClerk2Text::
	script_mart TM_MEGA_PUNCH, TM_RAZOR_WIND, TM_MEGA_KICK, TM_TAKE_DOWN, TM_RAGE, TM_DOUBLE_TEAM, TM_REFLECT, TM_EGG_BOMB, TM_SKULL_BASH
