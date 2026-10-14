#!/usr/bin/env python3
"""Headless scenario tests: check specific events later in the game in PyBoy.

Each scenario starts from a game that has just received its starter (Normal
mode with PIKACHU, or Pick Starter mode with CHARMANDER), adjusts a few RAM
values (money, happiness, moves) and uses the game's own scripted-warp
mechanism to enter the map, then talks to the NPC or reads the sign and checks
the result.

- Melanie (Cerulean City) gives BULBASAUR without a starter PIKACHU, and in
  Normal mode only if PIKACHU is happy enough.
- The Safari Zone gate with no money survives 6+ refusals (issue #14) and the
  4th refusal still gets in free.
- Pikachu's Beach: any Surf user can play in Pick Starter mode without a
  starter PIKACHU (the Surfin' Dude names it); Normal mode still needs a
  PIKACHU that knows SURF. The posters and the printer follow the same rule
  and must print their own text (issue #53).
- Oak's lab: the rival comments on a picked EEVEE ("Copycat") and on a pick
  that can't attack yet (MAGIKARP) before his first battle. The type and
  legendary comments are covered by the smoke test.
- Cerulean City rival battle: with a CHARMANDER pick (Pick Starter mode) the
  rival's ace is WARTORTLE, his counter starter's line (issue #106); in Normal
  mode it's EEVEE. The lab battle's counter is covered by the smoke test.
- Saving writes PIKACHU's happiness and mood to their own place in the save
  (issue #103: the party/Pokédex save used vanilla's offset, 78 bytes early,
  and overwrote other saved data), and the save checksum stays valid.
- With the Virtual Console ROM (optional second argument), the VC patch lets
  the starter PIKACHU play without SURF.

Usage: scenario_tests.py ROM_PREFIX [VC_ROM_PREFIX]
IDs come from the .sym (constants/ci_exports.asm), so the script can run from
any directory. On failure a screenshot is saved to smoke_test_failures/.
"""

import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from smoke_test import Game, TestFailure, get_starter, new_game, walk_to_oaks_lab  # noqa: E402


# --- starting points -------------------------------------------------------

def starter_state(prefix, difficulty, pick_buttons, expected):
    """Plays a new game up to receiving the starter; returns a saved state."""
    g = Game(prefix, f'setup {expected}')
    try:
        new_game(g, difficulty)
        walk_to_oaks_lab(g)
        received = get_starter(g, pick_buttons)
        if expected not in received:
            g.fail(f'setup: expected {expected}, got "{received}"')
        for _ in range(15):  # let the remaining lab text finish
            g.press('b', 25)
        state = io.BytesIO()
        g.pb.save_state(state)
        return state.getvalue()
    finally:
        g.stop()


def load(prefix, state, label):
    g = Game(prefix, label)
    g.pb.load_state(io.BytesIO(state))
    return g


def warp(g, map_name, came_from, warp_id=0):
    """Enter map_name at warp warp_id (its order in the map's warp_event list),
    as if walking in from came_from."""
    mem = g.pb.memory
    mem[g.syms['hWarpDestinationMap']] = g.const(map_name)
    mem[g.syms['wDestinationWarpID']] = warp_id
    mem[g.syms['wLastMap']] = g.const(came_from)
    mem[g.syms['wStatusFlags3']] |= 1 << g.const('BIT_WARP_FROM_CUR_SCRIPT')
    g.run(300)
    if g.mem('wCurMap') != g.const(map_name):
        g.fail(f'warp to {map_name} failed (on map {g.mem("wCurMap"):#x})')


def walk_to(g, tx, ty):
    for _ in range(40):
        _, x, y = g.pos()
        if (x, y) == (tx, ty):
            return
        g.press('up' if y > ty else 'down' if y < ty else ('left' if x > tx else 'right'), 15, hold=10)
        g.press('b', 10)
    g.fail(f'could not walk to ({tx}, {ty}), stuck at {g.pos()[1:]}')


def dialog_rows(g):
    t = g.text()
    return [t[i * 20:(i + 1) * 20].strip() for i in range(12, 17)]


