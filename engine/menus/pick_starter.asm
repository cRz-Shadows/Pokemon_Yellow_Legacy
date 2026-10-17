; Pick Starter mode: a scrollable list of all 151 Pokémon (in Pokédex order)
; with a preview of the highlighted one. The player can't back out; they
; must choose a starter. It opens in the intro, right after the mode is
; chosen (PickStarterIntroMenu), or in Oak's lab if the save has no starter
; yet (PickStarterMenu; saves from before the picker moved to the intro).
; Output: a = [wPlayerStarter] = chosen species (internal index)

DEF PICK_STARTER_LIST_ROWS EQU 7
DEF PICK_STARTER_MAX_TOP   EQU NUM_POKEMON - PICK_STARTER_LIST_ROWS
; Decompressing a front pic takes 40+ frames and input is ignored meanwhile,
; so it's only loaded once the d-pad has been released for this many frames.
; Until then the list stays responsive.
DEF PICK_STARTER_PIC_DELAY EQU 12
; PickStarter_TypeScore of a neutral matchup
DEF NEUTRAL_TYPE_SCORE EQU 4

; what the preview shows next to the picture; SELECT cycles through them
	const_def
	const PICK_STARTER_PAGE_TYPES ; number, name and types
	const PICK_STARTER_PAGE_STATS ; number, name and base stats
	const PICK_STARTER_PAGE_MOVES ; number, name and moves at STARTER_LEVEL
DEF NUM_PICK_STARTER_PAGES EQU const_value

; The list's state lives in the usual menu variables:
; [wListScrollOffset] = Pokédex index (0-based) of the top row
; [wCurrentMenuItem]  = highlighted row, 0 to PICK_STARTER_LIST_ROWS - 1

; In Oak's lab: returns to the map.
PickStarterMenu::
	ld a, [wUpdateSpritesEnabled]
	push af
	ldh a, [hTileAnimations]
	push af
	ld a, [wListScrollOffset]
	push af
	call SaveScreenTilesToBuffer2
	call PickStarter_Choose
	call RunDefaultPaletteCommand
	call ReloadMapData
	call LoadScreenTilesFromBuffer2
	call Delay3
	call LoadGBPal
	pop af
	ld [wListScrollOffset], a
	pop af
	ldh [hTileAnimations], a
	pop af
	ld [wUpdateSpritesEnabled], a
	call UpdateSprites
	ld a, [wPlayerStarter]
	ret

; In the intro (OakSpeech): returns with the screen cleared.
PickStarterIntroMenu::
	ld a, [wUpdateSpritesEnabled]
	push af
	call PickStarter_Choose
	call ClearScreen
	call LoadTextBoxTilePatterns ; LoadPokedexTilePatterns overwrote them
	call RunDefaultPaletteCommand
	call GBPalNormal
	pop af
	ld [wUpdateSpritesEnabled], a
	ld a, [wPlayerStarter]
	ret

; Runs the list until a Pokémon is chosen and stores it in [wPlayerStarter].
; Returns with the palettes white; clears wUpdateSpritesEnabled and
; hTileAnimations.
PickStarter_Choose:
	xor a
	ld [wUpdateSpritesEnabled], a
	ldh [hTileAnimations], a ; tile animations would overwrite the front pic in VRAM
	call GBPalWhiteOut
	call ClearSprites
	callfar LoadPokedexTilePatterns
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ldh [hJoy7], a ; repeat the d-pad while it's held
	xor a
	ld [wListScrollOffset], a
	ld [wCurrentMenuItem], a
	ld [wPickStarterPage], a ; PICK_STARTER_PAGE_TYPES
	call ClearScreen
	call PickStarter_Redraw
	call PickStarter_DrawPic
	call GBPalNormal

