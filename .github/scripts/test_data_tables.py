#!/usr/bin/env python3
"""Checks on the game data tables, read straight from the assembly (no ROM or emulator needed).

- The type chart lists each (attacking type, defending type) pair once, because the battle code
  multiplies every matching entry, and has the Steel matchups (issue #112).
- Every Pokémon's level-up learnset is sorted by level, because the code that gives a new Pokémon
  its moves stops at the first entry above its level (issue #113).

Run: python3 -m unittest discover -s .github/scripts -p 'test_*.py'
"""

import collections
import os
import re
import unittest

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')


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


if __name__ == '__main__':
    unittest.main()