def talk(g, stop_when):
    """Press A to talk, collecting dialog lines until stop_when(g) is true or
    the text ends. Returns the dialog as one string."""
    lines = []
    g.press('a', 60)
    for _ in range(25):
        for row in dialog_rows(g):
            if row and row not in lines[-6:]:
                lines.append(row)
        if stop_when(g):
            break
        g.press('a', 50)
    return ' / '.join(lines)


def yes_no_shown(g):
    return 'YES' in g.text()


def set_up_party(g, give_surf=False, species=None):
    if give_surf:
        g.pb.memory[g.syms['wPartyMon1Moves'] + 3] = g.const('SURF')
    if species is not None:
        g.pb.memory[g.syms['wPartySpecies']] = g.const(species)
        g.pb.memory[g.syms['wPartyMon1']] = g.const(species)


# --- Oak's lab: the rival's comment ------------------------------------------

def rival_comment(prefix, state, label, species, expect):
    """Makes species the picked starter, walks toward the exit and returns once
    the rival's challenge text before the battle contains expect."""
    g = load(prefix, state, label)
    try:
        set_up_party(g, species=species)
        g.pb.memory[g.syms['wPlayerStarter']] = g.const(species)
        # the CHARMANDER pick gave the rival a counter starter; these picks don't
        g.pb.memory[g.syms['wRivalStarter']] = g.const('RIVAL_STARTER_JOLTEON')
        challenge = g.const('SCRIPT_OAKSLAB_RIVAL_CHALLENGES_PLAYER')
        for _ in range(60):
            if g.mem('wOaksLabCurScript') == challenge and g.mem('wJoyIgnore'):
                break  # the rival has noticed the player
            g.press('down', 10, hold=12)
        seen = []
        for _ in range(80):
            if g.mem('wIsInBattle'):
                break
            seen.append(' '.join(dialog_rows(g)))
            if expect in seen[-1]:
                return f'rival: "{seen[-1]}"'
            g.press('a', 25)
        g.fail(f'expected the rival to say "{expect}", text was "{" | ".join(dict.fromkeys(seen))}"')
    finally:
        g.stop()


# --- Rival's team ----------------------------------------------------------

def cerulean_rival(prefix, state, label, expect_ace):
    """Enter Cerulean City by the trashed house's back door, put the player on
    the rival's trigger spot (21, 6) and check his last Pokémon in battle."""
    g = load(prefix, state, label)
    try:
        warp(g, 'CERULEAN_CITY', 'CERULEAN_TRASHED_HOUSE', 7)  # back door (27, 9)
        g.press('up', 12, hold=10)
        g.press('up', 12, hold=10)
        g.run(60)  # finish the step, then stand on the trigger
        g.pb.memory[g.syms['wXCoord']] = 21
        g.pb.memory[g.syms['wYCoord']] = 6
        for _ in range(120):
            if g.mem('wIsInBattle'):
                break
            g.press('a', 30)
        else:
            g.fail('the Cerulean City rival battle never started')
        count = g.mem('wEnemyPartyCount')
        party = [g.mem('wEnemyPartySpecies', i) for i in range(count)]
        if not party or party[-1] != g.const(expect_ace):
            g.fail(f'expected the rival\'s ace to be {expect_ace} ({g.const(expect_ace):#04x}), '
                   f'party was {[hex(x) for x in party]} (team {g.mem("wTrainerNo")})')
        return f'rival team {g.mem("wTrainerNo")}, ace {expect_ace}'
    finally:
        g.stop()


# --- Saving ----------------------------------------------------------------

def save_game(g):
    """START -> SAVE -> YES, until the game says it saved."""
    for _ in range(10):
        g.pb.button('start', 4)
        g.run(40)
        if 'SAVE' in g.text():
            break
    else:
        g.fail('the START menu never opened')
    for _ in range(8):
        t = g.text()
        if t[t.find('>') + 1:t.find('>') + 5] == 'SAVE':
            break
        g.press('down', 15)
    g.press('a', 90)
    g.press('a', 60)  # YES
    for _ in range(40):
        if 'saved' in g.text():
            return
        g.run(30)
    g.fail('the game never said it saved')


