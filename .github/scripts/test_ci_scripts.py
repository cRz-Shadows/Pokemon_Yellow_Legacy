#!/usr/bin/env python3
"""Unit tests for the CI and release scripts (no ROM or emulator needed).

Run: python3 -m unittest discover -s .github/scripts -p 'test_*.py'
"""

import os
import random
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', '..', 'tools'))

import check_warnings  # noqa: E402
import compare_builds  # noqa: E402
import make_release_patches  # noqa: E402
import upstream_watch  # noqa: E402


def syms(**extra):
    """A minimal symbol table with every saved range compare_builds expects."""
    s = {
        'wPlayerName': (0, 0xd158),
        'wMainDataStart': (0, 0xd300), 'wMainDataEnd': (0, 0xd310),
        'wSpriteDataStart': (0, 0xc100), 'wSpriteDataEnd': (0, 0xc200),
        'wPartyDataStart': (0, 0xd163), 'wPartyDataEnd': (0, 0xd170),
        'wBoxDataStart': (0, 0xda80), 'wBoxDataEnd': (0, 0xda90),
        'sGameData': (1, 0xa598),
    }
    s.update(extra)
    return s


class SaveLayoutTest(unittest.TestCase):
    def test_unchanged(self):
        base = syms(wA=(0, 0xd300), wB=(0, 0xd301))
        self.assertEqual(compare_builds.save_layout_changes(base, dict(base)), ([], []))

    def test_insert_and_shrink_padding_is_caught(self):
        # wNew inserted before wA; a later pad shrinks, so the range end stays
        base = syms(wA=(0, 0xd300), wB=(0, 0xd301), wC=(0, 0xd302))
        head = syms(wNew=(0, 0xd300), wA=(0, 0xd301), wB=(0, 0xd302), wC=(0, 0xd303))
        problems, _ = compare_builds.save_layout_changes(base, head)
        self.assertTrue(any('`wA` moved' in p for p in problems), problems)
        self.assertEqual(len(problems), 3)

    def test_rename_is_a_note(self):
        base = syms(wd472=(0, 0xd305))
        head = syms(wPikachuPartyFlags=(0, 0xd305))
        problems, notes = compare_builds.save_layout_changes(base, head)
        self.assertEqual(problems, [])
        self.assertTrue(any('renamed' in n for n in notes), notes)

    def test_removed_variable_is_a_problem(self):
        base = syms(wA=(0, 0xd300), wB=(0, 0xd301))
        head = syms(wA=(0, 0xd300))
        problems, _ = compare_builds.save_layout_changes(base, head)
        self.assertTrue(any('`wB`' in p and 'gone' in p for p in problems), problems)

    def test_moved_range_is_a_problem(self):
        base = syms()
        head = syms(wMainDataEnd=(0, 0xd311))
        problems, _ = compare_builds.save_layout_changes(base, head)
        self.assertTrue(any('wMainDataStart' in p for p in problems), problems)


class UpstreamWatchTest(unittest.TestCase):
    def test_code_span_neutralizes_markdown(self):
        span = upstream_watch.code_span('Fix @someone `x` | [link](http://e) ![img](x)')
        self.assertTrue(span.startswith('`') and span.endswith('`'))
        self.assertEqual(span.count('`'), 2)  # backticks inside are replaced
        self.assertIn('\\|', span)

    def test_marker_only_on_last_line(self):
        sha = 'a' * 40
        other = 'b' * 40
        body = f'| `<!-- upstream-head: {other} -->` |\n\n<!-- upstream-head: {sha} -->\n'
        self.assertEqual(upstream_watch.find_marker(body), sha)
        self.assertIsNone(upstream_watch.find_marker(f'<!-- upstream-head: {sha} -->\ntrailing text'))
        self.assertIsNone(upstream_watch.find_marker(''))


class BpsTest(unittest.TestCase):
    def test_number_round_trip(self):
        for n in (0, 1, 127, 128, 16511, 16512, 2 ** 21, 2 ** 32):
            data = make_release_patches.bps_number(n)
            self.assertEqual(make_release_patches.read_bps_number(data, 0), (n, len(data)))

    def test_patch_round_trip(self):
        rng = random.Random(1234)
        base = bytes(rng.randrange(256) for _ in range(4096))
        cases = [
            base,                                   # identical
            base[:1000] + b'\x00' * 20 + base[1020:],  # edit in place
            base + bytes(rng.randrange(256) for _ in range(3000)),  # grow
            base[2048:] + base[:2048],              # moved data (SourceCopy)
            b'\xff' * 5000,                         # runs (TargetCopy)
        ]
        for target in cases:
            patch = make_release_patches.make_bps(base, target)
            self.assertEqual(make_release_patches.apply_bps(base, patch), target)


class CheckWarningsTest(unittest.TestCase):
    def check(self, text):
        with tempfile.NamedTemporaryFile('w', suffix='.log', delete=False) as f:
            f.write(text)
        try:
            sys.argv = ['check_warnings.py', f.name]
            return check_warnings.main()
        finally:
            os.unlink(f.name)

    def test_known_warning_passes(self):
        self.assertEqual(self.check('warning: Truncating title "POKEMON YELLOW LEGACY" to 15 chars\n'), 0)

    def test_new_warning_fails(self):
        self.assertEqual(self.check('warning: scripts/Foo.asm(12): [-Wobsolete]\n    deprecated\n'), 1)


if __name__ == '__main__':
    unittest.main()
