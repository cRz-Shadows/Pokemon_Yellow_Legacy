VermilionMart_Script:
	jp EnableAutoTextBoxDrawing

VermilionMart_TextPointers:
	def_text_pointers
	dw_const VermilionMartClerkText,        TEXT_VERMILIONMART_CLERK
	dw_const VermilionMartCooltrainerMText, TEXT_VERMILIONMART_COOLTRAINER_M
	dw_const VermilionMartCooltrainerFText, TEXT_VERMILIONMART_COOLTRAINER_F

VermilionMartCooltrainerMText:
	text_far _VermilionMartCooltrainerMText
	text_end

VermilionMartCooltrainerFText:
	text_far _VermilionMartCooltrainerFText
	text_end

VermilionMartClerkText::
	script_mart POKE_BALL, GREAT_BALL, POTION, SUPER_POTION, REVIVE, REPEL, ANTIDOTE, PARLYZ_HEAL, AWAKENING, BURN_HEAL  