def pikachu_happiness_save(prefix, state):
    """Save, then read the cartridge RAM: the saved main data must hold
    PIKACHU's happiness and mood at their own offset, and the bytes at vanilla's
    offset ($179) must still match RAM."""
    g = load(prefix, state, 'Save happiness')
    try:
        warp(g, 'REDS_HOUSE_2F', 'REDS_HOUSE_1F')
        mem, syms = g.pb.memory, g.syms
        start, happiness = syms['wMainDataStart'], syms['wPikachuHappiness']
        vanilla = start + 0x179
        if happiness == vanilla:
            g.fail("wPikachuHappiness is at vanilla's offset; this test can't tell the difference")
        values = [v for v in (0xa7, 0x5c, 0x3e) if v not in (mem[vanilla], mem[vanilla + 1])][:2]
        mem[happiness], mem[happiness + 1] = values
        save_game(g)

        def sram(sym, offset=0):
            return mem[1, syms[sym] + offset]
        saved = [sram('sMainData', happiness - start + i) for i in range(2)]
        if saved != values:
            g.fail(f'saved happiness/mood {saved}, expected {values}')
        at_vanilla = [sram('sMainData', 0x179 + i) for i in range(2)]
        expect = [mem[vanilla], mem[vanilla + 1]]
        if at_vanilla != expect:
            g.fail(f"save data at vanilla's happiness offset is {at_vanilla}, RAM has {expect} (#103)")
        size = syms['sGameDataEnd'] - syms['sGameData']
        checksum = ~sum(sram('sGameData', i) for i in range(size)) & 0xff
        if checksum != sram('sMainDataCheckSum'):
            g.fail(f'save checksum {sram("sMainDataCheckSum"):#04x}, data sums to {checksum:#04x}')
        return f'happiness/mood saved at their own offset ({values}), other data intact, checksum valid'
    finally:
        g.stop()


# --- Melanie ---------------------------------------------------------------

def melanie(prefix, state, label, happiness_offset, expect_offer):
    """happiness_offset: None to leave happiness alone, else set it to the
    threshold plus this offset."""
    g = load(prefix, state, label)
    try:
        if happiness_offset is not None:
            g.pb.memory[g.syms['wPikachuHappiness']] = g.const('MELANIE_HAPPINESS_THRESHOLD') + happiness_offset
        warp(g, 'CERULEAN_MELANIES_HOUSE', 'CERULEAN_CITY')
        walk_to(g, 3, 2)
        g.press('up', 20, hold=3)
        said = talk(g, lambda g: yes_no_shown(g) and 'BULBASAUR' in ''.join(dialog_rows(g)))
        offered = yes_no_shown(g)
        if offered != expect_offer:
            g.fail(f'expected Melanie {"to offer" if expect_offer else "not to offer"} BULBASAUR; she said "{said}"')
        if not offered:
            return 'no offer, as expected'
        g.press('a', 60)  # YES
        for _ in range(40):
            if g.mem('wPartyCount') == 2:
                return 'offered BULBASAUR, now in the party'
            g.press('b', 40)  # B answers NO to the nickname prompt
        g.fail('accepted BULBASAUR but the party did not grow')
    finally:
        g.stop()


# --- Safari Zone gate ------------------------------------------------------

