roms := \
	pokemon_yellow_legacy.gbc \
	pokemon_yellow_legacy_debug.gbc
patches := \
	pokemon_yellow_legacy.patch

rom_obj := \
	audio.o \
	home.o \
	main.o \
	maps.o \
	ram.o \
	text.o \
	gfx/pics.o \
	gfx/pikachu.o \
	gfx/sprites.o \
	gfx/tilesets.o

pokemon_yellow_legacy_obj       := $(rom_obj)
pokemon_yellow_legacy_debug_obj := $(rom_obj:.o=_debug.o)
pokemon_yellow_legacy_vc_obj    := $(rom_obj:.o=_vc.o)


### Build tools

RGBDS ?=
RGBASM  ?= $(RGBDS)rgbasm
RGBFIX  ?= $(RGBDS)rgbfix
RGBGFX  ?= $(RGBDS)rgbgfx
RGBLINK ?= $(RGBDS)rgblink


### Build targets

.SUFFIXES:
.SECONDEXPANSION:
.PRECIOUS:
.SECONDARY:
.PHONY: all yellow yellow_debug yellow_vc clean tidy tools test

all: $(roms)
yellow:       pokemon_yellow_legacy.gbc
yellow_debug: pokemon_yellow_legacy_debug.gbc
yellow_vc:    pokemon_yellow_legacy.patch

clean: tidy
	find gfx \
	     \( -iname '*.1bpp' \
	        -o -iname '*.2bpp' \
	        -o -iname '*.pic' \) \
	     -delete
	find audio/pikachu_cries \
	     \( -iname '*.pcm' \) \
	     -delete

tidy:
	$(RM) $(roms) \
	      $(roms:.gbc=.sym) \
	      $(roms:.gbc=.map) \
	      $(patches) \
	      $(patches:.patch=_vc.gbc) \
	      $(patches:.patch=_vc.sym) \
	      $(patches:.patch=_vc.map) \
	      $(pokemon_yellow_legacy_obj) \
	      $(pokemon_yellow_legacy_vc_obj) \
	      $(pokemon_yellow_legacy_debug_obj) \
	      rgbdscheck.o
	$(MAKE) clean -C tools/

tools:
	$(MAKE) -C tools/

# Runs the CI tests locally (needs: pip install -r .github/requirements.txt).
# See docs/ci.md for the comparison checks, which need a build of the base commit.
PYTHON ?= python3
test: $(roms) $(patches)
	$(PYTHON) -m unittest discover -s .github/scripts -p 'test_*.py'
	$(PYTHON) .github/scripts/smoke_test.py pokemon_yellow_legacy pokemon_yellow_legacy_debug
	$(PYTHON) .github/scripts/scenario_tests.py pokemon_yellow_legacy pokemon_yellow_legacy_vc
	ruff check --config .github/ruff.toml .github/scripts tools/make_release_patches.py tools/upstream_rename.py


RGBASMFLAGS = -Q8 -P includes.asm -Weverything -Wnumeric-string=2 -Wtruncation=1
# Create a sym/map for debug purposes if `make` run with `DEBUG=1`
ifeq ($(DEBUG),1)
RGBASMFLAGS += -E
endif

$(pokemon_yellow_legacy_debug_obj): RGBASMFLAGS += -D _DEBUG
$(pokemon_yellow_legacy_vc_obj):    RGBASMFLAGS += -D _YELLOW_VC

%.patch: %_vc.gbc %.gbc vc/%.patch.template
	tools/make_patch $*_vc.sym $^ $@

rgbdscheck.o: rgbdscheck.asm
	$(RGBASM) -o $@ $<

# Build tools when building the rom.
# This has to happen before the rules are processed, since that's when scan_includes is run.
ifeq (,$(filter clean tidy tools,$(MAKECMDGOALS)))

$(info $(shell $(MAKE) -C tools))

# The dep rules have to be explicit or else missing files won't be reported.
# As a side effect, they're evaluated immediately instead of when the rule is invoked.
# It doesn't look like $(shell) can be deferred so there might not be a better way.
preinclude_deps := includes.asm $(shell tools/scan_includes includes.asm)
define DEP
$1: $2 $$(shell tools/scan_includes $2) $(preinclude_deps) | rgbdscheck.o
	$$(RGBASM) $$(RGBASMFLAGS) -o $$@ $$<
endef

# Dependencies for objects
$(foreach obj, $(pokemon_yellow_legacy_obj), $(eval $(call DEP,$(obj),$(obj:.o=.asm))))
$(foreach obj, $(pokemon_yellow_legacy_debug_obj), $(eval $(call DEP,$(obj),$(obj:_debug.o=.asm))))
$(foreach obj, $(pokemon_yellow_legacy_vc_obj), $(eval $(call DEP,$(obj),$(obj:_vc.o=.asm))))

endif


%.asm: ;


pokemon_yellow_legacy_pad       = 0x00
pokemon_yellow_legacy_debug_pad = 0xff
pokemon_yellow_legacy_vc_pad    = 0x00

opts = -cjsv -k 01 -l 0x33 -m 0x1b -r 03 -t "POKEMON YELLOW LEGACY"

%.gbc: $$(%_obj) layout.link
	$(RGBLINK) -p $($*_pad) -w -m $*.map -n $*.sym -l layout.link -o $@ $(filter %.o,$^)
	$(RGBFIX) -p $($*_pad) $(opts) $@


### Misc file-specific graphics rules

gfx/battle/move_anim_0.2bpp: tools/gfx += --trim-whitespace
gfx/battle/move_anim_1.2bpp: tools/gfx += --trim-whitespace

gfx/credits/the_end.2bpp: tools/gfx += --interleave --png=$<

gfx/slots/slots_1.2bpp: tools/gfx += --trim-whitespace

gfx/tilesets/%.2bpp: tools/gfx += --trim-whitespace
gfx/tilesets/reds_house.2bpp: tools/gfx += --preserve=0x48

gfx/title/pokemon_logo.2bpp: tools/gfx += --trim-whitespace

gfx/trade/game_boy.2bpp: tools/gfx += --remove-duplicates

gfx/sgb/border.2bpp: tools/gfx += --trim-whitespace

gfx/surfing_pikachu/surfing_pikachu_1c.2bpp: tools/gfx += --trim-whitespace
gfx/surfing_pikachu/surfing_pikachu_3.2bpp: tools/gfx += --trim-whitespace


### Catch-all graphics rules

%.png: ;

%.2bpp: %.png
	$(RGBGFX) $(rgbgfx) -o $@ $<
	$(if $(tools/gfx),\
		tools/gfx $(tools/gfx) -o $@ $@)

%.1bpp: %.png
	$(RGBGFX) $(rgbgfx) -d1 -o $@ $<
	$(if $(tools/gfx),\
		tools/gfx $(tools/gfx) -d1 -o $@ $@)

%.pic: %.2bpp
	tools/pkmncompress $< $@


### Catch-all audio rules

%.wav: ;

%.pcm: %.wav
	tools/pcm $< $@
