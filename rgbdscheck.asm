IF !DEF(__RGBDS_MAJOR__) || !DEF(__RGBDS_MINOR__) || !DEF(__RGBDS_PATCH__)
	fail "pokemon_yellow_legacy requires rgbds v1.0.0 or newer."
ENDC

IF __RGBDS_MAJOR__ < 1 || DEF(__RGBDS_RC__)
	fail "pokemon_yellow_legacy requires rgbds v1.0.0 or newer."
ENDC
