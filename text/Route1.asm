_Route1Youngster1MartSampleText::
	text "Hi! I work at a"
	line "#MON MART."

	para "It's a convenient"
	line "shop, so please"
	cont "visit us in"
	cont "VIRIDIAN CITY."

	para "I know, I'll give"
	line "you a sample!"
	cont "Here you go!"
	prompt

_Route1Youngster1GotPotionText::
	text "<PLAYER> got"
	line "@"
	text_ram wStringBuffer
	text "!@"
	text_end

_Route1Youngster1AlsoGotPokeballsText::
	text "We also carry"
	line "# BALLs for"
	cont "catching #MON!"
	done

_Route1Youngster1NoRoomText::
	text "You have too much"
	line "stuff with you!"
	done

_Route1Youngster2Text::
	text "See those ledges"
	line "along the road?"

	para "It's a bit scary,"
	line "but you can jump"
	cont "from them."

	para "You can get back"
	line "to PALLET TOWN"
	cont "quicker that way."
	done

_Route1SignText::
	text "ROUTE 1"
	line "PALLET TOWN -"
	cont "VIRIDIAN CITY"
	done

_OakBeforeBattleText::
	text "OAK: Oh, my!"
	
	para "It seems you"
	line "caught me during"
	cont "during my lunch"
	cont "hour!"

	para "<PLAYER>, you"
	line "have truly come"
	cont "into your own!"

	para "Your #MON"
	line "LEAGUE challenge"
	cont "has reignited"
	cont "a spirit that"
	cont "left me a long"
	cont "time ago..."

	para "How about we"
	line "spar a bit?"
	cont "What say you?"
	done

_OakRealChallengeBattleText::
	text "Excellent!"

	para "Prepare yourself"
	line "for a real"
	cont "challenge!"
	done

_OakRefusedBattleText::
	text "Maybe some other"
	line "time!"
	done

_OakDefeatedText::
	text "Hmm..."

	para "I still have a"
	line "lot to learn!"
	prompt

_OakWonText::
	text "Back in my day,"
	line "I was a serious"
	cont "TRAINER!"
	prompt

_OakPostBattleText::
	text "Well done,"
	line "<PLAYER>!"

	para "You've certainly"
	line "proved your"
	cont "mettle."

	para "It seems I might"
	line "be getting a bit"
	cont "rusty in my old"
	cont "age."

	para "A good trainer"
	line "always strives"
	cont "for improvement,"
	cont "and so shall I."

	para "May your journey"
	line "continue to be"
	cont "one of growth"
	cont "and discovery."
	done