def safari_gate(prefix, state, label, refusals_so_far):
    """Talks to the gate guard with no money after refusals_so_far refusals."""
    g = load(prefix, state, label)
    try:
        warp(g, 'SAFARI_ZONE_GATE', 'FUCHSIA_CITY')
        for i in range(3):
            g.pb.memory[g.syms['wPlayerMoney'] + i] = 0
        g.pb.memory[g.syms['wSafariSteps']] = refusals_so_far
        for _ in range(30):  # walking up triggers the guard
            if 'SAFARI ZONE' in g.text():
                break
            g.press('up', 12, hold=10)
        else:
            g.fail('the gate guard never spoke')
        lines, presses_after_answer = [], None
        for _ in range(60):
            for row in dialog_rows(g):
                if row and row not in lines[-6:]:
                    lines.append(row)
            if presses_after_answer is None and yes_no_shown(g):
                presses_after_answer = 0  # the A below answers YES to "join the hunt?"
            elif presses_after_answer is not None:
                presses_after_answer += 1
                if presses_after_answer > 15 or g.mem('wCurMap') != g.const('SAFARI_ZONE_GATE'):
                    break
            g.press('a', 40)
        else:
            g.fail('the guard never asked to join the hunt')
        g.run(120)
        if g.mem('wCurMap') == g.const('SAFARI_ZONE_GATE') and g.mem('wJoyIgnore'):
            g.fail('the game did not return control to the player (hang?)')
        said = ' / '.join(lines)
        return g, said
    except BaseException:
        g.stop()
        raise


def safari_overflow(prefix, state):
    g, said = safari_gate(prefix, state, 'Safari gate: 6th refusal', 6)
    try:
        if 'Read my lips' not in said:
            g.fail(f'expected "Read my lips", the guard said "{said}"')
        if g.mem('wSafariSteps') != 4:
            g.fail(f'refusal counter is {g.mem("wSafariSteps")}, expected it to stop at 4')
        return '"Read my lips", counter stays at 4, player free'
    finally:
        g.stop()


def safari_free_entry(prefix, state):
    g, said = safari_gate(prefix, state, 'Safari gate: 4th refusal', 3)
    try:
        if 'persistent' not in said or g.mem('wNumSafariBalls') != 1:
            g.fail(f'expected free entry with 1 ball; balls {g.mem("wNumSafariBalls")}, said "{said}"')
        return 'free entry with 1 SAFARI BALL'
    finally:
        g.stop()


# --- Pikachu's Beach -------------------------------------------------------

def beach(prefix, state, label, give_surf=False, species=None, expect=None):
    """Talks to the Surfin' Dude. expect: None (refused) or the name he must
    say in "Your <name> knows how to SURF"."""
    g = load(prefix, state, label)
    try:
        set_up_party(g, give_surf, species)
        warp(g, 'SUMMER_BEACH_HOUSE', 'ROUTE_19')
        walk_to(g, 2, 4)
        g.press('up', 20, hold=3)
        said = talk(g, yes_no_shown)
        offered = yes_no_shown(g)
        if expect is None:
            if offered:
                g.fail(f'expected the Surfin\' Dude to refuse; he said "{said}"')
            return 'refused, as expected'
        if not offered or f'Your {expect}' not in said:
            g.fail(f'expected "Your {expect} knows how to SURF" and the minigame offer; he said "{said}"')
        return f'offered: "Your {expect} knows how to SURF!"'
    finally:
        g.stop()


def beach_sign(prefix, state, label, x, give_surf, expect):
    """Reads the beach-house sign above (x, 1) (a poster, or the printer at
    x = 13) and checks its text contains expect."""
    g = load(prefix, state, label)
    try:
        set_up_party(g, give_surf)
        warp(g, 'SUMMER_BEACH_HOUSE', 'ROUTE_19')
        walk_to(g, 3, 6)
        walk_to(g, x, 6)
        walk_to(g, x, 2 if x == 13 else 1)
        g.press('up', 20, hold=3)
        said = talk(g, lambda g: expect in ' '.join(dialog_rows(g)))
        if expect not in said:
            g.fail(f'expected "{expect}", the sign says "{said}"')
        return f'"{expect}…"'
    finally:
        g.stop()