.loop
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	bit B_PAD_A, a
	jp nz, .confirm
	bit B_PAD_SELECT, a
	jp nz, .nextPage
	bit B_PAD_UP, a
	jr nz, .up
	bit B_PAD_DOWN, a
	jr nz, .down
	bit B_PAD_LEFT, a
	jr nz, .pageUp
	bit B_PAD_RIGHT, a
	jp nz, .pageDown
	; no input: count down to loading the highlighted mon's picture,
	; but not while the d-pad is held, since auto-repeat is coming
	ldh a, [hJoyHeld]
	and PAD_UP | PAD_DOWN | PAD_LEFT | PAD_RIGHT
	jr nz, .loop
	ld hl, wPickStarterPicDelay
	ld a, [hl]
	and a
	jr z, .loop
	dec [hl]
	jr nz, .loop
	call PickStarter_DrawPic
	jr .loop

.up
	ld hl, wCurrentMenuItem
	ld a, [hl]
	and a
	jr z, .scrollUp
	dec [hl]
	jr .moved
.scrollUp
	ld hl, wListScrollOffset
	ld a, [hl]
	and a
	jr z, .wrapToBottom
	dec [hl]
	jr .moved
.wrapToBottom
	ld a, PICK_STARTER_MAX_TOP
	ld [wListScrollOffset], a
	ld a, PICK_STARTER_LIST_ROWS - 1
	ld [wCurrentMenuItem], a
	jr .moved

.down
	ld hl, wCurrentMenuItem
	ld a, [hl]
	cp PICK_STARTER_LIST_ROWS - 1
	jr z, .scrollDown
	inc [hl]
	jr .moved
.scrollDown
	ld hl, wListScrollOffset
	ld a, [hl]
	cp PICK_STARTER_MAX_TOP
	jr z, .wrapToTop
	inc [hl]
	jr .moved
.wrapToTop
	xor a
	ld [wListScrollOffset], a
	ld [wCurrentMenuItem], a
	jr .moved

.pageUp
	ld hl, wListScrollOffset
	ld a, [hl]
	and a
	jr z, .firstRow ; already showing the top of the list
	sub PICK_STARTER_LIST_ROWS
	jr nc, .storeTop
	xor a
	jr .storeTop
.firstRow
	xor a
	ld [wCurrentMenuItem], a
	jr .moved

.pageDown
	ld hl, wListScrollOffset
	ld a, [hl]
	cp PICK_STARTER_MAX_TOP
	jr z, .lastRow ; already showing the bottom of the list
	add PICK_STARTER_LIST_ROWS
	cp PICK_STARTER_MAX_TOP
	jr c, .storeTop
	ld a, PICK_STARTER_MAX_TOP
	jr .storeTop
.lastRow
	ld a, PICK_STARTER_LIST_ROWS - 1
	ld [wCurrentMenuItem], a
	jr .moved

.storeTop
	ld [hl], a
.moved
	call PickStarter_Redraw
	jp .loop

.nextPage
	ld hl, wPickStarterPage
	ld a, [hl]
	inc a
	cp NUM_PICK_STARTER_PAGES
	jr c, .storePage
	xor a
.storePage
	ld [hl], a
	call PickStarter_DrawInfo ; the picture stays
	jp .loop

.confirm
	; show the highlighted mon's picture if it hasn't loaded yet
	ld a, [wPickStarterPicDelay]
	and a
	call nz, PickStarter_DrawPic
	; YesNoChoice uses wCurrentMenuItem, so save the list position
	ld a, [wCurrentMenuItem]
	push af
	call PickStarter_CanAttack
	ld hl, PickStarterConfirmText ; wNameBuffer still holds the highlighted mon's name
	jr nz, .printConfirm
	ld hl, PickStarterConfirmCantAttackText
.printConfirm
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	ld b, a
	pop af
	ld [wCurrentMenuItem], a
	ld a, b
	and a
	jr z, .chosen
	call ClearScreen
	call PickStarter_Redraw
	call PickStarter_DrawPic
	jp .loop

