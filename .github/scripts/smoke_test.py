#!/usr/bin/env python3
"""Headless smoke tests: play the start of the game in PyBoy.

For each case: new game -> Oak stops you in the grass -> starter in his lab ->
first rival battle -> rival leaves -> talk to Oak.
- Normal and Hard must give PIKACHU, and the "Pikachu escapes its Poké Ball"
  scene must play; Oak then says to talk to it.
- Pick Starter must open the picker and give the picked Pokémon. Picking
  PIKACHU must behave like Normal; picking anything else must skip the escape
  scene, and Oak gives his battle advice instead.
Two more Pick Starter cases cover the picker's list wrap (UP from the top
gives MEW) and paging (RIGHT moves a page).
Before the rival battle, the rival must comment on a picked starter (its type,
or that it's legendary), and say nothing extra about a PIKACHU.
SELECT in the picker must cycle the preview: types, base stats, level-5 moves.
The debug ROM must reach its debug menu.

Usage: smoke_test.py ROM_PREFIX [DEBUG_ROM_PREFIX]
       (a prefix is the ROM path without .gbc; the .sym next to it is used)
Map, script and other IDs come from the .sym (constants/ci_exports.asm), so the
script can run from any directory. On failure a screenshot is saved to
smoke_test_failures/.
"""

import os
import re
import sys

from pyboy import PyBoy

FAIL_DIR = 'smoke_test_failures'

# (label, difficulty, picker buttons or None, expected starter)
CASES = [
    ('Normal', 0, None, 'PIKACHU'),
    ('Hard', 1, None, 'PIKACHU'),
    ('Pick Starter: Charmander', 2, ['down'] * 3, 'CHARMANDER'),
    ('Pick Starter: Pikachu', 2, ['down'] * 24, 'PIKACHU'),
    ('Pick Starter: wrap to Mew', 2, ['up'], 'MEW'),
    ('Pick Starter: paging', 2, ['right', 'right', 'down'], 'PIDGEY'),  # #1 -> #8 -> #15 -> #16
]

# The rival's comment on a picked starter (text() drops punctuation). The
# EEVEE and "can't attack" comments are covered by the scenario tests.
RIVAL_COMMENTS = {'CHARMANDER': 'FIRE type', 'MEW': 'legendary', 'PIDGEY': 'NORMAL type'}
RIVAL_COMMENT_MARKERS = ('type  eh', 'legendary', 'Copycat', 'even attack')


class TestFailure(Exception):
    pass


class Game:
    def __init__(self, prefix, name):
        self.name = name
        self.syms = {}    # label -> address ("bank:address name" lines)
        self.consts = {}  # exported constant -> value ("value name" lines)
        with open(prefix + '.sym') as f:
            for line in f:
                parts = line.split(';')[0].split()
                if len(parts) != 2:
                    continue
                if ':' in parts[0]:
                    self.syms[parts[1]] = int(parts[0].split(':')[1], 16)
                else:
                    self.consts[parts[1]] = int(parts[0], 16)
        self.pb = PyBoy(prefix + '.gbc', window='null', sound_emulated=False)
        self.pb.set_emulation_speed(0)

    def mem(self, sym, offset=0):
        return self.pb.memory[self.syms[sym] + offset]

    def const(self, name):
        if name not in self.consts:
            raise TestFailure(f'{name} is not in the .sym; export it in constants/ci_exports.asm')
        return self.consts[name]

    def run(self, frames):
        # nothing reads the screen except failure screenshots, so skip rendering
        self.pb.tick(frames, False)

    def press(self, button, wait=30, hold=6):
        self.pb.button(button, hold)
        self.run(wait)

    def text(self):
        """The tilemap decoded to ASCII (letters, digits and '>' only)."""
        start = self.syms['wTileMap']
        upper, lower = self.const('CI_CHAR_A'), self.const('CI_CHAR_LOWER_A')
        digit, cursor = self.const('CI_CHAR_0'), self.const('CI_CHAR_CURSOR')
        out = []
        for i in range(20 * 18):
            c = self.pb.memory[start + i]
            if upper <= c < upper + 26:
                out.append(chr(c - upper + ord('A')))
            elif lower <= c < lower + 26:
                out.append(chr(c - lower + ord('a')))
            elif digit <= c < digit + 10:
                out.append(chr(c - digit + ord('0')))
            elif c == cursor:
                out.append('>')
            else:
                out.append(' ')
        return ''.join(out)

    def pos(self):
        return self.mem('wCurMap'), self.mem('wXCoord'), self.mem('wYCoord')

    def fail(self, message):
        os.makedirs(FAIL_DIR, exist_ok=True)
        path = os.path.join(FAIL_DIR, re.sub(r'\W+', '_', self.name) + '.png')
        self.pb.tick(1, True)  # run() skips rendering
        self.pb.screen.image.save(path)
        raise TestFailure(f'{message} (screenshot: {path})')

    def stop(self):
        self.pb.stop(save=False)