def main():
    prefix = sys.argv[1]
    vc_prefix = sys.argv[2] if len(sys.argv) > 2 else None
    print('Setting up: Normal (PIKACHU) and Pick Starter (CHARMANDER)…', flush=True)
    try:
        normal = starter_state(prefix, 0, None, 'PIKACHU')
        pick = starter_state(prefix, 2, ['down'] * 3, 'CHARMANDER')
    except TestFailure as e:
        print(f'FAIL  setup: {e}')
        return 1
    p = prefix
    tests = [
        ('Rival comment: Pick Starter, EEVEE',
         lambda: rival_comment(p, pick, 'Rival eevee', 'EEVEE', 'Copycat')),
        ('Rival comment: Pick Starter, MAGIKARP',
         lambda: rival_comment(p, pick, 'Rival magikarp', 'MAGIKARP', 'even attack')),
        ('Rival: Cerulean City, Pick Starter CHARMANDER',
         lambda: cerulean_rival(p, pick, 'Rival Cerulean pick', 'WARTORTLE')),
        ('Rival: Cerulean City, Normal', lambda: cerulean_rival(p, normal, 'Rival Cerulean normal', 'EEVEE')),
        ('Save: PIKACHU happiness offset', lambda: pikachu_happiness_save(p, normal)),
        ('Melanie: Pick Starter, CHARMANDER', lambda: melanie(p, pick, 'Melanie pick', None, True)),
        ('Melanie: Normal, unhappy PIKACHU', lambda: melanie(p, normal, 'Melanie unhappy', -47, False)),
        ('Melanie: Normal, happy PIKACHU', lambda: melanie(p, normal, 'Melanie happy', 50, True)),
        ('Safari gate: 6th refusal with no money', lambda: safari_overflow(p, normal)),
        ('Safari gate: 4th refusal with no money', lambda: safari_free_entry(p, normal)),
        ('Beach: Pick Starter, CHARMANDER with SURF',
         lambda: beach(p, pick, 'Beach pick surf', give_surf=True, expect='CHARMANDER')),
        ('Beach: Pick Starter, CHARMANDER without SURF', lambda: beach(p, pick, 'Beach pick')),
        ('Beach: Normal, PIKACHU with SURF',
         lambda: beach(p, normal, 'Beach normal surf', give_surf=True, expect='PIKACHU')),
        ('Beach: Normal, PIKACHU without SURF', lambda: beach(p, normal, 'Beach normal')),
        ('Beach: Normal, non-PIKACHU with SURF',
         lambda: beach(p, normal, 'Beach normal other', give_surf=True, species='CHARMANDER')),
        ('Beach poster: Pick Starter, no SURF',
         lambda: beach_sign(p, pick, 'Poster pick', 3, False, '30 years of waves')),
        ('Beach poster: Pick Starter, CHARMANDER with SURF',
         lambda: beach_sign(p, pick, 'Poster pick surf', 3, True, 'scribbles')),
        ('Beach poster: Normal, no SURF',
         lambda: beach_sign(p, normal, 'Poster normal', 3, False, '30 years of waves')),
        ('Beach printer: Pick Starter, no SURF',
         lambda: beach_sign(p, pick, 'Printer pick', 13, False, 'sort of')),
        ('Beach printer: Pick Starter, CHARMANDER with SURF',
         lambda: beach_sign(p, pick, 'Printer pick surf', 13, True, 'PRINTER')),
    ]
    if vc_prefix:
        print('Setting up the Virtual Console ROM…', flush=True)
        try:
            vc_normal = starter_state(vc_prefix, 0, None, 'PIKACHU')
            vc_pick = starter_state(vc_prefix, 2, ['down'] * 3, 'CHARMANDER')
        except TestFailure as e:
            print(f'FAIL  VC setup: {e}')
            return 1
        tests += [
            ('VC beach: Normal, PIKACHU without SURF',
             lambda: beach(vc_prefix, vc_normal, 'VC beach normal', expect='PIKACHU')),
            ('VC beach: Pick Starter, CHARMANDER without SURF',
             lambda: beach(vc_prefix, vc_pick, 'VC beach pick')),
            ('VC beach poster: Pick Starter, no SURF',
             lambda: beach_sign(vc_prefix, vc_pick, 'VC poster pick', 3, False, '30 years of waves')),
        ]
    failed = 0
    for label, test in tests:
        try:
            print(f'PASS  {label}: {test()}', flush=True)
        except TestFailure as e:
            failed += 1
            print(f'FAIL  {label}: {e}', flush=True)
    print(f'{len(tests) - failed}/{len(tests)} passed')
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
