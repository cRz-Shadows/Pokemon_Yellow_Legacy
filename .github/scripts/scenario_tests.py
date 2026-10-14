#!/usr/bin/env python3
"""Headless scenario tests: check specific events later in the game in PyBoy.

Each scenario starts from a game that has just received its starter (Normal
mode with PIKACHU, or Pick Starter mode with CHARMANDER), adjusts a few RAM
values (money, happiness, moves) and uses the game's own scripted-warp
mechanism to enter the map, then talks to the NPC and checks the result.

- Melanie (Cerulean City) gives BULBASAUR without a starter PIKACHU, and in
  Normal mode only if PIKACHU is happy enough.
- The Safari Zone gate with no money survives 6+ refusals (issue #14) and the
  4th refusal still gets in free.
- Pikachu's Beach: any Surf user can play in Pick Starter mode without a
  starter PIKACHU; Normal mode still needs a PIKACHU that knows SURF.

Usage: scenario_tests.py ROM_PREFIX
Must run from the repository root (map and move IDs are read from the source).
On failure a screenshot is saved to smoke_test_failures/.
"""

import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from smoke_test import Game, TestFailure, get_starter, new_game, walk_to_oaks_lab  # noqa: E402


def read_map_ids():
    """Map name -> ID: the order of map_const in constants/map_constants.asm."""
    names = []
    started = False
    for line in open('constants/map_constants.asm'):
        if line.strip() == 'const_def':
            started = True
        elif started:
            m = re.match(r'\s*map_const (\w+),', line)
            if m:
                names.append(m[1])
    return {name: i for i, name in enumerate(names)}


def read_move_id(name):
    """Move ID: the order of const in constants/move_constants.asm (from 1)."""
    names = re.findall(r'^\s*const (\w+)', open('constants/move_constants.asm').read(), re.MULTILINE)
    return names.index(name)  # the first const is NO_MOVE (0)


MAPS = read_map_ids()
SURF = read_move_id('SURF')
HAPPY_ENOUGH_FOR_MELANIE = 147


# --- starting points -------------------------------------------------------

def starter_state(prefix, difficulty, pick_dex_no, expected):
    """Plays a new game up to receiving the starter; returns a saved state."""
    g = Game(prefix, f'setup {expected}')
    try:
        new_game(g, difficulty)
        walk_to_oaks_lab(g)
        received = get_starter(g, pick_dex_no)
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


def warp(g, map_name, came_from):
    """Enter map_name at its first warp, as if walking in from came_from."""
    mem = g.pb.memory
    mem[g.syms['hWarpDestinationMap']] = MAPS[map_name]
    mem[g.syms['wDestinationWarpID']] = 0
    mem[g.syms['wLastMap']] = MAPS[came_from]
    mem[g.syms['wStatusFlags3']] |= 1 << 3  # scripted warp
    g.run(300)
    if g.mem('wCurMap') != MAPS[map_name]:
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


# --- Melanie ---------------------------------------------------------------

def melanie(prefix, state, label, happiness, expect_offer):
    g = load(prefix, state, label)
    try:
        if happiness is not None:
            g.pb.memory[g.syms['wPikachuHappiness']] = happiness
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
                if presses_after_answer > 15 or g.mem('wCurMap') != MAPS['SAFARI_ZONE_GATE']:
                    break
            g.press('a', 40)
        else:
            g.fail('the guard never asked to join the hunt')
        g.run(120)
        if g.mem('wCurMap') == MAPS['SAFARI_ZONE_GATE'] and g.mem('wJoyIgnore'):
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

def beach(prefix, state, label, give_surf, species=None, expect=None):
    """expect: None (refused) or the word the Surfin' Dude uses ("PIKACHU",
    "POK" for POKéMON)."""
    g = load(prefix, state, label)
    try:
        if give_surf:
            g.pb.memory[g.syms['wPartyMon1Moves'] + 3] = SURF
        if species is not None:
            g.pb.memory[g.syms['wPartySpecies']] = species
            g.pb.memory[g.syms['wPartyMon1']] = species
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
            g.fail(f'expected "Your {expect}… knows how to SURF" and the minigame offer; he said "{said}"')
        return f'offered: "Your {expect}{"MON" if expect == "POK" else ""} knows how to SURF!"'
    finally:
        g.stop()


def main():
    prefix = sys.argv[1]
    print('Setting up: Normal (PIKACHU) and Pick Starter (CHARMANDER)…', flush=True)
    try:
        normal = starter_state(prefix, 0, None, 'PIKACHU')
        pick = starter_state(prefix, 2, 4, 'CHARMANDER')
    except TestFailure as e:
        print(f'FAIL  setup: {e}')
        return 1
    charmander = read_species_id('CHARMANDER')
    tests = [
        ('Melanie: Pick Starter, CHARMANDER', lambda: melanie(prefix, pick, 'Melanie pick', None, True)),
        ('Melanie: Normal, unhappy PIKACHU', lambda: melanie(prefix, normal, 'Melanie unhappy', 100, False)),
        ('Melanie: Normal, happy PIKACHU', lambda: melanie(prefix, normal, 'Melanie happy',
                                                           HAPPY_ENOUGH_FOR_MELANIE + 50, True)),
        ('Safari gate: 6th refusal with no money', lambda: safari_overflow(prefix, normal)),
        ('Safari gate: 4th refusal with no money', lambda: safari_free_entry(prefix, normal)),
        ('Beach: Pick Starter, CHARMANDER with SURF', lambda: beach(prefix, pick, 'Beach pick surf', True,
                                                                    expect='POK')),
        ('Beach: Pick Starter, CHARMANDER without SURF', lambda: beach(prefix, pick, 'Beach pick', False)),
        ('Beach: Normal, PIKACHU with SURF', lambda: beach(prefix, normal, 'Beach normal surf', True,
                                                           expect='PIKACHU')),
        ('Beach: Normal, PIKACHU without SURF', lambda: beach(prefix, normal, 'Beach normal', False)),
        ('Beach: Normal, non-PIKACHU with SURF', lambda: beach(prefix, normal, 'Beach normal other', True,
                                                               species=charmander)),
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


def read_species_id(name):
    """Internal species ID: the order of const in constants/pokemon_constants.asm."""
    names = re.findall(r'^\s*const (\w+)', open('constants/pokemon_constants.asm').read(), re.MULTILINE)
    return names.index(name)


if __name__ == '__main__':
    sys.exit(main())
