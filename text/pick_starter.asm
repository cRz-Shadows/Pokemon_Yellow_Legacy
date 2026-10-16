; Pick Starter mode texts. A section of its own: the text banks are full.

; In the intro, before the picker (PickStarterIntroMenu)
_PickStarterIntroText::
	text "PROF.OAK will"
	line "catch a #MON"
	cont "for you to start"
	cont "your journey."

	para "Which one should"
	line "he catch?"

	para "UP/DOWN: look"
	line "LEFT/RIGHT: page"
	cont "SELECT: more info"
	cont "A: choose"
	prompt

; Oak's lab, for a save made before the picker moved to the intro: there's
; no starter yet and Oak caught a PIKACHU, so the picker opens there
_OaksLabOakPickStarterText::
	text "OAK: <PLAYER>, I"
	line "caught a PIKACHU"
	cont "earlier, but my"
	cont "research covers"
	cont "every #MON!"

	para "Go on, pick any"
	line "one you like!"

	para "UP/DOWN: look"
	line "LEFT/RIGHT: page"
	cont "SELECT: more info"
	cont "A: choose"
	prompt

; The rival's comment on the player's starter in Oak's lab
; (PickStarterRivalComment), between the two halves of
; _OaksLabRivalIllTakeYouOnText.

_OaksLabRivalWaitText::
	text "<RIVAL>: Wait"
	line "<PLAYER>!"
	cont "Let's check out"
	cont "our #MON!"
	prompt

_OaksLabRivalComeOnText::
	text "Come on, I'll take"
	line "you on!"
	done

_PickStarterRivalCopycatText::
	text "<RIVAL>: Hey!"
	line "You got an EEVEE"
	cont "too? Copycat!"
	prompt

_PickStarterRivalLegendaryText::
	text "<RIVAL>: What?!"
	line "Gramps gave you"
	cont "a legendary"
	cont "#MON?!"

	para "That's not fair!"
	prompt

_PickStarterRivalCantAttackText::
	text "<RIVAL>: Ha! Your"
	line "@"
	text_ram wNameBuffer
	text " can't"
	cont "even attack!"

	para "This'll be easy!"
	prompt

_PickStarterRivalTypeText::
	text "<RIVAL>: Heh!"
	line "Your @"
	text_ram wNameBuffer
	text " is"
	cont "@"
	text_ram wStringBuffer
	text "-type, eh?"

	para "My EEVEE can"
	line "handle that!"
	prompt

_PickStarterRivalSwapText::
	text "<RIVAL>: Your"
	line "@"
	text_ram wNameBuffer
	text "?"
	cont "Then I want a"
	cont "@"
	text_ram wStringBuffer
	text "!"

	para "Gramps! I'm going"
	line "to swap my EEVEE!"
	prompt

; after one of the comments above
_PickStarterRivalAlsoSwapText::
	text "<RIVAL>: But I"
	line "know what beats"
	cont "it: a @"
	text_ram wStringBuffer
	text "!"

	para "Gramps! I'm going"
	line "to swap my EEVEE!"
	prompt

_PickStarterRivalSwappedText::
	text "<RIVAL> got a"
	line "@"
	text_ram wStringBuffer
	text "!@"
	text_end
