; Pick Starter mode: the rival's comment on the player's starter in Oak's lab
; (PickStarterRivalComment), between the two halves of
; _OaksLabRivalIllTakeYouOnText. A section of its own: the text banks are full.

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
	line "You took an EEVEE"
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

	para "Gramps! I'm"
	line "swapping my EEVEE!"
	prompt

_PickStarterRivalSwappedText::
	text "<RIVAL> got a"
	line "@"
	text_ram wStringBuffer
	text "!@"
	text_end
