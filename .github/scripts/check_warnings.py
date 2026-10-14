#!/usr/bin/env python3
"""Fail if the build log has warnings other than the known ones.

Usage: check_warnings.py BUILD_LOG
"""

import re
import sys

# Warnings the build is known to print. Keep this list short.
ALLOWED = [
    # rgbfix: the cartridge header title is limited to 15 characters
    re.compile(r'Truncating title "POKEMON YELLOW LEGACY" to 15 chars'),
]


def main():
    lines = open(sys.argv[1], errors='replace').read().split('\n')
    unexpected = []
    for i, line in enumerate(lines):
        if not re.search(r'\bwarning\b', line, re.IGNORECASE):
            continue
        if any(p.search(line) for p in ALLOWED):
            continue
        # rgbasm prints the location on the following lines ("at file(line)")
        context = [line] + [l for l in lines[i + 1:i + 4] if l.startswith((' ', '\t'))]
        unexpected.append('\n'.join(context))
    if unexpected:
        print(f'{len(unexpected)} unexpected warning(s):')
        for w in unexpected:
            print(w)
        return 1
    print('No unexpected warnings.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