.chosen
	ld a, [wCurPartySpecies]
	ld [wPlayerStarter], a
	xor a
	ldh [hJoy7], a
	jp GBPalWhiteOutWithDelay3

; Draws the list and the highlighted mon's info (see PickStarter_DrawInfo),
; hides the old picture and schedules the new one (see PICK_STARTER_PIC_DELAY).
PickStarter_Redraw:
	hlcoord 0, 0
	lb bc, 9, 8
	call ClearScreenArea
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl] ; no printing delay, or every letter would wait on the text speed
	call PickStarter_DrawList
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	call PickStarter_DrawInfo
	ld a, PICK_STARTER_PIC_DELAY
	ld [wPickStarterPicDelay], a
	ret

; Draws the highlighted mon's number, name and the [wPickStarterPage] info
; right of the picture.
; Leaves the highlighted mon in [wCurPartySpecies] and its name in wNameBuffer.
PickStarter_DrawInfo:
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	call PickStarter_DrawPreview
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	ret

; Writes the moves the mon in [wCurSpecies]/[wCurPartySpecies] would know at
; STARTER_LEVEL to wEnemyMonMoves, the same way AddPartyMon gives them.
; Also loads its header (types, base stats) into wMonHeader.
; wEnemyMonMoves is free here (battle data, reloaded when a battle starts);
; wBuffer can't be used because it shares space with wLearningMovesFromDayCare.
PickStarter_GetMoves:
	call GetMonHeader ; level 1 moves in wMonHMoves
	ld hl, wMonHMoves
	ld de, wEnemyMonMoves
	ld bc, NUM_MOVES
	call CopyData
	ld a, STARTER_LEVEL
	ld [wCurEnemyLevel], a
	xor a
	ld [wLearningMovesFromDayCare], a
	ld de, wEnemyMonMoves
	predef_jump WriteMonMoves ; adds the moves learned up to STARTER_LEVEL

; Returns nz if the mon in [wCurSpecies]/[wCurPartySpecies] would know a
; damaging move at STARTER_LEVEL (see PickStarter_GetMoves).
PickStarter_CanAttack:
	call PickStarter_GetMoves
	ld hl, wEnemyMonMoves
	ld c, NUM_MOVES
.loop
	ld a, [hli]
	and a
	jr z, .next
	push hl
	push bc
	dec a
	ld hl, Moves + MOVE_POWER
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	pop bc
	pop hl
	and a
	ret nz ; power > 0 (fixed-damage moves have power 1)
.next
	dec c
	jr nz, .loop
	xor a
	ret

PickStarter_DrawPic:
	xor a
	ld [wPickStarterPicDelay], a
	hlcoord 1, 1
	call LoadFrontSpriteByMonIndex ; uses [wCurPartySpecies]
	ld b, SET_PAL_POKEDEX ; uses [wCurPartySpecies]
	jp RunPaletteCommand

PickStarter_DrawPreview:
	hlcoord 8, 0
	lb bc, 9, SCREEN_WIDTH - 8
	call ClearScreenArea
	ld a, [wListScrollOffset]
	ld b, a
	ld a, [wCurrentMenuItem]
	add b
	inc a
	ld [wPokedexNum], a
	hlcoord 9, 1
	ld de, PickStarterNoText
	call PlaceString
	hlcoord 12, 1
	ld de, wPokedexNum
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	ld [wNamedObjectIndex], a
	call GetMonName
	hlcoord 9, 2
	call PlaceString
	ld a, [wPickStarterPage]
	cp PICK_STARTER_PAGE_STATS
	jr z, PickStarter_DrawStats
	cp PICK_STARTER_PAGE_MOVES
	jr z, PickStarter_DrawMoves
	hlcoord 9, 4
	ld de, PickStarterTypesText
	call PlaceString
	hlcoord 10, 5
	predef_jump PrintMonType ; uses [wCurSpecies]

