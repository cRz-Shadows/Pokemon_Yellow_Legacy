#!/usr/bin/env python3
"""Compare a build against the base branch's build.

Reports (as Markdown on stdout):
- whether each ROM changed (byte-identical refactors show "identical")
- whether the save layout changed: the saved WRAM ranges and SRAM symbols
  must keep their addresses, or old save files would load incorrectly
- free space per ROM bank, and how it changed

Usage: compare_builds.py BASE_DIR HEAD_DIR
Exit status is 1 if the save layout changed, unless ALLOW_SAVE_LAYOUT_CHANGE=1.
"""

import hashlib
import os
import re
import sys

ROMS = ['pokemon_yellow_legacy', 'pokemon_yellow_legacy_debug']
NAME_LENGTH = 11

# WRAM ranges copied to and from SRAM by engine/menus/save.asm
SAVED_RANGES = [
    ('wPlayerName', None),
    ('wMainDataStart', 'wMainDataEnd'),
    ('wSpriteDataStart', 'wSpriteDataEnd'),
    ('wPartyDataStart', 'wPartyDataEnd'),
    ('wBoxDataStart', 'wBoxDataEnd'),
]


def sha1(path):
    with open(path, 'rb') as f:
        return hashlib.sha1(f.read()).hexdigest()


def read_syms(path):
    """name -> (bank, address)"""
    syms = {}
    for line in open(path):
        parts = line.split(';')[0].split()
        if len(parts) == 2 and ':' in parts[0]:
            bank, addr = parts[0].split(':')
            syms[parts[1]] = (int(bank, 16), int(addr, 16))
    return syms


def save_layout(syms):
    """Returns (ranges, addresses): the saved ranges' bounds, and every
    (bank, address) that has a symbol inside a saved range or in SRAM."""
    ranges = {}
    for start, end in SAVED_RANGES:
        lo = syms[start][1]
        hi = syms[end][1] if end else lo + NAME_LENGTH
        ranges[start] = (lo, hi)
    addrs = set()
    for name, (bank, addr) in syms.items():
        if 0xa000 <= addr < 0xc000:  # SRAM
            addrs.add((bank, addr))
        elif any(lo <= addr < hi for lo, hi in ranges.values()):
            addrs.add((bank, addr))
    return ranges, addrs


def names_at(syms, key):
    return ', '.join(sorted(n for n, v in syms.items() if v == key)) or '?'


def read_bank_space(path):
    """'ROMX bank #1' -> free bytes, from an rgblink .map file"""
    space = {}
    bank = None
    for line in open(path):
        m = re.match(r'(ROM0|ROMX) bank #(\d+):', line)
        if m:
            bank = f'{m[1]} {int(m[2])}'
            continue
        m = re.match(r'\s*TOTAL EMPTY: \$([0-9a-fA-F]+) bytes', line)
        if m and bank:
            space[bank] = int(m[1], 16)
            bank = None
    return space


def main():
    base, head = sys.argv[1], sys.argv[2]
    out = []
    failed = False

    out.append('### ROM changes')
    out.append('| ROM | Result |')
    out.append('|---|---|')
    for rom in ROMS:
        same = sha1(f'{base}/{rom}.gbc') == sha1(f'{head}/{rom}.gbc')
        out.append(f'| `{rom}.gbc` | {"identical to base" if same else "**changed**"} |')

    out.append('')
    out.append('### Save layout')
    base_syms = read_syms(f'{base}/{ROMS[0]}.sym')
    head_syms = read_syms(f'{head}/{ROMS[0]}.sym')
    base_ranges, base_addrs = save_layout(base_syms)
    head_ranges, head_addrs = save_layout(head_syms)
    problems = []
    for name in base_ranges:
        if base_ranges[name] != head_ranges[name]:
            (blo, bhi), (hlo, hhi) = base_ranges[name], head_ranges[name]
            problems.append(f'range `{name}` moved: ${blo:04x}-${bhi:04x} → ${hlo:04x}-${hhi:04x}')
    for key in sorted(base_addrs - head_addrs):
        problems.append(f'nothing at {key[0]:02x}:${key[1]:04x} any more (was `{names_at(base_syms, key)}`)')
    added = sorted(head_addrs - base_addrs)
    if problems:
        allowed = os.environ.get('ALLOW_SAVE_LAYOUT_CHANGE') == '1'
        failed = not allowed
        out.append('**The save layout changed**, so saves from the base build may not load correctly.'
                   + (' Allowed by the `save-layout-change` label.' if allowed else
                      ' If this is intended, add the `save-layout-change` label to the PR.'))
        out.extend(f'- {p}' for p in problems[:50])
        if len(problems) > 50:
            out.append(f'- …and {len(problems) - 50} more')
    else:
        out.append('Unchanged: saved WRAM ranges and SRAM symbols are at the same addresses.')
    if added:
        out.append('')
        out.append('New symbols inside saved memory (fine if they use previously unused space):')
        out.extend(f'- {k[0]:02x}:${k[1]:04x} `{names_at(head_syms, k)}`' for k in added[:20])

    out.append('')
    out.append('### Free ROM space')
    base_space = read_bank_space(f'{base}/{ROMS[0]}.map')
    head_space = read_bank_space(f'{head}/{ROMS[0]}.map')
    changed = [b for b in head_space if head_space[b] != base_space.get(b)]
    total_base, total_head = sum(base_space.values()), sum(head_space.values())
    out.append(f'Total free: {total_head:,} bytes ({total_head - total_base:+,} vs base). '
               f'Tightest bank: {min(head_space, key=head_space.get)} '
               f'({min(head_space.values())} bytes free).')
    if changed:
        out.append('')
        out.append('| Bank | Free (base) | Free (this PR) | Change |')
        out.append('|---|---:|---:|---:|')
        for b in changed:
            old = base_space.get(b, 0)
            out.append(f'| {b} | {old} | {head_space[b]} | {head_space[b] - old:+} |')
    else:
        out.append('No bank changed size.')

    print('\n'.join(out))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
