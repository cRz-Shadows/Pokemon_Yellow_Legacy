#!/usr/bin/env python3
"""Headless smoke tests: play the start of the game in PyBoy.

For each case: new game -> Oak stops you in the grass -> starter in his lab ->
first rival battle -> rival leaves -> talk to Oak.
- Normal and Hard must give PIKACHU, and the "Pikachu escapes its Poké Ball"
  scene must play; Oak then says to talk to it.
- Pick Starter must open the picker in the intro, right after the mode is
  confirmed and before the name screens (issue #135), and Oak must give the
  picked Pokémon in the lab, saying he caught it (#136). In the tall grass,
  Oak must catch the picked Pokémon instead of PIKACHU. Picking PIKACHU must
  behave like Normal; picking anything else must skip the escape scene, and
  Oak gives his battle advice instead.
Two more Pick Starter cases cover the picker's list wrap (UP from the top
gives MEW) and paging (RIGHT moves a page).
Before the rival battle, the rival must comment on a picked starter and say
nothing extra about a PIKACHU. The ball he takes holds the Pokémon that counters
the pick (tools/rival_counters.py): SQUIRTLE against CHARMANDER and BULBASAUR
against SQUIRTLE, as in Red/Blue (#106), and type counters for other picks
(#137), which he then uses in the battle.
SELECT in the picker must cycle the preview: types, base stats, level-5 moves.
A save made before the picker moved to the intro (no starter yet) must open
the picker in Oak's lab instead.
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
    ('Pick Starter: Squirtle', 2, ['down'] * 6, 'SQUIRTLE'),
    ('Pick Starter: Pikachu', 2, ['down'] * 24, 'PIKACHU'),
    ('Pick Starter: wrap to Mew', 2, ['up'], 'MEW'),
    ('Pick Starter: paging', 2, ['right', 'right', 'down'], 'PIDGEY'),  # #1 -> #8 -> #15 -> #16
]
# A save made in Pick Starter mode before the picker moved to the intro: the
# picker opens in Oak's lab.
OLD_SAVE_CASE = ('Pick Starter: old save, picker in the lab', 2, ['down'] * 3, 'CHARMANDER')

# The rival's comments on a picked starter (text() drops punctuation). The
# EEVEE and "can't attack" comments are covered by the scenario tests.
RIVAL_COMMENTS = {'CHARMANDER': ['Your CHARMANDER', 'My SQUIRTLE', 'handle that'], 'SQUIRTLE': ['My BULBASAUR'],
                  'MEW': ['legendary'], 'PIDGEY': ['My GEODUDE']}
RIVAL_COMMENT_MARKERS = ('type  eh', 'legendary', 'Copycat', 'even attack', 'handle that', 'swap')
# The rival's Pokémon in the lab battle (#106, #137: he counters the pick)
RIVAL_LAB_MON = {'CHARMANDER': 'SQUIRTLE', 'SQUIRTLE': 'BULBASAUR', 'MEW': 'GASTLY', 'PIDGEY': 'GEODUDE'}


class TestFailure(Exception):
    pass


class Game:
    def __init__(self, prefix, name):
        self.name = name
        self.oak_caught = None  # species Oak catches in the grass (walk_to_oaks_lab)
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


def choose_mode(g, mode_index):
    """From power-on to the confirmed difficulty."""
    for _ in range(3000):
        t = g.text()
        if 'NORMAL' in t and 'HARD' in t and 'STARTER' in t:
            for _ in range(mode_index):
                g.press('down', 20)
            g.press('a', 60)
            return
        g.press('a', 25)
    g.fail('difficulty menu never appeared')


def open_intro_picker(g):
    """After choosing Pick Starter: confirm it and wait for the picker, which
    must open before the boy/girl and name screens (#135)."""
    for _ in range(100):
        t = g.text()
        if 'TYPE1' in t:
            return
        if 'NEW NAME' in t or 'GIRL' in t:
            g.fail('the intro went on without opening the Pick Starter picker')
        g.press('a', 25)
    g.fail('the Pick Starter picker never opened in the intro')


def pick(g, pick_buttons):
    """In the picker: highlight and take a Pokémon (YES at the prompt).
    Sets g.saw_attack_warning."""
    highlight_and_confirm(g, pick_buttons)
    g.saw_attack_warning = False
    for _ in range(10):
        g.saw_attack_warning |= 'attack' in g.text()
        if 'you want' not in g.text():
            return
        g.press('a', 60)
    g.fail('the picker never closed')


def new_game(g, mode_index, pick_buttons=None):
    """From power-on to the player's room, choosing the given difficulty and,
    in Pick Starter mode, the starter."""
    choose_mode(g, mode_index)
    g.saw_attack_warning = False
    if pick_buttons is not None:
        open_intro_picker(g)
        pick(g, pick_buttons)
    finish_intro(g)


def finish_intro(g):
    """From the end of the mode menu (or the picker) to the player's room."""
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
        if g.mem('wIsInBattle'):  # Oak's catch in the grass
            g.oak_caught = g.mem('wEnemyMonSpecies2')
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


def check_ball(g):
    """In Oak's lab: walk up to the Poké Ball and check it."""
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
    if 'TYPE1' not in g.text():
        g.fail('the Pick Starter picker is not open')
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


def get_starter(g, lab_pick_buttons=None):
    """In Oak's lab: check the Poké Ball and receive the starter. If the picker
    opens there (a save without a starter), pick with lab_pick_buttons.
    Returns Oak's text and the "received" text."""
    check_ball(g)
    received = ''
    oak = []
    for _ in range(3000):
        t = g.text()
        if 'TYPE1' in t:
            if lab_pick_buttons is None:
                g.fail('the picker opened in Oak\'s lab')
            pick(g, lab_pick_buttons)
            lab_pick_buttons = None
            continue
        if 'OAK' in t or oak:
            box = ' '.join(t[i * 20:(i + 1) * 20].strip() for i in range(13, 17))
            if box not in oak and 'received' not in box:
                oak.append(box)
        if 'received' in t:
            received = ' '.join(t[i * 20:(i + 1) * 20].strip() for i in range(13, 17))
        if g.mem('wPartyCount') and g.mem('wPartyMon1Level'):
            return ' | '.join(oak), received
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
    g.rival_mon = None
    for step in range(1500):
        if step < 100:
            read_box()
        if g.mem('wIsInBattle') and g.rival_mon is None and g.mem('wEnemyPartyCount'):
            g.rival_mon = g.mem('wEnemyPartySpecies')
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


def test_case(prefix, label, difficulty, pick_buttons, expected, old_save=False):
    g = Game(prefix, label)
    try:
        new_game(g, difficulty, ['up'] if old_save else pick_buttons)
        if old_save:  # a save from before the picker moved to the intro: no starter yet
            g.pb.memory[g.syms['wPlayerStarter']] = 0
        if g.mem('wDifficulty') != difficulty:
            g.fail(f'difficulty byte is {g.mem("wDifficulty")}, expected {difficulty}')
        if pick_buttons and not old_save and g.mem('wPlayerStarter') != g.const(expected):
            g.fail(f'wPlayerStarter is {g.mem("wPlayerStarter")} after the intro, expected {expected}')
        walk_to_oaks_lab(g)
        caught = 'PIKACHU' if old_save else expected  # an old save picks in the lab
        if g.oak_caught != g.const(caught):
            g.fail(f'expected Oak to catch {caught} in the grass, got species {g.oak_caught}')
        oak, received = get_starter(g, pick_buttons if old_save else None)
        if expected not in received:
            g.fail(f'expected to receive {expected}, text was "{received}"')
        pikachu = expected == 'PIKACHU'
        oak_gives = ['caught a PIKACHU', 'every POK'] if old_save else ['caught earlier']
        oak = ' '.join(oak.replace(' |', ' ').split())
        if not all(words in oak for words in oak_gives):
            g.fail(f'expected Oak to say {oak_gives}, he said "...{oak[-300:]}"')
        if g.mem('wPartyCount') != 1 or g.mem('wPartyMon1Level') != g.const('STARTER_LEVEL'):
            g.fail(f'party count {g.mem("wPartyCount")}, level {g.mem("wPartyMon1Level")}')
        if g.mem('wPartySpecies') != g.mem('wPlayerStarter'):
            g.fail('party species does not match wPlayerStarter')
        if g.saw_attack_warning:
            g.fail(f'the "can\'t attack yet" warning appeared for {expected}')
        seen, challenge_text = rival_battle_and_exit(g)
        comment = RIVAL_COMMENTS.get(expected)
        said = ' '.join(challenge_text.replace(' |', ' ').split())
        if difficulty == 2 and comment and not all(c in said for c in comment):
            g.fail(f'expected the rival to say {comment}, he said "{challenge_text}"')
        if not comment and any(m in challenge_text for m in RIVAL_COMMENT_MARKERS):
            g.fail(f'the rival commented on {expected}: "{challenge_text}"')
        rival_mon = RIVAL_LAB_MON.get(expected, 'EEVEE')
        if g.rival_mon != g.const(rival_mon):
            g.fail(f'expected the rival to use {rival_mon} in the lab, got species {g.rival_mon}')
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
        rival = f'rival said {comment}' if comment else 'no rival comment'
        rival += f', used {rival_mon}'
        return (f'Oak caught {caught}; received {expected}, level 5; {rival}; rival battle done; {scene}; '
                f'Oak: "{want}..."')
    finally:
        g.stop()


def test_weak_starter_warning(prefix):
    """Highlighting MAGIKARP (only knows SPLASH) must warn that it can't attack;
    CHARMANDER must not."""
    g = Game(prefix, 'Weak starter warning')
    try:
        choose_mode(g, 2)
        open_intro_picker(g)
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
        choose_mode(g, 2)
        open_intro_picker(g)
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
    tests.append((OLD_SAVE_CASE[0], lambda: test_case(sys.argv[1], *OLD_SAVE_CASE, old_save=True)))
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