PickStarter_DrawStats:
	call GetMonHeader ; uses [wCurSpecies]
	ldh a, [hUILayoutFlags]
	push af
	set BIT_SINGLE_SPACED_LINES, a ; single-spaced <NEXT>
	ldh [hUILayoutFlags], a
	hlcoord 9, 4
	ld de, PickStarterStatsText
	call PlaceString
	pop af
	ldh [hUILayoutFlags], a
	ld de, wMonHBaseStats
	hlcoord 17, 4
	ld b, NUM_STATS
.loop
	push bc
	push de
	push hl
	lb bc, 1, 3
	call PrintNumber
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop de
	inc de
	pop bc
	dec b
	jr nz, .loop
	ret

; Move names are up to 12 letters, so they start one column further left.
PickStarter_DrawMoves:
	call PickStarter_GetMoves
	ld de, wEnemyMonMoves
	hlcoord 8, 4
	ld b, NUM_MOVES
.loop
	push bc
	push hl
	ld a, [de]
	inc de
	push de
	and a
	ld de, PickStarterNoMoveText
	jr z, .place
	ld [wNamedObjectIndex], a
	call GetMoveName
.place
	call PlaceString
	pop de
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	dec b
	jr nz, .loop
	; GetMoveName overwrote the mon's name, which the confirm prompt prints
	ld a, [wCurPartySpecies]
	ld [wNamedObjectIndex], a
	jp GetMonName

PickStarter_DrawList:
	hlcoord 0, 9
	lb bc, PICK_STARTER_LIST_ROWS, SCREEN_WIDTH - 2
	call TextBoxBorder
	ld a, [wListScrollOffset]
	ld c, a ; 0-based Pokédex index of the current row
	ld b, PICK_STARTER_LIST_ROWS
	hlcoord 2, 10
.loop
	push bc
	push hl
	ld a, c
	inc a
	ld [wPokedexNum], a
	ld de, wPokedexNum
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber
	callfar PokedexToIndex
	ld a, [wPokedexNum]
	ld [wNamedObjectIndex], a
	call GetMonName
	pop hl
	push hl
	ld bc, 4
	add hl, bc
	call PlaceString
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	inc c
	dec b
	jr nz, .loop
	hlcoord 1, 10
	ld a, [wCurrentMenuItem]
	ld bc, SCREEN_WIDTH
	call AddNTimes
	ld [hl], '▶'
	ret

PickStarterNoText:
	db "No.@"

PickStarterTypesText:
	db   "TYPE1/"
	next "TYPE2/@"

PickStarterStatsText: ; in wMonHBaseStats order
	db   "HP"
	next "ATTACK"
	next "DEFENSE"
	next "SPEED"
	next "SPECIAL@"

PickStarterNoMoveText:
	db "-@"

PickStarterConfirmText:
	text_far _PickStarterConfirmText
	text_end

PickStarterConfirmCantAttackText:
	text_far _PickStarterConfirmCantAttackText
	text_end

; Pick Starter mode, once the rival has taken his EEVEE in Oak's lab: sets
; wRivalStarter to the Pokémon he counters the player's starter with.
; - A Bulbasaur/Charmander/Squirtle-line pick: the starter that beats it, as in
;   Red/Blue (PickStarterRivalCounters).
; - PIKACHU: none, he keeps his EEVEE as in Normal mode.
; - Anything else: the PickStarterRivalCounterPicks entry whose types hit the
;   player's starter hardest (PickStarter_TypeScore). On a tie, the one the
;   starter's types hit least; on another tie, the first in the list. He keeps
;   his EEVEE if none of them is super effective.
; He keeps the counter's line all game (see RIVAL_STARTER_BULBASAUR and
; PickStarterRivalCounterMon).
PickStarterSetRivalStarter::
	ld a, [wPlayerStarter]
	ld b, a
	ld hl, PickStarterRivalCounters
.loop
	ld a, [hli]
	cp -1
	jr z, .notStarterLine
	cp b
	ld a, [hli]
	jr nz, .loop
	ld [wRivalStarter], a
	ret

