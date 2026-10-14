#!/usr/bin/env python3
"""Headless smoke tests: play the start of the game in PyBoy.

For each difficulty: new game -> Oak stops you in the grass -> starter in his
lab. Normal and Hard must give PIKACHU; Pick Starter must open the picker and
give the picked Pokémon. The debug ROM must reach its debug menu.

Usage: smoke_test.py ROM_PREFIX [DEBUG_ROM_PREFIX]
       (a prefix is the ROM path without .gbc; the .sym next to it is used)
On failure a screenshot is saved to smoke_test_failures/.
"""

import os
import sys

from pyboy import PyBoy

FAIL_DIR = 'smoke_test_failures'
PICK_STARTER_DEX_NO = 4  # CHARMANDER

MODES = [
    ('Normal', 0),
    ('Hard', 1),
    ('Pick Starter', 2),
]


class TestFailure(Exception):
    pass


class Game:
    def __init__(self, prefix, name):
        self.name = name
        self.syms = {}
        for line in open(prefix + '.sym'):
            parts = line.split(';')[0].split()
            if len(parts) == 2 and ':' in parts[0]:
                self.syms[parts[1]] = int(parts[0].split(':')[1], 16)
        self.pb = PyBoy(prefix + '.gbc', window='null', sound_emulated=False)
        self.pb.set_emulation_speed(0)

    def mem(self, sym, offset=0):
        return self.pb.memory[self.syms[sym] + offset]

    def run(self, frames):
        for _ in range(frames):
            self.pb.tick()

    def press(self, button, wait=30, hold=6):
        self.pb.button(button, hold)
        self.run(wait)

    def text(self):
        """The tilemap decoded to ASCII (letters, digits and '>' only)."""
        start = self.syms['wTileMap']
        out = []
        for i in range(20 * 18):
            c = self.pb.memory[start + i]
            if 0x80 <= c <= 0x99:
                out.append(chr(c - 0x80 + ord('A')))
            elif 0xa0 <= c <= 0xb9:
                out.append(chr(c - 0xa0 + ord('a')))
            elif 0xf6 <= c <= 0xff:
                out.append(chr(c - 0xf6 + ord('0')))
            elif c == 0xed:
                out.append('>')
            else:
                out.append(' ')
        return ''.join(out)

    def pos(self):
        return self.mem('wCurMap'), self.mem('wXCoord'), self.mem('wYCoord')

    def fail(self, message):
        os.makedirs(FAIL_DIR, exist_ok=True)
        path = os.path.join(FAIL_DIR, self.name.replace(' ', '_') + '.png')
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
    0x26: [(7, 1)],
    0x25: [(7, 6), (3, 6), (3, 7), (3, 8)],
    0x00: [(10, 6), (10, 0)],
}
OAKS_LAB = 0x28


def walk_to_oaks_lab(g):
    reached = {}
    last = None
    stuck = 0
    for _ in range(3000):
        mp, x, y = g.pos()
        if mp == OAKS_LAB:
            return
        targets = WAYPOINTS.get(mp)
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


def get_starter(g, pick_starter):
    """In Oak's lab: check the Poké Ball and receive (or pick) the starter.
    Returns the "received" text."""
    for i in range(80):  # Oak's arrival scene
        g.press('a', 30)
        if g.mem('wJoyIgnore') == 0 and i > 20:
            break
    for d in ('down', 'right', 'right'):  # stand below the Poké Ball
        g.press(d, 30, hold=10)
    g.press('up', 20, hold=3)
    g.press('a', 60)
    if pick_starter:
        for _ in range(400):
            if 'TYPE1' in g.text():
                break
            g.press('a', 25)
        else:
            g.fail('the Pick Starter picker never opened')
        g.run(60)
        for _ in range(PICK_STARTER_DEX_NO - 1):
            g.press('down', 16, hold=8)
        g.run(120)
        for _ in range(10):  # confirm, retrying while the sprite loads
            if 'you want' in g.text():
                break
            g.press('a', 60)
        for _ in range(10):
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


def test_mode(prefix, label, mode_index):
    g = Game(prefix, label)
    try:
        new_game(g, mode_index)
        if g.mem('wDifficulty') != mode_index:
            g.fail(f'difficulty byte is {g.mem("wDifficulty")}, expected {mode_index}')
        walk_to_oaks_lab(g)
        pick = mode_index == 2
        received = get_starter(g, pick)
        expected = 'CHARMANDER' if pick else 'PIKACHU'
        if expected not in received:
            g.fail(f'expected to receive {expected}, text was "{received}"')
        if g.mem('wPartyCount') != 1 or g.mem('wPartyMon1Level') != 5:
            g.fail(f'party count {g.mem("wPartyCount")}, level {g.mem("wPartyMon1Level")}')
        if g.mem('wPartySpecies') != g.mem('wPlayerStarter'):
            g.fail('party species does not match wPlayerStarter')
        return f'received {expected}, level 5'
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
    tests = [(label, lambda label=label, m=m: test_mode(sys.argv[1], label, m))
             for label, m in MODES]
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