def new_game(g, mode_index):
    """From power-on to the player's room, choosing the given difficulty."""
    for _ in range(3000):
        t = g.text()
        if 'NORMAL' in t and 'HARD' in t and 'STARTER' in t:
            for _ in range(mode_index):
                g.press('down', 20)
            g.press('a', 60)
            break
        g.press('a', 25)
    else:
        g.fail('difficulty menu never appeared')
    for _ in range(3000):
        t = g.text()
        if 'NEW NAME' in t:  # take the first preset name
            g.press('down', 20)
            g.press('a', 60)
            continue
        if 'unfold' in t:  # Oak's last line
            g.press('a', 400)
            return
        g.press('a', 25)
    g.fail('intro never finished')


# Player's room -> downstairs -> Pallet Town -> the grass, where Oak stops you
WAYPOINTS = {
    'REDS_HOUSE_2F': [(7, 1)],
    'REDS_HOUSE_1F': [(7, 6), (3, 6), (3, 7), (3, 8)],
    'PALLET_TOWN': [(10, 6), (10, 0)],
}


def walk_to_oaks_lab(g):
    waypoints = {g.const(name): targets for name, targets in WAYPOINTS.items()}
    oaks_lab = g.const('OAKS_LAB')
    reached = {}
    last = None
    stuck = 0
    for _ in range(3000):
        mp, x, y = g.pos()
        if mp == oaks_lab:
            return
        targets = waypoints.get(mp)
        if not targets or reached.get(mp, 0) >= len(targets):
            g.press('b', 25)  # scripted scene: let it play
            continue
        tx, ty = targets[reached.get(mp, 0)]
        if (x, y) == (tx, ty):
            reached[mp] = reached.get(mp, 0) + 1
            continue
        stuck = stuck + 1 if (mp, x, y) == last else 0
        last = (mp, x, y)
        horiz = 'right' if x < tx else 'left' if x > tx else None
        vert = 'up' if y > ty else 'down' if y < ty else None
        dirs = [d for d in (horiz, vert) if d]
        g.press(dirs[(stuck // 3) % len(dirs)], 12, hold=20)
        if stuck >= 2:
            g.press('b', 40)
        if stuck > 60:
            reached[mp] = reached.get(mp, 0) + 1
            stuck = 0
    g.fail(f'never reached Oak\'s lab (stuck at map {mp:#x} ({x}, {y}))')


def open_picker(g):
    """In Oak's lab: check the Poké Ball and press A until the picker opens."""
    for i in range(80):  # Oak's arrival scene
        g.press('a', 30)
        if g.mem('wJoyIgnore') == 0 and i > 20:
            break
    for d in ('down', 'right', 'right'):  # stand below the Poké Ball
        g.press(d, 30, hold=10)
    g.press('up', 20, hold=3)
    g.press('a', 60)


def highlight_and_confirm(g, pick_buttons):
    """In the picker: press pick_buttons, then A. Returns the confirm text."""
    for _ in range(400):
        if 'TYPE1' in g.text():
            break
        g.press('a', 25)
    else:
        g.fail('the Pick Starter picker never opened')
    g.run(60)
    for button in pick_buttons:
        g.press(button, 16, hold=8)
    g.run(120)
    for _ in range(10):  # confirm, retrying while the sprite loads
        if 'you want' in g.text():
            break
        g.press('a', 60)
    else:
        g.fail('the confirm prompt never appeared')
    t = g.text()
    return ' '.join(t[i * 20:(i + 1) * 20].strip() for i in range(12, 17))


def get_starter(g, pick_buttons):
    """In Oak's lab: check the Poké Ball and receive the starter, or pick it by
    pressing pick_buttons in the picker. Returns the "received" text."""
    open_picker(g)
    g.saw_attack_warning = False
    if pick_buttons:
        highlight_and_confirm(g, pick_buttons)
        for _ in range(10):
            g.saw_attack_warning |= 'attack' in g.text()
            if 'you want' not in g.text():
                break
            g.press('a', 60)
    received = ''
    for _ in range(3000):
        t = g.text()
        if 'received' in t:
            received = ' '.join(t[i * 20:(i + 1) * 20].strip() for i in range(13, 17))
        if g.mem('wPartyCount') and g.mem('wPartyMon1Level'):
            return received
        g.press('b' if 'nickname' in t else 'a', 25)
    g.fail('never received a starter')


def rival_battle_and_exit(g):
    """Walk toward the exit to trigger the rival's challenge, play through the
    battle (win or lose) until the rival has left and the player is free.
    Returns the set of lab script states seen and the text shown before the
    battle (the rival's challenge)."""
    for _ in range(40):  # let the gift text finish
        g.press('b', 20)
    challenge = g.const('SCRIPT_OAKSLAB_RIVAL_CHALLENGES_PLAYER')
    noop = g.const('SCRIPT_OAKSLAB_NOOP')
    challenge_text = []

    def read_box():
        if not g.mem('wIsInBattle'):
            t = g.text()
            challenge_text.append(' '.join(t[i * 20:(i + 1) * 20].strip() for i in range(13, 17)))

    for _ in range(60):
        if g.mem('wIsInBattle') or g.mem('wOaksLabCurScript') != challenge:
            break
        g.press('down', 10, hold=12)
        read_box()
        g.press('b', 15)
    seen = set()
    for step in range(1500):
        if step < 100:
            read_box()
        seen.add(g.mem('wOaksLabCurScript'))
        if (g.mem('wOaksLabCurScript') == noop and step > 50
                and g.mem('wJoyIgnore') == 0 and not g.mem('wIsInBattle')):
            for _ in range(30):  # finish any open text box
                g.press('b', 20)
            return seen, ' | '.join(challenge_text)
        g.press('a', 20)
    g.fail(f'the rival battle and exit never finished (lab script {g.mem("wOaksLabCurScript")})')


def talk_to_oak(g):
    """Walk below Oak (5, 2), talk to him and return his text."""
    for _ in range(40):
        _, x, y = g.pos()
        if (x, y) == (5, 3):
            break
        g.press('b', 15)
        g.press('left' if x > 5 else 'right' if x < 5 else ('up' if y > 3 else 'down'), 15, hold=10)
    else:
        g.fail(f'could not walk to Oak (at {g.pos()[1:]})')
    g.press('up', 20, hold=3)
    g.press('a', 90)
    t = g.text()
    return ' '.join(t[i * 20:(i + 1) * 20].strip() for i in range(13, 17))


def test_case(prefix, label, difficulty, pick_buttons, expected):
    g = Game(prefix, label)
    try:
        new_game(g, difficulty)
        if g.mem('wDifficulty') != difficulty:
            g.fail(f'difficulty byte is {g.mem("wDifficulty")}, expected {difficulty}')
        walk_to_oaks_lab(g)
        received = get_starter(g, pick_buttons)
        if expected not in received:
            g.fail(f'expected to receive {expected}, text was "{received}"')
        if g.mem('wPartyCount') != 1 or g.mem('wPartyMon1Level') != g.const('STARTER_LEVEL'):
            g.fail(f'party count {g.mem("wPartyCount")}, level {g.mem("wPartyMon1Level")}')
        if g.mem('wPartySpecies') != g.mem('wPlayerStarter'):
            g.fail('party species does not match wPlayerStarter')
        if g.saw_attack_warning:
            g.fail(f'the "can\'t attack yet" warning appeared for {expected}')
        pikachu = expected == 'PIKACHU'
        seen, challenge_text = rival_battle_and_exit(g)
        comment = RIVAL_COMMENTS.get(expected)
        if difficulty == 2 and comment and comment not in challenge_text:
            g.fail(f'expected the rival to say "{comment}", he said "{challenge_text}"')
        if not comment and any(m in challenge_text for m in RIVAL_COMMENT_MARKERS):
            g.fail(f'the rival commented on {expected}: "{challenge_text}"')
        escape_scene = {g.const('SCRIPT_OAKSLAB_PIKACHU_ESCAPES_POKEBALL'),
                        g.const('SCRIPT_OAKSLAB_PIKACHU_DISLIKES_POKEBALLS')}
        if pikachu and not seen & escape_scene:
            g.fail('the "Pikachu escapes its Poké Ball" scene did not play')
        if not pikachu and seen & escape_scene:
            g.fail('the "Pikachu escapes its Poké Ball" scene played without a starter Pikachu')
        oak = talk_to_oak(g)
        want = 'You should' if pikachu else 'If a wild'
        if want not in oak:
            g.fail(f'expected Oak to say "{want}...", he said "{oak}"')
        scene = 'escape scene played' if pikachu else 'no escape scene'
        rival = f'rival said "{comment}"' if comment else 'no rival comment'
        return f'received {expected}, level 5; {rival}; rival battle done; {scene}; Oak: "{want}..."'
    finally:
        g.stop()


def test_weak_starter_warning(prefix):
    """Highlighting MAGIKARP (only knows SPLASH) must warn that it can't attack;
    CHARMANDER must not."""
    g = Game(prefix, 'Weak starter warning')
    try:
        new_game(g, 2)
        walk_to_oaks_lab(g)
        open_picker(g)
        # #129: 18 pages down puts #127 on top, then 2 rows down
        prompt = highlight_and_confirm(g, ['right'] * 18 + ['down'] * 2)
        if 'MAGIKARP' not in prompt:
            g.fail(f'expected the MAGIKARP prompt, got "{prompt}"')
        for _ in range(10):  # show the second paragraph
            if "attack" in g.text():
                break
            g.press('a', 40)
        else:
            g.fail('no "can\'t attack" warning for MAGIKARP')
        return 'MAGIKARP prompt warns it can\'t attack yet'
    finally:
        g.stop()


def test_picker_info(prefix):
    """SELECT in the picker must cycle CHARMANDER's preview through its types,
    base stats and level-5 moves, and back; the confirm prompt must still name
    CHARMANDER after the moves page."""
    g = Game(prefix, 'Picker info pages')
    try:
        new_game(g, 2)
        walk_to_oaks_lab(g)
        open_picker(g)
        for _ in range(400):
            if 'TYPE1' in g.text():
                break
            g.press('a', 25)
        else:
            g.fail('the Pick Starter picker never opened')
        g.run(60)
        for _ in range(3):
            g.press('down', 16, hold=8)
        g.run(120)
        pages = (('stats', ('HP', 'ATTACK', 'DEFENSE', 'SPEED', 'SPECIAL', '52')),
                 ('moves', ('SCRATCH', 'GROWL')),
                 ('types', ('TYPE1', 'FIRE')))
        for page, words in pages:
            g.press('select', 30)
            preview = g.text()[:20 * 9]
            if 'CHARMANDER' not in preview or not all(w in preview for w in words):
                g.fail(f'expected the {page} page with {words}, got "{" ".join(preview.split())}"')
        g.press('select', 30)
        g.press('select', 30)  # moves page again
        for _ in range(10):
            if 'you want' in g.text():
                break
            g.press('a', 60)
        else:
            g.fail('the confirm prompt never appeared')
        g.run(60)
        if 'CHARMANDER' not in g.text()[20 * 12:]:
            g.fail(f'the confirm prompt after the moves page does not name CHARMANDER: "{g.text()[20 * 12:].strip()}"')
        return 'SELECT shows base stats (ATTACK 52), moves (SCRATCH, GROWL), then types; prompt names CHARMANDER'
    finally:
        g.stop()


def test_debug_menu(prefix):
    g = Game(prefix, 'Debug menu')
    try:
        g.run(300)
        g.press('a', 2)  # skip the intro, then hold SELECT into the title screen
        g.run(5)
        g.pb.button_press('select')
        for _ in range(100):
            g.run(30)
            if 'FIGHT' in g.text() and 'DEBUG' in g.text():
                return 'debug menu shown'
        g.fail('debug menu never appeared')
    finally:
        g.pb.button_release('select')
        g.stop()


def main():
    tests = [(case[0], lambda case=case: test_case(sys.argv[1], *case)) for case in CASES]
    tests.append(('Pick Starter: weak starter warning', lambda: test_weak_starter_warning(sys.argv[1])))
    tests.append(('Pick Starter: picker info pages', lambda: test_picker_info(sys.argv[1])))
    if len(sys.argv) > 2:
        tests.append(('Debug menu', lambda: test_debug_menu(sys.argv[2])))
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