.notStarterLine
	ld a, b
	cp STARTER_PIKACHU
	ret z
	; the player's types go to wBattleMonType and each candidate's to
	; wEnemyMonType (battle data, free outside battle)
	ld de, wBattleMonType
	call PickStarter_GetTypes
	lb bc, NEUTRAL_TYPE_SCORE, 0 ; the best attack and defense scores so far
	ld hl, PickStarterRivalCounterPicks
.candidate
	ld a, [hl]
	cp -1
	ret z
	push hl
	ld de, wEnemyMonType
	call PickStarter_GetTypes
	ld hl, wEnemyMonType
	ld de, wBattleMonType
	call PickStarter_BestTypeScore ; how hard it hits the player's starter
	cp b
	jr c, .next
	push af
	ld hl, wBattleMonType
	ld de, wEnemyMonType
	call PickStarter_BestTypeScore ; how hard the player's starter hits it
	ld e, a
	pop af
	jr nz, .better
	ld a, e
	cp c
	jr nc, .next ; a tie, and it isn't hit less
	ld a, b
.better
	ld b, a
	ld c, e
	pop hl
	push hl
	inc hl
	ld a, [hl]
	ld [wRivalStarter], a
.next
	pop hl
	inc hl
	inc hl
	jr .candidate

; Copies the types of species a to de. Preserves bc and hl.
PickStarter_GetTypes:
	push hl
	push bc
	push de
	ld [wCurSpecies], a
	call GetMonHeader
	pop de
	ld hl, wMonHTypes
	ld bc, 2 ; wMonHType1, wMonHType2
	call CopyData
	pop bc
	pop hl
	ret

; Returns in a how hard the types at hl hit the types at de: the better
; PickStarter_TypeScore of the two. Preserves bc, de and hl.
PickStarter_BestTypeScore:
	push bc
	ld a, [hli]
	call PickStarter_TypeScore
	ld b, a
	ld a, [hld]
	cp [hl]
	jr z, .done ; a single type
	call PickStarter_TypeScore
	cp b
	jr c, .done
	ld b, a
.done
	ld a, b
	pop bc
	ret

; Returns in a how hard attacking type a hits the defending types at de, on the
; type chart (TypeEffects): NEUTRAL_TYPE_SCORE, plus 1 for each type it's super
; effective against and minus 1 for each it's not very effective against, or 0
; if it has no effect. Preserves bc, de and hl.
PickStarter_TypeScore:
	push hl
	push bc
	ld b, a
	ld c, NEUTRAL_TYPE_SCORE
	ld a, [de]
	call .matchup
	jr c, .noEffect
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	dec de
	cp h
	jr z, .done ; a single type
	call .matchup
	jr c, .noEffect
.done
	ld a, c
	jr .return
.noEffect
	xor a
.return
	pop bc
	pop hl
	ret

; b = attacking type, a = defending type: c + 1 if it's super effective,
; c - 1 if it's not very effective, carry if it has no effect
.matchup
	push bc
	push de
	ld d, b
	ld e, a
	callfar GetTypeMatchup
	ld a, e
	pop de
	pop bc
	cp EFFECTIVE
	ret z
	jr nc, .superEffective
	and a
	scf
	ret z ; NO_EFFECT
	dec c
	and a
	ret
.superEffective
	inc c
	ret

; Returns in a the Pokémon the rival counters the player's starter with
; ([wRivalStarter] >= FIRST_RIVAL_COUNTER_STARTER); carry if there's none.
PickStarter_GetRivalCounter:
	ld a, [wRivalStarter]
	ld b, a
	ld hl, PickStarterRivalCounterPicks
.loop
	ld a, [hli]
	cp -1
	jr z, .none
	ld c, a
	ld a, [hli]
	cp b
	jr nz, .loop
	ld a, c
	and a
	ret
.none
	scf
	ret

