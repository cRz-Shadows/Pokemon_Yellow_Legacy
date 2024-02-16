	object_const_def
	const_export ROUTE1_YOUNGSTER1
	const_export ROUTE1_YOUNGSTER2
	const_export ROUTE1_OAK

Route1_Object:
	db $b ; border block

	def_warp_events

	def_bg_events
	bg_event  9, 27, 4

	def_object_events
	object_event  5, 24, SPRITE_YOUNGSTER, WALK, UP_DOWN, 1
	object_event 15, 13, SPRITE_YOUNGSTER, WALK, LEFT_RIGHT, 2
	object_event 10, 25, SPRITE_OAK, STAY, RIGHT, 3, OPP_PROF_OAK, 1 ; oak

	def_warps_to ROUTE_1

	; unused
	warp_to 2, 7, 4
