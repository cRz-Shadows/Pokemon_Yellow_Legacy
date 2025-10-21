_DaycareGentlemanIntroText::
	text "I run a DAYCARE."
	line "Would you like me"
	cont "to raise one of"
	cont "your #MON?"
	done

_DaycareGentlemanWhichMonText::
	text "Which #MON"
	line "should I raise?"
	prompt

_DaycareGentlemanWillLookAfterMonText::
	text "Fine, I'll look"
	line "after @"
	text_ram wcd6d
	text_start
	cont "for a while."
	prompt

_DaycareGentlemanComeSeeMeInAWhileText::
	text "Come see me in"
	line "a while."
	done

_DaycareGentlemanMonHasGrownText::
	text "Your @"
	text_ram wcd6d
	text_start
	line "has grown a lot!"

	para "By level, it's"
	line "grown by @"
	text_decimal wDayCareNumLevelsGrown, 1, 3
	text "!"

	para "Aren't I great?"
	prompt

_DaycareGentlemanOweMoneyText::
	text "You owe me ¥@"
	text_bcd wDayCareTotalCost, 2 | LEADING_ZEROES | LEFT_ALIGN
	text_start
	line "for the return"
	cont "of this #MON."
	done

_DaycareGentlemanGotMonBackText::
	text "<PLAYER> got"
	line "@"
	text_ram wDayCareMonName
	text " back!"
	done

_DaycareGentlemanMonNeedsMoreTimeText::
	text "Back already?"
	line "Your @"
	text_ram wcd6d
	text_start
	cont "needs some more"
	cont "time with me."
	prompt

_DaycareGentlemanAllRightThenText::
	text "All right then,"
	line "@"
	text_end

_DaycareGentlemanComeAgainText::
	text "Come again."
	done

_DaycareGentlemanNoRoomForMonText::
	text "You have no room"
	line "for this #MON!"
	done

_DaycareGentlemanOnlyHaveOneMonText::
	text "You only have one"
	line "#MON with you."
	done

_DaycareGentlemanCantAcceptMonWithHMText::
	text "I can't accept a"
	line "#MON that"
	cont "knows an HM move."
	done

_DaycareGentlemanHeresYourMonText::
	text "Thank you! Here's"
	line "your #MON!"
	prompt

_DaycareGentlemanNotEnoughMoneyText::
	text "Hey, you don't"
	line "have enough ¥!"
	done

_DayCareMonAtCapText::
	text "This #MON is"
	line "too strong for me"
	cont "to train further."
	prompt