#!/usr/bin/env python3
"""Rewrite upstream Yellow Legacy code or patches to this fork's label names.

This fork renamed ~1,100 labels (pret names, suggested names). Upstream
commits still use the old names, so they conflict when merged. This script
applies docs/rename_map.tsv to files, or to stdin, so an upstream patch can be
translated before applying it:

    git -C ../upstream format-patch -1 <sha> --stdout | tools/upstream_rename.py | git am -3

Usage: tools/upstream_rename.py [FILE ...]   (no files: stdin -> stdout;
                                             files are rewritten in place)

Only global labels are renamed automatically. Renamed local labels are listed
in the map as Parent.old / Parent.new for reference; fix those by hand if a
patch touches them.
"""

import os
import re
import sys

MAP = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'docs', 'rename_map.tsv')


def load_map():
    renames = {}
    with open(MAP, encoding='utf-8') as f:
        for line in f:
            if line.startswith('#') or not line.strip():
                continue
            old, new = line.rstrip('\n').split('\t')[:2]
            if '.' not in old and old != new:
                renames[old] = new
    return renames


def rewrite(text, renames):
    pattern = re.compile(r'(?<![A-Za-z0-9_])(' + '|'.join(
        sorted(map(re.escape, renames), key=len, reverse=True)) + r')(?![A-Za-z0-9_])')
    return pattern.sub(lambda m: renames[m[1]], text)


def main():
    renames = load_map()
    if len(sys.argv) == 1:
        sys.stdout.write(rewrite(sys.stdin.read(), renames))
        return
    for path in sys.argv[1:]:
        with open(path, encoding='utf-8') as f:
            text = f.read()
        new = rewrite(text, renames)
        if new != text:
            with open(path, 'w', encoding='utf-8') as f:
                f.write(new)
            print(f'rewrote {path}')


if __name__ == '__main__':
    main()
