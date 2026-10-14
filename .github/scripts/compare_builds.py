#!/usr/bin/env python3
"""Compare a build against the base branch's build, one section at a time.

Sections (each prints Markdown on stdout):
  roms   whether each ROM changed. Fails if EXPECT_IDENTICAL_ROM=1 (set by the
         expect-identical-rom label) and a ROM changed.
  save   whether the save layout changed: the saved WRAM ranges and SRAM
         symbols must keep their addresses, or old save files would load
         incorrectly. Fails if it changed, unless ALLOW_SAVE_LAYOUT_CHANGE=1
         (set by the save-layout-change label).
  banks  free space per ROM bank and how it changed. Never fails.

Usage: compare_builds.py roms|save|banks BASE_DIR HEAD_DIR
If BASE_DIR has no build (no base commit, or it doesn't build), the section
is skipped with a note.
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
    for bank, addr in syms.values():
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


def compare_roms(base, head):
    out = ['### ROM changes', '| ROM | Result |', '|---|---|']
    changed = False
    for rom in ROMS:
        same = sha1(f'{base}/{rom}.gbc') == sha1(f'{head}/{rom}.gbc')
        changed |= not same
        out.append(f'| `{rom}.gbc` | {"identical to base" if same else "**changed**"} |')
    failed = False
    if os.environ.get('EXPECT_IDENTICAL_ROM') == '1':
        out.append('')
        if changed:
            failed = True
            out.append('**The `expect-identical-rom` label is set, but a ROM changed.** '
                       'Remove the label if this PR is meant to change the game.')
        else:
            out.append('The `expect-identical-rom` label is set and the ROMs are identical.')
    return out, failed


def compare_save_layout(base, head):
    out = ['### Save layout']
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
    failed = False
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
    return out, failed


def compare_bank_space(base, head):
    out = ['### Free ROM space']
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
    return out, False


SECTIONS = {
    'roms': ('ROM changes', compare_roms),
    'save': ('Save layout', compare_save_layout),
    'banks': ('Free ROM space', compare_bank_space),
}


def main():
    if len(sys.argv) != 4 or sys.argv[1] not in SECTIONS:
        sys.exit(__doc__)
    title, compare = SECTIONS[sys.argv[1]]
    base, head = sys.argv[2], sys.argv[3]
    if not os.path.exists(f'{base}/{ROMS[0]}.gbc'):
        print(f'### {title}')
        print('Skipped: there is no base build to compare with '
              '(no base commit, or the base commit does not build).')
        return 0
    out, failed = compare(base, head)
    print('\n'.join(out))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