; Pick Starter mode: in the rival's battles, a counter that isn't one of the
; starters (rival_counter_line) replaces the starter in the teams he uses,
; evolved as far as the team's level allows. An evolution by item or trade
; counts from RIVAL_COUNTER_ITEM_EVO_LEVEL.
; Called by ReadTrainer for every enemy Pokémon: may change [wCurPartySpecies]
; (to be added at [wCurEnemyLevel]).
PickStarterRivalCounterMon::
	ld a, [wRivalStarter]
	cp FIRST_RIVAL_COUNTER_LINE
	ret c
	ld a, [wTrainerClass]
	cp RIVAL1
	jr z, .rival
	cp RIVAL2
	jr z, .rival
	cp RIVAL3
	ret nz
.rival
	ld a, [wCurPartySpecies]
	ld hl, PickStarterRivalCounters ; the starters' lines
	ld de, 2
	call IsInArray
	ret nc
	call PickStarter_GetRivalCounter
	ret c
.evolve
	ld [wCurPartySpecies], a
	dec a
	ld c, a
	ld b, 0
	ld hl, EvosMovesPointerTable
	add hl, bc
	add hl, bc
	ld a, BANK(EvosMovesPointerTable)
	call GetFarByte
	ld e, a
	inc hl
	ld a, BANK(EvosMovesPointerTable)
	call GetFarByte
	ld h, a
	ld l, e
	; its first evolution (none of the counters has more than one)
	ld a, BANK(EvosMovesPointerTable)
	call GetFarByte
	and a
	ret z ; it doesn't evolve
	ld e, a
	inc hl
	ld d, RIVAL_COUNTER_ITEM_EVO_LEVEL
	cp EVOLVE_LEVEL
	jr nz, .gotLevel
	ld a, BANK(EvosMovesPointerTable)
	call GetFarByte
	ld d, a
.gotLevel
	; the species follows the level, or the item and level
	ld a, e
	cp EVOLVE_ITEM
	jr nz, .gotSpecies
	inc hl
.gotSpecies
	inc hl
	ld a, [wCurEnemyLevel]
	cp d
	ret c
	ld a, BANK(EvosMovesPointerTable)
	call GetFarByte
	jr .evolve

PickStarterRivalCounters: ; player's pick, rival's starter
	db BULBASAUR,  RIVAL_STARTER_CHARMANDER
	db IVYSAUR,    RIVAL_STARTER_CHARMANDER
	db VENUSAUR,   RIVAL_STARTER_CHARMANDER
	db CHARMANDER, RIVAL_STARTER_SQUIRTLE
	db CHARMELEON, RIVAL_STARTER_SQUIRTLE
	db CHARIZARD,  RIVAL_STARTER_SQUIRTLE
	db SQUIRTLE,   RIVAL_STARTER_BULBASAUR
	db WARTORTLE,  RIVAL_STARTER_BULBASAUR
	db BLASTOISE,  RIVAL_STARTER_BULBASAUR
	db -1 ; end

; What the rival can counter any other pick with (PickStarterSetRivalStarter),
; in tie-break order: species, wRivalStarter. Only the first stage's types
; count: that's the one he picks. Each entry wins for some pick (see the table
; in docs/pick_starter_mode.md, from tools/rival_counters.py). A
; rival_counter_line uses that starter's teams (rival_team_fixed), chosen to
; avoid duplicates: no MACHOP with the Vaporeon team's MACHAMP, no MAGNEMITE
; with the Flareon team's MAGNETON, no GEODUDE with the Jolteon team's RHYDON.
PickStarterRivalCounterPicks:
	db SQUIRTLE,   RIVAL_STARTER_SQUIRTLE   ; WATER
	db CHARMANDER, RIVAL_STARTER_CHARMANDER ; FIRE
	db BULBASAUR,  RIVAL_STARTER_BULBASAUR  ; GRASS/POISON
	DEF RIVAL_COUNTER_LINES = 0
	rival_counter_line MACHOP,    RIVAL_STARTER_BULBASAUR  ; FIGHTING
	rival_counter_line GEODUDE,   RIVAL_STARTER_SQUIRTLE   ; ROCK/GROUND
	rival_counter_line MAGNEMITE, RIVAL_STARTER_BULBASAUR  ; ELECTRIC/STEEL
	rival_counter_line DROWZEE,   RIVAL_STARTER_CHARMANDER ; PSYCHIC
	rival_counter_line GASTLY,    RIVAL_STARTER_CHARMANDER ; GHOST/DARK
	rival_counter_line JYNX,      RIVAL_STARTER_SQUIRTLE   ; ICE/PSYCHIC
	rival_counter_line CLEFAIRY,  RIVAL_STARTER_BULBASAUR  ; FAIRY
	db -1 ; end
	ASSERT RIVAL_COUNTER_LINES == NUM_RIVAL_COUNTER_LINES

