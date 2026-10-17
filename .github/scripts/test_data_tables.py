#!/usr/bin/env python3
"""Checks on the game data tables, read straight from the assembly (no ROM or emulator needed).

- The type chart lists each (attacking type, defending type) pair once, because the battle code
  multiplies every matching entry, and has the Steel matchups (issue #112).
- Every Pokémon's level-up learnset is sorted by level, because the code that gives a new Pokémon
  its moves stops at the first entry above its level (issue #113).
- The Hard mode level caps (HardLevelCaps) have one entry per badge count and match docs/hard_mode.md.
- Pick Starter mode: the rival's type counters (issue #137, modelled by tools/rival_counters.py) are
  super effective against every pick they're used for, each candidate is used for some pick, and the
  table in docs/pick_starter_mode.md is up to date.

Run: python3 -m unittest discover -s .github/scripts -p 'test_*.py'
"""

import collections
import os
import re
import sys
import unittest

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import rival_counters  # noqa: E402


def read(path):
    with open(os.path.join(ROOT, path), encoding='utf-8') as f:
        return f.read()


def type_chart():
    return [m.groups() for m in re.finditer(
        r'^\s*db\s+(\w+),\s*(\w+),\s*(\w+)', read('data/types/type_matchups.asm'), re.MULTILINE)]


def learnsets():
    """{label: [(level, move), ...]} for every <Species>EvosMoves block."""
    sets, label, in_learnset = {}, None, False
    for line in read('data/pokemon/evos_moves.asm').splitlines():
        m = re.match(r'(\w+EvosMoves):', line)
        if m:
            label, in_learnset = m.group(1), False
            sets[label] = []
        elif label and line.strip().startswith('; Learnset'):
            in_learnset = True
        elif label and in_learnset:
            m = re.match(r'\s*db\s+(\d+),\s*(\w+)', line)
            if m:
                sets[label].append((int(m.group(1)), m.group(2)))
    return sets


class TypeChartTest(unittest.TestCase):
    def test_no_duplicate_pairs(self):
        counts = collections.Counter((a, d) for a, d, _ in type_chart())
        self.assertEqual([k for k, n in counts.items() if n > 1], [])

    def test_steel_matchups(self):
        chart = {(a, d): e for a, d, e in type_chart()}
        self.assertEqual(chart[('FIGHTING', 'STEEL')], 'SUPER_EFFECTIVE')
        self.assertEqual(chart[('FLYING', 'STEEL')], 'NOT_VERY_EFFECTIVE')
        self.assertEqual(chart[('FIGHTING', 'FAIRY')], 'NOT_VERY_EFFECTIVE')


class LearnsetTest(unittest.TestCase):
    def test_found_all_species(self):
        self.assertGreaterEqual(len(learnsets()), 151)

    def test_sorted_by_level(self):
        unsorted = [label for label, moves in learnsets().items()
                    if [lv for lv, _ in moves] != sorted(lv for lv, _ in moves)]
        self.assertEqual(unsorted, [])

    def test_golduck_learns_disable_before_tail_whip(self):
        moves = learnsets()['GolduckEvosMoves']
        self.assertLess(moves.index((10, 'DISABLE')), moves.index((28, 'TAIL_WHIP')))


class HardLevelCapTest(unittest.TestCase):
    def caps(self):
        block = read('engine/battle/experience.asm').split('HardLevelCaps:')[1]
        return [int(m.group(1)) for m in re.finditer(r'^\tdb (\d+)', block, re.MULTILINE)][:9]

    def test_nine_increasing_caps(self):
        caps = self.caps()
        self.assertEqual(len(caps), 9)
        self.assertEqual(caps, sorted(caps))

    def test_matches_docs(self):
        row = [line for line in read('docs/hard_mode.md').splitlines() if line.startswith('| Cap |')][0]
        self.assertEqual([int(x) for x in re.findall(r'\d+', row)], self.caps())


class RivalCounterTest(unittest.TestCase):
    def setUp(self):
        self.chart = rival_counters.type_chart()
        self.types, self.dex, self.name = rival_counters.species_data()
        self.starter_lines, self.picks = rival_counters.counter_tables()
        self.counters = dict(rival_counters.all_counters())

    def test_starter_lines_unchanged(self):
        # #106: the Bulbasaur/Charmander/Squirtle lines keep their Red/Blue counters
        for line, rival in (('BULBASAUR', 'CHARMANDER'), ('CHARMANDER', 'SQUIRTLE'), ('SQUIRTLE', 'BULBASAUR')):
            for i in range(3):
                pick = self.dex[self.dex.index(line) + i]
                self.assertEqual(self.counters[pick], (rival, rival), pick)

    def test_pikachu_keeps_eevee(self):
        self.assertIsNone(self.counters['PIKACHU'])

    def test_counters_are_super_effective(self):
        for pick, counter in self.counters.items():
            if pick in self.starter_lines or pick == 'PIKACHU':
                continue
            self.assertIsNotNone(counter, f'no counter for {pick}')
            attack = rival_counters.best_score(self.chart, self.types[counter[0]], self.types[pick])
            self.assertGreater(attack, rival_counters.NEUTRAL, f'{counter[0]} against {pick}')

    def test_every_candidate_is_used(self):
        used = {c[0] for c in self.counters.values() if c}
        self.assertEqual([s for s, _, _ in self.picks if s not in used], [])

    def test_line_count_and_names(self):
        lines = [s for s, _, line in self.picks if line]
        num = int(re.search(r'DEF NUM_RIVAL_COUNTER_LINES EQU (\d+)', read('constants/pokemon_constants.asm')).group(1))
        self.assertEqual(len(lines), num)
        # names start with a consonant (PickStarterRivalCounterPicks)
        self.assertEqual([s for s, _, _ in self.picks if self.name[s][0] in 'AEIOU'], [])

    def test_docs_table_up_to_date(self):
        self.assertEqual(rival_counters.docs_table(), rival_counters.markdown(),
                         'run tools/rival_counters.py and paste the table into docs/pick_starter_mode.md')


if __name__ == '__main__':
    unittest.main()
