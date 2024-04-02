	object_const_def
	const_export AGATHASROOM_AGATHA
	const_export AGATHASROOM_AGATHA_REMATCH

AgathasRoom_Object:
	db $0 ; border block

	def_warp_events
	warp_event  4, 11, BRUNOS_ROOM, 3
	warp_event  5, 11, BRUNOS_ROOM, 4
	warp_event  4,  0, LANCES_ROOM, 1
	warp_event  5,  0, LANCES_ROOM, 1

	def_bg_events

	def_object_events
	object_event  5,  2, SPRITE_AGATHA, STAY, DOWN, TEXT_AGATHASROOM_AGATHA, OPP_AGATHA, 1
	object_event  5,  2, SPRITE_AGATHA, STAY, DOWN, TEXT_AGATHASROOM_AGATHA_REMATCH, OPP_AGATHA, 2

	def_warps_to AGATHAS_ROOM