; Pick Starter mode: the rival's comment on the player's starter (not PIKACHU)
; before his first battle in Oak's lab. A legendary or a mon that can't attack
; yet gets its own comment, and so does an EEVEE like his (if he kept his).
; Otherwise he boasts about the counter he took (PickStarterSetRivalStarter),
; or, if he has none, talks about its (first) type.
PickStarterRivalComment::
	ld a, [wPlayerStarter]
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	ld [wNamedObjectIndex], a
	call GetMonName
	ld a, [wPlayerStarter]
	cp EEVEE
	jr nz, .notCopycat
	ld a, [wRivalStarter]
	cp FIRST_RIVAL_COUNTER_STARTER
	ld hl, PickStarterRivalCopycatText
	jr c, .comment
	ld a, [wPlayerStarter]
.notCopycat
	ld hl, PickStarterLegendaries
	ld de, 1
	call IsInArray
	ld hl, PickStarterRivalLegendaryText
	jr c, .comment
	call PickStarter_CanAttack ; also loads the mon header
	ld hl, PickStarterRivalCantAttackText
	jr z, .comment
	ld a, [wRivalStarter]
	cp FIRST_RIVAL_COUNTER_STARTER
	jr c, .type
	; the counter's name goes to wStringBuffer, the starter's stays in wNameBuffer
	call PickStarter_GetRivalCounter
	ret c ; only from a damaged save (SanitizeModeBytes allows unused values)
	ld [wNamedObjectIndex], a
	call GetMonName
	ld hl, wNameBuffer
	ld de, wStringBuffer
	ld bc, NAME_LENGTH
	call CopyData
	ld a, [wPlayerStarter]
	ld [wNamedObjectIndex], a
	call GetMonName
	ld hl, PickStarterRivalCounterText
.comment
	jp PrintText

.type
	; copy the name of its first type to wStringBuffer
	ld a, [wMonHType1]
	add a
	ld c, a
	ld b, 0
	ld hl, TypeNames
	add hl, bc
	ld a, BANK(TypeNames)
	call GetFarByte
	ld e, a
	inc hl
	ld a, BANK(TypeNames)
	call GetFarByte
	ld h, a
	ld l, e
	ld de, wStringBuffer
	ld bc, NAME_LENGTH ; longer than any type name
	ld a, BANK(TypeNames)
	call FarCopyData
	ld hl, PickStarterRivalTypeText
	jp PrintText

PickStarterLegendaries:
	db ARTICUNO
	db ZAPDOS
	db MOLTRES
	db MEWTWO
	db MEW
	db -1 ; end

PickStarterRivalCopycatText:
	text_far _PickStarterRivalCopycatText
	text_end

PickStarterRivalLegendaryText:
	text_far _PickStarterRivalLegendaryText
	text_end

PickStarterRivalCantAttackText:
	text_far _PickStarterRivalCantAttackText
	text_end

PickStarterRivalTypeText:
	text_far _PickStarterRivalTypeText
	text_end

PickStarterRivalCounterText:
	text_far _PickStarterRivalCounterText
	text_end
