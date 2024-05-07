CeladonMart5F_Script:
	call EnableAutoTextBoxDrawing
	ret

CeladonMart5F_TextPointers:
	def_text_pointers
	dw_const CeladonMart5FGentlemanText,        TEXT_CELADONMART5F_GENTLEMAN
	dw_const CeladonMart5FSailorText,           TEXT_CELADONMART5F_SAILOR
	dw_const CeladonMart5FClerk1Text,           TEXT_CELADONMART5F_CLERK1
	dw_const CeladonMart5FClerk2Text,           TEXT_CELADONMART5F_CLERK2
	dw_const CeladonMart5FCurrentFloorSignText, TEXT_CELADONMART5F_CURRENT_FLOOR_SIGN

CeladonMart5FGentlemanText:
	text_far _CeladonMart5FGentlemanText
	text_end

CeladonMart5FSailorText:
	text_far _CeladonMart5FSailorText
	text_end

CeladonMart5FCurrentFloorSignText:
	text_far _CeladonMart5FCurrentFloorSignText
	text_end

CeladonMart5FClerk1Text::
	script_mart TM_WATER_GUN, TM_PAY_DAY, TM_SEISMIC_TOSS, TM_TELEPORT, TM_BIDE, TM_SWIFT, TM_REST, TM_THUNDER_WAVE

CeladonMart5FClerk2Text::
	script_mart HP_UP, PROTEIN, IRON, CARBOS, CALCIUM, X_ACCURACY, X_ATTACK, X_DEFEND, X_SPEED, X_SPECIAL, DIRE_HIT, GUARD_SPEC